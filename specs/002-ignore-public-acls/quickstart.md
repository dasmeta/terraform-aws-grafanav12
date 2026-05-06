# Quickstart: Ignore Public ACLs Support

## Goal

Verify that the module accepts the new `ignore_public_acls` inputs for Loki and Tempo and that documentation/examples show where to set them.

## Example Input Shape

```hcl
tempo = {
  enabled             = true
  ignore_public_acls  = true
}

loki_stack = {
  enabled = true
  send_logs_s3 = {
    ignore_public_acls = true
  }
}
```

## Validation Commands

From repository root:

```bash
terraform fmt -check
terraform validate
```

From example scenarios:

```bash
cd tests/base && terraform validate
cd ../base-with-victoria-metrics && terraform validate
```

## Documentation Check

Confirm root `README.md` includes:

- the Loki input path `loki_stack.send_logs_s3.ignore_public_acls`
- the Tempo input path `tempo.ignore_public_acls`
- an example snippet showing both values
