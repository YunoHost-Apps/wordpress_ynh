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
# EXPERIMENTAL HELPERS
#=================================================

# Send an email to inform the administrator
#
# usage: ynh_send_readme_to_admin --app_message=app_message [--recipients=recipients] [--type=type]
# | arg: -m --app_message= - The file with the content to send to the administrator.
# | arg: -r, --recipients= - The recipients of this email. Use spaces to separate multiples recipients. - default: root
#	example: "root admin@domain"
#	If you give the name of a YunoHost user, ynh_send_readme_to_admin will find its email adress for you
#	example: "root admin@domain user1 user2"
# | arg: -t, --type= - Type of mail, could be 'backup', 'change_url', 'install', 'remove', 'restore', 'upgrade'
ynh_send_readme_to_admin() {
	# Declare an array to define the options of this helper.
	declare -Ar args_array=( [m]=app_message= [r]=recipients= [t]=type= )
	local app_message
	local recipients
	local type
	# Manage arguments with getopts

	ynh_handle_getopts_args "$@"
	app_message="${app_message:-}"
	recipients="${recipients:-root}"
	type="${type:-install}"

	# Get the value of admin_mail_html
	admin_mail_html=$(ynh_app_setting_get $app admin_mail_html)
	admin_mail_html="${admin_mail_html:-0}"

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

	# Subject base
	local mail_subject="☁️🆈🅽🅷☁️: \`$app\`"

	# Adapt the subject according to the type of mail required.
	if [ "$type" = "backup" ]; then
		mail_subject="$mail_subject has just been backup."
	elif [ "$type" = "change_url" ]; then
		mail_subject="$mail_subject has just been moved to a new URL!"
	elif [ "$type" = "remove" ]; then
		mail_subject="$mail_subject has just been removed!"
	elif [ "$type" = "restore" ]; then
		mail_subject="$mail_subject has just been restored!"
	elif [ "$type" = "upgrade" ]; then
		mail_subject="$mail_subject has just been upgraded!"
	else	# install
		mail_subject="$mail_subject has just been installed!"
	fi

	local mail_message="This is an automated message from your beloved YunoHost server.

Specific information for the application $app.

$(if [ -n "$app_message" ]
then
	cat "$app_message"
else
	echo "...No specific information..."
fi)

---
Automatic diagnosis data from YunoHost

__PRE_TAG1__$(yunohost tools diagnosis | grep -B 100 "services:" | sed '/services:/d')__PRE_TAG2__"

	# Store the message into a file for further modifications.
	echo "$mail_message" > mail_to_send

	# If a html email is required. Apply html tags to the message.
 	if [ "$admin_mail_html" -eq 1 ]
 	then
		# Insert 'br' tags at each ending of lines.
		ynh_replace_string "$" "<br>" mail_to_send

		# Insert starting HTML tags
		sed --in-place '1s@^@<!DOCTYPE html>\n<html>\n<head></head>\n<body>\n@' mail_to_send

		# Keep tabulations
		ynh_replace_string "  " "\&#160;\&#160;" mail_to_send
		ynh_replace_string "\t" "\&#160;\&#160;" mail_to_send

		# Insert url links tags
		ynh_replace_string "__URL_TAG1__\(.*\)__URL_TAG2__\(.*\)__URL_TAG3__" "<a href=\"\2\">\1</a>" mail_to_send

		# Insert pre tags
		ynh_replace_string "__PRE_TAG1__" "<pre>" mail_to_send
		ynh_replace_string "__PRE_TAG2__" "<\pre>" mail_to_send

		# Insert finishing HTML tags
		echo -e "\n</body>\n</html>" >> mail_to_send

	# Otherwise, remove tags to keep a plain text.
	else
		# Remove URL tags
		ynh_replace_string "__URL_TAG[1,3]__" "" mail_to_send
		ynh_replace_string "__URL_TAG2__" ": " mail_to_send

		# Remove PRE tags
		ynh_replace_string "__PRE_TAG[1-2]__" "" mail_to_send
	fi

	# Define binary to use for mail command
	if [ -e /usr/bin/bsd-mailx ]
	then
		local mail_bin=/usr/bin/bsd-mailx
	else
		local mail_bin=/usr/bin/mail.mailutils
	fi

	if [ "$admin_mail_html" -eq 1 ]
	then
		content_type="text/html"
	else
		content_type="text/plain"
	fi

	# Send the email to the recipients
	cat mail_to_send | $mail_bin -a "Content-Type: $content_type; charset=UTF-8" -s "$mail_subject" "$recipients"
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

	mkdir -p /var/www/html/
	
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

#=================================================

# Check the amount of available RAM
#
# usage: ynh_check_ram [--required=RAM required in Mb] [--no_swap|--only_swap] [--free_ram]
# | arg: -r, --required= - Amount of RAM required in Mb. The helper will return 0 is there's enough RAM, or 1 otherwise.
# If --required isn't set, the helper will print the amount of RAM, in Mb.
# | arg: -s, --no_swap   - Ignore swap
# | arg: -o, --only_swap - Ignore real RAM, consider only swap.
# | arg: -f, --free_ram  - Count only free RAM, not the total amount of RAM available.
ynh_check_ram () {
	# Declare an array to define the options of this helper.
	declare -Ar args_array=( [r]=required= [s]=no_swap [o]=only_swap [f]=free_ram )
	local required
	local no_swap
	local only_swap
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"
	required=${required:-}
	no_swap=${no_swap:-0}
	only_swap=${only_swap:-0}

	local total_ram=$(vmstat --stats --unit M | grep "total memory" | awk '{print $1}')
	local total_swap=$(vmstat --stats --unit M | grep "total swap" | awk '{print $1}')
	local total_ram_swap=$(( total_ram + total_swap ))

	local free_ram=$(vmstat --stats --unit M | grep "free memory" | awk '{print $1}')
	local free_swap=$(vmstat --stats --unit M | grep "free swap" | awk '{print $1}')
	local free_ram_swap=$(( free_ram + free_swap ))

	# Use the total amount of ram
	local ram=$total_ram_swap
	if [ $free_ram -eq 1 ]
	then
		# Use the total amount of free ram
		ram=$free_ram_swap
		if [ $no_swap -eq 1 ]
		then
			# Use only the amount of free ram
			ram=$free_ram
		elif [ $only_swap -eq 1 ]
		then
			# Use only the amount of free swap
			ram=$free_swap
		fi
	else
		if [ $no_swap -eq 1 ]
		then
			# Use only the amount of free ram
			ram=$total_ram
		elif [ $only_swap -eq 1 ]
		then
			# Use only the amount of free swap
			ram=$total_swap
		fi
	fi

	if [ -n "$required" ]
	then
		# Return 1 if the amount of ram isn't enough.
		if [ $ram -lt $required ]
		then
			return 1
		else
			return 0
		fi

	# If no RAM is required, return the amount of available ram.
	else
		echo $ram
	fi
}

#=================================================

# Define the values to configure php-fpm
#
# usage: ynh_get_scalable_phpfpm --usage=usage --footprint=footprint [--print]
# | arg: -f, --footprint      - Memory footprint of the service (low/medium/high).
# low    - Less than 20Mb of ram by pool.
# medium - Between 20Mb and 40Mb of ram by pool.
# high   - More than 40Mb of ram by pool.
# Or specify exactly the footprint, the load of the service as Mb by pool instead of having a standard value.
# To have this value, use the following command and stress the service.
# watch -n0.5 ps -o user,cmd,%cpu,rss -u APP
#
# | arg: -u, --usage     - Expected usage of the service (low/medium/high).
# low    - Personal usage, behind the sso.
# medium - Low usage, few people or/and publicly accessible.
# high   - High usage, frequently visited website.
#
# | arg: -p, --print - Print the result
#
#
#
# The footprint of the service will be used to defined the maximum footprint we can allow, which is half the maximum RAM.
# So it will be used to defined 'pm.max_children'
# A lower value for the footprint will allow more children for 'pm.max_children'. And so for
#    'pm.start_servers', 'pm.min_spare_servers' and 'pm.max_spare_servers' which are defined from the
#    value of 'pm.max_children'
# NOTE: 'pm.max_children' can't exceed 4 times the number of processor's cores.
#
# The usage value will defined the way php will handle the children for the pool.
# A value set as 'low' will set the process manager to 'ondemand'. Children will start only if the
#   service is used, otherwise no child will stay alive. This config gives the lower footprint when the
#   service is idle. But will use more proc since it has to start a child as soon it's used.
# Set as 'medium', the process manager will be at dynamic. If the service is idle, a number of children
#   equal to pm.min_spare_servers will stay alive. So the service can be quick to answer to any request.
#   The number of children can grow if needed. The footprint can stay low if the service is idle, but
#   not null. The impact on the proc is a little bit less than 'ondemand' as there's always a few
#   children already available.
# Set as 'high', the process manager will be set at 'static'. There will be always as many children as
#   'pm.max_children', the footprint is important (but will be set as maximum a quarter of the maximum
#   RAM) but the impact on the proc is lower. The service will be quick to answer as there's always many
#   children ready to answer.
ynh_get_scalable_phpfpm () {
    local legacy_args=ufp
    # Declare an array to define the options of this helper.
    declare -Ar args_array=( [u]=usage= [f]=footprint= [p]=print )
    local usage
    local footprint
    local print
    # Manage arguments with getopts
    ynh_handle_getopts_args "$@"
    # Set all characters as lowercase
    footprint=${footprint,,}
    usage=${usage,,}
    print=${print:-0}

    if [ "$footprint" = "low" ]
    then
        footprint=20
    elif [ "$footprint" = "medium" ]
    then
        footprint=35
    elif [ "$footprint" = "high" ]
    then
        footprint=50
    fi

    # Define the way the process manager handle child processes.
    if [ "$usage" = "low" ]
    then
        php_pm=ondemand
    elif [ "$usage" = "medium" ]
    then
        php_pm=dynamic
    elif [ "$usage" = "high" ]
    then
        php_pm=static
    else
        ynh_die --message="Does not recognize '$usage' as an usage value."
    fi

    # Get the total of RAM available, except swap.
    local max_ram=$(ynh_check_ram --no_swap)

    less0() {
        # Do not allow value below 1
        if [ $1 -le 0 ]
        then
            echo 1
        else
            echo $1
        fi
    }

    # Define pm.max_children
    # The value of pm.max_children is the total amount of ram divide by 2 and divide again by the footprint of a pool for this app.
    # So if php-fpm start the maximum of children, it won't exceed half of the ram.
    php_max_children=$(( $max_ram / 2 / $footprint ))
    # If process manager is set as static, use half less children.
    # Used as static, there's always as many children as the value of pm.max_children
    if [ "$php_pm" = "static" ]
    then
        php_max_children=$(( $php_max_children / 2 ))
    fi
    php_max_children=$(less0 $php_max_children)

    # To not overload the proc, limit the number of children to 4 times the number of cores.
    local core_number=$(nproc)
    local max_proc=$(( $core_number * 4 ))
    if [ $php_max_children -gt $max_proc ]
    then
        php_max_children=$max_proc
    fi

    if [ "$php_pm" = "dynamic" ]
    then
        # Define pm.start_servers, pm.min_spare_servers and pm.max_spare_servers for a dynamic process manager
        php_min_spare_servers=$(( $php_max_children / 8 ))
        php_min_spare_servers=$(less0 $php_min_spare_servers)

        php_max_spare_servers=$(( $php_max_children / 2 ))
        php_max_spare_servers=$(less0 $php_max_spare_servers)

        php_start_servers=$(( $php_min_spare_servers + ( $php_max_spare_servers - $php_min_spare_servers ) /2 ))
        php_start_servers=$(less0 $php_start_servers)
    else
        php_min_spare_servers=0
        php_max_spare_servers=0
        php_start_servers=0
    fi

    if [ $print -eq 1 ]
    then
        ynh_debug --message="Footprint=${footprint}Mb by pool."
        ynh_debug --message="Process manager=$php_pm"
        ynh_debug --message="Max RAM=${max_ram}Mb"
        if [ "$php_pm" != "static" ]; then
            ynh_debug --message="\nMax estimated footprint=$(( $php_max_children * $footprint ))"
            ynh_debug --message="Min estimated footprint=$(( $php_min_spare_servers * $footprint ))"
        fi
        if [ "$php_pm" = "dynamic" ]; then
            ynh_debug --message="Estimated average footprint=$(( $php_max_spare_servers * $footprint ))"
        elif [ "$php_pm" = "static" ]; then
            ynh_debug --message="Estimated footprint=$(( $php_max_children * $footprint ))"
        fi
        ynh_debug --message="\nRaw php-fpm values:"
        ynh_debug --message="pm.max_children = $php_max_children"
        if [ "$php_pm" = "dynamic" ]; then
            ynh_debug --message="pm.start_servers = $php_start_servers"
            ynh_debug --message="pm.min_spare_servers = $php_min_spare_servers"
            ynh_debug --message="pm.max_spare_servers = $php_max_spare_servers"
        fi
    fi
}
