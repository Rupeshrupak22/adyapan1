import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';
import 'app_layout.dart';
import 'signup_screen.dart';
import 'teacher_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  String _userRole = 'student'; // 'student' or 'teacher'

  @override
  void initState() {
    super.initState();
    // Micro-animations controller for floating elements
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final state = Provider.of<AppState>(context, listen: false);
    
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Please fill in both email and password.', style: AdyapanTheme.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        )
      );
      return;
    }

    if (!email.endsWith('@gmail.com') && !email.endsWith('@adyapan.com')) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Email must end with @gmail.com or @adyapan.com', style: AdyapanTheme.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        )
      );
      return;
    }

    try {
      final loginSuccess = await state.loginUser(email, password);
      if (!mounted) return;
      if (loginSuccess) {
        // Login successful!
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.userRole == 'teacher'
                        ? 'Welcome back Educator! Login successful.'
                        : 'Welcome back Student! Login successful.',
                    style: AdyapanTheme.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AdyapanTheme.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )
        );

        if (state.userRole == 'teacher') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AppLayout()),
          );
        }
      } else {
        // Invalid credentials
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Invalid Email or Password. Please register first!', style: AdyapanTheme.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Database Connection Failed!\n$e', style: AdyapanTheme.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.red[900],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 8),
        )
      );
    }
  }

  void _handleGoogleLogin() async {
    final state = Provider.of<AppState>(context, listen: false);
    
    // Auto-login using preloaded Aarav Sharma account!
    final googleEmail = 'aarav.sharma@gmail.com';
    const googlePassword = 'password123';
    
    _emailController.text = googleEmail;
    _passwordController.text = googlePassword;
    
    try {
      // Auto-register google account if it doesn't exist yet!
      if (!state.userCredentials.containsKey(googleEmail)) {
        await state.registerUser(
          email: googleEmail,
          password: googlePassword,
          name: 'Aarav Sharma',
          phone: '9876543210',
          className: 'Class 10',
          school: 'Adyapan Public School',
        );
      }
      
      await state.loginUser(googleEmail, googlePassword);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🚀', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Google Quick-Login successful! Welcome, Aarav.',
                  style: AdyapanTheme.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AdyapanTheme.blueAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        )
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppLayout()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Database Connection Failed!\n$e', style: AdyapanTheme.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.red[900],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 8),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Background elements stay fixed and do not jump when keyboard opens!
      backgroundColor: const Color(0xFFFFFDF8), // Creamy off-white background
      body: Stack(
        children: [
          // 1. HIGH-FIDELITY GRADIENTS & WAVY BACKGROUND PAINTER
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundDoodlesPainter(
                airplaneAnimValue: _animationController.value,
              ),
            ),
          ),

          // 2. MAIN SCROLLABLE CONTENT BODY
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()), // Bouncily scrolls up and down!
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 15),

                    // Top Brand Header Logo Widget
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Yellow circle badge with "ady."
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFC000), // Rich Golden Yellow
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ady.',
                                style: GoogleFonts.fredoka(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.w800, 
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                'ADYAPAN',
                                style: GoogleFonts.outfit(
                                  fontSize: 5, 
                                  fontWeight: FontWeight.w900, 
                                  color: const Color(0xFF1E293B).withOpacity(0.8),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Title Column
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Adyapan',
                              style: GoogleFonts.fredoka(
                                fontSize: 28, 
                                fontWeight: FontWeight.bold, 
                                color: const Color(0xFF1B2A4A),
                                letterSpacing: 0.2,
                              ),
                            ),
                            Text(
                              'SCHOOL',
                              style: GoogleFonts.outfit(
                                fontSize: 10, 
                                fontWeight: FontWeight.w900, 
                                color: const Color(0xFF3B82F6), // Sky blue subtitle
                                letterSpacing: 2.5,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 28),

                    // CENTRAL PREMIUM GLASS CARD
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E293B).withOpacity(0.06),
                            blurRadius: 40,
                            offset: const Offset(0, 15),
                          ),
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Glow gradient padlock container box
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, math.sin(_animationController.value * math.pi * 2) * 2),
                                child: child,
                              );
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFECF3FF),
                                    const Color(0xFFFCEEFA),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                              ),
                              alignment: Alignment.center,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFD946EF), width: 2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFD946EF),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Custom Painted Lock icon inside container
                          const SizedBox(height: 16),
                          Text(
                            'Welcome back',
                            style: GoogleFonts.fredoka(
                              fontSize: 24, 
                              fontWeight: FontWeight.bold, 
                              color: const Color(0xFF1B2A4A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _userRole == 'student'
                                ? 'Continue learning with your future skills dashboard.'
                                : 'Manage your students, assignments, and class standings.',
                            style: GoogleFonts.outfit(
                              fontSize: 12, 
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // ROLE SELECTOR TOGGLE (Student vs Teacher)
                          Container(
                            height: 40,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _userRole = 'student';
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _userRole == 'student' ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: _userRole == 'student'
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.05),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                )
                                              ]
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Student 🎓',
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: _userRole == 'student' ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _userRole = 'teacher';
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _userRole == 'teacher' ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: _userRole == 'teacher'
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.05),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                )
                                              ]
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Teacher 🍎',
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: _userRole == 'teacher' ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // EMAIL input field
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 6),
                              child: Text(
                                'Email',
                                style: GoogleFonts.outfit(
                                  fontSize: 13, 
                                  fontWeight: FontWeight.bold, 
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                          _buildField(
                            controller: _emailController,
                            hint: _userRole == 'student' ? 'student@example.com' : 'teacher@example.com',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 18),

                          // PASSWORD input field
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 6),
                              child: Text(
                                'Password',
                                style: GoogleFonts.outfit(
                                  fontSize: 13, 
                                  fontWeight: FontWeight.bold, 
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                          _buildField(
                            controller: _passwordController,
                            hint: 'Password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: const Color(0xFF64748B),
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

                          // LOGIN GRADIENT BUTTON (Blue to Pink/Magenta)
                          GestureDetector(
                            onTap: _handleLogin,
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2563EB), // Vibrant blue
                                    Color(0xFFEC4899), // Hot pink
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB).withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Login',
                                style: GoogleFonts.fredoka(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold, 
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // GOOGLE BUTTON WITH CUSTOM PAINTED LOGO
                          OutlinedButton(
                            onPressed: _handleGoogleLogin,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Multicolored Custom Painted Google G Logo
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CustomPaint(
                                    painter: GoogleIconPainter(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Google',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14, 
                                    color: const Color(0xFF334155),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Footer Navigate to SignUp
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'New to ADYAPAN? ',
                                style: GoogleFonts.outfit(
                                  fontSize: 12, 
                                  color: const Color(0xFF64748B), 
                                  fontWeight: FontWeight.w500,
                                ),
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
                    const SizedBox(height: 20),

                    // LOWER DESK ILLUSTRATION GRAPHIC
                    _buildLowerDeskDecoration(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // MAGIC WAND SPARKLE FLOATING BUTTON IN BOTTOM RIGHT
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: () {
                // Instantly trigger a fun lofi custom toast!
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Premium Focus Mode active. Get ready to learn like a superhero!',
                            style: GoogleFonts.fredoka(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF1B2A4A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  )
                );
              },
              backgroundColor: const Color(0xFF475569).withOpacity(0.85),
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
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
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF0F172A), fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 18),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFC7D2FE), width: 1.5),
          ),
        ),
      ),
    );
  }

  // Gorgeous 3D Cartoon Desk Illustration: Books, Succulent, Backpack with ady circular logo, and Globe on loop stand
  Widget _buildLowerDeskDecoration() {
    return SizedBox(
      width: double.infinity,
      height: 160,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Floor base shadow/floor wavy line
          Positioned(
            bottom: -20,
            left: -20,
            right: -20,
            child: SizedBox(
              height: 60,
              child: CustomPaint(
                painter: WavyFloorPainter(),
              ),
            ),
          ),

          // 1. Stacked Books (Left)
          Positioned(
            left: 10,
            bottom: 0,
            child: CustomPaint(
              size: const Size(90, 50),
              painter: BooksStackPainter(),
            ),
          ),

          // 2. Green Succulent plant (resting on top of books)
          Positioned(
            left: 32,
            bottom: 45,
            child: CustomPaint(
              size: const Size(40, 45),
              painter: SucculentPlantPainter(),
            ),
          ),

          // 3. Yellow and Blue School Backpack (Center)
          Positioned(
            bottom: -8,
            child: CustomPaint(
              size: const Size(120, 130),
              painter: BackpackPainter(),
            ),
          ),

          // 4. Globe on Golden loop Stand (Right)
          Positioned(
            right: 12,
            bottom: 0,
            child: CustomPaint(
              size: const Size(80, 85),
              painter: GlobeStandPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// CUSTOM PAINTERS & DRAWING CODE
// ----------------------------------------------------

class BackgroundDoodlesPainter extends CustomPainter {
  final double airplaneAnimValue;
  BackgroundDoodlesPainter({required this.airplaneAnimValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // A. CORNER GRADIENT ORGANIC BLOBS
    // 1. Top-Left Blob (Soft Lavender/Purple wave)
    paint.shader = const LinearGradient(
      colors: [Color(0xFFE2D6FF), Color(0xFFF1EAFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width * 0.45, size.height * 0.25));
    final pathTL = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.45, 0)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.08, size.width * 0.25, size.height * 0.12)
      ..quadraticBezierTo(size.width * 0.12, size.height * 0.16, 0, size.height * 0.22)
      ..close();
    canvas.drawPath(pathTL, paint);

    // 2. Top-Right Blob (Pink/Peach wave)
    paint.shader = const LinearGradient(
      colors: [Color(0xFFFDE8E2), Color(0xFFFFF0EC)],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ).createShader(Rect.fromLTWH(size.width * 0.55, 0, size.width * 0.45, size.height * 0.2));
    final pathTR = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width * 0.55, 0)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.06, size.width * 0.75, size.height * 0.09)
      ..quadraticBezierTo(size.width * 0.88, size.height * 0.12, size.width, size.height * 0.18)
      ..close();
    canvas.drawPath(pathTR, paint);

    // 3. Bottom-Left Blob (Lavender purple wave)
    paint.shader = const LinearGradient(
      colors: [Color(0xFFEFE8FF), Color(0xFFF5EFFF)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ).createShader(Rect.fromLTWH(0, size.height * 0.8, size.width * 0.35, size.height * 0.2));
    final pathBL = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.82)
      ..quadraticBezierTo(size.width * 0.08, size.height * 0.88, size.width * 0.15, size.height * 0.9)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.92, size.width * 0.3, size.height)
      ..close();
    canvas.drawPath(pathBL, paint);

    // 4. Bottom-Right Blob (Peach pink wave)
    paint.shader = const LinearGradient(
      colors: [Color(0xFFFDE2EC), Color(0xFFFFF0F5)],
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
    ).createShader(Rect.fromLTWH(size.width * 0.65, size.height * 0.8, size.width * 0.35, size.height * 0.2));
    final pathBR = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.92, size.height * 0.88, size.width * 0.85, size.height * 0.9)
      ..quadraticBezierTo(size.width * 0.72, size.height * 0.94, size.width * 0.68, size.height)
      ..close();
    canvas.drawPath(pathBR, paint);

    // B. FLOATING DOODLES & PATH LINES
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // 1. Dash-trail and flying paper airplane in Top Right area
    strokePaint.color = Colors.purple.withOpacity(0.35);
    final airplaneTrail = Path()
      ..moveTo(size.width * 0.9, size.height * 0.22)
      ..quadraticBezierTo(
        size.width * 0.82, size.height * 0.1,
        size.width * 0.75, size.height * 0.14,
      )
      ..quadraticBezierTo(
        size.width * 0.66, size.height * 0.18,
        size.width * 0.65, size.height * 0.08,
      );
    // Draw dashed line
    _drawDashedPath(canvas, airplaneTrail, strokePaint);

    // Draw the folded paper airplane
    final planeCenter = Offset(
      size.width * 0.65 + math.sin(airplaneAnimValue * 0.1) * 10,
      size.height * 0.08 + math.cos(airplaneAnimValue * 0.1) * 8,
    );
    final airplanePaint = Paint()
      ..color = const Color(0xFFD946EF).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final airplanePath = Path()
      ..moveTo(planeCenter.dx, planeCenter.dy)
      ..lineTo(planeCenter.dx + 25, planeCenter.dy - 10)
      ..lineTo(planeCenter.dx + 12, planeCenter.dy + 15)
      ..close()
      ..moveTo(planeCenter.dx + 12, planeCenter.dy + 15)
      ..lineTo(planeCenter.dx + 7, planeCenter.dy + 5)
      ..lineTo(planeCenter.dx, planeCenter.dy);
    canvas.drawPath(airplanePath, airplanePaint);

    // 2. Yellow outlines of scattered stars
    final starPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = const Color(0xFFFFB000).withOpacity(0.7);

    _drawStarDoodle(canvas, Offset(size.width * 0.2, size.height * 0.12), 12, starPaint);
    _drawStarDoodle(canvas, Offset(size.width * 0.1, size.height * 0.48), 10, starPaint);
    _drawStarDoodle(canvas, Offset(size.width * 0.9, size.height * 0.48), 9, starPaint);
    _drawStarDoodle(canvas, Offset(size.width * 0.62, size.height * 0.72), 11, starPaint);

    // 3. Hand-drawn blue pencil/pen (Left margin)
    final pencilPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = const Color(0xFF3B82F6).withOpacity(0.7);
    final pencilPath = Path()
      ..moveTo(size.width * 0.12, size.height * 0.24)
      ..lineTo(size.width * 0.08, size.height * 0.29)
      ..lineTo(size.width * 0.09, size.height * 0.3)
      ..lineTo(size.width * 0.13, size.height * 0.25)
      ..close()
      // Tip
      ..moveTo(size.width * 0.08, size.height * 0.29)
      ..lineTo(size.width * 0.06, size.height * 0.3) // Pointy lead
      ..lineTo(size.width * 0.09, size.height * 0.3)
      // Pencil cap stripes
      ..moveTo(size.width * 0.11, size.height * 0.255)
      ..lineTo(size.width * 0.075, size.height * 0.295);
    canvas.drawPath(pencilPath, pencilPaint);

    // 4. Red outline apple (Left margin)
    final applePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = const Color(0xFFEF4444).withOpacity(0.7);
    final applePath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.36)
      ..cubicTo(size.width * 0.06, size.height * 0.34, size.width * 0.05, size.height * 0.38, size.width * 0.08, size.height * 0.4)
      ..cubicTo(size.width * 0.06, size.height * 0.42, size.width * 0.12, size.height * 0.43, size.width * 0.13, size.height * 0.39)
      ..cubicTo(size.width * 0.15, size.height * 0.37, size.width * 0.12, size.height * 0.34, size.width * 0.1, size.height * 0.36)
      // stem
      ..moveTo(size.width * 0.1, size.height * 0.355)
      ..quadraticBezierTo(size.width * 0.11, size.height * 0.34, size.width * 0.12, size.height * 0.345);
    canvas.drawPath(applePath, applePaint);

    // 5. Glowing lightbulb (Right margin)
    final bulbPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = const Color(0xFFFFB000).withOpacity(0.85);
    final bulbPath = Path()
      ..moveTo(size.width * 0.92, size.height * 0.18)
      ..cubicTo(size.width * 0.88, size.height * 0.16, size.width * 0.86, size.height * 0.2, size.width * 0.89, size.height * 0.22)
      ..lineTo(size.width * 0.89, size.height * 0.24)
      ..lineTo(size.width * 0.93, size.height * 0.24)
      ..lineTo(size.width * 0.93, size.height * 0.22)
      ..cubicTo(size.width * 0.96, size.height * 0.2, size.width * 0.95, size.height * 0.16, size.width * 0.92, size.height * 0.18)
      // Screw threads base
      ..moveTo(size.width * 0.89, size.height * 0.24)
      ..lineTo(size.width * 0.91, size.height * 0.25)
      ..lineTo(size.width * 0.93, size.height * 0.24);
    canvas.drawPath(bulbPath, bulbPaint);
    // Draw lofi rays
    canvas.drawLine(Offset(size.width * 0.91, size.height * 0.15), Offset(size.width * 0.91, size.height * 0.13), bulbPaint);
    canvas.drawLine(Offset(size.width * 0.85, size.height * 0.18), Offset(size.width * 0.83, size.height * 0.17), bulbPaint);
    canvas.drawLine(Offset(size.width * 0.97, size.height * 0.18), Offset(size.width * 0.99, size.height * 0.17), bulbPaint);

    // 6. Circled "A+" grade mark (Right margin)
    final gradePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = const Color(0xFFEF4444).withOpacity(0.7);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.35), 14, gradePaint);
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'A+',
        style: GoogleFonts.fredoka(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFEF4444).withOpacity(0.8),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(size.width * 0.88 - 8, size.height * 0.35 - 8));

    // 7. Blue/Purple Atom Orbital (Right margin)
    final atomPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF3B82F6).withOpacity(0.6);
    canvas.save();
    canvas.translate(size.width * 0.88, size.height * 0.46);
    // Draw 3 ellipses rotated
    for (int i = 0; i < 3; i++) {
      canvas.rotate(math.pi / 3);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 32, height: 10), atomPaint);
    }
    // Nucleus
    atomPaint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 3, atomPaint);
    canvas.restore();

    // 8. Golden Music Note (Right margin)
    final notePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = const Color(0xFFEAB308).withOpacity(0.7);
    final notePath = Path()
      ..moveTo(size.width * 0.88, size.height * 0.56)
      ..lineTo(size.width * 0.91, size.height * 0.54)
      ..lineTo(size.width * 0.91, size.height * 0.6)
      ..moveTo(size.width * 0.88, size.height * 0.56)
      ..lineTo(size.width * 0.88, size.height * 0.62);
    canvas.drawPath(notePath, notePaint);
    // Draw note heads
    notePaint.style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromLTWH(size.width * 0.85, size.height * 0.61, 7, 5), notePaint);
    canvas.drawOval(Rect.fromLTWH(size.width * 0.88, size.height * 0.59, 7, 5), notePaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double distance = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }
  }

  void _drawStarDoodle(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const spikes = 5;
    double rot = math.pi / 2 * 3;
    final double step = math.pi / spikes;
    final innerRadius = radius * 0.45;

    path.moveTo(center.dx, center.dy - radius);
    for (int i = 0; i < spikes; i++) {
      double x = center.dx + math.cos(rot) * radius;
      double y = center.dy + math.sin(rot) * radius;
      path.lineTo(x, y);
      rot += step;

      x = center.dx + math.cos(rot) * innerRadius;
      y = center.dy + math.sin(rot) * innerRadius;
      path.lineTo(x, y);
      rot += step;
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ----------------------------------------------------
// FLOOR AND DESK ELEMENT PAINTERS
// ----------------------------------------------------

class WavyFloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF0EC), Color(0xFFFBE6F3)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.4, size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.6, size.width, size.height * 0.45)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BooksStackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1B2A4A).withOpacity(0.3)
      ..strokeWidth = 1.2;

    // 1. Bottom Pink/Red Book
    fillPaint.color = const Color(0xFFFF527B); // Vibrant pinkish red
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, size.height - 20, size.width * 0.95, 18), const Radius.circular(3)), fillPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, size.height - 20, size.width * 0.95, 18), const Radius.circular(3)), strokePaint);
    // Draw white pages side block
    fillPaint.color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(size.width * 0.8, size.height - 18, size.width * 0.12, 14), fillPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.8, size.height - 18, size.width * 0.12, 14), strokePaint);

    // 2. Top Blue Book
    fillPaint.color = const Color(0xFF3B82F6); // Soft blue book
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.08, size.height - 35, size.width * 0.82, 16), const Radius.circular(3)), fillPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.08, size.height - 35, size.width * 0.82, 16), const Radius.circular(3)), strokePaint);
    // Draw white pages
    fillPaint.color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(size.width * 0.76, size.height - 33, size.width * 0.1, 12), fillPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.76, size.height - 33, size.width * 0.1, 12), strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SucculentPlantPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1B2A4A).withOpacity(0.3)
      ..strokeWidth = 1.0;

    // 1. Purple lavender Pot
    fillPaint.color = const Color(0xFFD8B4FE); // Soft pastel purple
    final potPath = Path()
      ..moveTo(size.width * 0.25, size.height)
      ..lineTo(size.width * 0.75, size.height)
      ..lineTo(size.width * 0.82, size.height * 0.6)
      ..lineTo(size.width * 0.18, size.height * 0.6)
      ..close();
    canvas.drawPath(potPath, fillPaint);
    canvas.drawPath(potPath, strokePaint);

    // 2. Green leaves
    fillPaint.color = const Color(0xFF10B981); // Bright green leaves
    // Central leaf
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.38), width: 14, height: 26), fillPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.38), width: 14, height: 26), strokePaint);
    // Left leaf tilted
    canvas.save();
    canvas.translate(size.width * 0.36, size.height * 0.42);
    canvas.rotate(-math.pi / 5);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 11, height: 22), fillPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 11, height: 22), strokePaint);
    canvas.restore();
    // Right leaf tilted
    canvas.save();
    canvas.translate(size.width * 0.64, size.height * 0.42);
    canvas.rotate(math.pi / 5);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 11, height: 22), fillPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 11, height: 22), strokePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BackpackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1B2A4A).withOpacity(0.3)
      ..strokeWidth = 1.5;

    // 0. Stationary item peaks (Ruler & Pencils sticking out from back)
    fillPaint.color = const Color(0xFFC084FC); // Purple ruler
    canvas.drawRect(Rect.fromLTWH(size.width * 0.68, 5, 10, 50), fillPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.68, 5, 10, 50), strokePaint);
    fillPaint.color = const Color(0xFFFACC15); // Yellow pencil
    canvas.save();
    canvas.translate(size.width * 0.35, 12);
    canvas.rotate(-math.pi / 12);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 8, 40), fillPaint);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 8, 40), strokePaint);
    canvas.restore();

    // 1. Handle Strap Loop (Top yellow strap)
    fillPaint.color = const Color(0xFFFFC000);
    final strapPath = Path()
      ..moveTo(size.width * 0.42, 28)
      ..quadraticBezierTo(size.width * 0.5, 12, size.width * 0.58, 28)
      ..quadraticBezierTo(size.width * 0.5, 20, size.width * 0.42, 28);
    canvas.drawPath(strapPath, fillPaint);
    canvas.drawPath(strapPath, strokePaint);

    // 2. Main Blue Backpack Body
    fillPaint.color = const Color(0xFF1B3A4B); // Deep ocean blue
    final mainBody = Path()
      ..moveTo(size.width * 0.2, size.height * 0.88)
      ..quadraticBezierTo(size.width * 0.16, size.height * 0.28, size.width * 0.5, size.height * 0.24)
      ..quadraticBezierTo(size.width * 0.84, size.height * 0.28, size.width * 0.8, size.height * 0.88)
      ..quadraticBezierTo(size.width * 0.72, size.height * 0.94, size.width * 0.5, size.height * 0.94)
      ..quadraticBezierTo(size.width * 0.28, size.height * 0.94, size.width * 0.2, size.height * 0.88)
      ..close();
    canvas.drawPath(mainBody, fillPaint);
    canvas.drawPath(mainBody, strokePaint);

    // 3. Golden Yellow Outer Pocket
    fillPaint.color = const Color(0xFFFFC000); // Golden yellow
    final outerPocket = Path()
      ..moveTo(size.width * 0.26, size.height * 0.86)
      ..quadraticBezierTo(size.width * 0.24, size.height * 0.54, size.width * 0.5, size.height * 0.52)
      ..quadraticBezierTo(size.width * 0.76, size.height * 0.54, size.width * 0.74, size.height * 0.86)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.92, size.width * 0.5, size.height * 0.92)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.92, size.width * 0.26, size.height * 0.86)
      ..close();
    canvas.drawPath(outerPocket, fillPaint);
    canvas.drawPath(outerPocket, strokePaint);

    // 4. Circular Yellow Badge on Pocket with "ady."
    fillPaint.color = const Color(0xFFFFFBEB); // Creamy white circle
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.72), 16, fillPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.72), 16, strokePaint);
    final badgeText = TextPainter(
      text: TextSpan(
        text: 'ady.',
        style: GoogleFonts.fredoka(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1B3A4B),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    badgeText.paint(canvas, Offset(size.width * 0.5 - 8, size.height * 0.72 - 6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GlobeStandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1B2A4A).withOpacity(0.3)
      ..strokeWidth = 1.5;

    // 1. Golden curved stand loop arc
    strokePaint.color = const Color(0xFFFFB000); // Golden stand
    strokePaint.strokeWidth = 3.5;
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.1, size.width * 0.84, size.height * 0.75),
      math.pi * 0.15,
      math.pi * 1.05,
      false,
      strokePaint,
    );
    // Reset stroke paint properties
    strokePaint.color = const Color(0xFF1B2A4A).withOpacity(0.3);
    strokePaint.strokeWidth = 1.2;

    // 2. Golden Loop Stand base
    fillPaint.color = const Color(0xFFFFB000);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.25, size.height - 10, size.width * 0.5, 8), const Radius.circular(4)), fillPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.25, size.height - 10, size.width * 0.5, 8), const Radius.circular(4)), strokePaint);
    // Vertical neck joint
    canvas.drawRect(Rect.fromLTWH(size.width * 0.46, size.height * 0.72, size.width * 0.08, size.height * 0.2), fillPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.46, size.height * 0.72, size.width * 0.08, size.height * 0.2), strokePaint);

    // 3. Globe Sphere (Deep blue ocean)
    fillPaint.color = const Color(0xFF3B82F6); // Ocean blue
    final globeCenter = Offset(size.width * 0.5, size.height * 0.44);
    canvas.drawCircle(globeCenter, 24, fillPaint);
    canvas.drawCircle(globeCenter, 24, strokePaint);

    // 4. Green continents overlay inside circle boundary
    fillPaint.color = const Color(0xFF10B981); // Emerald Green continents
    canvas.save();
    // Clip path to only draw continents inside sphere
    final clipPath = Path()..addOval(Rect.fromCircle(center: globeCenter, radius: 24));
    canvas.clipPath(clipPath);
    // Draw simple geometric shapes representing continents
    final continentPath = Path()
      ..moveTo(globeCenter.dx - 18, globeCenter.dy - 6)
      ..quadraticBezierTo(globeCenter.dx - 10, globeCenter.dy - 12, globeCenter.dx - 5, globeCenter.dy - 8)
      ..quadraticBezierTo(globeCenter.dx, globeCenter.dy - 2, globeCenter.dx - 12, globeCenter.dy + 8)
      ..close()
      ..moveTo(globeCenter.dx + 4, globeCenter.dy - 16)
      ..quadraticBezierTo(globeCenter.dx + 16, globeCenter.dy - 10, globeCenter.dx + 12, globeCenter.dy + 2)
      ..quadraticBezierTo(globeCenter.dx + 2, globeCenter.dy + 6, globeCenter.dx + 4, globeCenter.dy - 16)
      ..close()
      ..moveTo(globeCenter.dx - 4, globeCenter.dy + 10)
      ..addOval(Rect.fromLTWH(globeCenter.dx - 4, globeCenter.dy + 8, 12, 8));
    canvas.drawPath(continentPath, fillPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter to draw the official Google multicoloured icon cleanly
class GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final r = size.width / 2;

    // 1. Red portion (top arc)
    paint.color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(r, r)
      ..lineTo(r - r * 0.707, r - r * 0.707)
      ..arcTo(Rect.fromLTWH(0, 0, size.width, size.height), -math.pi * 0.75, math.pi * 0.5, false)
      ..close();
    canvas.drawPath(redPath, paint);

    // 2. Yellow portion (left arc)
    paint.color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(r, r)
      ..lineTo(r - r * 0.707, r + r * 0.707)
      ..arcTo(Rect.fromLTWH(0, 0, size.width, size.height), -math.pi * 1.25, math.pi * 0.5, false)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // 3. Green portion (bottom arc)
    paint.color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(r, r)
      ..lineTo(r + r * 0.707, r + r * 0.707)
      ..arcTo(Rect.fromLTWH(0, 0, size.width, size.height), -math.pi * 1.75, math.pi * 0.5, false)
      ..close();
    canvas.drawPath(greenPath, paint);

    // 4. Blue portion (right arc + horizontal bar)
    paint.color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(r, r)
      ..lineTo(r, r - r * 0.3)
      ..lineTo(size.width, r - r * 0.3)
      ..lineTo(size.width, r)
      ..arcTo(Rect.fromLTWH(0, 0, size.width, size.height), 0, math.pi * 0.25, false)
      ..lineTo(r, r)
      ..close();
    canvas.drawPath(bluePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
