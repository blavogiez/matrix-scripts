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

@test "connexion base matrix" {
    run psql -h $DB_HOST -U synapse_user -d matrix -c "\dt"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "users" ]]
}
