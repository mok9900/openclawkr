#!/usr/bin/env bash
set -euo pipefail

# Fly.io first-time provisioning script for xoxopenclaw.
# - Loads secrets from local .env (not committed)
# - Creates app/volume in nrt
# - Applies fly.toml in this folder

APP_NAME="xoxopenclaw"
REGION="nrt"
VOLUME_NAME="openclaw_data"
VOLUME_SIZE_GB="500"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

if ! command -v fly >/dev/null 2>&1; then
  echo "flyctl is required: https://fly.io/docs/hands-on/install-flyctl/" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required." >&2
  exit 1
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  cat >&2 <<MSG
Missing ${ENV_FILE}

Create it from template:
  cp "${SCRIPT_DIR}/.env.example" "${ENV_FILE}"
Then fill in your real tokens.
MSG
  exit 1
fi

# Export env vars from .env for this process only.
set -a
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +a

if ! fly auth whoami >/dev/null 2>&1; then
  echo "You are not logged in. Run: fly auth login (or set FLY_API_TOKEN in .env)." >&2
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

# Set required/optional secrets when provided.
fly secrets set --app "${APP_NAME}" OPENCLAW_GATEWAY_TOKEN="${OPENCLAW_GATEWAY_TOKEN}"

[[ -n "${DISCORD_BOT_TOKEN:-}" ]] && fly secrets set --app "${APP_NAME}" DISCORD_BOT_TOKEN="${DISCORD_BOT_TOKEN}"
[[ -n "${SLACK_BOT_TOKEN:-}" ]] && fly secrets set --app "${APP_NAME}" SLACK_BOT_TOKEN="${SLACK_BOT_TOKEN}"
[[ -n "${GEMINI_API_KEY:-}" ]] && fly secrets set --app "${APP_NAME}" GEMINI_API_KEY="${GEMINI_API_KEY}"
[[ -n "${ANTHROPIC_API_KEY:-}" ]] && fly secrets set --app "${APP_NAME}" ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}"

fly deploy --app "${APP_NAME}" --config "${SCRIPT_DIR}/fly.toml"

echo "Done: ${APP_NAME}"
