# replication-kolab
Voici un script de replication pour kolab ce script requiere

- unison avec la conf jointe dans le repo ( a mettre dans /$HOME/.unison/)
- que le serveur master est une clé ssh reconnu par le slave pour qu'il puisse ce connecter en ssh sans mot de passe
Pour un bon fonctionnement une replication entre les bases sql est également à mettre en place sinnon
cela peut entrainer des problème au niveau des dossiers dans roundcube
