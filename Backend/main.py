import random
import pywhatkit as kit
from fastapi import FastAPI, HTTPException, Depends, status
from pydantic import BaseModel
from datetime import datetime, timedelta
from jose import jwt, JWTError
from fastapi.security import OAuth2PasswordBearer

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
    # Optionally delete OTP after verification
    otp_store.pop(request.phone_number, None)
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/protected-route")
async def protected_route(current_user: dict = Depends(get_current_user)):
    return {"message": "Welcome!", "user": current_user}

