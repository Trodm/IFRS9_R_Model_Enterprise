assign_enterprise_stage <- function(days_past_due, rating_downgrade, restructured,
                                    default_flag, stage2_dpd, stage3_dpd,
                                    forbearance_flag = 0, watchlist_flag = 0) {
  case_when(
    default_flag == 1 | days_past_due >= stage3_dpd ~ "Stage 3",
    days_past_due >= stage2_dpd | rating_downgrade == 1 |
      restructured == 1 | forbearance_flag == 1 | watchlist_flag == 1 ~ "Stage 2",
    TRUE ~ "Stage 1"
  )
}

apply_enterprise_staging <- function(loans) {
  loans |>
    mutate(
      forbearance_flag = coalesce(forbearance_flag, 0),
      watchlist_flag = coalesce(watchlist_flag, 0),
      stage = assign_enterprise_stage(
        days_past_due, rating_downgrade, restructured,
        default_flag, stage2_dpd, stage3_dpd,
        forbearance_flag, watchlist_flag
      )
    )
}
