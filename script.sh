#!/bin/bash


hostmaster="192.168.2.1"
usermaster="root"
hostslave="192.168.2.2"
userslave="root"



####extraction ldap#####
dirmaster=$(find /etc/dirsrv/ -mindepth 1 -maxdepth 1 -type d -name "slapd-*" | xargs -n 1 basename)
nsdbmaster=$(find /var/lib/dirsrv/$dirmaster/db/ -mindepth 1 -maxdepth 1 -type d | xargs -n 1 basename)
ns-slapd db2ldif -D /etc/dirsrv/$dirmaster -n $nsdbmaster -a /tmp/$nsdbmaster.ldif >/dev/null 2>&1


##definition des variable du slave
dirslave=$( ssh $userslave@$hostslave 'find /etc/dirsrv/ -mindepth 1 -maxdepth 1 -type d -name "slapd-*" | xargs -n 1 basename')
cmd="find /var/lib/dirsrv/$dirslave/db/ -mindepth 1 -maxdepth 1 -type d | xargs -n 1 basename"
nsdbslave=$(ssh $userslave@$hostslave $cmd)


#deverseversement de l'extraction####
scp /tmp/$nsdbmaster.ldif $userslave@$hostslave:/tmp
ssh $userslave@$hostslave "chmod 777 /tmp/$nsdbmaster.ldif"
ssh $userslave@$hostslave 'service dirsrv stop'
ssh $userslave@$hostslave "ns-slapd ldif2db -D /etc/dirsrv/$dirslave  -n $nsdbslave  -i /tmp/$nsdbmaster.ldif"
ssh $userslave@$hostslave 'service dirsrv start'

### synchronisation des boites mail#####
unison /var/lib/imap/ ssh://web.opensrc.fr//var/lib/imap/
unison /var/spool/imap/ ssh://web.opensrc.fr//var/spool/imap/
ssh $userslave@$hostslave 'chown -R cyrus:mail /var/spool/imap'
