# Installation automatique d'une architecture matrix

> Pour des informations sur les procédures d'installation, consultez le [dépôt des procédures](https://gitlab.univ-lille.fr/etu/2025-2026/s303/g-lavogiez-robert).

- Auto-installation de 6 VMs (voir l'architecture dans [Sommaire procédures](https://gitlab.univ-lille.fr/etu/2025-2026/s303/g-lavogiez-robert/-/blob/main/README.md?ref_type=heads)) avec DNS, pare-feu et sauvegarde automatique configurés.
- Tests (Framework BATS)

## **Informations de développement**

- **Développé par** : Ethan Robert, Baptiste Lavogiez
- **Contact** :  
  - Mail : [ethan.robert.etu@univ-lille.fr](mailto:ethan.robert.etu@univ-lille.fr) | [baptiste.lavogiez.etu@univ-lille.fr](mailto:baptiste.lavogiez.etu@univ-lille.fr)

## Démonstration

[Voir la démonstration accélérée](assets/automatic-install.mp4)

## Utilisation

Forkez ce dépôt, modifiez votre `config.env` selon vos besoins (avec votre nouvelle URL dépôt). Dans `attribution-ip.env`, mettez votre numéro d'IP (octet 3) attribué, à côté de votre nom tel que `toto.tata.etu=123`. `config.env` centralise toutes les variables d'installation : IP, packages, noms d'hôtes des services...

Lancez, sur une machine physique :

```bash
./dist-launch.sh
```

et le script va détecter votre :

- nom de machine physique ($HOSTNAME)
- numéro d'IP dans la plage d'attribution (selon votre nom/prénom)

puis, va modifier votre `config.env` et le push sur le dépôt configuré dans le script ([Exemple de commit automatique](https://gitlab.univ-lille.fr/baptiste.lavogiez.etu/matrix-scripts/-/commit/a0ecf0e3df1639a45d30b5a29a860b195146381a)).

De ce fait, l'autoinstall va utiliser votre : 

- nom de machine physique
- numéro d'IP dans la plage d'attribution

l'avantage étant que ce n'est pas hardcodé et modifiable selon *qui* lance le script et *où*.

Ensuite, `orchestrate.sh` est exécuté sur la machine de virtualisation distante configurée. Ce script ouvre `tmux` avec autant de terminaux que de machines afin d'avoir une pleine visibilité sur l'installation (voir démonstration).

Automatiquement, à la fin de l'installation, un tunnel SSH est initié vers le reverse proxy (rentrez le mot de passe configuré), et Firefox s'ouvre avec l'URL Element correcte.

## Fonctionnement

Le script `vmiut` intègre une fonction `executer()` utilisant la variable `SCRIPT` définissant un script shell. `vmiut`, par le biais de VBoxManage, va copier et exécuter le script sur la vm passée en argument.

Une utilisation typique serait alors : 

```bash
baptiste.lavogiez.etu@dattier:~$ export SCRIPT=scripts/vmiut/deploy-matrix.sh
baptiste.lavogiez.etu@dattier:~$ vmiut executer matrix # le script va chercher la variable $SCRIPT et l'exécuter sur la vm matrix
```

Tout s'exécutera en tant que `root` sur la vm, avec le résultat s'affichant dans la sortie standard.

### Spécialisation des scripts, depuis la machine de virtualisation

Nous ne pouvons pas passer d'argument au script mis dans la variable `SCRIPT`. Ainsi, nous allons "fabriquer" un argument avec notre script `make-vm`, qui lorsque appelé sur `dattier` de la façon `./make-vm.sh install element`, peut fabriquer, par exemple, un `install-element.sh` à partir de `install-template.sh`. La structure du dépôt (scripts aux noms identiques dans des dossiers spécialisés) permet de spécialiser ce template en faisant deux commandes `sed`. 

En effet, `make-vm` a deux modes : `install` et `setup`, correspondant aux deux phases de l'installation, appelant donc deux scripts différents (`install-template` ou `setup-template`). 

> Si `make-vm setup {nom machine}` est appelé, alors la vm `{nom machine}` est supprimée, puis recréée, puis démarrée (visible dans la démonstration).

`make-vm install element` appelé sur `dattier` associerait ainsi, après fabrication, `install-element.sh` à la variable `SCRIPT`, puis appellerait `vmiut executer {nom machine}`, le nom de machine correspondant logiquement au service appelé par `make-vm`. 


### Spécialisation des scripts, depuis la machine virtuelle créée 

Lorsque `vmiut executer {nom machine}` est appelé pour la première fois, la machine virtuelle est vide. Elle va donc cloner ce dépôt, exécuter la phase de configuration (dossier configuration commun à toutes les VMs où des paramètres changent tout de même, comme le suffixe d'IP ou le `hostname`) et, se déplacer dans le dossier correspondant à son service, pour exécuter `install.sh` étant cette fois-ci spécialisé pour son service (et, à la fin, exécuter les tests). 

Les scripts sont pensés pour être explicites, ainsi l'arborescence pourra vous renseigner.

L'architecture s'installe en ~6min30 pour 6 VMs (en conditions optimales). Les deux phases sont expliquées ci-dessous :

#### Phase 1 : Configuration parallèle (setup-template.sh)

Dans un premier temps, les 6 VMs sont configurées **en parallèle** via `setup-template.sh`. Ce script :

1. Télécharge et extrait le dépôt sur la VM
2. Associe les variables du service (`HOSTNAME`, `IP_SUFFIX`) selon un `case`
3. Appelle `configuration/setup-vm.sh` qui exécute :
   - Installation des paquets de base (vim, curl, rsync, bats...)
   - Configuration de l'adresse IP statique + `dns-nameservers` si la VM n'est pas le DNS
   - Définition du hostname (permanent)
   - Configuration de sudo
   - (DNS uniquement) Remplissage de `/etc/hosts` avec toutes les VMs

Cette phase étant indépendante entre VMs, elle peut être parallélisée afin d'accélérer l'installation.

#### Phase 2 : Installation des services (install-template.sh)

Ensuite, les services sont installés dans un ordre précis (contrôlé avec les signaux `wait-for` de `tmux`) afin de permettre des tests ciblés :

- 1 : `dns`, `backup` ; ne communiquent pas directement avec les autres machines pendant leur installation
- 2 : `db`, `element` ; services plus indépendants (`db` a tout de même besoin de `backup` pour les tests)
- 3 : `matrix` ; doit se connecter à `db` pour vérifier le bon fonctionnement
- 4 : `rproxy` : doit réussir des requêtes vers le nom physique redirigeant vers les deux machines étant `matrix` (nécessitant ainsi `db`) et `element`. 

À la toute fin de l'installation d'un service, le firewall est configuré (s'il était configuré avant, le dashboard afficherait toujours `[DOWN]` puisque fonctionnant par requête réseau). **On peut configurer le firewall pendant la phase de setup si l'on souhaite tester l'installation sous firewall (fonctionnement des liens entre machines). Il s'agit dans notre cas plus d'un choix de monitoring pour la démonstration, ayant testé le firewall complet et ne l'ayant plus modifié lorsque déplacé à la fin.**

Les mots de passe sont également changés à la toute fin (nous y sommes contraints car il y a deux commandes `vmiut executer` qui sont réalisées et la sous-couche VirtualBox nécessite le mot de passe par défaut).

> **Si tous les tests passent, l'architecture est pleinement fonctionnelle (les scripts sont assez précis et nombreux pour tout tester, avec notamment un `curl -H` final sur `rproxy` qui simule l'accès aux URL Element et Synapse)**.

#### Note sur la sécurité

**Il est préférable de changer les mots de passe d'utilisateur/root car nous avons choisi de les passer par le dépôt git.**

Une solution alternative consisterait à utiliser une génération aléatoire dans `config.env`, avec, par exemple, `openssl rand -base64 32`, puis de transmettre les mots de passe pour chaque machine à l'utilisateur. Par souci d'accessibilité à nos machines, nous avons choisi un mot de passe fixe et nous l'avons changé manuellement à la fin. Les deux solutions restent parfaitement viables (la génération aléatoire étant en réalité plus sécurisée).

## Licence

- Script `vmiut` (non contenu ici) réalisé par Bruno Beaufils - Michaël Hauspie 
- [Apache 2.0](.LICENSE)