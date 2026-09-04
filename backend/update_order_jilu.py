import asyncio
from sqlalchemy import select
from app.core.database import AsyncSessionLocal
from app.models.order import Order

async def main():
    async with AsyncSessionLocal() as db:
        res = await db.execute(select(Order).where(Order.order_number == 'KZM-2026-165441'))
        o = res.scalar_one_or_none()
        if o:
            print("Updating order KZM-2026-165441...")
            o.customer_name = "Jilu"
            sa = dict(o.shipping_address or {})
            sa['full_name'] = "Jilu"
            sa['name'] = "Jilu"
            o.shipping_address = sa
            
            ba = dict(o.billing_address or {})
            ba['full_name'] = "Jilu"
            ba['name'] = "Jilu"
            o.billing_address = ba
            
            await db.commit()
            print("Successfully updated KZM-2026-165441 customer_name to Jilu!")

if __name__ == "__main__":
    asyncio.run(main())
