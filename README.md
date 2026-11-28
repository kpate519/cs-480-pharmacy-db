# cs-480-pharmacy-db

## D5 – Pharmacy Web Application

### Requirements

- Python 3
- MySQL Server
- Git

### Database Setup

Start MySQL Server and log in using your local MySQL credentials.

From the project directory, execute the following commands inside MySQL:

```sql
SOURCE schema.sql;
SOURCE data.sql;
```

Note: `schema.sql` deletes and recreates the pharmacy database. Only run it on a local development database.

### Application Setup (macOS)

Open a terminal in the project folder and run:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Set your local MySQL password:

```bash
export DB_PASSWORD="your_mysql_password"
```

The application uses the MySQL username `root`, host `localhost`, and database `pharmacy`.

### Running the Application

```bash
python app.py
```

Open the following URL in your web browser:

http://127.0.0.1:5000

### Application Features

1. Patient List – Displays patient records directly from MySQL.
2. Patient Search – Searches patients by first or last name using parameterized SQL.
3. Staff Fill Report – Displays monthly prescription fill counts by staff member using JOIN, GROUP BY, and HAVING.
4. Add Fill – Inserts a new prescription fill and displays database errors if constraints are violated.

### Stopping the Application

Press Control + C in the terminal to stop the Flask server.
