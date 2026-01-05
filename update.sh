#!/bin/sh

# ===== FUNCTIONS =====

fetch_latest_changes() {
    echo "Fetching latest changes from origin..."
    git fetch origin

    if [ $? -ne 0 ]; then
        echo "Error: Failed to fetch from origin"
        return 1
    fi

    return 0
}

checkout_main_branch() {
    echo "Checking out origin/main..."
    git checkout -B main origin/main

    if [ $? -ne 0 ]; then
        echo "Error: Failed to checkout origin/main"
        return 1
    fi

    return 0
}

# ===== MAIN =====

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$SCRIPT_DIR" || exit 1

fetch_latest_changes || exit 1

checkout_main_branch || exit 1

echo "Update completed successfully!"
exit 0

