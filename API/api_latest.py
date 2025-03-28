from fastapi import FastAPI, HTTPException, Path, Query
import secrets
import asyncio
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from fastapi.middleware.cors import CORSMiddleware
import MySQLdb
from pydantic import BaseModel
import bcrypt
from typing import List, Optional
from datetime import datetime  # Add this line
import logging
import json
import pytz

db_config = {
    'host': 'localhost',
    'user': 'root',
    'passwd': '',
    'db': 'irrigation',
}

conn = MySQLdb.connect(**db_config)

app = FastAPI()

class User(BaseModel):
    username: str
    password: str
    email: str

class UserInfo(BaseModel):
    username: str
    email: str

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

async def remove_otp(email: str):
    await asyncio.sleep(300)  # Remove OTP after 5 minutes
    if email in otp_map:
        del otp_map[email]

otp_map = {}

def send_email(subject, message, to_email):
    try:
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        email_username = '1901020@iot.bdu.ac.bd'
        email_password = 'hfnyjytlyifordjs'
        server.login(email_username, email_password)
        msg = MIMEMultipart()
        msg['From'] = email_username
        msg['To'] = to_email
        msg['Subject'] = subject
        msg.attach(MIMEText(message, 'plain'))
        server.sendmail(email_username, to_email, msg.as_string())
        print("Email sent successfully!")
    except smtplib.SMTPException as e:
        print(f"Failed to send email: {e}")
    finally:
        server.quit()


@app.post("/users/")
def create_user(user: User):
    hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
    cursor = conn.cursor()
    query = "INSERT INTO users (username, password, email) VALUES (%s, %s, %s)"
    cursor.execute(query, (user.username, hashed_password, user.email))
    conn.commit()
    cursor.close()
    return {'msg': 'create successful'}


@app.post("/generate_otp/")
async def generate_otp(email: str):
    print(f"Received email: {email}")
    if '@' not in email or '.' not in email:
        raise HTTPException(status_code=400, detail="Invalid email format")

    otp = str(secrets.randbelow(900000) + 100000)  # Generate a 6-digit OTP
    otp_map[email] = otp
    asyncio.create_task(remove_otp(email))
    send_email("User Verification", f"Your OTP is: {otp}", email)
    print(f"OTP for {email} is: {otp}")
    return {"message": "OTP generated successfully."}

@app.post("/validate_otp/")
async def validate_otp(email: str, entered_otp: str):
    if email not in otp_map:
        raise HTTPException(status_code=404, detail="OTP not found for the given email.")
    
    stored_otp = otp_map[email]
    if stored_otp == entered_otp:
        del otp_map[email]
        print(f"OTP for {email} validated successfully.")
        return {"message": "OTP validated successfully."}
    else:
        print(f"OTP validation failed for {email}.")
        raise HTTPException(status_code=400, detail="Invalid OTP.")
    

@app.post("/login/")
async def login(username: str, password: str):
    cursor = conn.cursor()
    query = "SELECT password FROM users WHERE username=%s"
    cursor.execute(query, (username,))
    result = cursor.fetchone()
    cursor.close()
    if result is None:
        raise HTTPException(status_code=401, detail="Invalid username or password")
    hashed_password = result[0]
    if bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8')):
        return {"message": "Login successful"}
    else:
        raise HTTPException(status_code=401, detail="Invalid username or password")
    

@app.get("/user_info/{username}")
def get_user_info(username: str):
    cursor = conn.cursor()
    query = "SELECT username, email FROM users WHERE username=%s"
    cursor.execute(query, (username,))
    user = cursor.fetchone()
    cursor.close()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return {"username": user[0], "email": user[1]}

@app.get("/get_user_info/{email}")
def get_user_info(email: str = Path(..., title="User Email")):
    cursor = conn.cursor()
    query = "SELECT username, password FROM users WHERE email = %s"
    cursor.execute(query, (email,))
    user = cursor.fetchone()
    cursor.close()
    
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    
    return {"username": user[0], "password": user[1]}


@app.put("/updateusers/{user_email}")
def update_user(user_email: str, user: User):
    # Hash the password
    hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())

    # Create a cursor object to execute SQL queries
    cursor = conn.cursor()

    try:
        # Update the user information in the database
        query = "UPDATE users SET username=%s, password=%s WHERE email=%s"
        cursor.execute(query, (user.username, hashed_password, user_email))
        conn.commit()

        # Close the cursor
        cursor.close()

        # Return the updated user information
        return {"message": "User information updated successfully"}
    except Exception as e:
        # Rollback changes if an error occurs
        conn.rollback()
        cursor.close()
        raise HTTPException(status_code=500, detail="Failed to update user information")





# Define the response model for field information
class FieldInfoResponse(BaseModel):
    temp: float
    hum: float
    soil_mois: float
    flow_rate: float
    volume: float
    last_rain_days_ago: int

