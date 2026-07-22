import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/api/api_client.dart';
import '../../core/api/token_manager.dart';
import '../cart/cart_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _contactController = TextEditingController();
  final _otpController = TextEditingController();
  final _api = ApiClient();
  
  bool _otpSent = false;
  bool _isLoading = false;
  int _timerSeconds = 60;
  Timer? _countdownTimer;
  String _loginMethod = 'email'; // 'email' or 'phone'

  @override
  void initState() {
    super.initState();
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 60;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _contactController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    final input = _contactController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _loginMethod == 'email' ? 'Please enter your email address' : 'Please enter your phone number',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          backgroundColor: Colors.black87,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final isPhone = _loginMethod == 'phone';
      final body = isPhone
          ? {'phone': input}
          : {'email': input};

      await _api.dio.post('/storefront/auth/otp/send', data: body);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _otpSent = true;
      });
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification code sent successfully!', style: GoogleFonts.poppins(fontSize: 12)),
          backgroundColor: Colors.black87,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final msg = e.toString().contains('400')
          ? 'Invalid address format. Please try again.'
          : 'Failed to send verification code. Please check connection.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg, style: GoogleFonts.poppins(fontSize: 12)), backgroundColor: Colors.black87),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter verification code', style: GoogleFonts.poppins(fontSize: 12)),
          backgroundColor: Colors.black87,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final input = _contactController.text.trim();
      final isPhone = _loginMethod == 'phone';
      final body = isPhone
          ? {'phone': input, 'otp': otp}
          : {'email': input, 'otp': otp};

      final res = await _api.dio.post('/storefront/auth/otp/verify', data: body);
      final token = res.data['access_token']?.toString() ?? '';

      if (token.isNotEmpty) {
        await TokenManager.saveToken(token);
        await ref.read(cartProvider.notifier).syncWithServerAfterLogin();
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged in successfully! 🎉', style: GoogleFonts.poppins(fontSize: 12)),
          backgroundColor: Colors.black87,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final msg = e.toString().contains('400')
          ? 'Invalid or expired code. Please try again.'
          : 'Verification failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg, style: GoogleFonts.poppins(fontSize: 12)), backgroundColor: Colors.black87),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Left side branding banner (visible on larger screens/desktop layout)
          if (isDesktop)
            Expanded(
              child: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        "https://images.unsplash.com/photo-1541643600914-78b084683601?q=80&w=1000&auto=format&fit=crop",
                        fit: BoxFit.cover,
                        opacity: const AlwaysStoppedAnimation(0.4),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'The Art of Fragrance',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 36,
                                color: Colors.white,
                                letterSpacing: 3,
                                fontWeight: FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Container(width: 40, height: 1, color: const Color(0xFFD4AF37)),
                            const SizedBox(height: 16),
                            Text(
                              'Exclusive access to the world\'s most prestigious perfume houses.',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: Colors.white70,
                                letterSpacing: 2,
                                height: 2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
          // Main Form Section
          Expanded(
            child: Container(
              color: Colors.white,
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Logo and Back Navigation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.black87),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              Image.asset('assets/logo.png', height: 28, fit: BoxFit.contain),
                              const SizedBox(width: 40),
                            ],
                          ),
                          const SizedBox(height: 48),
                          
                          // Title & Tagline
                          Text(
                            _otpSent ? 'VERIFY ACCOUNT' : 'SIGN IN',
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.5,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _otpSent 
                              ? 'Enter the 6-digit authentication code sent to $_contactController.text'
                              : 'Unlock your personalized scent journey',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          
                          if (!_otpSent) ...[
                            // Segmented Method Selector (Email / Mobile)
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFF2F2F7), width: 1.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildTabButton('email', 'Email Address'),
                                  _buildTabButton('phone', 'Mobile Number'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Custom Minimalist Text Input
                            Text(
                              _loginMethod == 'email' ? 'EMAIL IDENTIFICATION' : 'MOBILE VERIFICATION',
                              style: GoogleFonts.montserrat(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _contactController,
                              style: GoogleFonts.poppins(fontSize: 13.5, color: Colors.black87),
                              keyboardType: _loginMethod == 'email' ? TextInputType.emailAddress : TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: _loginMethod == 'email' ? 'your@email.com' : 'e.g. 9876543210',
                                hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: Colors.black26),
                                prefixIcon: Icon(
                                  _loginMethod == 'email' ? Icons.mail_outline : Icons.smartphone_outlined,
                                  size: 18,
                                  color: Colors.black54,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFE5E5EA)),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black87, width: 1.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            
                            // Main CTA Button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _requestOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isLoading 
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(
                                    'CONTINUE',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                            ),
                            const SizedBox(height: 48),
                            
                            // Social Logins Divider
                            Row(
                              children: [
                                const Expanded(child: Divider(color: Color(0xFFF2F2F7))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    'OR CONNECT WITH',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider(color: Color(0xFFF2F2F7))),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Social Logins Row
                            Row(
                              children: [
                                Expanded(child: _buildSocialButton('GOOGLE')),
                                const SizedBox(width: 16),
                                Expanded(child: _buildSocialButton('APPLE')),
                              ],
                            ),
                          ] else ...[
                            // OTP Verification Box
                            Text(
                              'ACCESS CODE',
                              style: GoogleFonts.montserrat(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _otpController,
                              style: GoogleFonts.poppins(fontSize: 13.5, color: Colors.black87),
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: 'Enter 6-digit OTP',
                                hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: Colors.black26),
                                prefixIcon: const Icon(Icons.shield_outlined, size: 18, color: Colors.black54),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFE5E5EA)),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black87, width: 1.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            ElevatedButton(
                              onPressed: _isLoading ? null : _verifyOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isLoading 
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(
                                    'VERIFY & CONTINUE',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Timer countdown and Resend
                            Center(
                              child: _timerSeconds > 0
                                ? Text(
                                    'Resend code in ${_timerSeconds}s',
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.textMuted,
                                      fontSize: 11.5,
                                    ),
                                  )
                                : TextButton(
                                    onPressed: _requestOtp,
                                    child: Text(
                                      'RESEND CODE',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.black87,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _otpSent = false;
                                    _otpController.clear();
                                  });
                                },
                                child: Text(
                                  'CHANGE DETAILS',
                                  style: GoogleFonts.montserrat(
                                    color: AppTheme.textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 60),
                          
                          // Trust Certifications / Badges
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTrustBadge(Icons.verified_outlined, '100% ORIGINAL'),
                              const SizedBox(width: 24),
                              Container(width: 1, height: 20, color: const Color(0xFFE9E9EB)),
                              const SizedBox(width: 24),
                              _buildTrustBadge(Icons.lock_outline, 'SECURE SYSTEM'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String method, String label) {
    final isActive = _loginMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _loginMethod = method;
            _contactController.clear();
          });
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.black : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive ? Colors.black87 : const Color(0xFFC7C7CC),
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: Color(0xFFE5E5EA)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFFD4AF37)),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 8.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
