"""
run_sql.py: runs a .sql file against the database and prints the result.
Run:   python run_sql.py sql/01_monthly_revenue.sql
Save:  python run_sql.py sql/01_monthly_revenue.sql --save   (writes a CSV to dashboard/ for Tableau)
"""
import sys
from pathlib import Path

import duckdb
import pandas as pd

ROOT = Path(__file__).resolve().parent
con = duckdb.connect(str(ROOT / "data" / "ecommerce.duckdb"), read_only=True)

path = Path(sys.argv[1])
df = con.execute(path.read_text()).df()

pd.set_option("display.width", 200)
pd.set_option("display.max_columns", 20)
print(df.head(60).to_string(index=False))
print(f"\n{len(df)} rows")

if "--save" in sys.argv:
    out = ROOT / "dashboard" / f"{path.stem}.csv"
    df.to_csv(out, index=False)
    print(f"Saved {out}")
