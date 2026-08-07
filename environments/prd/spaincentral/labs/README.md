# Placeholder regional lab

**Not deployable yet.** This folder is a stub so Azure DevOps can resolve a working directory when pipeline `location` is set to this region.

When the regional lab / subscription exists:

1. Replace the placeholder service connection in `pipelines/templates/env-context.yml` (`TODO-<env>-<location>-SC`).
2. Point `tf.backend.*` (or a regional variable group) at state storage for this region.
3. Add real Terraform roots (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `terraform.tfvars.example`) here — mirror the uksouth stack under `environments/<env>/<stack>/`.
4. Fill subscription IDs, CIDRs, and tags for the region.

Until then, queueing a pipeline with this `location` will show a warning banner and fail at Azure auth / missing TF files.
