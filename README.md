# UK Payroll Trends 2014–2026

**How has pay and employment changed across UK regions, and how does the North West compare?**

An interactive Tableau dashboard built from official HMRC PAYE Real Time Information (RTI) statistics, with the data cleaned and reshaped in SQL.

**[View the live dashboard on Tableau Public](https://public.tableau.com/app/profile/john.shotade/viz/UKPayrollTrends20142026/UKPayrollTrends)**

[![Dashboard screenshot](https://public.tableau.com/static/images/UK/UKPayrollTrends20142026/UKPayrollTrends/1.png)](https://public.tableau.com/app/profile/john.shotade/viz/UKPayrollTrends20142026/UKPayrollTrends)

---

## Key findings (year to October 2026)

1. **Pay is rising while jobs dip slightly.** UK median monthly pay reached **£2,671**, up **4.5%** on a year earlier, while the number of payrolled employees fell **0.3%** to **30.3 million**.
2. **The North West is growing faster than the UK average, but still earns less.** Pay in the North West rose **4.7%** (4th fastest of 12 regions), yet its median pay (£2,563) is still **£108 a month below** the UK. That gap has widened from £84 in 2014.
3. **London's pay lead has grown, but its growth is now below average.** London's premium over the UK grew from **£325 to £464 a month** between 2014 and 2026, but its pay growth this year (**4.4%**) was below the UK average. Every region saw median pay dip in spring 2020 during the first lockdown, before growth accelerated from 2021.

## Data

- **Source:** ONS / HMRC, *Earnings and employment from Pay As You Earn Real Time Information, non-seasonally adjusted* (November 2026 release)
- **Tables used:** payrolled employees by region (NUTS1) and median monthly pay by region (NUTS1)
- **Coverage:** July 2014 to October 2026, 12 UK regions plus the UK total (1,924 region-month rows)
- **Caveats:** the data is not seasonally adjusted, so growth is measured year on year, not month on month. October 2026 is an early estimate and may be revised.

## Method

| Step | Tool | What it does |
|---|---|---|
| 1. Extract | Excel / Python | Exported the two regional sheets from the ONS workbook to CSV |
| 2. Clean and reshape | SQL (DuckDB) | `UNPIVOT` from wide (one column per region) to long format, parse dates, strip thousands separators |
| 3. Enrich | SQL | Joined employees and pay, added year-on-year growth with `LAG(…, 12)` window functions, and flagged the early estimate |
| 4. Validate | SQL | Checked every region has the same 148 months |
| 5. Visualise | Tableau Public | KPI tiles, trend lines and a ranked bar chart, with a calculated field to highlight the North West against the UK |

The full SQL is in [`sql/clean.sql`](sql/clean.sql).

## Run it yourself

```bash
brew install duckdb
duckdb paye.duckdb < sql/clean.sql   # creates data/region_monthly.csv
```

Then connect Tableau to `data/region_monthly.csv`.

## Project structure

```
data/raw/       source CSVs exported from the ONS workbook
sql/clean.sql   cleaning and transformation SQL (creates data/region_monthly.csv)
```

---

*Built by John Shotade · [LinkedIn](https://www.linkedin.com/in/john-shotade) · [GitHub](https://github.com/johnshotade)*
