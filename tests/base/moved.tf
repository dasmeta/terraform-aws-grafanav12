# # # Moved blocks to help migrate state from the old repository to this new one
# # # These blocks should be applied during the migration process and can be removed afterward

# # # Main module migration - old structure had sub-modules with [0] indices, new structure is unified
# moved {
#   from = module.this.module.grafana[0]
#   to   = module.this.module.this.module.grafana[0]
# }

# moved {
#   from = module.this.module.prometheus[0]
#   to   = module.this.module.this.module.prometheus[0]
# }

# moved {
#   from = module.this.module.loki[0]
#   to   = module.this.module.this.module.loki[0]
# }

# moved {
#   from = module.this.module.tempo[0]
#   to   = module.this.module.this.module.tempo[0]
# }

# # # S3 bucket migrations - these are nested within the sub-modules in the old structure
# # moved {
# #   from = module.this.module.loki[0].module.loki_bucket.module.bucket
# #   to   = module.this.module.this.module.loki_bucket
# # }

# # moved {
# #   from = module.this.module.tempo[0].module.tempo_bucket
# #   to   = module.this.module.this.module.tempo_bucket
# # }

# # # IAM role migrations - these are nested within the sub-modules in the old structure
# moved {
#   from = module.this.module.loki[0].module.loki_iam_eks_role[0]
#   to   = module.this.module.s3_eks_role
# }

# # # moved {
# # #   from = module.this.module.tempo[0].module.tempo_iam_eks_role[0]
# # #   to   = module.this.module.s3_eks_role
# # # }

# # # Note: There doesn't seem to be a separate grafana_cloudwatch_role in the old structure
# # # You may need to create this or it might be handled differently

# # # Random string migration - this is nested within the loki sub-module
# # # moved {
# # #   from = module.this.module.loki[0].random_string.random
# # #   to   = module.this.module.this.random_string.random
# # # }

# # # Data source migrations - these are nested within the sub-modules in the old structure
# # moved {
# #   from = module.this.module.grafana[0].data.aws_region.current
# #   to   = module.this.data.aws_region.current
# # }

# # moved {
# #   from = module.this.module.grafana[0].data.aws_caller_identity.current
# #   to   = module.this.data.aws_caller_identity.current
# # }

# # moved {
# #   from = module.this.module.grafana[0].data.aws_eks_cluster.this
# #   to   = module.this.data.aws_eks_cluster.this
# # }

# moved {
#   from = module.this.module.loki[0].module.loki_bucket.module.bucket.aws_s3_bucket.this[0]
#   to = module.this.module.this.module.loki_bucket.module.bucket.aws_s3_bucket.this[0]
# }

# moved {
#   from = module.this.module.tempo[0].module.tempo_bucket.module.bucket.aws_s3_bucket.this[0]
#   to = module.this.module.tempo_bucket.aws_s3_bucket.this[0]
# }
