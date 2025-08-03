#!/bin/bash
set -e

# Initialize firewall if requested
if [ "${ENABLE_FIREWALL:-false}" = "true" ]; then
    echo "Initializing firewall..."
    sudo /workspace/.devcontainer/gemini/init-firewall.sh
fi

# Execute the original command
exec "$@"
