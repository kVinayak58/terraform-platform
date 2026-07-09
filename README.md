# terraform-platform

AWS platform infrastructure for ShopEasy.

> Standalone Git repository. Lives at `repos/terraform-platform/` in the platform workspace.

## Layout

```
terraform-platform/
├── bootstrap/              # Step 1: S3 + DynamoDB remote state (local backend)
├── modules/
│   ├── ecr/                # Step 2: registries + lifecycle (rollback window)
│   ├── iam-jenkins/        # Step 2: OIDC CI/CD roles (no long-lived keys)
│   ├── secrets/            # Step 2: Secrets Manager placeholders
│   ├── cloudwatch/         # Step 2: log groups + error metric filters
│   └── artifacts/          # Step 2: S3 for SBOM + promotion/rollback history
├── environments/
│   └── shared/             # Step 2: ECR, IAM, secrets, logs (one state file)
└── README.md
```

Environment-specific EKS/VPC stacks (`environments/dev`, etc.) arrive in **Step 3**.

## Apply order

### 1. Bootstrap remote state (once)

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform apply
```

Save outputs: `state_bucket_name`, `lock_table_name`, `kms_key_arn`.

### 2. Shared platform layer

```bash
cd environments/shared
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl
# Edit backend.hcl with bootstrap outputs (add kms_key_id)

terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

### 3. Populate secrets (manual, before Jenkins runs)

Terraform creates secret **containers** only — not values.

```bash
aws secretsmanager put-secret-value \
  --secret-id shopeasy/jenkins/sonarqube-token \
  --secret-string "YOUR_SONAR_TOKEN"

aws secretsmanager put-secret-value \
  --secret-id shopeasy/dev/db-credentials \
  --secret-string '{"username":"admin","password":"CHANGE_ME","host":"postgres","database":"shopeasy"}'
```

Repeat for `qa`, `uat`, `prod`.

## Step 2 outputs (interview talking points)

| Output | Purpose |
|--------|---------|
| `ecr_repository_urls` | Jenkins pushes images here |
| `jenkins_ci_role_arn` | OIDC-assumed role for build/push/sign |
| `jenkins_cd_role_arn` | Pull-only + read promotion manifests for deploy/rollback |
| `artifacts_bucket_name` | SBOM + promotion history for Layer 2 rollback |
| `db_secret_names` | External Secrets / CSI driver will mount these in Step 3 |

## Rollback support (ADR-003)

- **ECR lifecycle** keeps last 30 tagged images per service
- **S3 versioning** on artifacts bucket preserves promotion manifest history
- **Jenkins CD role** can read S3 for digest re-deploy without ECR push permission

## Next step

See `docs/platform/ROADMAP.md` — **Step 3**: VPC + EKS + namespaces.
