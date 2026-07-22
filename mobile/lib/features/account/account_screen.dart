import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/api/api_client.dart';
import '../../core/api/token_manager.dart';
import '../cart/cart_provider.dart';
import '../wishlist/wishlist_provider.dart';
import '../auth/login_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'account_subpages.dart';
import '../../core/widgets/logo_loader.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _isLoggedIn = false;
  String _name = 'Guest User';
  String _email = 'Log in to sync your cart and preferences';
  int _loyaltyPoints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        _setGuestState();
        return;
      }

      final res = await ApiClient().dio.get('/storefront/account/me');
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        final fName = data['first_name']?.toString() ?? '';
        final lName = data['last_name']?.toString() ?? '';
        final email = data['email']?.toString() ?? data['phone']?.toString() ?? '';
        final points = data['loyalty_points'] is int ? data['loyalty_points'] as int : 0;
        final fullName = (fName.isNotEmpty || lName.isNotEmpty)
            ? '$fName $lName'.trim()
            : 'Customer';

        if (mounted) {
          setState(() {
            _isLoggedIn = true;
            _name = fullName;
            _email = email;
            _loyaltyPoints = points;
            _isLoading = false;
          });
        }
      } else {
        _setGuestState();
      }
    } catch (_) {
      _setGuestState();
    }
  }

  void _setGuestState() {
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _name = 'Guest User';
        _email = 'Log in to sync your preferences';
        _loyaltyPoints = 0;
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await TokenManager.clearToken();
      ref.read(cartProvider.notifier).clearCart();
      ref.read(wishlistProvider.notifier).clearWishlist();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged out successfully!', style: GoogleFonts.poppins(fontSize: 12)),
          backgroundColor: Colors.black87,
        ),
      );
      _setGuestState();
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 26, fit: BoxFit.contain),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: Colors.black87, size: 20),
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const LogoLoader()
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Profile Luxury Floating Card
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isLoggedIn
                                    ? [Colors.white, const Color(0xFFFCF9FA)]
                                    : [const Color(0xFFFFF5FA), const Color(0xFFFDE8F3)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isLoggedIn ? const Color(0xFFD4AF37) : const Color(0xFFF5D6E3),
                                width: 1.2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0C000000),
                                  blurRadius: 18,
                                  offset: Offset(0, 6),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                // Elegant Profile Ring
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _isLoggedIn ? const Color(0xFFD4AF37) : const Color(0xFFD2168D),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 38,
                                    backgroundColor: _isLoggedIn ? const Color(0xFFFAF6F0) : Colors.white,
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      size: 34,
                                      color: _isLoggedIn ? Colors.black87 : const Color(0xFFD2168D),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                
                                // Customer Name
                                Text(
                                  _isLoggedIn ? _name : 'Welcome to Kozmocart',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                
                                // Customer Email/Phone details
                                Text(
                                  _isLoggedIn ? _email : 'Sign in to unlock personalized fragrance matching',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),

                                if (_isLoggedIn) ...[
                                  // Elite Member Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFAF6F0),
                                      border: Border.all(color: const Color(0xFFEADFCD)),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star, color: Color(0xFFD4AF37), size: 14),
                                        const SizedBox(width: 6),
                                        Text(
                                          'ELITE MEMBER  |  $_loyaltyPoints PTS',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                            color: const Color(0xFF8C6D3B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Sign out Outlined Button
                                  OutlinedButton(
                                    onPressed: _signOut,
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFFE5E5EA)),
                                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    ),
                                    child: Text(
                                      'SIGN OUT',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  // Login Solid Button (Brand Rose Pink)
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                                      ).then((_) => _loadProfile());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD2168D),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      shadowColor: const Color(0x3DD2168D),
                                    ),
                                    child: Text(
                                      'SIGN IN / REGISTER',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Preferences Label
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Text(
                            'ACCOUNT PREFERENCES',
                            style: GoogleFonts.montserrat(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                        
                        // Action menu items styled beautifully
                        _buildMenuItem(
                          Icons.favorite_border_rounded,
                          'My Wishlist',
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const WishlistScreen()),
                            ).then((_) => _loadProfile());
                          },
                        ),
                        _buildMenuItem(
                          Icons.shopping_bag_outlined,
                          'My Orders',
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
                            );
                          },
                        ),
                        _buildMenuItem(
                          Icons.location_on_outlined,
                          'Shipping Addresses',
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const ShippingAddressesScreen()),
                            );
                          },
                        ),

                        _buildMenuItem(
                          Icons.help_outline_rounded,
                          'Customer Support',
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const CustomerSupportScreen()),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFFDF0F6), width: 1.2), // Soft Rose border divider
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87, size: 19),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFD2168D), size: 12), // Brand Rose arrow
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
        onTap: onTap,
      ),
    );
  }
}
