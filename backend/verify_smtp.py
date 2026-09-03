from app.services.email import send_otp_email

print("--- VERIFYING LIVE SMTP EMAIL TRANSMISSION ---")
res = send_otp_email("info@kozmocart.com", "987654")
print("RESULT:", res)
if res:
    print("SUCCESS: Live email sent successfully!")
else:
    print("FAILED: Live email sending failed.")
