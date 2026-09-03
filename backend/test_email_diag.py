import asyncio
import smtplib
from app.core.config import settings
from app.services.email import send_smtp_email, send_otp_email

print("--- Testing Email Settings ---")
print(f"SMTP Host: {settings.SMTP_HOST}")
print(f"SMTP Port: {settings.SMTP_PORT}")
print(f"SMTP User: {settings.SMTP_USER}")
print(f"SMTP Password Length: {len(settings.SMTP_PASSWORD)}")
print(f"SMTP TLS: {settings.SMTP_TLS}")
print(f"SMTP SSL: {settings.SMTP_SSL}")
print(f"SMTP From Email: {settings.SMTP_FROM_EMAIL}")

print("\n--- Attempting Direct smtplib Connection ---")
try:
    if settings.SMTP_SSL:
        print("Connecting via SSL...")
        server = smtplib.SMTP_SSL(settings.SMTP_HOST, settings.SMTP_PORT, timeout=10)
    else:
        print("Connecting via standard SMTP...")
        server = smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT, timeout=10)
        
    if settings.SMTP_TLS and not settings.SMTP_SSL:
        print("Starting TLS...")
        server.starttls()
        
    if settings.SMTP_USER and settings.SMTP_PASSWORD:
        print("Logging in...")
        server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
        print("Login successful!")
        
    server.quit()
    print("Direct Connection OK!")
except Exception as e:
    print(f"Direct Connection FAILED: {type(e).__name__}: {e}")

print("\n--- Attempting send_otp_email ---")
try:
    res = send_otp_email("teqmatessolutions@gmail.com", "123456")
    print(f"send_otp_email result: {res}")
except Exception as e:
    print(f"send_otp_email FAILED: {type(e).__name__}: {e}")
