import socket
import smtplib
from app.core.config import settings
from app.services.email import send_smtp_email, send_otp_email

print("--- Testing Email Diagnostics ---")
print(f"Configured Host: {settings.SMTP_HOST}, Port: {settings.SMTP_PORT}")
print(f"Configured User: {settings.SMTP_USER}")
print(f"Configured Pass Length: {len(settings.SMTP_PASSWORD)}")
print(f"Configured TLS: {settings.SMTP_TLS}, SSL: {settings.SMTP_SSL}")

# Test 1: Socket test to port 587
print("\n[TEST 1] Testing TCP socket connection to smtp.gmail.com:587 (timeout=5s)...")
try:
    sock = socket.create_connection(("smtp.gmail.com", 587), timeout=5)
    print("✓ Socket to 587 SUCCESSFUL!")
    sock.close()
except Exception as e:
    print(f"✗ Socket to 587 FAILED: {type(e).__name__}: {e}")

# Test 2: Socket test to port 465
print("\n[TEST 2] Testing TCP socket connection to smtp.gmail.com:465 (timeout=5s)...")
try:
    sock = socket.create_connection(("smtp.gmail.com", 465), timeout=5)
    print("✓ Socket to 465 SUCCESSFUL!")
    sock.close()
except Exception as e:
    print(f"✗ Socket to 465 FAILED: {type(e).__name__}: {e}")

# Test 3: SMTP Login on 587
print("\n[TEST 3] Testing smtplib.SMTP 587 TLS login...")
try:
    s = smtplib.SMTP("smtp.gmail.com", 587, timeout=5)
    s.starttls()
    res = s.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
    print(f"✓ SMTP 587 Login SUCCESSFUL: {res}")
    s.quit()
except Exception as e:
    print(f"✗ SMTP 587 Login FAILED: {type(e).__name__}: {e}")

# Test 4: SMTP Login on 465
print("\n[TEST 4] Testing smtplib.SMTP_SSL 465 SSL login...")
try:
    s = smtplib.SMTP_SSL("smtp.gmail.com", 465, timeout=5)
    res = s.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
    print(f"✓ SMTP 465 Login SUCCESSFUL: {res}")
    s.quit()
except Exception as e:
    print(f"✗ SMTP 465 Login FAILED: {type(e).__name__}: {e}")
