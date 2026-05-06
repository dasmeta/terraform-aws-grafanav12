# Contract: S3 Public Access Inputs

## Loki Input Contract

- Consumer path: `loki_stack.send_logs_s3.ignore_public_acls`
- Type: `bool`
- Required: No
- Default: `true`
- Effect: Passed to `module.loki_bucket.ignore_public_acls`

## Tempo Input Contract

- Consumer path: `tempo.ignore_public_acls`
- Type: `bool`
- Required: No
- Default: `true`
- Effect: Passed to `module.tempo_bucket.ignore_public_acls`

## Compatibility Rules

- Existing callers may omit both fields.
- Existing Loki and Tempo object structure remains intact.
- No other S3 public-access-block fields change behavior in this feature.
