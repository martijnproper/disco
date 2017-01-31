#!/bin/bash
#
#=========================================
#	Variablelen declareren
#=========================================
#		< Om veiligheidsredenen, zodat de een of andere idioot >
#		< geen variabelen kan passeren zonder dat dat de       > 
#		< bedoeling is. Ook als verduidelijking, zeg maar      >
#		< index. En FTW.                                       >
# Algemeen ----------------------
Dag=""				# Duh. Ga thee zetten.
Tijd=""				# STERKE thee. Met melk en suiker, graag.
STijd=""			# Aantal seconden sinds 1 jan 1970. Handig voor unieke nummers enzo.
NormGebr="WTF?"			# Als we naar root veranderen, wie was dan de oorspronkelijke gebruiker? Passeert van $USER, dus als die niet bestaat...
# Netwerk -----------------------	
NETdev=""			# Netwerkinterface X
NETarr=""			# Array van gedetecteerde NICs
IP=""				# IP van NIC X
MAC=""				# MAC van NIC X
IParr=""			# Array van IPs gedetecteerde NICs
MACarr=""			# Array van MACs gedetecteerde NICs
# Opslag ------------------------		
DRV=""				# Disk X
DRVmount=""			# Waar disk X gemount is
DRVarr=""			# Array van gedetecteerde disk X
# Backup ------------------------		
BUcfg=""			# Voor rdiff
RScfg=""			# Voor rsync
BUtype=""			# Leest backup stijl uit config bestand op doelschijf
BUmarker=""			# Voor terminal output
BUsrc=""			# Backup bron
BUtgt=""			# Backup doel
#
#=========================================
#	Variabelen toewijzen
#=========================================
#		< Want variabelen zijn wel leuk, maar ze moeten ook iets doen >
Dag=$(date)								# Vandaag in complete vorm
Tijd=$(date +"%T")							# Korte tijd
STijd=$(date +"%s")							# Een berg nummers
NormGebr=$USER								# Leg huidige gebruiker vast
DRVarr=$(ls /dev | grep "[sh]d[a-z][1-9]")				# Toon alle aangesloten disks
NETarr=$(ifconfig -a | sed 's/[ \t].*//;/^\(lo\|\)$/d')			# Toon alle actieve netwerkinterfaces
IP="Niet verbonden"							# Melding
BUcfg="backup.9"							# Kies rdiff
RScfg="sync.9"								# Kies rsync
BUmarker="Interne schijf"						# Melding
DefErr="0x35c000 Replace user"						# Standaard foutmelding
#
#=========================================
#	Functies
#=========================================
#
FindIP () {
	echo -e "\e[96m --- Netwerk interfaces --- \033[0m"
	printf "%-15s | %-15s | %-15s\n" "______NIC______" "______IP_______" "______MAC_________"
	for NETdev in $NETarr; do
		IP=`ifconfig $NETdev | awk '/inet addr/{print substr($2,6)}'`
		MAC=`ifconfig $NETdev | grep $NETdev | tr -s ' ' | cut -d ' ' -f5 | cut -c 1-17`
		printf "%-15s | %-15s | %-15s\n" "$NETdev" "$IP" "$MAC"
	done
}
#
FindStorage () {
	echo -e "\e[96m --- Opslag --- \033[0m"
	printf "%-15s | %-15s | %-15s\n" "______dev______" "______type_____" "______mnt_________"
	for DRV in $DRVarr; do 
		DRVmount=$(readlink -f $DRV* | while read dev;do mount | grep "$DRV\b" | awk '{print $3}';done)
		if [[ $DRVmount == /* ]] ; then
			if [ -f "$DRVmount/$BUcfg" ]; then				# Backup
				BUpath=$DRVmount/$BUcfg
				BUtype=`cat $BUpath`
				BUmarker="\e[32m Backup $BUtype \033[0m"
 				BUsrc="/media/mdctr/Data/$BUtype"
 				BUtgt="$DRVName/$BUtype"
 				echo "rdiff-backup -v5 --print-statistics $BUsrc $BUtgt"
			elif [ -f "$DRVmount/$RScfg" ]; then				# Sync
				BUpath=$DRVmount/$RScfg
				RStype=`cat $BUpath`
				BUmarker="Sync $RStype"
 				BUsrc="$HOME/$RStype"
 				BUtgt="$DRVName/$RStype"
#				echo "rsync -vzp $BUsrc $BUtgt"
			fi
			printf "%-15s | %-15s | %-15s\n" "$DRV" "$BUmarker" "$DRVmount"		 
		else
			printf "%-15s | %-15s | %-15s\n" "$DRV" "x" "x"
		fi
	done
}
infoblock1 () {
	echo -e "\e[96m --- Diverse informatie --- \033[0m"
	echo "Huidige gebruiker...............: $USER"
	echo "Standaard niet-root gebruiker...: $NormGebr"
	echo "Huidige datum...................: $Dag"
	echo "Huidige tijd....................: $Tijd"
	echo "Aantal seconden sinds 1/1/1970..: $STijd"
	echo
	FindIP
	echo
	FindStorage
}
#
#=========================================
#	Begin programma
#=========================================
clear
infoblock1
#
#while true
#do
#   tail /var/log/syslog | grep “iptables denied:” | grep –o “DST=[0-9\.]*[[:space:]]”
    echo tail /var/log/syslog | grep "nijn"
xterm -e find $HOME -not -path '*/\.*' -mtime -1
#   sleep 0.5
#done
echo -e "\033[0m"; exit 0
#=========================================
#	Einde programma
#=========================================
# - Netwerk, IP en MAC in array ivm netcat, portscan
# - Backup jobs a la rsync -vzp $BUsrc $BUtgt in array voor job afhandeling
