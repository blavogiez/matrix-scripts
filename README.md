# Dépôt public pour scripts relatifs à l'installation matrix

- Auto-installation
- Tests (Framework BATS)

# Utilisation

Le script `vmiut` intègre une fonction `executer()` utilisant la variable `SCRIPTS` définissant un script shell.

Une utilisation typique serait alors : 

```bash
baptiste.lavogiez.etu@dattier:~$ export SCRIPT=scripts/vmiut/deploy-test.sh
baptiste.lavogiez.etu@dattier:~$ vmiut executer test # le script va chercher la variable $SCRIPTS
```

Tout s'exécutera en tant que root, avec le résultat s'affichant dans la sortie standard.

## Environnement

Forkez ce dépôt, modifiez votre `config.env` (y compris URL dépôt) pour mettre votre numéro d'IP (octet 3) attribué.

# Automatisation