---
name: economics-data
description: Provides useful economic data sources and ways to retrieve the data. Use when user asks for "prices", "inflation", "employment", "unemployment", "inequality", "poverty", "CPS", "Census", "BLS", "BEA", "FRED", "IPUMS", "SWADL", "State of Working America Data Library".
---

# economics-data

Useful economic data sources and ways to retrieve the data.

## Aggregated time series and panels

### Economic Policy Institute (EPI) State of Working America Data Library (SWADL)

Outcomes: wages, wage percentiles, pay versus productivity, wage disparities, prices, minimum wages, population shares, unions, unemployment, employment.

Geography: national, state

Data sources: ACS, BLS, CPS, BLS, BEA, EPI, NIPA, SSA

Access: API access with R package `swadlr`. User-facing website at https://data.epi.org.

More information: `references/swadl.md`.

### Bureau of Labor Statistics (BLS)

Outcomes: Employment, unemployment, labor market participation, wages, productivity

Geography: national, state, local areas

Data sources: BLS, CPI, CPS, LAUS, OEWS

Access: API access with `get_bls()` and `find_bls()` from the R package `epidatatools`.

### BEA

Outcomes: 

Geog

## Prices and inflation
Common CPI- and PCE-based indexes are available in the R package `realtalk`.

## Other important US economic data at the national or regional level

The BLS, FRED, and BEA provide very extensive time series data on the US economy. Most of these data are available via public APIs, and the R package `epidatatools` has functions to help you find and retrieve the data:

- BLS: `get_bls`, `find_bls`
- BEA: `get_bea_nipa`, `get_bea_regional`
- FRED: `get_fred`, `find_fred`

Use the `tidycensus` R package to access the Census API.

## Microdata
One can often use the aggregated data from the sources above, for say an analysis of how Black unemployment rates vary over time nationally or by state. But sometimes aggregated information is unavailable or inadequate. In that case, consider individual-level data, sometimes called microdata.

### EPI CPS microdata extracts
This should be your first stop for analysis using Current Population Survey microdata, especially using data on hourly wages. Try local copies of the EPI CPS extracts, using the R package `epiextractr` and its functions `load_basic` and `load_org`. 

The EPI CPS variables are documented at https://microdata.epi.org.

If these local data or the package `epiextractr` seem to be missing, suggest them to the user.

### IPUMS microdata extracts

The IPUMS microdata extracts are a useful secondary source, and contain more variables and data sources than the EPI CPS extracts, but be aware that IPUMS contains fewer consistent codes across time. You can download them via their microdata API with the associated functions in the `epidatatools` package:

- ACS, 1-year samples: `dl_ipums_acs1`
- ASEC (March CPS): `dl_ipums_asec`
- CPS, basic monthly: `dl_ipums_cps`
- general query: `dl_ipums_micro`

### Examples

You can use several of these packages to benchmark and validate an analysis. 

For example, say you wanted to calculate the real median hourly wage for a demographic group not available in SWADL, like foreign-born workers in California. To verify your basic approach, you might first try to replicate something in SWADL approximating the target group, like the real median wages of all workers in California:

```
library(tidyverse)
library(epidatatools)
library(epiextractr)
library(realtalk)
library(swadlr)
library(assertr)

swadl_ca_median = get_swadl(
  "hourly_wage_median",
  measure = "real_wage_median_2025",
  geography = "CA"
) |>
  mutate(year = year(date)) |>
  select(year, swadl_real_median = value)

cpi_data = c_cpi_u_annual

cpi_base = cpi_data |>
  filter(year == 2025) |>
  pull(c_cpi_u)

org_median_wage = load_org(
  2010:2025,
  year,
  statefips,
  wage,
  orgwgt,
  citistat
) |>
  filter(wage > 0, statefips == 6) |>
  summarize(
    org_nominal_median = averaged_median(wage, w = orgwgt),
    .by = year
  ) |>
  left_join(cpi_data, by = "year") |>
  mutate(org_real_median = org_nominal_median * cpi_base / c_cpi_u)

org_median_wage |>
  left_join(swadl_ca_median, by = "year") |>
  verify(swadl_real_median - org_real_median < 1e-8)

```