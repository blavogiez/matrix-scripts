#!/usr/bin/env bats

@test "service nginx actif" {
    run systemctl is-active nginx
    [ "$status" -eq 0 ]
}

@test "port 80 en ecoute" {
    run ss -tlnp
    [ "$status" -eq 0 ]
    [[ "$output" =~ ":80" ]]
}

@test "element web accessible" {
    run curl -s http://localhost:80
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Element" ]]
}
