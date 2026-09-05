#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/env.sh
source "$DIR/lib/env.sh"
# shellcheck source=lib/run.sh
source "$DIR/lib/run.sh"

MODE="${1:-all}"
MODE="${MODE#-}"
MODE="${MODE#-}"

case "$MODE" in
    cli)
        run_script "$DIR/install/cli.sh"
        ;;
    all | installs)
        run_script "$DIR/install/all.sh"
        ;;
    *)
        echo "Usage: $0 {cli|all}" >&2
        exit 1
        ;;
esac
