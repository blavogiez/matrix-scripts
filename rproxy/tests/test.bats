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

@test "route vers synapse" {
    run curl -s -H "Host: matrix.$INSTANCE_NAME" http://localhost
    [ "$status" -eq 0 ]
    [[ "$output" =~ "matrix" ]]
}

@test "route vers element" {
    run curl -s -H "Host: element.$INSTANCE_NAME" http://localhost
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Element" ]]
}
