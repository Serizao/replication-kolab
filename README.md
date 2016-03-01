# replication-kolab
Voici un script de replication pour kolab ce script requiere

- unison avec la conf jointe dans le repo ( a mettre dans /$HOME/.unison/)
- que le serveur master est une clé ssh reconnu par le slave pour qu'il puisse ce connecter en ssh sans mot de passe
Pour un bon fonctionnement une replication entre les bases sql est également à mettre en place sinnon
cela peut entrainer des problème au niveau des dossiers dans roundcube


et pour la tache plannifié faire 

crontab -e


puis ajouter la ligne :

@hourly /root/replica_kolab.sh >>/var/log/replica/cron.log
0,5,10,15,20,25,30,35,40,45,50,55 * * * * /root/replica_kolab.sh >>/var/log/replica/cron.log