# Define Bangladesh timezone
bangladesh_tz = pytz.timezone("Asia/Dhaka")

@app.get("/field_info/latest", response_model=FieldInfoResponse)
def get_latest_field_info(field_id: str):
   
    # Connect to the database
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()

    try:
        

        # Query to get the latest field information
        query = """
            SELECT temp, hum, soil_mois, rain, flow_rate, volume, timestamp 
            FROM field_info 
            WHERE field_id = %s 
            ORDER BY id DESC 
            LIMIT 1
        """
        cursor.execute(query, (field_id,))
        latest_data = cursor.fetchone()
        
        # Check if data exists for the specified field_id
        if latest_data is None:
            raise HTTPException(status_code=404, detail="No data found for the specified field_id")
        
        temp, hum, soil_mois, rain, flow_rate, volume, latest_timestamp = latest_data

        # Query to find the most recent date it rained
        rain_query = """
            SELECT timestamp 
            FROM field_info 
            WHERE field_id = %s AND rain = 1 
            ORDER BY id DESC 
            LIMIT 1
        """
        cursor.execute(rain_query, (field_id,))
        rain_data = cursor.fetchone()
        print(rain_data)

        # Calculate days since last rain, considering Bangladesh timezone
        if rain_data is None:
            last_rain_days_ago = -1  # Indicates no recorded rain event
        else:
            last_rain_timestamp = rain_data[0].astimezone(bangladesh_tz)
            current_time_bd = datetime.now(bangladesh_tz)
            last_rain_days_ago = (current_time_bd - last_rain_timestamp).days

        # Structure the response data
        response_data = {
            "temp": temp,
            "hum": hum,
            "soil_mois": soil_mois,
            "flow_rate": flow_rate,
            "volume": volume,
            "last_rain_days_ago": last_rain_days_ago
        }
        
        return response_data
    
    except Exception as e:
        # Handle any exceptions that occur during database access
        raise HTTPException(status_code=500, detail="Failed to fetch monitoring data") from e
    
    finally:
        # Ensure the database cursor and connection are closed
        cursor.close()
        conn.close()




# Control model for updating statuses
class ControlStatus(BaseModel):
    field_id: str
    status: str  # "on" or "off"

@app.post("/control/automatic")
def set_automatic_control(status: ControlStatus):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    try:
        # Insert the automatic control status along with the field_id
        query = "INSERT INTO automatic_control (automatic_status, field_id) VALUES (%s, %s)"
        cursor.execute(query, (status.status, status.field_id))
        conn.commit()
        return {"message": "Automatic control status updated successfully"}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail="Failed to update automatic control status") from e
    finally:
        cursor.close()
        conn.close()

@app.post("/control/manual")
def set_manual_control(status: ControlStatus):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    try:
        # Insert the manual control status along with the field_id
        query = "INSERT INTO manual_control (manual_status, field_id) VALUES (%s, %s)"
        cursor.execute(query, (status.status, status.field_id))
        conn.commit()
        return {"message": "Manual control status updated successfully"}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail="Failed to update manual control status") from e
    finally:
        cursor.close()
        conn.close()





# api for temperature graph
@app.get("/last_15_values/")
def get_last_15_values(field_id: str):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    try:
        query = """
            SELECT temp, timestamp 
            FROM field_info 
            WHERE field_id = %s 
            ORDER BY id DESC 
            LIMIT 15
        """
        cursor.execute(query, (field_id,))
        data = cursor.fetchall()
        result = [{"temp": row[0], "timestamp": row[1].isoformat()} for row in data]
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch data") from e
    finally:
        cursor.close()
        conn.close()


@app.get("/last_7_days_avg/")
def get_last_7_days_avg(field_id: str):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    try:
        query = """
            SELECT AVG(temp) as avg_temp, DATE(timestamp) as date 
            FROM field_info 
            WHERE field_id = %s AND timestamp >= NOW() - INTERVAL 7 DAY 
            GROUP BY DATE(timestamp)
        """
        cursor.execute(query, (field_id,))
        data = cursor.fetchall()
        result = [{"temp": row[0], "timestamp": row[1].isoformat()} for row in data]
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch data") from e
    finally:
        cursor.close()
        conn.close()



@app.get("/last_15_days_avg/")
def get_last_15_days_avg(field_id: str):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    try:
        query = """
            SELECT AVG(temp) as avg_temp, DATE(timestamp) as date 
            FROM field_info 
            WHERE field_id = %s AND timestamp >= NOW() - INTERVAL 15 DAY 
            GROUP BY DATE(timestamp)
        """
        cursor.execute(query, (field_id,))
        data = cursor.fetchall()
        result = [{"temp": row[0], "timestamp": row[1].isoformat()} for row in data]
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch data") from e
    finally:
        cursor.close()
        conn.close()


