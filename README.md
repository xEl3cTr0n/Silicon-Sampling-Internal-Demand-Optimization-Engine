# Silicon-Sampling-Internal-Demand-Optimization-Engine
Understanding Supply Chain, SQL Analytics, and Cost Optimization
# NVIDIA Internal Sampling & Demand Optimization (SQL)

## Project Overview
This project simulates NVIDIA’s internal hardware supply chain and tracks high-value asset demand across global departments and individual requestors.

## Key Features
- Relational schema for Departments (with regions), Employees (requestors), Products, and Hardware Requests.
- Cost analysis by department and product family.
- Stagnant inventory report for fulfilled requests held longer than 60 days (fixed report date for stable snapshots; switch to `DATE('now')` for live values).

## Run In VSCode (Visual Table Output)

Recommended setup using the `SQLite` VSCode extension by `alexcvzz`.

1. Install the `SQLite` extension in VSCode.
2. Open `nvidia_ops.db`.
3. Open `nvidia_ops_reset.sql`.
4. Highlight a query and run `SQLite: Run Query` (right-click or Command Palette).
5. Results appear in a table/grid panel in VSCode.

## Run In Terminal (Text Output)

```bash
sqlite3 nvidia_ops.db <<'SQL' > /tmp/sql_results.txt
.headers on
.mode column
.read nvidia_ops_reset.sql
SQL
```

View the output:
```bash
cat /tmp/sql_results.txt
```

## Files

`nvidia_ops.sql` is the original script.  
`nvidia_ops_reset.sql` is rerun-safe and drops tables before rebuilding.  
`results.md` is a static sample output for GitHub viewing.

## Notes

- Running queries in VSCode does not update `results.md` automatically.
- The database file is ignored by git via `.gitignore` (`*.db`).
