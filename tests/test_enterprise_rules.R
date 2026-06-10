source("scripts/10_enterprise_config.R")
source("scripts/11_enterprise_staging.R")

test_loans <- tibble::tibble(
  account_id = "A1",
  product_type = "Mortgage",
  days_past_due = 35,
  rating_downgrade = 0,
  restructured = 0,
  default_flag = 0,
  ccf = 0
)

x <- apply_institution_rules(test_loans, "Bank")
x <- apply_enterprise_staging(x)

stopifnot(x$stage == "Stage 2")
message("Enterprise rule test passed.")
