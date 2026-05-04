################################################################################
# NMC Register 2021 Rebuild to Match Expected Workforce Totals                 #
#                                                                              #
# Version: 1.0.0                                                               #
#                                                                              #
# The March 2021 NMC register extract contains a shortfall of                  #
# registrants relative to published NMC workforce reports. This script         #
# demonstrates the problem, reconstructs the 2021 register using the 2022      #
# extract, and verifies the fix.                                               #
#                                                                              #
# Dataset:                                                                     #
#   NMC Register linked to Census 2021 England & Wales                         #
#   ONS Secure Researcher Service                                              #
#   https://doi.org/10.57906/04mq-bj53                                         #
#                                                                              #
# Assumes:                                                                     #
#   nmc_2021 and nmc_2022 are already loaded as R data frames with             #
#   demographic_entry_id and registration_date present.                        #
#                                                                              #
# Output:                                                                      #
#   nmc_2021_rebuilt                                                           #
#                                                                              #
################################################################################


# ==============================================================================
# LOAD LIBRARIES
# ==============================================================================

library(dplyr)
library(tibble)
library(readr)


# ==============================================================================
# CONSTANTS
# ==============================================================================

# Snapshot date used to identify records that should have been present in the
# March 2021 extract.
snapshot_date <- as.Date("2021-03-31")

# Canonical set of NMC register variables carried into the rebuilt dataset.
# any_of() means absent columns are skipped rather than causing an error.
cols_nmc <- c(
  "demographic_entry_id",
  "registration_date",
  "registration_type",
  "field_of_nursing",
  "residence_oa01",
  "residence_oa11",
  "residence_oa21",
  "residence_country",
  "training_country",
  "age_group",
  "gender",
  "disability",
  "religion_and_belief",
  "sexual_orientation",
  "ethnicity",
  "gender_identity",
  "employment_type",
  "employer_oa01",
  "employer_oa11",
  "employeroa21",
  "scope_of_practice",
  "work_setting",
  "post_reg_qualifications",
  "leaving_date",
  "meets_validationrequirements",
  "year"
)


# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

# Count total rows in a local R data frame.
count_rows <- function(x) {
  nrow(x)
}

# Count distinct registrants in a local R data frame.
count_ids <- function(x) {
  dplyr::n_distinct(x$demographic_entry_id)
}

# Standardise an NMC extract: retain canonical columns and cast key variables.
standardise_nmc <- function(x) {
  x %>%
    transmute(
      across(any_of(cols_nmc), ~ .x),
      demographic_entry_id = as.character(demographic_entry_id),
      registration_date    = as.Date(registration_date)
    )
}


# ==============================================================================
# SECTION 1 — DEMONSTRATE THE PROBLEM
# ==============================================================================
# Compare raw row counts and distinct registrant counts side by side for 2021
# and 2022.
#
# The 2021 distinct registrant count should broadly match published NMC workforce
# 2021 totals but falls short. The comparison with 2022 helps demonstrate that
# the shortfall is due to missing records in the supplied 2021 extract rather
# than a real workforce decrease.
# ==============================================================================

problem_counts <- tibble(
  metric = c(
    "raw rows",
    "distinct registrants",
    "distinct registrants — England & Wales"
  ),
  n_2021 = c(
    count_rows(nmc_2021),
    count_ids(nmc_2021),
    nmc_2021 %>%
      filter(residence_country %in% c("England", "Wales")) %>%
      count_ids()
  ),
  n_2022 = c(
    count_rows(nmc_2022),
    count_ids(nmc_2022),
    nmc_2022 %>%
      filter(residence_country %in% c("England", "Wales")) %>%
      count_ids()
  )
)

print(problem_counts)


# ==============================================================================
# SECTION 2 — STANDARDISE AND DEDUPLICATE
# ==============================================================================

nmc_2021_clean <- standardise_nmc(nmc_2021)
nmc_2022_clean <- standardise_nmc(nmc_2022)

# Deduplicate 2022 to one row per registrant.
#
# Raw extracts can contain multiple rows per registrant. This is a structural
# feature of the data, not necessarily an error.
#
# arrange() before distinct() makes row selection deterministic. Which row is
# retained is arbitrary with respect to variable values. This does not affect
# the rebuild counts, but downstream users should be cautious when using fields
# such as registration_type or field_of_nursing.
nmc_2022_dedup <- nmc_2022_clean %>%
  arrange(demographic_entry_id) %>%
  distinct(demographic_entry_id, .keep_all = TRUE)


# ==============================================================================
# SECTION 3 — IDENTIFY AND RECOVER MISSING RECORDS
# ==============================================================================
# A registrant is eligible for recovery if all of the following hold:
#
#   1. They appear in the 2022 extract after deduplication.
#   2. Their registration_date is non-missing and on or before 31 March 2021,
#      indicating that they had entered the register by the 2021 snapshot date.
#   3. They are absent from the supplied 2021 extract.
#
# Because these records appear in the 2022 extract and had a registration date
# on or before the 2021 snapshot date, they are treated as records that should
# have been present in the March 2021 extract unless already included.
#
# The anti_join uses nmc_2021_clean before deduplication on the right-hand side,
# so any registrant present under any row in 2021 is correctly excluded.
# ==============================================================================

nmc_2022_eligible <- nmc_2022_dedup %>%
  filter(
    !is.na(registration_date),
    registration_date <= snapshot_date
  )

nmc_2021_recovered <- nmc_2022_eligible %>%
  anti_join(
    nmc_2021_clean %>% distinct(demographic_entry_id),
    by = "demographic_entry_id"
  ) %>%
  mutate(
    year            = 2021L,
    backfill_flag   = 1L,
    backfill_reason = "from2022_registrationdate<=2021-03-31"
  )

