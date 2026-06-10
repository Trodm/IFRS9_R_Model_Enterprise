source("scripts/01_data_import.R")
source("scripts/02_data_cleaning.R")
source("scripts/04_pd_model.R")
source("scripts/05_lgd_model.R")
source("scripts/06_ead_model.R")
source("scripts/08_validation.R")
source("scripts/09_reporting.R")
source("scripts/10_enterprise_config.R")
source("scripts/11_enterprise_staging.R")
source("scripts/12_governance_audit.R")

run_enterprise_ifrs9 <- function(institution_type = "Bank") {
  write_audit_log("MODEL_RUN_STARTED", details = list(institution_type = institution_type))

  data <- import_data()
  loans <- clean_loan_data(data$loans)
  loans <- apply_institution_rules(loans, institution_type)
  loans <- apply_enterprise_staging(loans)

  pd_model <- fit_pd_model(loans)
  saveRDS(pd_model, "models/pd_model.rds")

  loans <- loans |>
    mutate(
      pd_12m = pmin(pmax(predict(pd_model, newdata = loans, type = "response"), minimum_pd), maximum_pd),
      monthly_pd = 1 - (1 - pd_12m)^(1/12),
      pd_lifetime = 1 - (1 - monthly_pd)^remaining_term_months,
      base_pd = if_else(stage == "Stage 1", pd_12m, pd_lifetime),
      ead = calculate_ead(product_type, current_balance, credit_limit, ccf),
      collateral_lgd = calculate_lgd(ead, collateral_value, forced_sale_discount, recovery_cost),
      base_lgd = if_else(collateral_value > 0, collateral_lgd, base_lgd_override),
      df = discount_factor(interest_rate, pmin(remaining_term_months, 12))
    )

  account_scenario <- loans |>
    tidyr::crossing(data$macro |> select(scenario, scenario_weight, pd_multiplier, lgd_multiplier)) |>
    mutate(
      scenario_pd = pmin(base_pd * pd_multiplier, 1),
      scenario_lgd = pmin(base_lgd * lgd_multiplier, 1),
      scenario_ecl = scenario_pd * scenario_lgd * ead * df,
      weighted_ecl = scenario_weight * scenario_ecl
    )

  account_results <- account_scenario |>
    group_by(account_id, customer_id, institution_type, product_type, stage, ead, base_pd, base_lgd, df) |>
    summarise(ecl = sum(weighted_ecl, na.rm = TRUE), .groups = "drop") |>
    mutate(coverage_ratio = if_else(ead > 0, ecl / ead, 0))

  portfolio_summary <- create_portfolio_summary(account_results)
  validation_summary <- validate_ifrs9_results(account_results)

  write_outputs(account_results, portfolio_summary, validation_summary)
  create_model_governance_pack()

  write_audit_log(
    "MODEL_RUN_COMPLETED",
    details = list(
      institution_type = institution_type,
      accounts = nrow(account_results),
      total_exposure = sum(account_results$ead, na.rm = TRUE),
      total_ecl = sum(account_results$ecl, na.rm = TRUE)
    )
  )

  list(
    account_results = account_results,
    portfolio_summary = portfolio_summary,
    validation_summary = validation_summary
  )
}

# Examples:
# bank_result <- run_enterprise_ifrs9("Bank")
# mfi_result <- run_enterprise_ifrs9("Microfinance Institution")
# insurer_result <- run_enterprise_ifrs9("Insurer")
# credit_provider_result <- run_enterprise_ifrs9("Credit Provider")
