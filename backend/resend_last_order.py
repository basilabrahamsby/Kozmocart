import asyncio
import sys
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.core.database import AsyncSessionLocal
from app.models.order import Order, OrderItem
from app.models.product import ProductVariant, Product
from app.services.email import (
    send_order_confirmation_email,
    send_admin_invoice_email
)

async def main():
    target_email = sys.argv[1] if len(sys.argv) > 1 else None

    async with AsyncSessionLocal() as db:
        stmt = (
            select(Order)
            .options(
                selectinload(Order.items).selectinload(OrderItem.variant).selectinload(ProductVariant.product)
            )
            .order_by(Order.created_at.desc())
            .limit(10)
        )
        res = await db.execute(stmt)
        orders = res.scalars().all()

        if not orders:
            print("No orders found.")
            return

        print(f"FOUND {len(orders)} RECENT ORDERS:")
        for idx, o in enumerate(orders, 1):
            print(f"[{idx}] {o.order_number} | Customer: {o.customer_name} | Email: {o.customer_email} | Phone: {o.customer_phone} | Total: ₹{o.total_amount:,.2f} | Status: {o.payment_status} | Date: {o.created_at}")

        # Pick the most recent order (or first with email)
        last_order = orders[0]
        
        # If order customer_email is None or empty, check if target_email provided or pick order with email
        send_to_email = target_email or last_order.customer_email
        if not send_to_email:
            for o in orders:
                if o.customer_email:
                    last_order = o
                    send_to_email = o.customer_email
                    break

        if not send_to_email:
            send_to_email = "info@kozmocart.com"

        print("\n==================================================")
        print(f"RESENDING DETAILS FOR ORDER: {last_order.order_number}")
        print(f"Destination Email: {send_to_email}")
        print(f"Customer Name:    {last_order.customer_name or 'Valued Customer'}")
        print(f"Customer Phone:   {last_order.customer_phone or 'N/A'}")
        print(f"Total Amount:     ₹{last_order.total_amount:,.2f}")
        print(f"Payment Method:   {last_order.payment_method}")
        print(f"Payment Status:   {last_order.payment_status}")
        print(f"Created At:       {last_order.created_at}")
        print(f"==================================================")

        items_data = []
        for item in last_order.items:
            pname = item.product_name
            items_data.append({
                "product_name": pname,
                "size_ml": item.size_ml,
                "quantity": item.quantity,
                "total_price": float(item.total_price or 0)
            })

        # Temporarily attach customer_email if overridden
        if not last_order.customer_email:
            last_order.customer_email = send_to_email

        print(f"\n1. Dispatching Order Confirmation Email to {send_to_email}...")
        conf_res = send_order_confirmation_email(
            to_email=send_to_email,
            customer_name=last_order.customer_name or "Valued Customer",
            order_number=last_order.order_number,
            items=items_data,
            total=float(last_order.total_amount or 0),
            subtotal=float(last_order.subtotal or 0),
            discount=float(last_order.discount_amount or 0),
            shipping=float(last_order.shipping_amount or 0),
            tax=float(last_order.tax_amount or 0),
            loyalty_used=int(last_order.loyalty_points_used or 0),
            shipping_address=last_order.shipping_address if isinstance(last_order.shipping_address, dict) else {},
            payment_method=str(last_order.payment_method.value if hasattr(last_order.payment_method, 'value') else last_order.payment_method or ""),
            coupon_code=last_order.coupon_code or "",
            gift_message=last_order.gift_message or "",
            customer_email=send_to_email,
            customer_phone=last_order.customer_phone or ""
        )
        print(f"✓ Customer Confirmation Email Dispatch Result: {conf_res}")

        print(f"\n2. Dispatching Admin Tax Invoice & Label Email for {last_order.order_number}...")
        admin_res = send_admin_invoice_email(last_order)
        print(f"✓ Admin Invoice Email Dispatch Result: {admin_res}")

if __name__ == "__main__":
    asyncio.run(main())
