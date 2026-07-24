# Research: Alert Rule Field Preservation

## Decision: Mirror downstream onpremise alert fields in the AWS wrapper

The AWS module calls `dasmeta/grafana/onpremise` and forwards `alerts = var.alerts`. The nested onpremise module already accepts `alerts.rules[*].datasource_type`, `interval_ms`, `pending_period`, `condition`, and `alerts.disk_capacity`. The AWS wrapper should expose these same optional fields so consumers can pass valid downstream alert settings through the wrapper.

## Rationale

- Keeping the wrapper schema narrower than the nested module creates a hidden contract mismatch.
- Optional fields preserve existing consumer behavior.
- The wrapper should not translate or infer Loki versus Prometheus query semantics; operators must set `datasource_type` based on the query datasource.

## Alternatives Considered

- **Change only downstream consumer YAML**: Rejected because unsupported wrapper schema fields can still be lost or rejected before reaching the nested module.
- **Make `alerts` type `any`**: Rejected because it removes useful validation for the entire alert contract.
- **Add a special-case Loki input**: Rejected because the nested module already has a general field for datasource type.
