#!/usr/bin/env bats

setup() {
    export USERNAME="testuser"
    export PASSWORD="testpass123"
    export DB_HOST="$IP_PREFIX.$IP_OCTET3.$DB_SUFFIX"
    export PGPASSWORD="synapse_user"
}

@test "service synapse actif" {
    run systemctl is-active matrix-synapse
    [ "$status" -eq 0 ]
    [ "$output" = "active" ]
}

@test "port 8008 en ecoute" {
    run ss -tlnp
    [ "$status" -eq 0 ]
    [[ "$output" =~ ":8008" ]]
}

@test "api matrix versions accessible" {
    run curl -s http://localhost:8008/_matrix/client/versions
    [ "$status" -eq 0 ]
    [[ "$output" =~ "versions" ]]
}

@test "page accueil synapse" {
    run curl -s http://localhost:8008
    [ "$status" -eq 0 ]
    [[ "$output" =~ "matrix" ]]
}

@test "creation utilisateur synapse reussit" {
    run tests/test_create_user.sh "$USERNAME" "$PASSWORD" "$DB_HOST"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "test reussi" ]]
}

@test "utilisateur existe dans postgres" {
    tests/test_create_user.sh "$USERNAME" "$PASSWORD" "$DB_HOST" >/dev/null 2>&1
    
    run psql -h $DB_HOST -U synapse_user -d matrix -t -c "select 1 from users where name like '%$USERNAME%';"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "1" ]]
}
