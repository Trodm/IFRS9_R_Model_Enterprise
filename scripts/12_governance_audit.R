library(jsonlite)
library(lubridate)

write_audit_log <- function(event_type, user = Sys.info()[["user"]], details = list()) {
  dir.create("audit", showWarnings = FALSE)
  audit_file <- "audit/model_audit_log.jsonl"

  record <- list(
    timestamp = as.character(now()),
    event_type = event_type,
    user = user,
    model_version = "IFRS9_R_Model_Enterprise_v1.0",
    details = details
  )

  cat(toJSON(record, auto_unbox = TRUE), "\n", file = audit_file, append = TRUE)
}

create_model_governance_pack <- function() {
  dir.create("governance", showWarnings = FALSE)

  governance <- c(
    "# IFRS 9 Model Governance Pack",
    "",
    "## Purpose",
    "This pack documents model ownership, methodology, validation, approvals, limitations, and audit controls.",
    "",
    "## Suitable Institutions",
    "- Banks",
    "- Microfinance institutions",
    "- Insurers",
    "- Retail credit providers",
    "",
    "## Key Controls",
    "- Segregated input, model, validation, and reporting layers",
    "- Institution-specific staging rules",
    "- Scenario-weighted forward-looking ECL",
    "- Account-level audit trail",
    "- Version-controlled assumptions",
    "- Validation and back-testing checks",
    "",
    "## Approval Requirements",
    "- Data owner sign-off",
    "- Model owner sign-off",
    "- Independent validation sign-off",
    "- Finance/reporting sign-off",
    "- Executive/risk committee approval where required"
  )

  writeLines(governance, "governance/IFRS9_Model_Governance_Pack.md")
}
