library(tidyverse)
library(data.table)

load_enterprise_config <- function(
  institution_config_file = "config/institution_config.csv",
  product_config_file = "config/product_config.csv"
) {
  list(
    institution_config = fread(institution_config_file) |> as_tibble(),
    product_config = fread(product_config_file) |> as_tibble()
  )
}

apply_institution_rules <- function(loans, institution_type = "Bank") {
  cfg <- load_enterprise_config()

  inst <- cfg$institution_config |>
    filter(.data$institution_type == !!institution_type) |>
    slice(1)

  prod <- cfg$product_config |>
    filter(.data$institution_type == !!institution_type)

  loans |>
    left_join(prod, by = "product_type") |>
    mutate(
      institution_type = institution_type,
      stage2_dpd = inst$stage2_dpd,
      stage3_dpd = inst$stage3_dpd,
      ccf = if_else(is.na(ccf) | ccf == 0, coalesce(default_ccf, 0), ccf),
      base_lgd_override = coalesce(default_lgd, 0.45),
      minimum_pd = coalesce(minimum_pd, 0.0001),
      maximum_pd = coalesce(maximum_pd, 0.9999)
    )
}
