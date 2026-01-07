#!/usr/bin/env bats

setup() {
    export DB_HOST="localhost"
    export PGPASSWORD="synapse_user"
}

@test "service postgresql actif" {
    run systemctl is-active postgresql
    [ "$status" -eq 0 ]
}

@test "port 5432 en ecoute" {
    run ss -tlnp
    [ "$status" -eq 0 ]
    [[ "$output" =~ ":5432" ]]
}

@test "connexion base matrix depuis synapse_user (la base doit être vide)" {
    run psql -h $DB_HOST -U synapse_user -d matrix -c "\dt"
    [ "$status" -eq 0 ]
}

# on fera plus de tests relatifs à la base lors de la vm matrix (puisque la vm db est installée en premier, on ne peut pas encore les faire)
