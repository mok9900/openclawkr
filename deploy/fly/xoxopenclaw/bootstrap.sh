#!/usr/bin/env bash
set -euo pipefail

# Fly.io first-time provisioning script for xoxopenclaw.
# - Creates app/volume in nrt
# - Applies fly.toml in this folder
# - Sets required secrets (prompted if missing)

APP_NAME="xoxopenclaw"
REGION="nrt"
VOLUME_NAME="openclaw_data"
VOLUME_SIZE_GB="500"

if ! command -v fly >/dev/null 2>&1; then
  echo "flyctl is required: https://fly.io/docs/hands-on/install-flyctl/" >&2
  exit 1
fi

if ! fly auth whoami >/dev/null 2>&1; then
  echo "You are not logged in. Run: fly auth login" >&2
  exit 1
fi

if ! fly apps list --json | jq -e ".[] | select(.Name == \"${APP_NAME}\")" >/dev/null; then
  fly apps create "${APP_NAME}"
fi

if ! fly volumes list --app "${APP_NAME}" --json | jq -e ".[] | select(.Name == \"${VOLUME_NAME}\")" >/dev/null; then
  fly volumes create "${VOLUME_NAME}" --app "${APP_NAME}" --size "${VOLUME_SIZE_GB}" --region "${REGION}"
fi

if [[ -z "${OPENCLAW_GATEWAY_TOKEN:-}" ]]; then
  OPENCLAW_GATEWAY_TOKEN="$(openssl rand -hex 32)"
fi

echo "Setting required secrets"
fly secrets set --app "${APP_NAME}" OPENCLAW_GATEWAY_TOKEN="${OPENCLAW_GATEWAY_TOKEN}"

if [[ -n "${DISCORD_BOT_TOKEN:-}" ]]; then
  fly secrets set --app "${APP_NAME}" DISCORD_BOT_TOKEN="${DISCORD_BOT_TOKEN}"
else
  echo "DISCORD_BOT_TOKEN is not set. Skipping."
fi

if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
  fly secrets set --app "${APP_NAME}" ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}"
else
  echo "ANTHROPIC_API_KEY is not set. Skipping."
fi

fly deploy --app "${APP_NAME}" --config "$(dirname "$0")/fly.toml"

cat <<MSG
Done.

Next checks:
  fly status --app ${APP_NAME}
  fly logs --app ${APP_NAME}
  fly ssh console --app ${APP_NAME}
MSG
