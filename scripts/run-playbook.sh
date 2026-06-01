#!/usr/bin/env bash
# Run Ansible playbooks with 1Password secrets and macOS fork-safety defaults.
set -euo pipefail

cd "$(dirname "$0")/.."

exec op run --env-file=.env.op -- ansible-playbook "$@"
