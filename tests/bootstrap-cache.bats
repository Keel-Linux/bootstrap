#!/usr/bin/env bats
# The cache is opt-in; the default debootstrap line is unchanged. The
# Makefile's parse-time checks are stubbed, and `make -n` prints the
# command instead of running debootstrap.

REPO=$BATS_TEST_DIRNAME/..

setup() {
    STUBS=$BATS_TEST_TMPDIR/stubs
    mkdir -p "$STUBS"
    printf '#!/bin/sh\necho Debian\n' > "$STUBS/lsb_release"
    chmod +x "$STUBS/lsb_release"
    printf '#!/bin/sh\necho amd64\n' > "$STUBS/dpkg"
    chmod +x "$STUBS/dpkg"
    for c in fab pool debootstrap; do
        printf '#!/bin/sh\nexit 0\n' > "$STUBS/$c"
        chmod +x "$STUBS/$c"
    done
    export PATH="$STUBS:$PATH"
    export FAB_PATH="$BATS_TEST_TMPDIR/fab"
}

@test "the cache is off by default" {
    run make -n -C "$REPO" bootstrap
    [ "$status" -eq 0 ]
    [[ "$output" != *"--cache-dir"* ]]
}

@test "DEBOOTSTRAP_CACHE adds --cache-dir" {
    run make -n -C "$REPO" bootstrap DEBOOTSTRAP_CACHE=/tmp/cache
    [ "$status" -eq 0 ]
    [[ "$output" == *"--cache-dir=/tmp/cache"* ]]
}
