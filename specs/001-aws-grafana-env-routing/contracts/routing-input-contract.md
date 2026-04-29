## Routing Input Contract (AWS Wrapper Context)

This contract defines the expected input shape for same-cluster environment/namespace alert routing as consumed by `dasmeta/terraform-aws-grafanav12`.

The AWS module passes `alerts` through to wrapped `dasmeta/grafana/onpremise`; therefore compatibility is defined by existing `alerts.notifications` schema rather than a new wrapper field.

### Required Routing Semantics

1. Default fallback is configured with:
   - `alerts.notifications.contact_point`
2. Environment-specific routing is configured with:
   - `alerts.notifications.policies[*].matchers[*]`
3. `env` label is used as the matcher label for environment routing.

### Minimal Contract Example

```hcl
alerts = {
  contact_points = {
    slack = [
      { name = "Slack-dev", webhook_url = var.slack_webhook_url, recipient = "#dev-alerts" },
      { name = "Slack-prod", webhook_url = var.slack_webhook_url, recipient = "#prod-alerts" },
      { name = "ops-fallback", webhook_url = var.slack_webhook_url, recipient = "#ops-alerts" }
    ]
  }

  notifications = {
    contact_point = "ops-fallback"
    policies = [
      {
        contact_point = "Slack-dev"
        matchers = [{ label = "env", match = "=", value = "dev" }]
      },
      {
        contact_point = "Slack-prod"
        matchers = [{ label = "env", match = "=", value = "prod" }]
      }
    ]
  }
}
```

### Compatibility Guarantees

- No new `environment_routing` wrapper field is introduced.
- Existing matcher-based routing remains the canonical interface.
- Base test scenarios are not repurposed by this feature.

### Out of Scope

- Multi-cluster central Grafana routing topologies.
- New notification channel abstractions beyond existing contact points and policies.