# soil_moisture graph

@app.get("/soil_moisture_last_15_values/")
def get_last_15_soil_moisture_values(field_id: str):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    try:
        query = """
            SELECT soil_mois, timestamp 
            FROM field_info 
            WHERE field_id = %s 
            ORDER BY id DESC 
            LIMIT 15
        """
        cursor.execute(query, (field_id,))
        data = cursor.fetchall()
        result = [{"soil_moisture": row[0], "timestamp": row[1].isoformat()} for row in data]
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch data") from e
    finally:
        cursor.close()
        conn.close()


@app.get("/soil_moisture_last_7_days_avg/")
def get_last_7_days_avg_soil_moisture(field_id: str):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    try:
        query = """
            SELECT AVG(soil_mois) as avg_soil_moisture, DATE(timestamp) as date 
            FROM field_info 
            WHERE field_id = %s AND timestamp >= NOW() - INTERVAL 7 DAY 
            GROUP BY DATE(timestamp)
        """
        cursor.execute(query, (field_id,))
        data = cursor.fetchall()
        result = [{"soil_moisture": row[0], "timestamp": row[1].isoformat()} for row in data]
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch data") from e
    finally:
        cursor.close()
        conn.close()


@app.get("/soil_moisture_last_15_days_avg/")
def get_last_15_days_avg_soil_moisture(field_id: str):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    try:
        query = """
            SELECT AVG(soil_mois) as avg_soil_moisture, DATE(timestamp) as date 
            FROM field_info 
            WHERE field_id = %s AND timestamp >= NOW() - INTERVAL 15 DAY 
            GROUP BY DATE(timestamp)
        """
        cursor.execute(query, (field_id,))
        data = cursor.fetchall()
        result = [{"soil_moisture": row[0], "timestamp": row[1].isoformat()} for row in data]
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch data") from e
    finally:
        cursor.close()
        conn.close()


# for humidity graph
@app.get("/humidity_last_15_values/")
def get_last_15_humidity_values(field_id: str):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    try:
        query = """
            SELECT hum, timestamp 
            FROM field_info 
            WHERE field_id = %s 
            ORDER BY id DESC 
            LIMIT 15
        """
        cursor.execute(query, (field_id,))
        data = cursor.fetchall()
        result = [{"humidity": row[0], "timestamp": row[1].isoformat()} for row in data]
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch data") from e
    finally:
        cursor.close()
        conn.close()


@app.get("/humidity_last_7_days_avg/")
def get_last_7_days_avg_humidity(field_id: str):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    try:
        query = """
            SELECT AVG(hum) as avg_humidity, DATE(timestamp) as date 
            FROM field_info 
            WHERE field_id = %s AND timestamp >= NOW() - INTERVAL 7 DAY 
            GROUP BY DATE(timestamp)
        """
        cursor.execute(query, (field_id,))
        data = cursor.fetchall()
        result = [{"humidity": row[0], "timestamp": row[1].isoformat()} for row in data]
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch data") from e
    finally:
        cursor.close()
        conn.close()


@app.get("/humidity_last_15_days_avg/")
def get_last_15_days_avg_humidity(field_id: str):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    try:
        query = """
            SELECT AVG(hum) as avg_humidity, DATE(timestamp) as date 
            FROM field_info 
            WHERE field_id = %s AND timestamp >= NOW() - INTERVAL 15 DAY 
            GROUP BY DATE(timestamp)
        """
        cursor.execute(query, (field_id,))
        data = cursor.fetchall()
        result = [{"humidity": row[0], "timestamp": row[1].isoformat()} for row in data]
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch data") from e
    finally:
        cursor.close()
        conn.close()

# for flow rate screen

@app.get("/flow_rate_last_15_values/")
def get_last_15_flow_rate_values(field_id: str):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    try:
        query = """
            SELECT flow_rate, timestamp 
            FROM field_info 
            WHERE field_id = %s 
            ORDER BY id DESC 
            LIMIT 15
        """
        cursor.execute(query, (field_id,))
        data = cursor.fetchall()
        result = [{"flow_rate": row[0], "timestamp": row[1].isoformat()} for row in data]
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch data") from e
    finally:
        cursor.close()
        conn.close()


@app.get("/flow_rate_last_7_days_avg/")
def get_last_7_days_avg_flow_rate(field_id: str):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    try:
        query = """
            SELECT AVG(flow_rate) as avg_flow_rate, DATE(timestamp) as date 
            FROM field_info 
            WHERE field_id = %s AND timestamp >= NOW() - INTERVAL 7 DAY 
            GROUP BY DATE(timestamp)
        """
        cursor.execute(query, (field_id,))
        data = cursor.fetchall()
        result = [{"flow_rate": row[0], "timestamp": row[1].isoformat()} for row in data]
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch data") from e
    finally:
        cursor.close()
        conn.close()


