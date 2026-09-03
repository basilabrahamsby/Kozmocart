import asyncio
from sqlalchemy import select
from app.core.database import AsyncSessionLocal
from app.models.order import Order

async def main():
    async with AsyncSessionLocal() as db:
        res = await db.execute(select(Order).where(Order.order_number == 'KZM-2026-165441'))
        o = res.scalar_one_or_none()
        if o:
            print("Order Number:", o.order_number)
            print("Customer Name:", o.customer_name)
            print("Customer Email:", o.customer_email)
            print("Customer Phone:", o.customer_phone)
            print("Shipping Address:", repr(o.shipping_address))
            print("Billing Address:", repr(o.billing_address))
            print("Payment Details:", repr(o.payment_details))

if __name__ == "__main__":
    asyncio.run(main())
