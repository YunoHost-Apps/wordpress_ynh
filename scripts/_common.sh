#!/bin/bash

#=================================================
# DISPLAYING
#=================================================

WARNING () {	# Écrit sur le canal d'erreur pour passer en warning.
	$@ >&2
}

ALL_QUIET () {	# Redirige la sortie standard et d'erreur dans /dev/null
	$@ > /dev/null 2>&1
}

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
		WARNING echo "Espace insuffisant pour sauvegarder $file_to_analyse."
		WARNING echo "Espace disponible: $(HUMAN_SIZE $free_space)"
		ynh_die "Espace nécessaire: $(HUMAN_SIZE $backup_size)"
	fi
}


#=================================================
#============= FUTURE YUNOHOST HELPER ============
#=================================================

# Delete a file checksum from the app settings
#
# $app should be defined when calling this helper
#
# usage: ynh_remove_file_checksum file
# | arg: file - The file for which the checksum will be deleted
ynh_delete_file_checksum () {
	local checksum_setting_name=checksum_${1//[\/ ]/_}	# Replace all '/' and ' ' by '_'
	ynh_app_setting_delete $app $checksum_setting_name
}


#=================================================
# EXPERIMENTAL HELPERS
#=================================================

# Create a dedicated fail2ban config (jail and filter conf files)
#
# usage: ynh_add_fail2ban_config log_file filter [max_retry [ports]]
# | arg: log_file - Log file to be checked by fail2ban
# | arg: failregex - Failregex to be looked for by fail2ban
# | arg: max_retry - Maximum number of retries allowed before banning IP address - default: 3
# | arg: ports - Ports blocked for a banned IP address - default: http,https
ynh_add_fail2ban_config () {
	# Process parameters
	logpath=$1
	failregex=$2
	max_retry=${3:-3}
	ports=${4:-http,https}

	test -n "$logpath" || ynh_die "ynh_add_fail2ban_config expects a logfile path as first argument and received nothing."
	test -n "$failregex" || ynh_die "ynh_add_fail2ban_config expects a failure regex as second argument and received nothing."

	finalfail2banjailconf="/etc/fail2ban/jail.d/$app.conf"
	finalfail2banfilterconf="/etc/fail2ban/filter.d/$app.conf"
	ynh_backup_if_checksum_is_different "$finalfail2banjailconf" 1
	ynh_backup_if_checksum_is_different "$finalfail2banfilterconf" 1

	sudo tee $finalfail2banjailconf <<EOF
[$app]
enabled = true
port = $ports
filter = $app
logpath = $logpath
maxretry = $max_retry" 
EOF

	sudo tee $finalfail2banfilterconf <<EOF
[INCLUDES]
before = common.conf
[Definition]
failregex = $failregex
ignoreregrex =" 
EOF

	ynh_store_file_checksum "$finalfail2banjailconf"
	ynh_store_file_checksum "$finalfail2banfilterconf"

	sudo systemctl restart fail2ban
	local fail2ban_error=$(tail -n50 /var/log/fail2ban.log | grep "ERROR.*$app")
	echo "restart=$?"
}

# Remove the dedicated fail2ban config (jail and filter conf files)
#
# usage: ynh_remove_fail2ban_config
ynh_remove_fail2ban_config () {
	ynh_secure_remove "/etc/fail2ban/jail.d/$app.conf"
	ynh_secure_remove "/etc/fail2ban/filter.d/$app.conf"
	sudo systemctl restart fail2ban
}
