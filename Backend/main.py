import random
import pywhatkit as kit
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import datetime

app = FastAPI()

class OTPRequest(BaseModel):
    phone_number: str   # format: +91XXXXXXXXXX

def generate_otp():
    return str(random.randint(100000, 999999))

@app.post("/send-otp/")
def send_otp(request: OTPRequest):
    otp = generate_otp()

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
