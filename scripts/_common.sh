#!/bin/bash

#=================================================
# BACKUP
#=================================================

HUMAN_SIZE () {	# Transforme une taille en Ko en une taille lisible pour un humain
	human=$(numfmt --to=iec --from-unit=1K $1)
	echo $human
}

CHECK_SIZE () {	# Vérifie avant chaque backup que l'espace est suffisant
	file_to_analyse=$1
	backup_size=$(du --summarize "$file_to_analyse" | cut -f1)
	free_space=$(df --output=avail "/home/yunohost.backup" | sed 1d)

	if [ $free_space -le $backup_size ]
	then
		ynh_print_err "Espace insuffisant pour sauvegarder $file_to_analyse."
		ynh_print_err "Espace disponible: $(HUMAN_SIZE $free_space)"
		ynh_die "Espace nécessaire: $(HUMAN_SIZE $backup_size)"
	fi
}

#=================================================
# FUTUR OFFICIAL HELPERS
#=================================================

# Create a dedicated fail2ban config (jail and filter conf files)
#
# usage: ynh_add_fail2ban_config log_file filter [max_retry [ports]]
# | arg: -l, --logpath= - Log file to be checked by fail2ban
# | arg: -r, --failregex= - Failregex to be looked for by fail2ban
# | arg: -m, --max_retry= - Maximum number of retries allowed before banning IP address - default: 3
# | arg: -p, --ports= - Ports blocked for a banned IP address - default: http,https
ynh_add_fail2ban_config () {
	# Declare an array to define the options of this helper.
	declare -Ar args_array=( [l]=logpath= [r]=failregex= [m]=max_retry= [p]=ports= )
	local logpath
	local failregex
	local max_retry
	local ports
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"
	max_retry=${max_retry:-3}
	ports=${ports:-http,https}

	test -n "$logpath" || ynh_die "ynh_add_fail2ban_config expects a logfile path as first argument and received nothing."
	test -n "$failregex" || ynh_die "ynh_add_fail2ban_config expects a failure regex as second argument and received nothing."

	finalfail2banjailconf="/etc/fail2ban/jail.d/$app.conf"
	finalfail2banfilterconf="/etc/fail2ban/filter.d/$app.conf"
	ynh_backup_if_checksum_is_different "$finalfail2banjailconf" 1
	ynh_backup_if_checksum_is_different "$finalfail2banfilterconf" 1

	tee $finalfail2banjailconf <<EOF
[$app]
enabled = true
port = $ports
filter = $app
logpath = $logpath
maxretry = $max_retry
EOF

  tee $finalfail2banfilterconf <<EOF
[INCLUDES]
before = common.conf
[Definition]
failregex = $failregex
ignoreregex =
EOF

	ynh_store_file_checksum "$finalfail2banjailconf"
	ynh_store_file_checksum "$finalfail2banfilterconf"

	if [ "$(lsb_release --codename --short)" != "jessie" ]; then
		systemctl reload fail2ban
	else
		systemctl restart fail2ban
	fi
	local fail2ban_error="$(journalctl -u fail2ban | tail -n50 | grep "WARNING.*$app.*")"
	if [ -n "$fail2ban_error" ]
	then
		echo "[ERR] Fail2ban failed to load the jail for $app" >&2
		echo "WARNING${fail2ban_error#*WARNING}" >&2
	fi
}

# Remove the dedicated fail2ban config (jail and filter conf files)
#
# usage: ynh_remove_fail2ban_config
ynh_remove_fail2ban_config () {
	ynh_secure_remove "/etc/fail2ban/jail.d/$app.conf"
	ynh_secure_remove "/etc/fail2ban/filter.d/$app.conf"
	if [ "$(lsb_release --codename --short)" != "jessie" ]; then
		systemctl reload fail2ban
	else
		systemctl restart fail2ban
	fi
}

#=================================================

