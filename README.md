# NMC-Census 2021 Register Rebuild

[OSF badge] [Zenodo DOI badge] [Environment badge] [License badge]

This repository provides disclosure-safe R code for reconstructing the March 2021 extract of the Nursing and Midwifery Council (NMC) Register within the ADR UK NMC–Census 2021 linked dataset. The project is documented on OSF and archived on Zenodo for reproducibility.

---

## Overview

This repository contains the code and minimal supporting documentation for rebuilding the March 2021 NMC Register extract.

The original March 2021 extract contains a shortfall in the number of registrants relative to published NMC workforce statistics. The script identifies records present in the March 2022 extract that should have been present in March 2021, based on registration dates, and appends eligible records to the original 2021 extract.

The rebuilt extract is intended for reproducible analysis of the NMC–Census 2021 linked dataset.

---

## Open science and transparency

This project follows a hybrid open science model:

- OSF: project hub, documentation, and non-disclosive materials.
- Zenodo: versioned, citable archive of the code.
- GitHub: live development repository.

The underlying NMC Register and NMC–Census linked data are restricted-access administrative data and cannot be shared publicly.

---

## Study status

- Code: complete / under active refinement
- Manuscript: in preparation
- Preregistration: not applicable
- Data sharing: not permitted; restricted-access data only

---

## Repository structure

- `nmc_2021_register_rebuild.R` — main rebuild script
- `CITATION.cff` — citation metadata
- `LICENSE` — MIT licence
- `manuscript_status.md` — optional manuscript/project tracking notes

---

## Data access

The analysis uses restricted-access NMC Register and Census 2021 linked administrative data.

These data are not publicly available. Access is subject to approval through the ONS Secure Research Service and relevant governance arrangements.

To reproduce the rebuild, users must:

- obtain authorised access to the required NMC Register extracts;
- run the code within an approved secure research environment;
- adapt file paths and environment-specific settings;
- comply with all disclosure control requirements before exporting outputs.

---

## Software and dependencies

The main script uses R and tidyverse-style data manipulation.

Expected packages include:

- dplyr
- tidyr
- readr
- stringr
- lubridate
- tibble

Additional packages may be required depending on the secure research environment.

---

## Reproducibility

This repository provides the complete analytical logic used to rebuild the March 2021 NMC Register extract.

Full reproducibility requires execution within an approved secure data environment. The code may require minor adaptation because of:

- secure data access constraints;
- environment-specific file paths;
- local object names for the 2021 and 2022 NMC extracts;
- disclosure-control rules governing exported outputs.

---

## Citation

Please cite the archived Zenodo release for the exact version of the code used in analysis.

After release, citation details should appear here.

---

## Authors and affiliation

Michelle Jamieson  
Edinburgh Napier University  
Scottish Centre for Administrative Data Research

---

## Related resources

- OSF project hub: https://osf.io/5kfn4/
- Zenodo archive: add DOI after first release
- Related analysis repository: add link if relevant

---

## License

This repository is licensed under the MIT License.
