from flask import Flask, render_template, request, redirect, url_for, flash, session
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import check_password_hash
import os


app = Flask(__name__)
# Secret key for signing session cookies
app.secret_key = os.environ.get('SECRET_KEY', 'super_secret_key')
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL')
# The DATABASE_URL default is pointing to a local MSSQL instance

app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Session cookie hardening
debug_flag = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
app.config['SESSION_COOKIE_SECURE'] = not debug_flag

db = SQLAlchemy(app)  # Initialize the ORM

# Database models
class User(db.Model):
    __tablename__ = 'Users'
    UserID = db.Column(db.Integer, primary_key=True)
    Username = db.Column(db.String(50), unique=True, nullable=False)
    PasswordHash = db.Column(db.String(255), nullable=False)
    Role = db.Column(db.String(20), default='User')


class Employee(db.Model):
    __tablename__ = 'Employees'
    EmployeeID = db.Column(db.Integer, primary_key=True)
    FullName = db.Column(db.String(100), nullable=False)
    ICnumber = db.Column(db.String(20))
    Salary = db.Column(db.Numeric(10, 2))
    Position = db.Column(db.String(50))

# Routes
@app.route('/', methods=['GET', 'POST'])
def login():

    # Login page: show the form on GET, check the credentials on POST
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        # search user by username using ORM
        user = User.query.filter_by(Username=username).first()
        
        # Checking the keyed in password against stored hash.
        if user and check_password_hash(user.PasswordHash, password):
            session['user_id'] = user.UserID
            session['username'] = user.Username
            session['role'] = user.Role
            return redirect(url_for('dashboard'))
        else:
            flash('Wrong credentials')
            
    return render_template('login.html')

@app.route('/dashboard')
def dashboard():
    # Require login
    if 'user_id' not in session: return redirect(url_for('login'))

    # Only the Admin can view the dashboard page
    if session.get('role') != 'Admin':
        return "Access Denied: Administrators Only.", 403   
    
    # get all employees' details from the DB
    employees = Employee.query.all()
    
    return render_template('dashboard.html', employees=employees, username=session['username'])

@app.route('/add', methods=['POST'])
def add_employee():
    # Add a new employee record and only for logged in admins
    if 'user_id' not in session: return redirect(url_for('login'))
    if session.get('role') != 'Admin':
        return "Access Denied: Administrators Only.", 403

    new_emp = Employee(
        FullName=request.form['fullname'],
        ICnumber=request.form['icnumber'],
        Salary=request.form['salary'],
        Position=request.form['position']
    )
    
    db.session.add(new_emp)
    db.session.commit()
    
    flash('Employee Added Successfully')
    return redirect(url_for('dashboard'))

@app.route('/delete/<int:id>', methods=['POST'])
def delete_employee(id):
    # Delete an employee by id, only for logged in admins
    if 'user_id' not in session: return redirect(url_for('login'))
    if session.get('role') != 'Admin':
        return "Access Denied: Administrators Only.", 403

    emp = Employee.query.get_or_404(id)
    db.session.delete(emp)
    db.session.commit()

    flash('Employee Deleted')
    return redirect(url_for('dashboard'))

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

if __name__ == '__main__':
    with app.app_context():
        if os.environ.get('SKIP_DB_CREATE') != '1':
            db.create_all()
    debug_mode = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
    app.run(debug=debug_mode)



