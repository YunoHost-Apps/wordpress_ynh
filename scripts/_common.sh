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
