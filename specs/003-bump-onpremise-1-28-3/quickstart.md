# Quickstart: Validate the Dependency Upgrade

From the repository root:

```sh
terraform fmt -check
terraform init -backend=false
terraform validate
```

Expected result: Terraform recognizes `dasmeta/grafana/onpremise` v1.28.3 as the child module. If provider initialization cannot run on the local host, retain the successful static checks and validate on the repository CI runner before release.
