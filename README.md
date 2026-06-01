# Meraki Ansible playbooks

Ansible playbooks for Meraki Dashboard automation using the [Cisco Meraki Ansible collection](https://docs.ansible.com/ansible/latest/collections/cisco/meraki/index.html).

## Prerequisites

- Ansible 2.15+
- Python 3.8+
- [1Password CLI](https://developer.1password.com/docs/cli/) (`op`) for local runs
- Meraki Dashboard API key (and organization ID) available as environment variables

Install the collection and Python SDK:

```bash
ansible-galaxy collection install -r requirements.yml
pip install "meraki>=2.4.9"
```

## Configuration

Copy `.env.op.example` to `.env.op` and set:

| Variable | Description |
|----------|-------------|
| `MERAKI_DASHBOARD_API_KEY` | API key (`op://` secret reference or plain value) |
| `MERAKI_ORGANIZATION_ID` | Target organization ID (plain value is fine) |

Thresholds (`inactive_days_threshold`, `inactive_admin_target_org_access`) stay in `inventory/group_vars/all.yml`.

The `.env.op.example` file also sets `OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES` for macOS ([Meraki Ansible docs](https://developer.cisco.com/codeexchange/github/repo/meraki/dashboard-api-ansible/)).

### Environment variables and `op run`

The playbook reads secrets with `lookup('env', 'MERAKI_…')`. That works with:

- **`op run --env-file=.env.op`** — 1Password resolves `op://` references, then starts `ansible-playbook` with those variables in the process environment.
- **Semaphore** — set the same variable names in the task template (Key Store for the API key).
- **Plain export** — `export MERAKI_DASHBOARD_API_KEY=…` and `export MERAKI_ORGANIZATION_ID=…`

Yes, the API key should be an environment variable (not in Git). The org ID can be env-only too so you can target different orgs without changing committed files.

## Run playbooks

From this directory:

```bash
op run --account runsushiesrun.1password.com --env-file=.env.op -- ansible-playbook playbooks/downgrade-inactive-full-admins.yml
```

Or use the helper script:

```bash
chmod +x scripts/run-playbook.sh   # once
./scripts/run-playbook.sh playbooks/downgrade-inactive-full-admins.yml
```

## Downgrade inactive full-access org admins

`playbooks/downgrade-inactive-full-admins.yml` lists org admins, finds **full** `orgAccess` admins with no `lastActive` or last active ≥ `inactive_days_threshold` days (default 90), and downgrades them to `read-only` (configurable) via `cisco.meraki.organizations_admins`.

## Semaphore UI (EC2 / manual install)

Semaphore runs `ansible-playbook` in its own Python environment. Install `meraki` and the `cisco.meraki` collection for the user that actually runs tasks (see [manual install troubleshooting](https://semaphoreui.com/docs/admin-guide/installation_manually)) — not necessarily a `semaphore` user if your AMI uses another account.

In the **task template**:

- Playbook path: `playbooks/downgrade-inactive-full-admins.yml`
- Environment variables: `MERAKI_DASHBOARD_API_KEY`, `MERAKI_ORGANIZATION_ID`

The `/etc/semaphore/requirements.txt` path is for [Docker installs only](https://semaphoreui.com/docs/admin-guide/installation#installing-additional-python-packages).
