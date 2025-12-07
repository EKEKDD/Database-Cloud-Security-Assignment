Assignment 1 - Secure Employee System Setup

1. Install Dependencies

Open your terminal/command prompt and run:
pip install flask flask-sqlalchemy pyodbc

Install these with browser:
SSMS 2022
MSSQL 2022 Developer Edition
ODBC Driver 18

No Raw SQL: Do not write raw SQL queries (e.g., SELECT * FROM...) in the Python code. Use SQLAlchemy syntax (User.query.all()). This protects against SQL Injection 
