#!/bin/bash
# Clone, build, and configure garretpatten/google-mcp-server so the opencode
# config in dotfiles can start it from ~/Projects/google-mcp-server/dist/index.js.
# Runs after NodeSource nodejs is installed and the async dev phase (nvm) finishes.

GOOGLE_MCP_REPO_URL="${GOOGLE_MCP_REPO_URL:-https://github.com/garretpatten/google-mcp-server}"
GOOGLE_MCP_DIR="${GOOGLE_MCP_DIR:-$HOME/Projects/google-mcp-server}"

# Resolve the system-scripts .env that holds the shared Google OAuth client.
# Override with GOOGLE_MCP_SYSTEM_SCRIPTS_ENV for a non-standard path.
google_mcp_system_scripts_env() {
    if [[ -n "${GOOGLE_MCP_SYSTEM_SCRIPTS_ENV:-}" ]]; then
        printf '%s\n' "$GOOGLE_MCP_SYSTEM_SCRIPTS_ENV"
        return 0
    fi

    local candidate
    for candidate in \
        "$HOME/Projects/system-scripts/.env" \
        "$HOME/Scripts/system-scripts/.env"; do
        if [[ -f "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    printf '%s\n' "$HOME/Projects/system-scripts/.env"
}

# True when KEY is present in a dotenv file and has a non-empty value.
# Does not print the value.
google_mcp_env_key_is_set() {
    local file="$1"
    local key="$2"

    [[ -f "$file" ]] || return 1

    awk -v key="$key" '
        function unquote(v) {
            if (v ~ /^".*"$/) {
                return substr(v, 2, length(v) - 2)
            }
            if (v ~ /^'\''.*'\''$/) {
                return substr(v, 2, length(v) - 2)
            }
            return v
        }
        index($0, key "=") == 1 {
            val = unquote(substr($0, length(key) + 2))
            if (val != "") {
                found = 1
            }
        }
        END { exit found ? 0 : 1 }
    ' "$file"
}

# Write or replace a KEY=... assignment in dest without printing the value.
# The assignment line is read from a file so it never appears in process arguments.
google_mcp_upsert_env_assignment() {
    local dest="$1"
    local assignment_file="$2"
    local key tmp

    key=$(awk -F= 'NR==1 { print $1; exit }' "$assignment_file")
    if [[ -z "$key" ]]; then
        return 1
    fi

    tmp=$(mktemp)
    if [[ -f "$dest" ]]; then
        awk -v key="$key" -v assignment_file="$assignment_file" '
            BEGIN {
                while ((getline line < assignment_file) > 0) {
                    assignment = line
                    break
                }
                close(assignment_file)
            }
            index($0, key "=") == 1 {
                if (!replaced) {
                    print assignment
                    replaced = 1
                    next
                }
            }
            { print }
            END {
                if (!replaced) {
                    print assignment
                }
            }
        ' "$dest" >"$tmp"
    else
        cat "$assignment_file" >"$tmp"
        printf '\n' >>"$tmp"
    fi

    mv "$tmp" "$dest"
}

# Copy GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET from system-scripts/.env
# into the MCP server .env. Preserves any existing GOOGLE_REFRESH_TOKEN.
# Never prints or logs secret values.
google_mcp_copy_oauth_client_credentials() {
    local src="$1"
    local dest="$2"
    local key assignment_file

    if [[ ! -f "$src" ]]; then
        echo "google-mcp-server: skipped OAuth client copy; $src not found"
        return 0
    fi

    if ! google_mcp_env_key_is_set "$src" GOOGLE_CLIENT_ID ||
        ! google_mcp_env_key_is_set "$src" GOOGLE_CLIENT_SECRET; then
        echo "google-mcp-server: skipped OAuth client copy; GOOGLE_CLIENT_ID or GOOGLE_CLIENT_SECRET is unset in $src"
        return 0
    fi

    if [[ ! -f "$dest" ]]; then
        if [[ -f "$(dirname "$dest")/.env.example" ]]; then
            cp "$(dirname "$dest")/.env.example" "$dest" || true
        else
            touch "$dest"
        fi
    fi

    assignment_file=$(mktemp)
    for key in GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET; do
        # Isolate the last assignment for this key; write it to a temp file.
        awk -v key="$key" '
            index($0, key "=") == 1 { line = $0 }
            END { if (line != "") print line }
        ' "$src" >"$assignment_file"
        if [[ ! -s "$assignment_file" ]]; then
            rm -f "$assignment_file"
            echo "google-mcp-server: skipped OAuth client copy; missing $key in $src"
            return 0
        fi
        google_mcp_upsert_env_assignment "$dest" "$assignment_file"
    done
    rm -f "$assignment_file"

    chmod 600 "$dest" || true
}

google_mcp_clone_or_update() {
    local dest="$1"
    local dest_parent

    dest_parent=$(dirname "$dest")
    mkdir -p "$dest_parent"

    if [[ -d "$dest/.git" ]]; then
        GIT_TERMINAL_PROMPT=0 git -C "$dest" pull --ff-only || true
        return 0
    fi

    if [[ -e "$dest" ]]; then
        echo "ERROR: google-mcp-server: $dest exists but is not a git checkout" >&2
        return 1
    fi

    if ! GIT_TERMINAL_PROMPT=0 git clone "$GOOGLE_MCP_REPO_URL" "$dest"; then
        echo "ERROR: google-mcp-server: failed to clone $GOOGLE_MCP_REPO_URL" >&2
        return 1
    fi
}

google_mcp_node_major() {
    command -v node >/dev/null 2>&1 || return 1
    node -p "parseInt(process.versions.node, 10)" 2>/dev/null
}

google_mcp_build() {
    local dest="$1"
    local major

    if ! command -v npm >/dev/null 2>&1; then
        echo "ERROR: google-mcp-server: npm is not on PATH; install Node >= 24 and retry" >&2
        return 1
    fi

    major=$(google_mcp_node_major) || major=""
    if [[ -z "$major" || "$major" -lt 24 ]]; then
        echo "google-mcp-server: skipped npm install and build; Node >= 24 is required (found ${major:-none})"
        return 1
    fi

    if ! (
        cd "$dest" || exit 1
        if ! npm ci; then
            exit 1
        fi
        if ! npm run build; then
            exit 1
        fi
    ); then
        echo "ERROR: google-mcp-server: npm ci or npm run build failed in $dest" >&2
        return 1
    fi
}

# Prompt is opt-in, default no, and is skipped when stdin or stdout is not a TTY.
google_mcp_is_interactive() {
    [[ -t 0 && -t 1 ]]
}

google_mcp_prompt_auth() {
    local dest="$1"
    local answer=""

    if ! google_mcp_is_interactive; then
        return 0
    fi

    read -r -p "Run interactive Google OAuth for google-mcp-server (npm run auth)? [y/N] " answer || true
    case "$answer" in
        y | Y | yes | YES)
            if ! (
                cd "$dest" || exit 1
                npm run auth
            ); then
                echo "ERROR: google-mcp-server: npm run auth failed" >&2
            fi
            ;;
    esac
}

# Confirm the build output exists. When all three OAuth values are set, start
# the stdio server briefly: a clean exit on stdin close, or a hang-free start
# that we then stop, counts as success. The smoke log is never printed.
google_mcp_smoke_check() {
    local dest="$1"
    local entry="$dest/dist/index.js"
    local smoke_log pid elapsed status

    if [[ ! -f "$entry" ]]; then
        echo "ERROR: google-mcp-server: build output missing: $entry" >&2
        return 1
    fi

    if ! google_mcp_env_key_is_set "$dest/.env" GOOGLE_CLIENT_ID ||
        ! google_mcp_env_key_is_set "$dest/.env" GOOGLE_CLIENT_SECRET ||
        ! google_mcp_env_key_is_set "$dest/.env" GOOGLE_REFRESH_TOKEN; then
        echo "google-mcp-server: skipped start check; run npm run auth in $dest to finish OAuth"
        return 0
    fi

    if ! command -v node >/dev/null 2>&1; then
        echo "ERROR: google-mcp-server: node is not on PATH; cannot start $entry" >&2
        return 1
    fi

    smoke_log=$(mktemp)
    node "$entry" </dev/null >"$smoke_log" 2>&1 &
    pid=$!

    elapsed=0
    while kill -0 "$pid" 2>/dev/null && ((elapsed < 5)); do
        sleep 1
        elapsed=$((elapsed + 1))
    done

    if kill -0 "$pid" 2>/dev/null; then
        # Still running after 5s with stdin closed: started cleanly; stop it.
        kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
        rm -f "$smoke_log"
        return 0
    fi

    wait "$pid"
    status=$?
    rm -f "$smoke_log"
    if [[ "$status" -ne 0 ]]; then
        echo "ERROR: google-mcp-server: server exited with status $status on start" >&2
        return 1
    fi
    return 0
}

google_mcp_install() {
    local dest="$GOOGLE_MCP_DIR"
    local src_env

    if ! google_mcp_clone_or_update "$dest"; then
        return 0
    fi
    if ! google_mcp_build "$dest"; then
        return 0
    fi

    src_env=$(google_mcp_system_scripts_env)
    google_mcp_copy_oauth_client_credentials "$src_env" "$dest/.env"
    google_mcp_prompt_auth "$dest"
    google_mcp_smoke_check "$dest" || true
}

# Only run when executed directly, so the file can be sourced safely.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    google_mcp_install "$@"
fi
