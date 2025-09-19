import random
import pywhatkit as kit
from fastapi import FastAPI, HTTPException, Depends, status
from pydantic import BaseModel,Field
from datetime import datetime, timedelta
from jose import jwt, JWTError
from fastapi.security import OAuth2PasswordBearer
from pymongo import MongoClient
from bson import ObjectId

app = FastAPI()

SECRET_KEY = "qwaszxerdfcvtyghbnuijkm,opl;./"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# In-memory OTP store: phone_number -> otp
otp_store = {}

class OTPRequest(BaseModel):
    phone_number: str   # format: +91XXXXXXXXXX

class OTPVerifyRequest(BaseModel):
    phone_number: str
    otp: str

def generate_otp():
    return str(random.randint(100000, 999999))

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        return None

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

async def get_current_user(token: str = Depends(oauth2_scheme)):
    payload = verify_token(token)
    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return payload

@app.post("/send-otp/")
def send_otp(request: OTPRequest):
    otp = generate_otp()
    otp_store[request.phone_number] = otp
    try:
        kit.sendwhatmsg_instantly(
            phone_no=request.phone_number,
            message=f"Your OTP is {otp}",
            wait_time=15,
            tab_close=True,
            close_time=3
        )
        return {"status": "success", "otp": otp}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/verify-otp/")
def verify_otp(request: OTPVerifyRequest):
    stored_otp = otp_store.get(request.phone_number)
    if stored_otp is None or stored_otp != request.otp:
        raise HTTPException(status_code=401, detail="Invalid OTP")
    access_token = create_access_token({"sub": request.phone_number})
    otp_store.pop(request.phone_number, None)
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/protected-route")
async def protected_route(current_user: dict = Depends(get_current_user)):
    return {"message": "Welcome!", "user": current_user}

# mongodb database

client=MongoClient("mongodb://localhost:27017")
db=client["hospital"]
patients=db["patients"]
doctors=db["doctors"]
appointments = db["appointments"]

all_patient_ids = [str(doc['_id']) for doc in patients.find({}, {'_id': 1})]
all_doctors_ids = [str(doc['_id']) for doc in doctors.find({},{'_id':1})]
all_appoinment_ids = [str(doc['_id'] for doc in appointments.find({},{'_id':1}))]
#functions to update the collections

def update_doctor(doctor_id, update_fields):
    update_fields["updated_at"] = datetime.utcnow()
    result = doctors.update_one(
        {"_id": ObjectId(doctor_id)},
        {"$set": update_fields}
    )
    return result.modified_count

def update_patient(patient_id, update_fields):
    update_fields["updated_at"] = datetime.utcnow()
    result = patients.update_one(
        {"_id": ObjectId(patient_id)},
        {"$set": update_fields}
    )
    return result.modified_count

def update_appointment(appointment_id, update_fields):
    update_fields["updated_at"] = datetime.utcnow()
    result = appointments.update_one(
        {"_id": ObjectId(appointment_id)},
        {"$set": update_fields}
    )
    return result.modified_count

#to insert one data into the table
patient_doc = {
    "name": "Jane Smith",
    "age": 30,
    "gender": "Female",
    "contact_info": {
        "phone": "+91-9876543211",
        "email": "jane.smith@email.com",
        "address": "456 Elm Street, City, State"
    },
    "medical_history": ["Diabetes", "Hypertension"],
    "current_medications": ["Metformin", "Lisinopril"],
    "blood_group": "B+",
    "emergency_contact": {
        "name": "John Smith",
        "relation": "Brother",
        "phone": "+91-9876543212"
    },
    "insurance_details": {
        "provider": "HealthCare Inc.",
        "policy_number": "HC12345678",
        "validity": "2026-12-31"
    },
    "appointments": [],  # List of ObjectId referencing appointments
    "created_at": datetime.utcnow(),
    "updated_at": datetime.utcnow()
}
doctor_doc = {
    "name": "doctor1",
    "specialization": "Cardiologist",
    "qualifications": ["MBBS", "MD Cardiology"],
    "contact_info": {
        "phone": "+91-9876543210",
        "email": "john.doe@hospital.com"
    },
    "experience_years": 15,
    "patients": all_patient_ids,  # List of patient ObjectIds as per your system
    "schedule": {
        "monday": "9am-5pm",
        "tuesday": "9am-5pm",
        "wednesday": "9am-1pm"
    },
    "address": "123 Medical St, City, State",
    "status": "Active",
    "created_at": datetime.utcnow(),
    "updated_at": datetime.utcnow()
}

def insert_doctor(doctor_doc):
    doctor_doc["created_at"] = datetime.utcnow()
    doctor_doc["updated_at"] = datetime.utcnow()
    result = doctors.insert_one(doctor_doc)
    return result.inserted_id

def insert_patient(patient_doc):
    patient_doc["created_at"] = datetime.utcnow()
    patient_doc["updated_at"] = datetime.utcnow()
    result = patients.insert_one(patient_doc)
    return result.inserted_id

def insert_appointment(appointment_doc):
    appointment_doc["created_at"] = datetime.utcnow()
    appointment_doc["updated_at"] = datetime.utcnow()
    result = appointments.insert_one(appointment_doc)
    return result.inserted_id

def delete_doctor(doctor_id):
    result = doctors.delete_one({"_id": ObjectId(doctor_id)})
    return result.deleted_count

def delete_patient(patient_id):
    result = patients.delete_one({"_id": ObjectId(patient_id)})
    return result.deleted_count

def delete_appointment(appointment_id):
    result = appointments.delete_one({"_id": ObjectId(appointment_id)})
    return result.deleted_count

class AppointmentRequest(BaseModel):
    patient_id: str = Field(...)
    doctor_id: str = Field(...)  # Assuming user selects doctor or system assigns
    appointment_date: datetime = Field(...)

@app.post("/book_appointment/")
async def book_appointment(request: AppointmentRequest,current_user: dict = Depends(get_current_user)):
    slot_start = request.appointment_date
    slot_end = slot_start + timedelta(minutes=15)

    conflict = db.appointments.find_one({
        "doctor_id": request.doctor_id,
        "appointment_date": {"$lt": slot_end},
        "$expr": {"$gte": [ { "$add": ["$appointment_date", 15 * 60 * 1000] }, slot_start ]},
        "status": "Booked"
    })
    if conflict:
        raise HTTPException(status_code=409, detail="Appointment slot not available")
    
    new_appointment = {
        "doctor_id": request.doctor_id,
        "patient_id": request.patient_id,
        "appointment_date": request.appointment_date,
        "status": "Booked",
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow()
    }

    result = db.appointments.insert_one(new_appointment)

    return {"appointment_id": str(result.inserted_id), "message": "Appointment successfully booked"}