@app.get("/flow_rate_last_15_days_avg/")
def get_last_15_days_avg_flow_rate(field_id: str):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    try:
        query = """
            SELECT AVG(flow_rate) as avg_flow_rate, DATE(timestamp) as date 
            FROM field_info 
            WHERE field_id = %s AND timestamp >= NOW() - INTERVAL 15 DAY 
            GROUP BY DATE(timestamp)
        """
        cursor.execute(query, (field_id,))
        data = cursor.fetchall()
        result = [{"flow_rate": row[0], "timestamp": row[1].isoformat()} for row in data]
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch data") from e
    finally:
        cursor.close()
        conn.close()


# for volume screen.dart
@app.get("/volume_last_15_values/")
def get_last_15_volume_values(field_id: str):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    try:
        query = """
            SELECT volume, timestamp 
            FROM field_info 
            WHERE field_id = %s 
            ORDER BY id DESC 
            LIMIT 15
        """
        cursor.execute(query, (field_id,))
        data = cursor.fetchall()
        result = [{"volume": row[0], "timestamp": row[1].isoformat()} for row in data]
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch data") from e
    finally:
        cursor.close()
        conn.close()


@app.get("/volume_last_7_days_avg/")
def get_last_7_days_avg_volume(field_id: str):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    try:
        query = """
            SELECT AVG(volume) as avg_volume, DATE(timestamp) as date 
            FROM field_info 
            WHERE field_id = %s AND timestamp >= NOW() - INTERVAL 7 DAY 
            GROUP BY DATE(timestamp)
        """
        cursor.execute(query, (field_id,))
        data = cursor.fetchall()
        result = [{"volume": row[0], "timestamp": row[1].isoformat()} for row in data]
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch data") from e
    finally:
        cursor.close()
        conn.close()


@app.get("/volume_last_15_days_avg/")
def get_last_15_days_avg_volume(field_id: str):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    try:
        query = """
            SELECT AVG(volume) as avg_volume, DATE(timestamp) as date 
            FROM field_info 
            WHERE field_id = %s AND timestamp >= NOW() - INTERVAL 15 DAY 
            GROUP BY DATE(timestamp)
        """
        cursor.execute(query, (field_id,))
        data = cursor.fetchall()
        result = [{"volume": row[0], "timestamp": row[1].isoformat()} for row in data]
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch data") from e
    finally:
        cursor.close()
        conn.close()






# ML model

import joblib
import pandas as pd

from MySQLdb import OperationalError



# Load the pre-trained KNN model using joblib
try:
    knn_model = joblib.load('knn_model.pkl')
    print("Model loaded successfully!")
except Exception as e:
    print(f"Error loading model: {e}")
    knn_model = None

# Define the input data structure
class InputData(BaseModel):
    crop_id: str
    soil_type: str
    seedling_stage: str
    field_id: str  # field_id will come from Flutter app

@app.post("/predict")
async def predict(input_data: InputData):
    conn = None
    cursor = None
    try:
        # Check if the model is loaded
        if knn_model is None:
            raise HTTPException(status_code=500, detail="Model failed to load")

        # Connect to MySQL database
        conn = MySQLdb.connect(**db_config)
        cursor = conn.cursor()

        # Query to fetch the last record for the given field_id
        query = f"SELECT * FROM field_info WHERE field_id = %s ORDER BY id DESC LIMIT 1"
        cursor.execute(query, (input_data.field_id,))
        record = cursor.fetchone()

        # If no record found, return an error
        if not record:
            raise HTTPException(status_code=404, detail="No data found for the given field_id.")
        
        # Extracting values from the database record using index-based access
        moi = float(record[3])  # 'moi' is at index 5
        temp = float(record[1])  # 'temp' is at index 6
        humidity = float(record[2])  # 'humidity' is at index 7

        print(moi)
        print(temp)
        print(humidity)

        # Prepare data for prediction
        data = pd.DataFrame({
            'crop_id': [input_data.crop_id],
            'soil_type': [input_data.soil_type],
            'seedling stage': [input_data.seedling_stage],
            'moi': [moi],
            'temp': [temp],
            'humidity': [humidity]
        })
        print(data)

        # Make prediction using the model
        prediction = knn_model.predict(data)
        result = 'Irrigation Needed' if prediction[0] == 1 else 'No Need of Irrigation'
        
        return {"prediction": result}

    except OperationalError as e:
        print(f"Error fetching data from MySQL: {e}")
        raise HTTPException(status_code=500, detail="Error connecting to the database")
    
    except Exception as e:
        print(f"Error in prediction: {e}")
        raise HTTPException(status_code=500, detail="Error during prediction")
    
    finally:
        # Close the cursor and connection
        if cursor:
            cursor.close()
        if conn:
            conn.close()





