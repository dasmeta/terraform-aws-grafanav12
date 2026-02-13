# Moved blocks to help migrate state when modules become conditional
# These blocks handle the transition from always-created modules to conditionally-created modules with count
# Apply these during migration and they can be removed afterward if desired

# Loki bucket migration - from always-created to conditional
moved {
  from = module.loki_bucket
  to   = module.loki_bucket[0]
}

# Tempo bucket migration - from always-created to conditional
moved {
  from = module.tempo_bucket
  to   = module.tempo_bucket[0]
}

# S3 EKS role migration - from always-created to conditional (when loki or tempo enabled)
moved {
  from = module.s3_eks_role
  to   = module.s3_eks_role[0]
}

# Grafana CloudWatch role migration - from always-created to conditional (when grafana enabled)
moved {
  from = module.grafana_cloudwatch_role
  to   = module.grafana_cloudwatch_role[0]
}