# Read the value of a key in a ynh manifest file
#
# usage: ynh_read_manifest manifest key
# | arg: -m, --manifest= - Path of the manifest to read
# | arg: -k, --key= - Name of the key to find
ynh_read_manifest () {
	# Declare an array to define the options of this helper.
	declare -Ar args_array=( [m]=manifest= [k]=manifest_key= )
	local manifest
	local manifest_key
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"

	python3 -c "import sys, json;print(json.load(open('$manifest', encoding='utf-8'))['$manifest_key'])"
}

# Read the upstream version from the manifest
# The version number in the manifest is defined by <upstreamversion>~ynh<packageversion>
# For example : 4.3-2~ynh3
# This include the number before ~ynh
# In the last example it return 4.3-2
#
# usage: ynh_app_upstream_version [-m manifest]
# | arg: -m, --manifest= - Path of the manifest to read
ynh_app_upstream_version () {
	declare -Ar args_array=( [m]=manifest= )
	local manifest
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"

	manifest="${manifest:-../manifest.json}"
	if [ ! -e "$manifest" ]; then
		manifest="../settings/manifest.json"	# Into the restore script, the manifest is not at the same place
	fi
	version_key=$(ynh_read_manifest --manifest="$manifest" --manifest_key="version")
	echo "${version_key/~ynh*/}"
}

# Read package version from the manifest
# The version number in the manifest is defined by <upstreamversion>~ynh<packageversion>
# For example : 4.3-2~ynh3
# This include the number after ~ynh
# In the last example it return 3
#
# usage: ynh_app_package_version [-m manifest]
# | arg: -m, --manifest= - Path of the manifest to read
ynh_app_package_version () {
	declare -Ar args_array=( [m]=manifest= )
	local manifest
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"

	manifest="${manifest:-../manifest.json}"
	if [ ! -e "$manifest" ]; then
		manifest="../settings/manifest.json"	# Into the restore script, the manifest is not at the same place
	fi
	version_key=$(ynh_read_manifest --manifest="$manifest" --manifest_key="version")
	echo "${version_key/*~ynh/}"
}

# Checks the app version to upgrade with the existing app version and returns:
# - UPGRADE_APP if the upstream app version has changed
# - UPGRADE_PACKAGE if only the YunoHost package has changed
#
## It stops the current script without error if the package is up-to-date
#
# This helper should be used to avoid an upgrade of an app, or the upstream part
# of it, when it's not needed
#
# To force an upgrade, even if the package is up to date,
# you have to set the variable YNH_FORCE_UPGRADE before.
# example: sudo YNH_FORCE_UPGRADE=1 yunohost app upgrade MyApp
#
# usage: ynh_check_app_version_changed
ynh_check_app_version_changed () {
	local force_upgrade=${YNH_FORCE_UPGRADE:-0}
	local package_check=${PACKAGE_CHECK_EXEC:-0}

	# By default, upstream app version has changed
	local return_value="UPGRADE_APP"

	local current_version=$(ynh_read_manifest --manifest="/etc/yunohost/apps/$YNH_APP_INSTANCE_NAME/manifest.json" --manifest_key="version" || echo 1.0)
	local current_upstream_version="$(ynh_app_upstream_version --manifest="/etc/yunohost/apps/$YNH_APP_INSTANCE_NAME/manifest.json")"
	local update_version=$(ynh_read_manifest --manifest="../manifest.json" --manifest_key="version" || echo 1.0)
	local update_upstream_version="$(ynh_app_upstream_version)"

	if [ "$current_version" == "$update_version" ] ; then
		# Complete versions are the same
		if [ "$force_upgrade" != "0" ]
		then
			echo "Upgrade forced by YNH_FORCE_UPGRADE." >&2
			unset YNH_FORCE_UPGRADE
		elif [ "$package_check" != "0" ]
		then
			echo "Upgrade forced for package check." >&2
		else
			ynh_die "Up-to-date, nothing to do" 0
		fi
	elif [ "$current_upstream_version" == "$update_upstream_version" ] ; then
		# Upstream versions are the same, only YunoHost package versions differ
		return_value="UPGRADE_PACKAGE"
	fi
	echo $return_value
}

