# Quickstart: Alert Rule Field Preservation

Validate from the module repository root:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform -chdir=tests/base-with-victoria-metrics init -backend=false
terraform -chdir=tests/base-with-victoria-metrics validate
```

The VictoriaMetrics fixture includes:

- A metric alert using `datasource = "victoriametrics"` and `datasource_type = "prometheus"`.
- A Loki alert using `datasource = "loki"` and `datasource_type = "loki"`.
- A `disk_capacity` configuration using `datasource = "victoriametrics"`.
