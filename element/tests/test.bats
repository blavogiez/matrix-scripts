#!/usr/bin/env bats

@test "service nginx actif" {
    run systemctl is-active nginx
    [ "$status" -eq 0 ]
}

@test "port 8080 en ecoute" {
    run ss -tlnp
    [ "$status" -eq 0 ]
    [[ "$output" =~ ":8080" ]]
}

@test "element web accessible" {
    run curl -s http://localhost:8080
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Element" ]]
}
