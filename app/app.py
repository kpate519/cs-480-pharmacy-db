import os
from datetime import date

import pymysql
from flask import Flask, redirect, render_template, request

app = Flask(__name__)


def get_connection():
    return pymysql.connect(
        host="localhost",
        user="root",
        password=os.environ.get("DB_PASSWORD", ""),
        database="pharmacy",
        cursorclass=pymysql.cursors.DictCursor,
    )


def run_query(sql, params=()):
    """Run a SELECT and return all rows. Values go in params, never in sql."""
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(sql, params)
            return cur.fetchall()
    finally:
        conn.close()


@app.route("/")
def home():
    return redirect("/patients")


# 1. LIST PAGE ---------------------------------------------------------------
@app.route("/patients")
def patients():
    rows = run_query(
        "SELECT patient_id, first_name, last_name, date_of_birth, "
        "city, state_info, deceased_flag "
        "FROM patient ORDER BY last_name, first_name"
    )
    return render_template("patients.html", rows=rows)


# 2. SEARCH ------------------------------------------------------------------
@app.route("/search")
def search():
    q = request.args.get("q", "").strip()
    rows = None
    if q:
        like = f"%{q}%" 
        rows = run_query(
            "SELECT patient_id, first_name, last_name, date_of_birth "
            "FROM patient "
            "WHERE first_name LIKE %s OR last_name LIKE %s "
            "ORDER BY last_name, first_name",
            (like, like),
        )
    return render_template("search.html", q=q, rows=rows)


# 3. REPORT  -----------------------
@app.route("/report")
def report():
    month = request.args.get("month") or date.today().strftime("%Y-%m")
    min_fills = request.args.get("min_fills", "0")
    rows, error = [], None
    try:
        year, mon = (int(x) for x in month.split("-"))
        start = date(year, mon, 1)
        end = date(year + (mon == 12), mon % 12 + 1, 1)
        rows = run_query(
            "SELECT s.employee_id, s.first_name, s.last_name, "
            "       s.employee_role, COUNT(f.fill_id) AS fills_made "
            "FROM staff_member s "
            "JOIN fill f ON f.employee_id = s.employee_id "
            "WHERE f.fill_date >= %s AND f.fill_date < %s "
            "GROUP BY s.employee_id, s.first_name, s.last_name, s.employee_role "
            "HAVING COUNT(f.fill_id) > %s "
            "ORDER BY fills_made DESC, s.last_name",
            (start, end, int(min_fills)),
        )
    except ValueError:
        error = "Enter the month as YYYY-MM and the minimum as a whole number."
    except pymysql.MySQLError as e:
        error = f"Database error: {e}"
    return render_template(
        "report.html", rows=rows, month=month, min_fills=min_fills, error=error
    )


# 4. INSERT FORM -------------------------------------------------------------
@app.route("/fills/new", methods=["GET", "POST"])
def new_fill():
    message = error = None
    form = {}
    if request.method == "POST":
        form = {key: request.form.get(key, "").strip() for key in
                ("fill_id", "fill_date", "quantity", "fill_status",
                 "employee_id", "prescription_number")}
        conn = get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO fill (fill_id, fill_date, quantity, "
                    "fill_status, employee_id, prescription_number) "
                    "VALUES (%s, %s, %s, %s, %s, %s)",
                    (form["fill_id"], form["fill_date"], form["quantity"],
                     form["fill_status"], form["employee_id"],
                     form["prescription_number"]),
                )
            conn.commit()
            message = f"Fill {form['fill_id']} was added."
            form = {}
        except pymysql.MySQLError as e:
            conn.rollback()
            error = f"The database rejected this fill: {e}"
        finally:
            conn.close()
    recent = run_query(
        "SELECT fill_id, fill_date, quantity, fill_status, "
        "employee_id, prescription_number "
        "FROM fill ORDER BY fill_date DESC, fill_id DESC LIMIT 8"
    )
    return render_template("new_fill.html", message=message, error=error,
                           form=form, recent=recent)


if __name__ == "__main__":
    app.run(debug=True)