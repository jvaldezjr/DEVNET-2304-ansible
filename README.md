# Meraki Ansible playbooks

Ansible playbooks for Meraki Dashboard automation using the [Cisco Meraki Ansible collection](https://docs.ansible.com/ansible/latest/collections/cisco/meraki/index.html).

## Prerequisites

- Ansible 2.15+
- Python 3.8+
- [1Password CLI](https://developer.1password.com/docs/cli/) (`op`)
- Meraki Dashboard API key stored in 1Password

Install the collection and Python SDK:

```bash
ansible-galaxy collection install -r requirements.yml
pip install "meraki>=2.4.9"
```

## Configuration

1. Copy `.env.op.example` to `.env.op` and set your `op://` secret reference for `MERAKI_DASHBOARD_API_KEY`.
2. Update the organization ID in `inventory/group_vars/all.yml`:

```yaml
meraki_organization_id: "your-organization-id"
```

The `.env.op.example` file also sets `OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES` for macOS ([Meraki Ansible docs](https://developer.cisco.com/codeexchange/github/repo/meraki/dashboard-api-ansible/)). Add that line to your `.env.op` if you copied an older example.

## Run playbooks

From this directory, use `--` so `op run` passes arguments to Ansible correctly:

```bash
op run --account runsushiesrun.1password.com --env-file=.env.op -- ansible-playbook playbooks/list-organization-admins.yml
```

Or use the helper script (same behavior, reads `.env.op` from project root):

```bash
chmod +x scripts/run-playbook.sh   # once
./scripts/run-playbook.sh playbooks/list-organization-admins.yml
```

## List organization administrators

The `cisco.meraki.organizations_admins` module manages administrators (create, update, delete). To **list** admins, use the companion `cisco.meraki.organizations_admins_info` module — see `playbooks/list-organization-admins.yml`.

```bash
op run --env-file=.env.op -- ansible-playbook playbooks/list-organization-admins.yml
```

Admin data is returned in `organization_admins.meraki_response`. Inactive **full-access** admins (null `lastActive` or inactive for `inactive_days_threshold` days, default 90) are downgraded to `inactive_admin_target_org_access` (default `read-only`) via `cisco.meraki.organizations_admins`.
