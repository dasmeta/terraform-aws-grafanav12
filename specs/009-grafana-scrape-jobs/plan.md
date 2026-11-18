# Plan

DS-14399: bump the base stack and dashboard pins from 2.0.2 to 2.0.3 together; update version documentation. This is a patch-level wrapper dependency update and adds no provider capability. Verify module initialization, validation and available tests, and compare both pins. Roll back to 2.0.2 if the consumer plan shows unexpected changes. This update does not independently approve a consumer's major wrapper upgrade or production deployment.
