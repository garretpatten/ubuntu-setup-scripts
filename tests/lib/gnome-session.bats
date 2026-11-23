#!/usr/bin/env bats
# Unit tests for src/scripts/lib/gnome-session.sh.
# shellcheck disable=SC2030,SC2031

setup() {
    load ../helpers/setup
    common_setup
    # shellcheck source=../../src/scripts/lib/gnome-session.sh
    source "$REAL_SCRIPTS_DIR/lib/gnome-session.sh"
    unset XDG_CURRENT_DESKTOP DESKTOP_SESSION GNOME_SHELL_SESSION_MODE
    # Default: hide loginctl so tests that do not install a stub stop at the
    # env-var checks.
    hide_binary loginctl
}

teardown() {
    common_teardown
}

@test "gnome_session_active is true when XDG_CURRENT_DESKTOP mentions GNOME" {
    XDG_CURRENT_DESKTOP="ubuntu:GNOME"
    run gnome_session_active
    assert_success
}

@test "gnome_session_active is true for a known GNOME DESKTOP_SESSION" {
    DESKTOP_SESSION=ubuntu
    run gnome_session_active
    assert_success
}

@test "gnome_session_active is true when GNOME_SHELL_SESSION_MODE is set" {
    GNOME_SHELL_SESSION_MODE=ubuntu
    run gnome_session_active
    assert_success
}

@test "gnome_session_active is false when no GNOME signals are present" {
    run gnome_session_active
    assert_failure 1
}

@test "gnome_session_active uses loginctl for the current user" {
    mkdir -p "$SANDBOX/bin"
    cat >"$SANDBOX/bin/loginctl" <<STUB
#!/bin/bash
echo "loginctl \$*" >>"\${STUB_CALL_LOG:?}"
if [[ "\$1" == "list-sessions" ]]; then
    printf '%s\\n' "2 1000 seat0 ${USER} active"
    exit 0
fi
if [[ "\$1" == "show-session" ]]; then
    printf '%s\\n' "GNOME"
    exit 0
fi
exit 0
STUB
    chmod +x "$SANDBOX/bin/loginctl"
    PATH="$SANDBOX/bin:$PATH"
    export HIDDEN_BINARIES=""
    run gnome_session_active
    assert_success
    assert_stub_call '^loginctl list-sessions'
    assert_stub_call "^loginctl show-session 2 -p Desktop --value"
}

@test "gnome_session_active ignores loginctl sessions for other users" {
    mkdir -p "$SANDBOX/bin"
    cat >"$SANDBOX/bin/loginctl" <<STUB
#!/bin/bash
echo "loginctl \$*" >>"\${STUB_CALL_LOG:?}"
if [[ "\$1" == "list-sessions" ]]; then
    printf '%s\\n' "2 1000 seat0 someone-else active"
    exit 0
fi
if [[ "\$1" == "show-session" ]]; then
    printf '%s\\n' "GNOME"
    exit 0
fi
exit 0
STUB
    chmod +x "$SANDBOX/bin/loginctl"
    PATH="$SANDBOX/bin:$PATH"
    export HIDDEN_BINARIES=""
    run gnome_session_active
    assert_failure 1
    refute_stub_call 'show-session'
}