#=================================================

# Start (or other actions) a service,  print a log in case of failure and optionnaly wait until the service is completely started
#
# usage: ynh_systemd_action [-n service_name] [-a action] [ [-l "line to match"] [-p log_path] [-t timeout] [-e length] ]
# | arg: -n, --service_name= - Name of the service to reload. Default : $app
# | arg: -a, --action=       - Action to perform with systemctl. Default: start
# | arg: -l, --line_match=   - Line to match - The line to find in the log to attest the service have finished to boot.
#                              If not defined it don't wait until the service is completely started.
# | arg: -p, --log_path=     - Log file - Path to the log file. Default : /var/log/$app/$app.log
# | arg: -t, --timeout=      - Timeout - The maximum time to wait before ending the watching. Default : 300 seconds.
# | arg: -e, --length=       - Length of the error log : Default : 20
ynh_systemd_action() {
	# Declare an array to define the options of this helper.
	declare -Ar args_array=( [n]=service_name= [a]=action= [l]=line_match= [p]=log_path= [t]=timeout= [e]=length= )
	local service_name
	local action
	local line_match
	local length
	local log_path
	local timeout

	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"

	local service_name="${service_name:-$app}"
	local action=${action:-start}
	local log_path="${log_path:-/var/log/$service_name/$service_name.log}"
	local length=${length:-20}
	local timeout=${timeout:-300}

	# Start to read the log
	if [[ -n "${line_match:-}" ]]
	then
		local templog="$(mktemp)"
	# Following the starting of the app in its log
	if [ "$log_path" == "systemd" ] ; then
		# Read the systemd journal
		journalctl -u $service_name -f --since=-45 > "$templog" &
	else
		# Read the specified log file
		tail -F -n0 "$log_path" > "$templog" &
	fi
		# Get the PID of the tail command
		local pid_tail=$!
	fi

	echo "${action^} the service $service_name" >&2
	systemctl $action $service_name \
		|| ( journalctl --lines=$length -u $service_name >&2 \
		; test -n "$log_path" && echo "--" && tail --lines=$length "$log_path" >&2 \
		; false )

	# Start the timeout and try to find line_match
	if [[ -n "${line_match:-}" ]]
	then
		local i=0
		for i in $(seq 1 $timeout)
		do
			# Read the log until the sentence is found, that means the app finished to start. Or run until the timeout
			if grep --quiet "$line_match" "$templog"
			then
				echo "The service $service_name has correctly started." >&2
				break
			fi
			echo -n "." >&2
			sleep 1
		done
		if [ $i -eq $timeout ]
		then
			echo "The service $service_name didn't fully started before the timeout." >&2
			echo "Please find here an extract of the end of the log of the service $service_name:"
			journalctl --lines=$length -u $service_name >&2
			test -n "$log_path" && echo "--" && tail --lines=$length "$log_path" >&2
		fi

		echo ""
		ynh_clean_check_starting
	fi
}

# Clean temporary process and file used by ynh_check_starting
# (usually used in ynh_clean_setup scripts)
#
# usage: ynh_clean_check_starting
ynh_clean_check_starting () {
	# Stop the execution of tail.
	kill -s 15 $pid_tail 2>&1
	ynh_secure_remove "$templog" 2>&1
}

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

