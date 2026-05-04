# NMC-Census 2021 Register Rebuild

[![OSF](https://img.shields.io/badge/OSF-10.17605%2FOSF.IO%2F5KFN4-blue)](https://doi.org/10.17605/OSF.IO/5KFN4)
[![DOI](https://zenodo.org/badge/1228761783.svg)](https://doi.org/10.5281/zenodo.20023960)
[![Environment](https://img.shields.io/badge/environment-ONS%20SRS-red)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

Disclosure-safe R code for rebuilding the March 2021 Nursing and Midwifery Council (NMC) Register extract within the ADR UK NMC–Census 2021 linked dataset (https://doi.org/10.57906/04mq-bj53).

## Overview

This repository contains reproducible R code for reconstructing the March 2021 extract of the NMC Register.

The original March 2021 extract contains a shortfall in the number of registrants relative to published NMC workforce statistics. The script identifies records present in the March 2022 extract that are expected to have been present in March 2021, based on registration dates, and appends eligible records to the original 2021 extract.

The rebuilt 2021 register is intended to support reproducible analysis of the ADR UK NMC–Census 2021 linked dataset.

## What the code does

The script:

1. checks the size of the original March 2021 NMC Register extract;
2. identifies registrants present in March 2022 but absent from the original March 2021 extract;
3. restricts candidate recovered records to registrants whose registration dates indicate that they should already have been present by March 2021;
4. appends eligible recovered records to the original 2021 extract;
5. deduplicates to one record per registrant identifier;
6. compares the original, recovered, and rebuilt counts;
7. produces disclosure-safe summary outputs.

## Open science and transparency

This project uses a three-part open science structure:

- **OSF**: project hub, documentation, and non-disclosive materials.
- **GitHub**: live development repository.
- **Zenodo**: fixed, archived, DOI-minted code release.

Zenodo DOI: https://doi.org/10.5281/zenodo.20023960  
OSF DOI: https://doi.org/10.17605/OSF.IO/5KFN4

## Data access

No individual-level NMC Register, Census, or linked administrative data are included in this repository.

The underlying NMC Register and NMC–Census 2021 linked data are restricted-access administrative data. Access is available only to approved researchers through the ONS Secure Research Service under the relevant governance arrangements.

To reproduce the rebuild, users must:

- obtain authorised access to the relevant NMC Register extracts;
- run the code within an approved secure research environment;
- adapt file paths and object names to their local secure environment;
- comply with all applicable disclosure control requirements before exporting outputs.

## Repository contents

- `nmc_2021_register_rebuild.R` — main R script for rebuilding the March 2021 extract.
- `CITATION.cff` — citation metadata.
- `LICENSE` — MIT licence.
- `manuscript_status.md` — brief project/manuscript status note.
- `.zenodo.json` — Zenodo metadata used for DOI-minted releases.
- `.gitignore` — exclusion rules to prevent restricted data and local files being committed.

## Citation

Please cite both the archived Zenodo software release and the OSF project record when using this repository.

The **Zenodo DOI** should be used when citing the exact version of the code used in analysis. The **OSF DOI** should be used when citing the broader project documentation and open research record.

### Software citation

Jamieson M & Atherton I. NMC-Census 2021 Register Rebuild [Software]. Zenodo; 2026. doi:10.5281/zenodo.20023960

```bibtex
@software{jamieson_atherton_2026_nmc_rebuild,
  author    = {Jamieson, Michelle and Atherton, Iain},
  title     = {NMC-Census 2021 Register Rebuild},
  year      = {2026},
  publisher = {Zenodo},
  version   = {1.0.0},
  doi       = {10.5281/zenodo.20023960},
  url       = {https://doi.org/10.5281/zenodo.20023960}
}

## Software requirements

The script is written in R and uses tidyverse-style data manipulation.

Expected packages include:

```r
dplyr
tidyr
readr
stringr
lubridate
tibble
