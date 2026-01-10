#!/usr/bin/env bats

@test "répertoire /var/backups/matrix existe" {
    [ -d /var/backups/matrix ]
}

@test "permissions du répertoire 700" {
    run stat -c "%a" /var/backups/matrix
    [ "$status" -eq 0 ]
    [ "$output" = "700" ]
}

@test "propriétaire du répertoire est user" {
    run stat -c "%U" /var/backups/matrix
    [ "$status" -eq 0 ]
    [ "$output" = "user" ]
}

@test "script cleanup-old-backups.sh existe" {
    [ -f /usr/local/bin/cleanup-old-backups.sh ]
}

@test "script cleanup-old-backups.sh est exécutable" {
    [ -x /usr/local/bin/cleanup-old-backups.sh ]
}

@test "cron contient cleanup-old-backups" {
    run crontab -l
    [ "$status" -eq 0 ]
    [[ "$output" =~ "cleanup-old-backups.sh" ]]
}

@test "rsync est installé" {
    run which rsync
    [ "$status" -eq 0 ]
}
