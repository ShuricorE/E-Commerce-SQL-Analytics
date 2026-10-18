"""
load_data.py: loads the 9 Olist CSV files into one DuckDB database.
Run:  python load_data.py
"""
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parent
RAW = ROOT / "data" / "raw"
DB = ROOT / "data" / "ecommerce.duckdb"

# short table name -> CSV file
TABLES = {
    "orders": "olist_orders_dataset.csv",
    "customers": "olist_customers_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "payments": "olist_order_payments_dataset.csv",
    "reviews": "olist_order_reviews_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "category_translation": "product_category_name_translation.csv",
}

con = duckdb.connect(str(DB))
for name, file in TABLES.items():
    # read_csv_auto works out column types (numbers, dates, text) by itself
    con.execute(f"CREATE OR REPLACE TABLE {name} AS "
                f"SELECT * FROM read_csv_auto('{RAW / file}', header=True)")
    rows = con.execute(f"SELECT COUNT(*) FROM {name}").fetchone()[0]
    print(f"{name:<22}{rows:>10,} rows")
con.close()
print(f"\nSaved database to {DB}")
