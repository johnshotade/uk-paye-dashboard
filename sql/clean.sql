-- UK PAYE RTI dashboard: clean and combine regional data
-- Source: ONS/HMRC "Earnings and employment from PAYE RTI, non-seasonally adjusted" (Nov 2026 release)

-- Employees by region: wide -> long, clean dates and numbers
CREATE OR REPLACE TABLE emp_region AS
SELECT * FROM (
  SELECT try_strptime(trim("Date"), '%B %Y')::DATE        AS month,
         trim(replace(region, chr(10), ' '))              AS region,
         TRY_CAST(replace(val, ',', '') AS BIGINT)        AS employees
  FROM (
    UNPIVOT (SELECT * FROM read_csv('data/raw/employees_region.csv',
                                    header = true, all_varchar = true))
    ON COLUMNS(* EXCLUDE ("Date"))
    INTO NAME region VALUE val
  )
) WHERE month IS NOT NULL AND employees IS NOT NULL;

-- Median pay by region: same process
CREATE OR REPLACE TABLE pay_region AS
SELECT * FROM (
  SELECT try_strptime(trim("Date"), '%B %Y')::DATE        AS month,
         trim(replace(region, chr(10), ' '))              AS region,
         TRY_CAST(replace(val, ',', '') AS DOUBLE)        AS median_pay
  FROM (
    UNPIVOT (SELECT * FROM read_csv('data/raw/pay_region.csv',
                                    header = true, all_varchar = true))
    ON COLUMNS(* EXCLUDE ("Date"))
    INTO NAME region VALUE val
  )
) WHERE month IS NOT NULL AND median_pay IS NOT NULL;

-- Join and add year-on-year growth (data is not seasonally adjusted)
CREATE OR REPLACE TABLE region_monthly AS
SELECT e.month, e.region, e.employees, p.median_pay,
       e.employees  / LAG(e.employees, 12)  OVER w - 1 AS employees_yoy,
       p.median_pay / LAG(p.median_pay, 12) OVER w - 1 AS pay_yoy,
       e.month = (SELECT MAX(month) FROM emp_region)   AS is_early_estimate
FROM emp_region e
JOIN pay_region p USING (month, region)
WINDOW w AS (PARTITION BY e.region ORDER BY e.month);

-- Quality checks
SELECT region, MIN(month) AS first, MAX(month) AS last, COUNT(*) AS months
FROM region_monthly GROUP BY region ORDER BY region;

-- Export for Tableau
COPY region_monthly TO 'data/region_monthly.csv' (HEADER);
