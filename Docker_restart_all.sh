#!/bin/bash

BASE_DIR="/var/lib/jenkins/workspace/CCTNS-2.0-Backend-Dev-PGSQL"
ENV_FILE="$BASE_DIR/.env"

echo "Using env file: $ENV_FILE"
echo

for dir in "$BASE_DIR"/*; do
    # Skip @tmp directories
    [[ ! -d "$dir" || "$dir" == *"@tmp"* ]] && continue

    COMPOSE_FILE="$dir/docker-compose.yml"

    if [[ -f "$COMPOSE_FILE" ]]; then
        cd "$dir"

        # Get service container names from compose
        CONTAINERS=$(docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" ps -q)

        # Skip if no containers exist
        [[ -z "$CONTAINERS" ]] && continue

        # Check if any container is running
        RUNNING=false
        for c in $CONTAINERS; do
            if [[ "$(docker inspect -f '{{.State.Running}}' "$c")" == "true" ]]; then
                RUNNING=true
                break
            fi
        done

        if $RUNNING; then
            echo "========================================="
            echo "Recreating $(basename "$dir")"
            echo "========================================="
            docker compose --env-file "$ENV_FILE" up -d
            echo
        fi
    fi
done

echo "Done."
