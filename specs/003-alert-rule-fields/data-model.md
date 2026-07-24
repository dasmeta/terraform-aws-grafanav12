# Data Model: Alert Rule Field Preservation

## Alert Rule

Custom rule object under `alerts.rules`.

Fields added to the AWS wrapper contract:

- `datasource_type`: Optional string. Grafana datasource plugin type, defaulting to `prometheus`.
- `interval_ms`: Optional number. Grafana query interval in milliseconds, defaulting to `1000`.
- `pending_period`: Optional string. Duration the condition must remain satisfied before firing, defaulting to `0`.
- `condition`: Optional string. Full custom comparison condition on evaluated value `$B`.

## Disk Capacity Alert

Global PVC disk-capacity alert object under `alerts.disk_capacity`.

Fields added to the AWS wrapper contract:

- `enabled`
- `folder_name`
- `group`
- `datasource`
- `datasource_type`
- `namespace`
- `pvc`
- `threshold`
- `pending_period`
- `no_data_state`
- `exec_err_state`
- `interval_ms`
- `function`
- `settings_mode`
- `settings_replaceWith`
- `labels`
- `annotations`

## Compatibility

All fields are optional and use the same defaults as the nested onpremise module. Existing consumers that omit them keep the previous behavior.
