#!/bin/bash

hostmaster="51.254.122.248"
usermaster="root"
hostslave="51.254.122.251"

userslave="root"


rm -rf /tmp/$nsdbmaster.ldif 
ssh $userslave@$hostslave "rm -rf /tmp/$nsdbmaster.ldif"
ssh $userslave@$hostslave 'service dirsrv stop'

###extraction ldap#####
dirmaster=$(find /etc/dirsrv/ -mindepth 1 -maxdepth 1 -type d -name "slapd-*" | xargs -n 1 basename)
nsdbmaster=$(find /var/lib/dirsrv/$dirmaster/db/ -mindepth 1 -maxdepth 1 -type d | xargs -n 1 basename)
ns-slapd db2ldif -D /etc/dirsrv/$dirmaster -n $nsdbmaster -a /tmp/$nsdbmaster.ldif >/dev/null 2>&1


###definition des variable du slave####
dirslave=$( ssh $userslave@$hostslave 'find /etc/dirsrv/ -mindepth 1 -maxdepth 1 -type d -name "slapd-*" | xargs -n 1 basename')
cmd="find /var/lib/dirsrv/$dirslave/db/ -mindepth 1 -maxdepth 1 -type d | xargs -n 1 basename"
nsdbslave=$(ssh $userslave@$hostslave $cmd)


echo "################################"
echo "debut du cron le $(date +%y-%m-%d-%H:%M:%S)"

###deverseversement de l'extraction####
/usr/lib/dirsrv/$dirmaster/db2bak /tmp/$nsdbmaster.ldif
scp -r /tmp/$nsdbmaster.ldif $userslave@$hostslave:/tmp >> /var/log/replica/journal.log
ssh $userslave@$hostslave "chmod -R 777 /tmp/$nsdbmaster.ldif"
 >> /var/log/replica/journal.log
ssh $userslave@$hostslave "/usr/lib/dirsrv/$dirmaster/bak2db /tmp/$nsdbmaster.ldif/"
ssh $userslave@$hostslave "service dirsrv start"

### synchronisation des boites mail#####
unison /var/lib/imap/ ssh://web.opensrc.fr//var/lib/imap/ >> /var/log/replica/journal.log
unison /var/spool/imap/ ssh://web.opensrc.fr//var/spool/imap/ >> /var/log/replica/journal.log
ssh $userslave@$hostslave 'chown -R cyrus:mail /var/spool/imap'
echo "fin du cron le $(date +%y-%m-%d-%H:%M:%S)"


