# Dépôt public pour scripts relatifs à l'installation matrix

> Pour des informations sur les procédures d'installation, consultez : [Dépôt procédures](https://gitlab.univ-lille.fr/etu/2025-2026/s303/g-lavogiez-robert).

- Auto-installation de 6 VMs (voir l'architecture dans [Sommaire procédures](https://gitlab.univ-lille.fr/etu/2025-2026/s303/g-lavogiez-robert/-/blob/main/README.md?ref_type=heads)) avec sauvegarde automatique, dns et pare-feu configurés.
- Tests (Framework BATS)

# Explication

Le script `vmiut` intègre une fonction `executer()` utilisant la variable `SCRIPTS` définissant un script shell. `vmiut`, par le biais de VBoxManage, va copier et exécuter le script sur la vm passée en argument.

Une utilisation typique serait alors : 

```bash
baptiste.lavogiez.etu@dattier:~$ export SCRIPT=scripts/vmiut/deploy-matrix.sh
baptiste.lavogiez.etu@dattier:~$ vmiut executer matrix # le script va chercher la variable $SCRIPTS et l'executer sur la vm matrix
```

Tout s'exécutera en tant que `root` sur la vm, avec le résultat s'affichant dans la sortie standard.

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

> Temps d'installation : ~6min30 pour 6 VMs

# Licence

- Script `vmiut` (non contenu ici) réalisé par Bruno Beaufils - Michaël Hauspie 
- Voir [Licence](.LICENSE) - copie interdite sans autorisation