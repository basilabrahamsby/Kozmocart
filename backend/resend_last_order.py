import asyncio
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.core.database import AsyncSessionLocal
from app.models.order import Order
from app.services.email import (
    send_order_confirmation_email,
    send_admin_invoice_email
)

async def resend_last_order():
    async with AsyncSessionLocal() as db:
        stmt = (
            select(Order)
            .options(selectinload(Order.items))
            .order_by(Order.created_at.desc())
            .limit(1)
        )
        res = await db.execute(stmt)
        order = res.scalar_one_or_none()

        if not order:
            print("No orders found in database.")
            return

        print(f"==================================================")
        print(f"LAST ORDER DETAILS:")
        print(f"Order ID:       {order.id}")
        print(f"Order Number:   {order.order_number}")
        print(f"Customer Name:  {order.customer_name}")
        print(f"Customer Email: {order.customer_email}")
        print(f"Customer Phone: {order.customer_phone}")
        print(f"Total Amount:   ₹{order.total_amount:,.2f}")
        print(f"Payment Status: {order.payment_status}")
        print(f"Payment Method: {order.payment_method}")
        print(f"Created At:     {order.created_at}")
        print(f"Item Count:     {len(order.items)}")
        for idx, item in enumerate(order.items, 1):
            print(f"  Item {idx}: {item.product_name} (Qty: {item.quantity}, Price: ₹{item.total_price})")
        print(f"==================================================")

        items_data = [
            {
                "product_name": item.product_name,
                "size_ml": item.size_ml,
                "quantity": item.quantity,
                "total_price": float(item.total_price or 0)
            }
            for item in order.items
        ]

        print(f"\nResending Order Confirmation Email to customer ({order.customer_email})...")
        conf_res = send_order_confirmation_email(
            to_email=order.customer_email,
            customer_name=order.customer_name or "Valued Customer",
            order_number=order.order_number,
            items=items_data,
            total=float(order.total_amount or 0),
            subtotal=float(order.subtotal or 0),
            discount=float(order.discount_amount or 0),
            shipping=float(order.shipping_amount or 0),
            tax=float(order.tax_amount or 0),
            loyalty_used=int(order.loyalty_points_used or 0),
            shipping_address=order.shipping_address if isinstance(order.shipping_address, dict) else {},
            payment_method=str(order.payment_method.value if hasattr(order.payment_method, 'value') else order.payment_method or ""),
            coupon_code=order.coupon_code or "",
            gift_message=order.gift_message or "",
            customer_email=order.customer_email or "",
            customer_phone=order.customer_phone or ""
        )
        print(f"Customer Email Sent Result: {conf_res}")

        print(f"\nResending Admin Invoice Email for order {order.order_number}...")
        admin_res = send_admin_invoice_email(order)
        print(f"Admin Invoice Email Sent Result: {admin_res}")

if __name__ == "__main__":
    asyncio.run(resend_last_order())
