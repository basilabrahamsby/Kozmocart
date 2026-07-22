import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_client.dart';
import '../../core/widgets/cached_image.dart';

String _formatDateTime(DateTime dt) {
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final day = dt.day.toString().padLeft(2, '0');
  final month = months[dt.month - 1];
  final year = dt.year;
  final hour24 = dt.hour;
  final minute = dt.minute.toString().padLeft(2, '0');
  final ampm = hour24 >= 12 ? 'PM' : 'AM';
  final hour = hour24 % 12 == 0 ? 12 : hour24 % 12;
  return "$day $month $year, ${hour.toString().padLeft(2, '0')}:$minute $ampm";
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. My Orders Screen
// ─────────────────────────────────────────────────────────────────────────────

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final _api = ApiClient();
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final res = await _api.dio.get('/storefront/account/orders');
      if (res.statusCode == 200 && res.data != null) {
        setState(() {
          _orders = res.data as List<dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load orders.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch orders. Please check your login session.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'MY ORDERS',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black87))
          : _error.isNotEmpty
              ? _buildErrorPlaceholder()
              : _orders.isEmpty
                  ? _buildEmptyPlaceholder()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return _buildOrderCard(order);
                      },
                    ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.black38),
            const SizedBox(height: 16),
            Text(
              _error,
              style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _fetchOrders,
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.black26),
            const SizedBox(height: 16),
            Text(
              'You have no orders yet.',
              style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    final number = order['order_number']?.toString() ?? 'Order';
    final dateStr = order['created_at']?.toString() ?? '';
    final total = order['total_amount']?.toString() ?? '0.00';
    final status = (order['status']?.toString() ?? 'pending').toUpperCase();
    final items = order['items'] as List<dynamic>? ?? [];
    
    DateTime? date;
    if (dateStr.isNotEmpty) {
      try {
        date = DateTime.parse(dateStr);
      } catch (_) {}
    }

    Color statusColor = Colors.orange;
    if (status == 'DELIVERED') statusColor = Colors.green;
    if (status == 'SHIPPED') statusColor = Colors.blue;
    if (status == 'CANCELLED') statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF2F2F7)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header of order card
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFFFAF9F6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#$number',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (date != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(date.toLocal()),
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
                      ),
                    ],
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Order items list
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: items.map((item) {
                final v = item['variant'];
                final prod = v != null ? v['product'] : null;
                final prodName = prod != null ? prod['name']?.toString() ?? 'Product' : 'Fragrance';
                final size = v != null ? v['size']?.toString() ?? '' : '';
                final qty = item['quantity']?.toString() ?? '1';
                final price = item['unit_price']?.toString() ?? '0.00';
                
                String? imgUrl;
                if (prod != null && prod['images'] is List && prod['images'].isNotEmpty) {
                  imgUrl = prod['images'][0]['image_url']?.toString();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF9F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: imgUrl != null
                            ? CachedImage(imageUrl: imgUrl, fit: BoxFit.contain)
                            : const Icon(Icons.image_outlined, size: 20, color: Colors.black26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prodName,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${size.isNotEmpty ? "$size | " : ""}QTY: $qty',
                              style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '₹$price',
                        style: GoogleFonts.montserrat(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          const Divider(color: Color(0xFFF2F2F7), height: 1),
          
          // Total Amount footer
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                  style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.black87),
                ),
                Text(
                  '₹$total',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Shipping Addresses Screen
// ─────────────────────────────────────────────────────────────────────────────

class ShippingAddressesScreen extends StatefulWidget {
  const ShippingAddressesScreen({super.key});

  @override
  State<ShippingAddressesScreen> createState() => _ShippingAddressesScreenState();
}

class _ShippingAddressesScreenState extends State<ShippingAddressesScreen> {
  final _api = ApiClient();
  List<dynamic> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.dio.get('/storefront/account/addresses');
      if (res.statusCode == 200 && res.data != null) {
        setState(() {
          _addresses = res.data as List<dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    try {
      final res = await _api.dio.delete('/storefront/account/addresses/$addressId');
      if (res.statusCode == 204 || res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address deleted successfully')),
        );
        _fetchAddresses();
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete address')),
      );
    }
  }

  void _showAddAddressSheet() {
    final labelCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final areaCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final stateCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ADD NEW ADDRESS',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Form Fields
                _buildField(labelCtrl, 'ADDRESS LABEL (e.g. Home, Office)'),
                _buildField(addressCtrl, 'ADDRESS LINE 1 (Building / Villa / House)'),
                _buildField(areaCtrl, 'ADDRESS LINE 2 (Area / Landmark)'),
                _buildField(cityCtrl, 'CITY / EMIRATE'),
                _buildField(stateCtrl, 'STATE'),
                _buildField(pinCtrl, 'PINCODE / PO BOX'),
                _buildField(phoneCtrl, 'CONTACT PHONE NUMBER', isPhone: true),
                
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (labelCtrl.text.isEmpty || addressCtrl.text.isEmpty || cityCtrl.text.isEmpty || phoneCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please complete all required fields')),
                      );
                      return;
                    }
                    
                    Navigator.of(context).pop();
                    setState(() => _isLoading = true);
                    
                    try {
                      await _api.dio.post(
                        '/storefront/account/addresses',
                        data: {
                          'label': labelCtrl.text.trim(),
                          'address_line1': addressCtrl.text.trim(),
                          'address_line2': areaCtrl.text.trim(),
                          'city': cityCtrl.text.trim(),
                          'state': stateCtrl.text.trim().isNotEmpty ? stateCtrl.text.trim() : cityCtrl.text.trim(),
                          'pincode': pinCtrl.text.trim().isNotEmpty ? pinCtrl.text.trim() : '00000',
                          'phone': phoneCtrl.text.trim(),
                          'country': 'India',
                        },
                      );
                      _fetchAddresses();
                    } catch (_) {
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to save address.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'SAVE ADDRESS',
                    style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: ctrl,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        style: GoogleFonts.poppins(fontSize: 12),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.montserrat(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'SHIPPING ADDRESSES',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: _showAddAddressSheet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black87))
          : _addresses.isEmpty
              ? _buildEmptyPlaceholder()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final addr = _addresses[index];
                    final id = addr['id']?.toString() ?? '';
                    final label = addr['label']?.toString() ?? 'Address';
                    final line1 = addr['address_line1']?.toString() ?? '';
                    final line2 = addr['address_line2']?.toString() ?? '';
                    final city = addr['city']?.toString() ?? '';
                    final state = addr['state']?.toString() ?? '';
                    final pin = addr['pincode']?.toString() ?? '';
                    final phone = addr['phone']?.toString() ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFF2F2F7)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                label.toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  color: Colors.black87,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                onPressed: () => _deleteAddress(id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            line1,
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                          ),
                          if (line2.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              line2,
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            '$city, $state - $pin',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone_iphone, size: 12, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text(
                                phone,
                                style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_outlined, size: 48, color: Colors.black26),
            const SizedBox(height: 16),
            Text(
              'No saved shipping addresses found.',
              style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _showAddAddressSheet,
              child: const Text('ADD NEW ADDRESS'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Saved Payments Screen
// ─────────────────────────────────────────────────────────────────────────────

class SavedPaymentsScreen extends StatelessWidget {
  const SavedPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'SAVED PAYMENTS',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFAF6F0),
                ),
                child: const Icon(Icons.shield_outlined, size: 48, color: Color(0xFFD4AF37)),
              ),
              const SizedBox(height: 24),
              Text(
                'SECURE CHECKOUT SYSTEM',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Kozmocart prioritizes your payment security. All credentials and card details are securely captured directly by our verified gateway partners (Stripe & Razorpay) during checkout. No card credentials are saved or processed on Kozmocart servers.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Customer Support Screen
// ─────────────────────────────────────────────────────────────────────────────

class CustomerSupportScreen extends StatelessWidget {
  const CustomerSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'CUSTOMER SUPPORT',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              'WE\'RE HERE TO HELP',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Our concierge support team is available from 9 AM to 9 PM IST to assist with orders, tracking, and fragrance recommendations.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black54,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            
            // Support Option Cards
            _buildSupportCard(
              Icons.mail_outline_rounded,
              'EMAIL ASSISTANCE',
              'info@kozmocart.com',
              'Expect a reply within 12-24 hours.',
            ),
            const SizedBox(height: 16),
            _buildSupportCard(
              Icons.phone_iphone_rounded,
              'WHATSAPP SUPPORT',
              '+91 99465 96018',
              'Quick chat support for order status.',
            ),
            const SizedBox(height: 16),
            _buildSupportCard(
              Icons.location_on_outlined,
              'CORPORATE HEADQUARTERS',
              'Kozmocart Commodities Pvt Ltd,\nCochin, Kerala, IN 682026',
              'Registered corporate office details.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(IconData icon, String title, String val, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F6),
        border: Border.all(color: const Color(0xFFF2F2F7)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  val,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
