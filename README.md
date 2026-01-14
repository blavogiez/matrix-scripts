# Dépôt public pour scripts relatifs à l'nstallation d'une architecture matrix

> Pour des informations sur les procédures d'installation, consultez le [dépôt des procédures](https://gitlab.univ-lille.fr/etu/2025-2026/s303/g-lavogiez-robert).

- Auto-installation de 6 VMs (voir l'architecture dans [Sommaire procédures](https://gitlab.univ-lille.fr/etu/2025-2026/s303/g-lavogiez-robert/-/blob/main/README.md?ref_type=heads)) avec sauvegarde automatique, dns et pare-feu configurés.
- Tests (Framework BATS)

# Démonstration

[Voir la démo accélérée](assets/automatic-install.mp4)

# Utilisation

Forkez ce dépôt, modifiez votre `config.env` (y compris URL dépôt) pour mettre votre numéro d'IP (octet 3) attribué. 

Lancez 

```bash
./dist-launch.sh
```

et le script va détecter votre :

- nom de machine physique ($HOSTNAME)
- numéro d'IP dans la plage d'attribution (selon votre nom/prénom)

puis, va modifier votre `config.env` et le push sur le dépôt configuré dans le script.

De ce fait, l'autoinstall va utiliser votre : 

- nom de machine physique
- numéro d'IP dans la plage d'attribution

Automatiquement, à la fin de l'installation, un tunnel SSH est initié vers le reverse proxy (rentrez le mot de passe configuré), et votre navigateur s'ouvre avec l'url element correct.

# Fonctionnement

Le script `vmiut` intègre une fonction `executer()` utilisant la variable `SCRIPT` définissant un script shell. `vmiut`, par le biais de VBoxManage, va copier et exécuter le script sur la vm passée en argument.

Une utilisation typique serait alors : 

```bash
baptiste.lavogiez.etu@dattier:~$ export SCRIPT=scripts/vmiut/deploy-matrix.sh
baptiste.lavogiez.etu@dattier:~$ vmiut executer matrix # le script va chercher la variable $SCRIPT et l'executer sur la vm matrix
```

Tout s'exécutera en tant que `root` sur la vm, avec le résultat s'affichant dans la sortie standard.

## Spécialisation des scripts, depuis la machine de virtualisation

Nous ne pouvons pas passer d'argument au script mis dans la variable `SCRIPT`. Ainsi, nous allons "fabriquer" un argument avec notre script `make-vm`, qui lorsque appelé sur `dattier` de la façon `./make-vm.sh install element`, peut fabriquer, par exemple, un `install-element.sh` à partir de `install-template.sh`. La structure du dépôt (scripts aux noms identiques dans des dossiers spécialisés) permet de spécialiser ce template en faisant deux commandes `sed`. 

Enfin, `make-vm` a deux modes : `install` et `setup`, correspondant aux deux phases de l'installation, appelant donc deux scripts différents (`install-template` ou `setup-template`). 

`make-vm` appelé sur `dattier` associerait ainsi `install-element.sh` à la variable `SCRIPT`, puis appellerait `vmiut executer {nom machine}`, le nom de machine correspondant logiquement au service appelé par `make-vm`.

## Spécialisation des scripts, depuis la machine virtuelle créée 

Lorsque `vmiut executer {nom machine}` est appelé pour la première fois, la machine virtuelle est vide. Elle va donc cloner ce dépôt et se déplacer dans le dossier correspondant à son service, pour exécuter `install.sh` (et, à la fin, exécuter les tests). 



Les scripts sont pensés pour être explicites, ainsi l'arborescence pourra vous renseigner.





L'architecture s'installe en ~6min30 pour 6 VMs (en conditions optimales)

### Phase 1 : Setup parallèle

Dans un premier temps, les 6 VMs sont configurées

### Phase 2 : Installation des services

Ensuite, les services sont installés dans un ordre précis afin de permettre des tests ciblés :

- 1 : `dns`, `backup` ; ne nécessitent pas de résolution DNS des autres machines
- 2 : `db`, `element` ; services indépendants (`db` a tout de même besoin de `backup` pour les tests)
- 3 : `matrix` ; doit se connecter à `db` pour vérifier le bon fonctionnement
- 4 : `rproxy` : doit réussir des requêtes vers le nom physique, nécessitant donc `matrix` (donc `db`) et `element` fonctionnels 

À la toute fin, le firewall est configuré (si il était configuré avant, le dashboard afficherait toujours `[DOWN]`) et les mots de passe sont changés.

### Note sur la sécurité

**Il est préférable de changer les mots de passe d'utilisateur/root car nous avons choisi de les passer par le dépôt git.**

Une solution alternative consisterait à utiliser une génération aléatoire dans `config.env`, avec, par exemple, `openssl rand -base64 32`, puis de transmettre les mot de passe pour chaque machine à l'utilisateur. Par soucis d'accessibilité à nos machines, nous avons choisi un mot de passe fixe et nous l'avons changé manuellement à la fin. Les deux solutions restent parfaitement viables (la génération aléatoire est plus sécurisée en réalité).

# Licence

- Script `vmiut` (non contenu ici) réalisé par Bruno Beaufils - Michaël Hauspie 
- Voir [Licence](.LICENSE) - copie interdite sans autorisation