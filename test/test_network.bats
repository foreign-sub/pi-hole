#!/usr/bin/env bats
# Network detection tests — IPv6 address detection and IP validation

load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'libs/bats-mock/stub'
load 'bats_helper.bash'

# ---------------------------------------------------------------------------
# IPv6 detection
# ---------------------------------------------------------------------------

@test "IPv6 link-local only: blocking disabled" {
    stub ip "-6 address : echo 'inet6 fe80::d210:52fa:fe00:7ad7/64 scope link'"
    run bash -c "
        source /opt/pihole/basic-install.sh
        find_IPv6_information
    "
    assert_output --partial "Unable to find IPv6 ULA/GUA address"

    unstub ip 2>/dev/null || true
}

@test "IPv6 ULA only: blocking enabled" {
    stub ip "-6 address : echo 'inet6 fda2:2001:5555:0:d210:52fa:fe00:7ad7/64 scope global'"
    run bash -c "
        source /opt/pihole/basic-install.sh
        find_IPv6_information
    "
    assert_output --partial "Found IPv6 ULA address"

    unstub ip 2>/dev/null || true
}

@test "IPv6 GUA only: blocking enabled" {
    stub ip "-6 address : echo 'inet6 2003:12:1e43:301:d210:52fa:fe00:7ad7/64 scope global'"
    run bash -c "
        source /opt/pihole/basic-install.sh
        find_IPv6_information
    "
    assert_output --partial "Found IPv6 GUA address"

    unstub ip 2>/dev/null || true
}

@test "IPv6 GUA + ULA: ULA takes precedence" {
    stub ip "-6 address : printf 'inet6 2003:12:1e43:301:d210:52fa:fe00:7ad7/64 scope global\ninet6 fda2:2001:5555:0:d210:52fa:fe00:7ad7/64 scope global\n'"
    run bash -c "
        source /opt/pihole/basic-install.sh
        find_IPv6_information
    "
    assert_output --partial "Found IPv6 ULA address"

    unstub ip 2>/dev/null || true
}

@test "IPv6 ULA + GUA: ULA takes precedence" {
    stub ip "-6 address : printf 'inet6 fda2:2001:5555:0:d210:52fa:fe00:7ad7/64 scope global\ninet6 2003:12:1e43:301:d210:52fa:fe00:7ad7/64 scope global\n'"
    run bash -c "
        source /opt/pihole/basic-install.sh
        find_IPv6_information
    "
    assert_output --partial "Found IPv6 ULA address"

    unstub ip 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# IP address validation
# ---------------------------------------------------------------------------

@test "valid_ip accepts and rejects addresses correctly" {
    _valid() {
        run bash -c "source /opt/pihole/basic-install.sh; valid_ip '${1}'"
        assert_success
    }
    _invalid() {
        run bash -c "source /opt/pihole/basic-install.sh; valid_ip '${1}'"
        assert_failure
    }

    _valid  "192.168.1.1"
    _valid  "127.0.0.1"
    _valid  "255.255.255.255"
    _invalid "255.255.255.256"
    _invalid "255.255.256.255"
    _invalid "255.256.255.255"
    _invalid "256.255.255.255"
    _invalid "1092.168.1.1"
    _invalid "not an IP"
    _invalid "8.8.8.8#"
    _valid  "8.8.8.8#0"
    _valid  "8.8.8.8#1"
    _valid  "8.8.8.8#42"
    _valid  "8.8.8.8#888"
    _valid  "8.8.8.8#1337"
    _valid  "8.8.8.8#65535"
    _invalid "8.8.8.8#65536"
    _invalid "8.8.8.8#-1"
    _invalid "00.0.0.0"
    _invalid "010.0.0.0"
    _invalid "001.0.0.0"
    _invalid "0.0.0.0#00"
    _invalid "0.0.0.0#01"
    _invalid "0.0.0.0#001"
    _invalid "0.0.0.0#0001"
    _invalid "0.0.0.0#00001"
}