# Print a message as INFO and show progression during an app script
#
# usage: ynh_script_progression --message=message [--weight=weight] [--time]
# | arg: -m, --message= - The text to print
# | arg: -w, --weight=  - The weight for this progression. This value is 1 by default. Use a bigger value for a longer part of the script.
# | arg: -t, --time=    - Print the execution time since the last call to this helper. Especially usefull to define weights.
# | arg: -l, --last=    - Use for the last call of the helper, to fill te progression bar.
increment_progression=0
previous_weight=0
# Define base_time when the file is sourced
base_time=$(date +%s)
ynh_script_progression () {
	# Declare an array to define the options of this helper.
	declare -Ar args_array=( [m]=message= [w]=weight= [t]=time [l]=last )
	local message
	local weight
	local time
	local last
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"
	weight=${weight:-1}
	time=${time:-0}
	last=${last:-0}

	# Get execution time since the last $base_time
	local exec_time=$(( $(date +%s) - $base_time ))
	base_time=$(date +%s)

	# Get the number of occurrences of 'ynh_script_progression' in the script. Except those are commented.
	local helper_calls="$(grep --count "^[^#]*ynh_script_progression" $0)"
	# Get the number of call with a weight value
	local weight_calls=$(grep --perl-regexp --count "^[^#]*ynh_script_progression.*(--weight|-w )" $0)

	# Get the weight of each occurrences of 'ynh_script_progression' in the script using --weight
	local weight_valuesA="$(grep --perl-regexp "^[^#]*ynh_script_progression.*--weight" $0 | sed 's/.*--weight[= ]\([[:digit:]].*\)/\1/g')"
	# Get the weight of each occurrences of 'ynh_script_progression' in the script using -w
	local weight_valuesB="$(grep --perl-regexp "^[^#]*ynh_script_progression.*-w " $0 | sed 's/.*-w[= ]\([[:digit:]].*\)/\1/g')"
	# Each value will be on a different line.
	# Remove each 'end of line' and replace it by a '+' to sum the values.
	local weight_values=$(( $(echo "$weight_valuesA" | tr '\n' '+') + $(echo "$weight_valuesB" | tr '\n' '+') 0 ))

	# max_progression is a total number of calls to this helper.
	#    Less the number of calls with a weight value.
	#    Plus the total of weight values
	local max_progression=$(( $helper_calls - $weight_calls + $weight_values ))

	# Increment each execution of ynh_script_progression in this script by the weight of the previous call.
	increment_progression=$(( $increment_progression + $previous_weight ))
	# Store the weight of the current call in $previous_weight for next call
	previous_weight=$weight

	# Set the scale of the progression bar
	local scale=20
	# progress_string(1,2) should have the size of the scale.
	local progress_string1="####################"
	local progress_string0="...................."

	# Reduce $increment_progression to the size of the scale
	if [ $last -eq 0 ]
	then
		local effective_progression=$(( $increment_progression * $scale / $max_progression ))
	# If last is specified, fill immediately the progression_bar
	else
		local effective_progression=$scale
	fi

	# Build $progression_bar from progress_string(1,2) according to $effective_progression
	local progression_bar="${progress_string1:0:$effective_progression}${progress_string0:0:$(( $scale - $effective_progression ))}"

	local print_exec_time=""
	if [ $time -eq 1 ]
	then
		print_exec_time=" [$(date +%Hh%Mm,%Ss --date="0 + $exec_time sec")]"
	fi

	ynh_print_info "[$progression_bar] > ${message}${print_exec_time}"
}

#=================================================

# Send an email to inform the administrator
#
# usage: ynh_send_readme_to_admin app_message [recipients]
# | arg: -m --app_message= - The message to send to the administrator.
# | arg: -r, --recipients= - The recipients of this email. Use spaces to separate multiples recipients. - default: root
#	example: "root admin@domain"
#	If you give the name of a YunoHost user, ynh_send_readme_to_admin will find its email adress for you
#	example: "root admin@domain user1 user2"
ynh_send_readme_to_admin() {
	# Declare an array to define the options of this helper.
	declare -Ar args_array=( [m]=app_message= [r]=recipients= )
	local app_message
	local recipients
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"
	local app_message="${app_message:-...No specific information...}"
	local recipients="${recipients:-root}"

	# Retrieve the email of users
	find_mails () {
		local list_mails="$1"
		local mail
		local recipients=" "
		# Read each mail in argument
		for mail in $list_mails
		do
			# Keep root or a real email address as it is
			if [ "$mail" = "root" ] || echo "$mail" | grep --quiet "@"
			then
				recipients="$recipients $mail"
			else
				# But replace an user name without a domain after by its email
				if mail=$(ynh_user_get_info "$mail" "mail" 2> /dev/null)
				then
					recipients="$recipients $mail"
				fi
			fi
		done
		echo "$recipients"
	}
	recipients=$(find_mails "$recipients")

	local mail_subject="☁️🆈🅽🅷☁️: \`$app\` was just installed!"

	local mail_message="This is an automated message from your beloved YunoHost server.

Specific information for the application $app.

$app_message

---
Automatic diagnosis data from YunoHost

$(yunohost tools diagnosis | grep -B 100 "services:" | sed '/services:/d')"

	# Define binary to use for mail command
	if [ -e /usr/bin/bsd-mailx ]
	then
		local mail_bin=/usr/bin/bsd-mailx
	else
		local mail_bin=/usr/bin/mail.mailutils
	fi

	# Send the email to the recipients
	echo "$mail_message" | $mail_bin -a "Content-Type: text/plain; charset=UTF-8" -s "$mail_subject" "$recipients"
}

#=================================================

ynh_maintenance_mode_ON () {
	# Load value of $path_url and $domain from the config if their not set
	if [ -z $path_url ]; then
		path_url=$(ynh_app_setting_get $app path)
	fi
	if [ -z $domain ]; then
		domain=$(ynh_app_setting_get $app domain)
	fi

	# Create an html to serve as maintenance notice
	echo "<!DOCTYPE html>
<html>
<head>
<meta http-equiv="refresh" content="3">
<title>Your app $app is currently under maintenance!</title>
<style>
	body {
		width: 70em;
		margin: 0 auto;
	}
</style>
</head>
<body>
<h1>Your app $app is currently under maintenance!</h1>
<p>This app has been put under maintenance by your administrator at $(date)</p>
<p>Please wait until the maintenance operation is done. This page will be reloaded as soon as your app will be back.</p>

</body>
</html>" > "/var/www/html/maintenance.$app.html"

	# Create a new nginx config file to redirect all access to the app to the maintenance notice instead.
	echo "# All request to the app will be redirected to ${path_url}_maintenance and fall on the maintenance notice
rewrite ^${path_url}/(.*)$ ${path_url}_maintenance/? redirect;
# Use another location, to not be in conflict with the original config file
location ${path_url}_maintenance/ {
alias /var/www/html/ ;

try_files maintenance.$app.html =503;

# Include SSOWAT user panel.
include conf.d/yunohost_panel.conf.inc;
}" > "/etc/nginx/conf.d/$domain.d/maintenance.$app.conf"

	# The current config file will redirect all requests to the root of the app.
	# To keep the full path, we can use the following rewrite rule:
	# 	rewrite ^${path_url}/(.*)$ ${path_url}_maintenance/\$1? redirect;
	# The difference will be in the $1 at the end, which keep the following queries.
	# But, if it works perfectly for a html request, there's an issue with any php files.
	# This files are treated as simple files, and will be downloaded by the browser.
	# Would be really be nice to be able to fix that issue. So that, when the page is reloaded after the maintenance, the user will be redirected to the real page he was.

	systemctl reload nginx
}

ynh_maintenance_mode_OFF () {
	# Load value of $path_url and $domain from the config if their not set
	if [ -z $path_url ]; then
		path_url=$(ynh_app_setting_get $app path)
	fi
	if [ -z $domain ]; then
		domain=$(ynh_app_setting_get $app domain)
	fi

	# Rewrite the nginx config file to redirect from ${path_url}_maintenance to the real url of the app.
	echo "rewrite ^${path_url}_maintenance/(.*)$ ${path_url}/\$1 redirect;" > "/etc/nginx/conf.d/$domain.d/maintenance.$app.conf"
	systemctl reload nginx

	# Sleep 4 seconds to let the browser reload the pages and redirect the user to the app.
	sleep 4

	# Then remove the temporary files used for the maintenance.
	rm "/var/www/html/maintenance.$app.html"
	rm "/etc/nginx/conf.d/$domain.d/maintenance.$app.conf"

	systemctl reload nginx
}
