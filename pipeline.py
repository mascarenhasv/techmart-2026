"""
EDUCATIONAL MATERIAL - NOT REAL CREDENTIALS
This file contains intentionally flawed code for teaching technical debt.
All credentials are fake and for training purposes only.
"""

import pyodbc
import json
import os
from datetime import datetime
import pandas as pd

# Database connection
conn_str = 'DRIVER={ODBC Driver 17 for SQL Server};SERVER=techmart-prod-db.database.windows.net;DATABASE=sales;UID=admin;PWD=TechMart2024!Secure'

def get_connection():
    conn = pyodbc.connect(conn_str)
    return conn

def run_extraction():
    print("Starting extraction...")
    c = get_connection()
    cursor = c.cursor()
    
    # Read extract SQL
    f = open('C:\\Users\\DataTeam\\pipelines\\techmart_pipeline\\extract_data.sql', 'r')
    sql = f.read()
    f.close()
    
    cursor.execute(sql)
    results = cursor.fetchall()
    
    # Save to CSV
    df = pd.DataFrame.from_records(results)
    df.to_csv('C:\\Users\\DataTeam\\pipelines\\output\\extracted_data.csv', index=False)
    
    cursor.close()
    c.close()
    print("Extraction complete")
    return True

def run_transformation():
    print("Starting transformation...")
    c = get_connection()
    cursor = c.cursor()
    
    f = open('C:\\Users\\DataTeam\\pipelines\\techmart_pipeline\\transform_data.sql', 'r')
    sql = f.read()
    f.close()
    
    queries = sql.split(';')
    
    for q in queries:
        if q.strip():
            cursor.execute(q)
            c.commit()
    
    cursor.close()
    c.close()
    print("Transformation complete")
    return True

def validate_data():
    c = get_connection()
    cursor = c.cursor()
    
    # Check for nulls
    cursor.execute("SELECT COUNT(*) FROM reporting.dbo.daily_sales_summary WHERE daily_revenue IS NULL")
    null_count = cursor.fetchone()[0]
    
    if null_count > 0:
        print("WARNING: Found null values in revenue")
    
    # Check date range
    cursor.execute("SELECT MIN(sale_date), MAX(sale_date) FROM reporting.dbo.daily_sales_summary")
    r = cursor.fetchone()
    print(f"Data range: {r[0]} to {r[1]}")
    
    cursor.close()
    c.close()
    return True

def send_notification(msg):
    # TODO: Implement email notification
    print(f"NOTIFICATION: {msg}")

def cleanup_old_files():
    output_dir = 'C:\\Users\\DataTeam\\pipelines\\output\\'
    files = os.listdir(output_dir)
    
    for f in files:
        file_path = output_dir + f
        # Delete files older than 7 days
        file_time = os.path.getmtime(file_path)
        if (datetime.now().timestamp() - file_time) > 604800:
            os.remove(file_path)
            print(f"Deleted old file: {f}")

def main():
    print("="*50)
    print("TechMart Sales Pipeline")
    print("Starting at:", datetime.now())
    print("="*50)
    
    # Run extraction
    result1 = run_extraction()
    
    # Run transformation
    result2 = run_transformation()
    
    # Validate
    result3 = validate_data()
    
    # Cleanup
    cleanup_old_files()
    
    # Notify
    send_notification("Pipeline completed successfully")
    
    print("="*50)
    print("Pipeline finished at:", datetime.now())
    print("="*50)

if __name__ == "__main__":
    main()
