# Data Model: Ignore Public ACLs Support

## Entity: LokiBucketSettings

- **Location**: `var.loki_stack.send_logs_s3`
- **Fields**:
  - `enable` (bool, existing)
  - `bucket_name` (string, existing)
  - `aws_role_arn` (string, existing)
  - `ignore_public_acls` (bool, new)
- **Validation/Rules**:
  - Must remain optional.
  - Must not change the required/optional contract of existing fields.
  - Must map directly to the `loki_bucket` child module input.

## Entity: TempoBucketSettings

- **Location**: `var.tempo`
- **Fields**:
  - `enabled` (bool, existing)
  - `bucket_name` (string, existing)
  - `ignore_public_acls` (bool, new)
- **Validation/Rules**:
  - Must remain optional.
  - Must not change existing Tempo storage configuration requirements.
  - Must map directly to the `tempo_bucket` child module input.

## Entity: PublicAccessBlockConfiguration

- **Location**: `module.loki_bucket` and `module.tempo_bucket`
- **Fields in scope for this feature**:
  - `block_public_acls` (existing)
  - `block_public_policy` (existing)
  - `restrict_public_buckets` (existing)
  - `ignore_public_acls` (newly wired)
- **Validation/Rules**:
  - Existing flags remain unchanged.
  - `ignore_public_acls` is additive and must not disturb unrelated bucket settings.
