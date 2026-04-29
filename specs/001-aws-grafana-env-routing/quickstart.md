## Quickstart: AWS Env Routing Parity

### 1) Use feature branch artifacts

```bash
cd /Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12
git checkout 001-aws-grafana-env-routing
```

### 2) Confirm wrapped module version upgrade

Check `main.tf` to ensure module `source = "dasmeta/grafana/onpremise"` is pinned to the targeted latest compatible version for env-routing parity.

### 3) Run dedicated routing example

```bash
cd /Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/tests/multi-environment-alert-routing
terraform init
terraform validate
```

Expected result: configuration validates successfully and includes:
- `env` matcher-based notification policies
- default fallback `contact_point` for unmatched alerts
- no changes required to `tests/base`

### 4) Verify README guidance

Confirm root `README.md` includes:
- upgrade intent (onprem module parity)
- dedicated test/example path reference
- matcher-based routing example in AWS wrapper context

### 5) Manual behavior check (optional)

In the example config:
- alerts with `env=dev|stage|prod` route to environment contact points
- alerts lacking matching `env` route to fallback contact point
