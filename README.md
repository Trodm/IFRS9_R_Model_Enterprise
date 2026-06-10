# IFRS9_R_Model


# Enterprise Upgrade

This version is suitable for banks, microfinance institutions, insurers, retail credit providers, and consumer credit providers.

## Enterprise features added

- Institution-specific configuration
- Product-level PD/LGD/EAD assumptions
- Flexible IFRS 9 staging rules
- Scenario-weighted ECL
- Model governance pack
- Audit logging
- Validation checklist
- Docker deployment
- Render deployment file
- API-ready architecture

## Run enterprise model

```r
source("scripts/run_enterprise.R")

bank_result <- run_enterprise_ifrs9("Bank")
mfi_result <- run_enterprise_ifrs9("Microfinance Institution")
insurer_result <- run_enterprise_ifrs9("Insurer")
credit_provider_result <- run_enterprise_ifrs9("Credit Provider")
```

## Docker deployment

```bash
cd deployment
docker compose up --build
```