# Warn if no records were recovered. This may indicate that the upstream 2021
# extract has been corrected, or that the eligibility filter is too strict.
if (count_rows(nmc_2021_recovered) == 0) {
  warning(
    "nmc_2021_recovered is empty: no records were identified for recovery. ",
    "Verify that nmc_2022 contains registrants with registration_date <= ",
    snapshot_date, " who are absent from nmc_2021."
  )
}

# Tag original 2021 records and align types before union.
# Assigned to a new object so nmc_2021_clean remains unmodified and the script
# is safe to re-run interactively.
nmc_2021_labelled <- nmc_2021_clean %>%
  mutate(
    year            = as.integer(year),
    backfill_flag   = 0L,
    backfill_reason = NA_character_
  )

nmc_2021_recovered <- nmc_2021_recovered %>%
  mutate(
    year            = as.integer(year),
    backfill_flag   = as.integer(backfill_flag),
    backfill_reason = as.character(backfill_reason)
  )


# ==============================================================================
# SECTION 4 — BUILD THE REBUILT 2021 REGISTER
# ==============================================================================
# Union all original 2021 rows with the recovered records, then deduplicate to
# one row per demographic_entry_id.
#
# Original 2021 rows take precedence because nmc_2021_labelled is placed first
# in the union.
# ==============================================================================

nmc_2021_rebuilt <- nmc_2021_labelled %>%
  union_all(nmc_2021_recovered) %>%
  distinct(demographic_entry_id, .keep_all = TRUE)


# ==============================================================================
# SECTION 5 — VERIFY THE FIX
# ==============================================================================

# Deduplicate original 2021 to one row per registrant for person-level checks.
nmc_2021_dedup <- nmc_2021_labelled %>%
  distinct(demographic_entry_id, .keep_all = TRUE)

# Print counts to confirm arithmetic.
qc_counts <- tibble(
  n_original_distinct_registrants = count_rows(nmc_2021_dedup),
  n_recovered_distinct_registrants = count_rows(nmc_2021_recovered),
  n_rebuilt_distinct_registrants = count_rows(nmc_2021_rebuilt)
)

print(qc_counts)

# Expected distinct-person arithmetic:
# approximately 726,570 + 6,265 = 732,835, subject to disclosure rounding and
# any upstream changes to the supplied extract.

# Formally verify rebuilt count equals distinct original IDs plus recovered IDs.
recovered_ids <- nmc_2022_dedup %>%
  filter(
    !is.na(registration_date),
    registration_date <= snapshot_date
  ) %>%
  select(demographic_entry_id) %>%
  anti_join(
    nmc_2021_dedup %>% select(demographic_entry_id),
    by = "demographic_entry_id"
  ) %>%
  distinct()

n_ids_original  <- count_rows(nmc_2021_dedup)
n_ids_recovered <- count_rows(recovered_ids)
n_ids_rebuilt   <- count_rows(nmc_2021_rebuilt)

stopifnot(
  "Rebuilt count does not equal original + recovered — check for upstream table changes or duplicate IDs" =
    n_ids_rebuilt == n_ids_original + n_ids_recovered
)

# Check no duplicate IDs remain in the rebuilt register.
n_duplicate_ids <- nmc_2021_rebuilt %>%
  count(demographic_entry_id, name = "n_rows") %>%
  filter(n_rows > 1) %>%
  nrow()

stopifnot(
  "Duplicate demographic_entry_id values found in nmc_2021_rebuilt" =
    n_duplicate_ids == 0
)

# Save QC results to file for audit trail.
qc_log <- tibble(
  check = c(
    "rebuilt == original + recovered",
    "no duplicate IDs in rebuilt register"
  ),
  result = c(
    paste0(n_ids_rebuilt, " == ", n_ids_original, " + ", n_ids_recovered),
    paste0(n_duplicate_ids, " duplicate IDs found")
  ),
  passed = c(
    n_ids_rebuilt == n_ids_original + n_ids_recovered,
    n_duplicate_ids == 0
  ),
  run_at = Sys.time()
)

print(qc_log)

write_csv(qc_log, "nmc_2021_rebuild_qc_log.csv", na = "NA")


# ==============================================================================
# SECTION 6 — REBUILD COUNTS TABLE
# ==============================================================================
# Counts table for documenting the 2021 extract correction.
#
# Counts are rounded to the nearest 5. Values below 10 are suppressed in line
# with standard disclosure-control practice.
#
# This is not the full NMC-Census attrition table. It documents the register
# rebuild only.
# ==============================================================================

n_rebuilt_all <- count_rows(nmc_2021_rebuilt)

n_rebuilt_engwales <- nmc_2021_rebuilt %>%
  filter(residence_country %in% c("England", "Wales")) %>%
  count_rows()

counts_tbl <- tibble(
  metric = c(
    "NMC 2021 raw rows",
    "NMC 2022 raw rows",
    "NMC 2021 distinct registrants",
    "NMC 2022 distinct registrants",
    "NMC 2021 rebuilt distinct registrants",
    "NMC 2021 rebuilt distinct registrants — England & Wales"
  ),
  n_unrounded = c(
    count_rows(nmc_2021),
    count_rows(nmc_2022),
    count_ids(nmc_2021),
    count_ids(nmc_2022),
    n_rebuilt_all,
    n_rebuilt_engwales
  )
) %>%
  mutate(
    n_rounded = 5 * round(n_unrounded / 5),
    n = if_else(n_rounded < 10, "<10", as.character(n_rounded))
  ) %>%
  select(metric, n)

print(counts_tbl, n = Inf, width = Inf)

write_csv(counts_tbl, "nmc_2021_rebuild_counts.csv", na = "NA")

