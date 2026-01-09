**Ici on peut marquer les idées d'opti/reformulation que l'on observe dans les procédures, l'install...**

- Scripts de test type `echo "uneconfig" > /etc/network/interfaces` (On les extrait de la section tests des procédures !)
- Scripts déterministes d'installation, qui exécutent les tests à la fin.

Les scripts pourraient être assez simplistes, il s'agit souvent de juste echo des fichiers et executer des commandes. Si leur code est simple, on pourra mieux l'expliquer.


- Machine physique (IUT) --> SSH (dattier) --> VMs
- Redémarrage final des machines
- Terminal d'état s'affichant à la fin avec des indicateurs (ping) pour les services tournant