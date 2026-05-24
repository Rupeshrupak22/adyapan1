import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';
import 'app_layout.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final state = Provider.of<AppState>(context, listen: false);
    state.addXp(10); // Reward a quick login XP!
    
    // Smooth transition straight to Main Dashboard Shell
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AppLayout()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF4FF), // Creamy pastel blue background
      body: Stack(
        children: [
          // 1. PASTEL GRADIENT ORBS (TOP-LEFT PINK, BOTTOM-RIGHT YELLOW)
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFFF7E9D).withOpacity(0.15), // Pink
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: const Color(0xFFF9B800).withOpacity(0.08), // Yellow
                shape: BoxShape.circle,
              ),
            ),
          ),

          // scattered school doodles
          const Positioned(top: 100, left: 30, child: Text('✏️', style: TextStyle(fontSize: 20))),
          const Positioned(top: 250, left: 16, child: Text('🍎', style: TextStyle(fontSize: 22))),
          const Positioned(top: 80, right: 80, child: Text('📐', style: TextStyle(fontSize: 16))),
          const Positioned(top: 220, right: 24, child: Text('💯', style: TextStyle(fontSize: 20))),
          const Positioned(top: 360, right: 16, child: Text('🧬', style: TextStyle(fontSize: 22))),

          // 2. SCROLLABLE CONTENT BODY
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Top Brand Logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF9B800), // Gold yellow circle
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'ady.',
                            style: GoogleFonts.fredoka(
                              fontSize: 14, 
                              fontWeight: FontWeight.bold, 
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Adyapan',
                              style: GoogleFonts.fredoka(
                                fontSize: 22, 
                                fontWeight: FontWeight.w700, 
                                color: const Color(0xFF1E293B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'SCHOOL',
                              style: GoogleFonts.outfit(
                                fontSize: 9, 
                                fontWeight: FontWeight.w800, 
                                color: const Color(0xFF64748B),
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 24),

                    // CENTRAL GLASS CARD
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E293B).withOpacity(0.06),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Lock Icon Box
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE0E7FF), Color(0xFFEEF2F6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFC7D2FE), width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: const Text('🔓', style: TextStyle(fontSize: 26)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Welcome back',
                            style: GoogleFonts.fredoka(
                              fontSize: 20, 
                              fontWeight: FontWeight.bold, 
                              color: const Color(0xFF0F172A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Continue learning with your future skills dashboard.',
                            style: GoogleFonts.outfit(
                              fontSize: 12, 
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // EMAIL input field
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Email',
                              style: GoogleFonts.outfit(
                                fontSize: 13, 
                                fontWeight: FontWeight.bold, 
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildField(
                            controller: _emailController,
                            hint: 'student@example.com',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // PASSWORD input field
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Password',
                              style: GoogleFonts.outfit(
                                fontSize: 13, 
                                fontWeight: FontWeight.bold, 
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildField(
                            controller: _passwordController,
                            hint: 'Password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: const Color(0xFF94A3B8),
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // LOGIN GRADIENT BUTTON
                          GestureDetector(
                            onTap: _handleLogin,
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2563EB), Color(0xFFEC4899)], // Blue-to-Pink gradient
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB).withOpacity(0.25),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  )
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Login',
                                style: GoogleFonts.fredoka(
                                  fontSize: 15, 
                                  fontWeight: FontWeight.bold, 
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // GOOGLE BYPASS BUTTON
                          OutlinedButton.icon(
                            onPressed: _handleLogin,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFFF1F5F9)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: Container(
                              width: 18,
                              height: 18,
                              alignment: Alignment.center,
                              child: const Text('G', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueAccent)),
                            ),
                            label: Text(
                              'Google',
                              style: GoogleFonts.outfit(
                                fontSize: 13, 
                                color: const Color(0xFF334155),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Footer Navigate to SignUp
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'New to ADYAPAN? ',
                                style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                                  );
                                },
                                child: Text(
                                  'Create account',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12, 
                                    color: const Color(0xFF2563EB), 
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // LOWER PREMIUM DESK GRAPHICS
                    _buildLowerDeskDecoration(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF0F172A), fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 18),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFC7D2FE), width: 1.5),
          ),
        ),
      ),
    );
  }

  // Premium Custom 3D Desk visual rendering: Blue Backpack with ady logo, Globe, Succulent, and Stacked Books
  Widget _buildLowerDeskDecoration() {
    return SizedBox(
      width: double.infinity,
      height: 120,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Stacked Books (Left)
          Positioned(
            left: 20,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB07E),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
                  ),
                ),
                const SizedBox(height: 1),
                Container(
                  width: 74,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3366),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
                  ),
                ),
                const SizedBox(height: 1),
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3388FF),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
                  ),
                ),
              ],
            ),
          ),

          // 2. Green Succulent plant (on top of books)
          const Positioned(
            left: 38,
            bottom: 45,
            child: Text('🪴', style: TextStyle(fontSize: 22)),
          ),

          // 3. Huge Blue-Yellow Backpack (Center)
          Positioned(
            bottom: 0,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Main Backpack body
                Container(
                  width: 90,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A), // Royal dark blue
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                ),
                // Yellow Pocket
                Positioned(
                  bottom: 6,
                  child: Container(
                    width: 70,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B), // Golden yellow
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(color: Color(0xFFF9B800), shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(
                        'ady.', 
                        style: GoogleFonts.fredoka(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      ),
                    ),
                  ),
                ),
                // Handle strap top
                Positioned(
                  top: 2,
                  child: Container(
                    width: 24,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: const Color(0xFFF59E0B), width: 3),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                    ),
                  ),
                )
              ],
            ),
          ),

          // 4. Globe on stand (Right)
          Positioned(
            right: 20,
            bottom: 0,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Golden stand loop
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: const Color(0xFF94A3B8), width: 3.5),
                    shape: BoxShape.circle,
                  ),
                ),
                // Stand base
                Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(color: const Color(0xFF64748B), borderRadius: BorderRadius.circular(10)),
                ),
                // Globe ball
                Positioned(
                  bottom: 6,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981), // Green continents
                      border: Border.all(color: const Color(0xFF3B82F6), width: 6), // Blue ocean boundary
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
