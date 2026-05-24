import 'dart:ui';
import 'dart:math' show cos, sin;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';
import 'app_layout.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _schoolController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedClass = 'Class 1';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _schoolController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    final state = Provider.of<AppState>(context, listen: false);
    state.addXp(50);
    
    String displayName = _nameController.text.trim();
    if (displayName.isEmpty) {
      displayName = 'Super Learner';
    }

    // Save actual signup inputs into persistent AppState
    state.updateProfile(
      name: displayName,
      email: _emailController.text.trim().isEmpty ? 'aarav.sharma@school.com' : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? '9876543210' : _phoneController.text.trim(),
      className: _selectedClass,
      school: _schoolController.text.trim().isEmpty ? 'Adyapan Public School' : _schoolController.text.trim(),
    );
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          '🚀 Account Created!',
          style: AdyapanTheme.fredoka(fontSize: 20, color: AdyapanTheme.green, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
         ),
        content: Text(
          'Welcome $displayName! Your student profile has been created and you have unlocked the learning dashboard.',
          style: AdyapanTheme.outfit(fontSize: 14, color: AdyapanTheme.textSub),
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AppLayout()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdyapanTheme.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              minimumSize: const Size(double.infinity, 44),
            ),
            child: Text(
              'Unlock Dashboard',
              style: AdyapanTheme.fredoka(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Optimized height & spacing calculation to prevent overflows and shift card upwards!
    double screenHeight = MediaQuery.of(context).size.height;
    double cardPadding = screenHeight < 700 ? 10 : 14; 
    double cardContentSpacing = screenHeight < 700 ? 6 : 8; 

    return Scaffold(
      resizeToAvoidBottomInset: true, // Automatically resizes view when keyboard opens
      body: Stack(
        children: [
          // 1. DYNAMIC PASTEL BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFD6E0), // Soft pink top-left
                  Color(0xFFFFF0E5), // Soft peach
                  Color(0xFFFFF9F2), // Light cream center
                  Color(0xFFFFEAD2), // Warm yellow-peach bottom-right
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 2. ORGANIC TOP BLOBS
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B70).withOpacity(0.16),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(180),
                  bottomLeft: Radius.circular(100),
                  topRight: Radius.circular(100),
                ),
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B70).withOpacity(0.12),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(150),
                  bottomRight: Radius.circular(80),
                  topLeft: Radius.circular(80),
                ),
              ),
            ),
          ),

          // 3. BACKGROUND HAND-DRAWN DOODLES & HIGH BULB VIA CUSTOM PAINT
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundDoodlesPainter(),
            ),
          ),

          // 4. WOOD/PEACH TABLE BOTTOM BASE
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 35,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFE3C4).withOpacity(0.45),
                border: const Border(
                  top: BorderSide(color: Color(0xFFFFD0A1), width: 1.5),
                ),
              ),
            ),
          ),

          // 5. HORIZONTAL SIDE-BY-SIDE DESK DECORATION ROW (NO OVERLAPPING!)
          Positioned(
            left: 10,
            right: 10,
            bottom: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildRealisticRocket(),
                _buildStackedBooks(),
                _buildStandingCalendar(),
                _buildPencilCup(),
                _buildAlarmClock(),
              ],
            ),
          ),

          // 6. BRAND LOGO AND MAIN SIGNUP FORM CARD (SCROLLABLE TO AVOID KEYBOARD OVERFLOWS!)
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  const SizedBox(height: 4), // Shrunk to shift card higher

                  // TOP BRANDING HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF9B800), // Gold yellow
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ady.',
                              style: GoogleFonts.fredoka(
                                fontSize: 12, 
                                fontWeight: FontWeight.bold, 
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'ADYAPAN',
                              style: GoogleFonts.outfit(
                                fontSize: 4.5, 
                                fontWeight: FontWeight.w900, 
                                color: const Color(0xFF0F172A),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adyapan',
                            style: GoogleFonts.fredoka(
                              fontSize: 20, 
                              fontWeight: FontWeight.w700, 
                              color: const Color(0xFF1E293B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'SCHOOL',
                            style: GoogleFonts.outfit(
                              fontSize: 8.5, 
                              fontWeight: FontWeight.w800, 
                              color: const Color(0xFF64748B),
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 12), // Fixed padding to shift card higher

                  // MAIN SIGNUP CARD (Compact, Rounded, Premium Soft Shadow)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: cardPadding, vertical: cardPadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E293B).withOpacity(0.08),
                          blurRadius: 36,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Rocket icon box
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFB07E), Color(0xFFFF5D7E)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Text('🚀', style: TextStyle(fontSize: 20)),
                          ),
                          SizedBox(height: cardContentSpacing),
                          
                          Text(
                            'Start your future skills journey',
                            style: GoogleFonts.fredoka(
                              fontSize: 16.5, 
                              fontWeight: FontWeight.bold, 
                              color: const Color(0xFF0F172A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Create your student profile and unlock the dashboard.',
                            style: GoogleFonts.outfit(
                              fontSize: 10.5, 
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: cardContentSpacing * 1.2),

                          // INPUT ROW 1: Student Name & Phone
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: _nameController,
                                  hint: 'Student name',
                                  icon: Icons.person_outline_rounded,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildInputField(
                                  controller: _phoneController,
                                  hint: 'Phone',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: cardContentSpacing),

                          // INPUT ROW 2: Email & Class Dropdown
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: _emailController,
                                  hint: 'Email',
                                  icon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 38,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedClass,
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8), size: 18),
                                      style: GoogleFonts.outfit(fontSize: 11.5, color: const Color(0xFF0F172A), fontWeight: FontWeight.w600),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedClass = newValue!;
                                        });
                                      },
                                      items: <String>[
                                        'Class 1',
                                        'Class 2',
                                        'Class 3',
                                        'Class 4',
                                        'Class 5',
                                        'Class 6',
                                        'Class 7',
                                        'Class 8',
                                        'Class 9',
                                        'Class 10'
                                      ].map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Row(
                                            children: [
                                              const Icon(Icons.school_outlined, size: 14, color: Color(0xFF94A3B8)),
                                              const SizedBox(width: 6),
                                              Text(value),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: cardContentSpacing),

                          // INPUT ROW 3: Password with outline eye
                          _buildInputField(
                            controller: _passwordController,
                            hint: 'Password with uppercase and number',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              child: const Icon(
                                Icons.visibility_outlined,
                                color: Color(0xFF94A3B8),
                                size: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: cardContentSpacing),

                          // INPUT ROW 4: Confirm Password with outline eye
                          _buildInputField(
                            controller: _confirmPasswordController,
                            hint: 'Confirm password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                              child: const Icon(
                                Icons.visibility_outlined,
                                color: Color(0xFF94A3B8),
                                size: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: cardContentSpacing),

                          // INPUT ROW 5: School Name
                          _buildInputField(
                            controller: _schoolController,
                            hint: 'School name',
                            icon: Icons.domain_outlined,
                          ),
                          
                          SizedBox(height: cardContentSpacing * 1.2),

                          // CREATE ACCOUNT GRADIENT BUTTON (Compact 40px Height)
                          GestureDetector(
                            onTap: _handleSignup,
                            child: Container(
                              width: double.infinity,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF2D55), Color(0xFFFF9F0A)], 
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF2D55).withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Create Account',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 13.5, 
                                      fontWeight: FontWeight.bold, 
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 15),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: cardContentSpacing),

                          // GOOGLE SIGN IN BUTTON (Compact 38px Height)
                          OutlinedButton.icon(
                            onPressed: _handleSignup,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 38),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            icon: const GoogleLogo(size: 15), 
                            label: Text(
                              'Google',
                              style: GoogleFonts.outfit(
                                fontSize: 12.5, 
                                color: const Color(0xFF334155),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: cardContentSpacing),

                          // Already have account? Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  );
                                },
                                child: Text(
                                  'Login',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11, 
                                    color: const Color(0xFFFF2D55), 
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 112), // Safe padding to clear bottom positioned graphics
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // REUSABLE TEXT FIELD BUILDER
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      height: 38,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.outfit(fontSize: 11.5, color: const Color(0xFF0F172A), fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(fontSize: 10.5, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 15),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFFB07E), width: 1.5),
          ),
        ),
      ),
    );
  }

  // 3D REALISTIC BOOK BUILDER (WITH SPINE, COVER LAYERS & INSET PAGES SHEETS)
  Widget _buildRealisticBook({
    required double width,
    required double height,
    required Color coverColor,
    required String spineText,
    required Color textColor,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // White paper pages block inside book
          Positioned(
            top: 2,
            bottom: 2,
            left: 6,
            right: 2,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFCFCFC),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(2),
                  bottomRight: Radius.circular(2),
                ),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  2,
                  (index) => Container(
                    height: 0.5,
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
              ),
            ),
          ),
          
          // Left Spine of book (rounded & 3D shaded, text printed and naturally integrated)
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: 22,
            child: Container(
              decoration: BoxDecoration(
                color: coverColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                  topRight: Radius.circular(1.5),
                  bottomRight: Radius.circular(1.5),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.transparent,
                    Colors.black.withOpacity(0.15),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                spineText,
                style: GoogleFonts.fredoka(
                  fontSize: 7.0,
                  fontWeight: FontWeight.w900,
                  color: textColor.withOpacity(0.85),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

          // Top Cover flap (drawn above pages to show realistic cover)
          Positioned(
            top: 0,
            left: 20,
            right: 0,
            height: 2.2,
            child: Container(
              decoration: BoxDecoration(
                color: coverColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(2),
                ),
              ),
            ),
          ),

          // Bottom Cover flap
          Positioned(
            bottom: 0,
            left: 20,
            right: 0,
            height: 2.2,
            child: Container(
              decoration: BoxDecoration(
                color: coverColor,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Realistic horizontal stacked books with Succulent plant on top (Heights increased for premium book view!)
  Widget _buildStackedBooks() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🪴', style: TextStyle(fontSize: 22)),
        const SizedBox(height: 2),
        // Learn (Yellow)
        _buildRealisticBook(
          width: 76,
          height: 18,
          coverColor: const Color(0xFFFFD600),
          spineText: 'LEARN',
          textColor: const Color(0xFF4A3E00),
        ),
        const SizedBox(height: 2),
        // Grow (Pinkish-Red)
        _buildRealisticBook(
          width: 82,
          height: 18,
          coverColor: const Color(0xFFFF2D55),
          spineText: 'GROW',
          textColor: Colors.white,
        ),
        const SizedBox(height: 2),
        // Succeed (Blue)
        _buildRealisticBook(
          width: 88,
          height: 20,
          coverColor: const Color(0xFF007AFF),
          spineText: 'SUCCEED',
          textColor: Colors.white,
        ),
      ],
    );
  }

  // HIGH-FIDELITY STANDING A-FRAME CALENDAR WIDGET WITH LOOP SPIRALS & STAND DEPTH
  Widget _buildStandingCalendar() {
    return SizedBox(
      width: 78,
      height: 94,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Dark Blue Back Frame Base (standing easel support frame)
          Positioned(
            top: 8,
            left: 2,
            right: 2,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A), 
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
            ),
          ),
          
          // 2. White notepad page (shifted up, overlaying base frame)
          Positioned(
            top: 12,
            left: 5,
            right: 5,
            bottom: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Every step\ntoday,\na success\ntomorrow.',
                        style: GoogleFonts.outfit(
                          fontSize: 8.0,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFF2D55),
                          height: 1.15,
                          letterSpacing: 0.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Smiling face at bottom
                  Text(
                    '•‿•',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF2D55),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 3. Four Gold Spiral Rings at the top
          Positioned(
            top: 2,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (index) => Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD600), // Gold metallic color
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HIGH-FIDELITY 3D PENCIL CUP WITH INNER rim DEPTH & SHADED CYLINDER & DETAILED PENCILS
  Widget _buildPencilCup() {
    return SizedBox(
      width: 32,
      height: 64,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Detailed pencils sticking out
          // Blue Pencil (angled left)
          Positioned(
            top: 2,
            left: 4,
            child: Transform.rotate(
              angle: -0.25,
              child: _buildDetailedPencil(
                color: const Color(0xFF007AFF),
                height: 28,
              ),
            ),
          ),
          
          // Red Pencil (straight up)
          Positioned(
            top: -2,
            left: 14,
            child: _buildDetailedPencil(
              color: const Color(0xFFFF2D55),
              height: 30,
            ),
          ),
          
          // Yellow Pencil (angled right)
          Positioned(
            top: 2,
            right: 4,
            child: Transform.rotate(
              angle: 0.25,
              child: _buildDetailedPencil(
                color: const Color(0xFFFFD600),
                height: 28,
              ),
            ),
          ),
          
          // Cup body rounded cylinder
          Container(
            width: 30,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
                topLeft: Radius.circular(2),
                topRight: Radius.circular(2),
              ),
              border: Border.all(color: Colors.white, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
              // Cylinder 3D Shaded gradient
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFC633), // Darker edge shadow
                  Color(0xFFFFE082), // Glowing reflection center
                  Color(0xFFFFB300), // Original yellow-gold body
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                '⭐',
                style: TextStyle(
                  fontSize: 8,
                  color: Color(0xFFFFB300),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Inner black shadow rim at top to show hollow depth
          Positioned(
            top: 20,
            child: Container(
              width: 27.6,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Detailed Pencil Builder (Body + Tan wood collar + Grey lead tip)
  Widget _buildDetailedPencil({required Color color, required double height}) {
    return SizedBox(
      width: 4,
      height: height,
      child: Column(
        children: [
          // Lead Tip (Grey)
          Container(
            width: 2,
            height: 2,
            decoration: const BoxDecoration(
              color: Color(0xFF475569),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(1),
                topRight: Radius.circular(1),
              ),
            ),
          ),
          // Wood collar (Tan)
          Container(
            width: 3.5,
            height: 3.5,
            color: const Color(0xFFE5C199),
          ),
          // Colored pencil shaft
          Expanded(
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(0.5),
                  bottomRight: Radius.circular(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Purple alarm clock sitting on a pink book base
  Widget _buildAlarmClock() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 38,
          height: 44,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Bells
              Positioned(
                top: 2,
                left: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF5856D6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF5856D6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Handle loop
              Positioned(
                top: 0,
                child: Container(
                  width: 14,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: const Color(0xFF8E8E93), width: 1.5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7),
                    ),
                  ),
                ),
              ),
              // Clock main body (Purple)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF5856D6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.2),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Hands
                      Positioned(
                        top: 4,
                        child: Container(
                          width: 1.2,
                          height: 8,
                          color: const Color(0xFF1C1C1E),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        child: Container(
                          width: 8,
                          height: 1.2,
                          color: const Color(0xFF1C1C1E),
                        ),
                      ),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1C1C1E),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Legs
              Positioned(
                bottom: 0,
                left: 4,
                child: Transform.rotate(
                  angle: -0.4,
                  child: Container(
                    width: 2.5,
                    height: 6,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 4,
                child: Transform.rotate(
                  angle: 0.4,
                  child: Container(
                    width: 2.5,
                    height: 6,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        
        // Realistic Pink book base
        _buildRealisticBookBase(
          width: 56,
          height: 12,
          coverColor: const Color(0xFFFF2D55),
        ),
      ],
    );
  }

  // Realistic horizontal single book base helper
  Widget _buildRealisticBookBase({
    required double width,
    required double height,
    required Color coverColor,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Pages
          Positioned(
            top: 1.5,
            bottom: 1.5,
            left: 5,
            right: 2,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFCFCFC),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(1.5),
                  bottomRight: Radius.circular(1.5),
                ),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 0.4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  2,
                  (index) => Container(
                    height: 0.4,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
              ),
            ),
          ),
          // Left rounded Spine
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: 6,
            child: Container(
              decoration: BoxDecoration(
                color: coverColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  bottomLeft: Radius.circular(2),
                  topRight: Radius.circular(1),
                  bottomRight: Radius.circular(1),
                ),
              ),
            ),
          ),
          // Top Cover
          Positioned(
            top: 0,
            left: 8,
            right: 0,
            height: 1.8,
            child: Container(
              decoration: BoxDecoration(
                color: coverColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(1.5),
                ),
              ),
            ),
          ),
          // Bottom Cover
          Positioned(
            bottom: 0,
            left: 8,
            right: 0,
            height: 1.8,
            child: Container(
              decoration: BoxDecoration(
                color: coverColor,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // VECTOR-BASED HIGHLY DETAILED TOY ROCKET FLYING UPRIGHT WITH PUFFY BASE SMOKE
  Widget _buildRealisticRocket() {
    return SizedBox(
      width: 65,
      height: 110,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // 1. Puffy clouds smoke base
          Positioned(
            bottom: 0,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 52,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                ),
                Positioned(
                  bottom: 4,
                  left: 6,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 6,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(color: Color(0xFFE2E8F0), shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          
          // 2. Bright launching flame
          Positioned(
            bottom: 18,
            child: Container(
              width: 14,
              height: 22,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF9F0A), Color(0xFFFF375F)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(7),
                  bottomRight: Radius.circular(7),
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
              ),
            ),
          ),
          
          // 3. Side Fins (Red)
          Positioned(
            bottom: 28,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left fin angled
                Transform.rotate(
                  angle: -0.4,
                  child: Container(
                    width: 14,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF2D55),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 28),
                // Right fin angled
                Transform.rotate(
                  angle: 0.4,
                  child: Container(
                    width: 14,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF2D55),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Rocket Main Body
          Positioned(
            bottom: 28,
            child: Container(
              width: 28,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Red Nose Cone
                  Container(
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF2D55),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                  ),
                  // Circular Blue Window
                  Positioned(
                    top: 24,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 8. MATHEMATICALLY PRECISE CUSTOM GOOGLE G LOGO PAINTER
class GoogleLogoPainter extends CustomPainter {
  @override
  bool shouldRepaint(_) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final length = size.width;
    final verticalOffset = (size.height / 2) - (length / 2);
    final bounds = Offset(0, verticalOffset) & Size.square(length);
    final center = bounds.center;
    final arcThickness = size.width / 4.5;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = arcThickness;

    void drawArc(double startAngle, double sweepAngle, Color color) {
      canvas.drawArc(bounds, startAngle, sweepAngle, false, paint..color = color);
    }

    // Precise segment angles for the Google logo
    drawArc(3.5, 1.9, const Color(0xFFEA4335)); // Red
    drawArc(2.5, 1.0, const Color(0xFFFBBC05)); // Yellow
    drawArc(0.9, 1.6, const Color(0xFF34A853)); // Green
    drawArc(-0.18, 1.1, const Color(0xFF4285F4)); // Blue

    canvas.drawRect(
      Rect.fromLTRB(
        center.dx,
        center.dy - (arcThickness / 2),
        bounds.centerRight.dx + (arcThickness / 2) - 1,
        bounds.centerRight.dy + (arcThickness / 2),
      ),
      paint
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.fill
        ..strokeWidth = 0,
    );
  }
}

// 9. GOOGLE LOGO STATUTORY ICON WIDGET
class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GoogleLogoPainter(),
      size: Size.square(size),
    );
  }
}

// 10. BACKGROUND DOODLES PAINTER (HAND-DRAWN SUSPENDED WIRE LIGHTBULB SHIFTED HIGHER, GRIDS OF DOTS, SUN, AIRPLANES, STARS, HEART, CLOUD)
class BackgroundDoodlesPainter extends CustomPainter {
  @override
  bool shouldRepaint(_) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // A. Wavy Hanging Wire and Lightbulb on the top-right (Shifted UP to y=50-80 to make it fully visible!)
    final wirePaint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final wirePath = Path();
    wirePath.moveTo(width - 60, 0);
    // Draw wavy natural hand-drawn loop curve
    wirePath.cubicTo(
      width - 57, 15,
      width - 64, 35,
      width - 60, 50,
    );
    canvas.drawPath(wirePath, wirePaint);

    // Socket
    final socketPaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(width - 60, 53), width: 10, height: 6),
        const Radius.circular(1),
      ),
      socketPaint,
    );

    // Bulb outline & radial glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFBBF24).withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(width - 60, 68), 16, glowPaint);

    final bulbPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Pear shape bulb
    final bulbPath = Path();
    bulbPath.moveTo(width - 64, 56);
    bulbPath.lineTo(width - 56, 56);
    bulbPath.lineTo(width - 54, 60);
    bulbPath.cubicTo(
      width - 44, 64,
      width - 44, 76,
      width - 60, 80,
    );
    bulbPath.cubicTo(
      width - 76, 76,
      width - 76, 64,
      width - 66, 60,
    );
    bulbPath.close();
    canvas.drawPath(bulbPath, bulbPaint);

    // Filament inside bulb
    final filamentPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final filamentPath = Path();
    filamentPath.moveTo(width - 63, 70);
    filamentPath.lineTo(width - 60, 64);
    filamentPath.lineTo(width - 57, 70);
    canvas.drawPath(filamentPath, filamentPaint);

    // Bulb rays (glow lines)
    final rayPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final rays = [
      Offset(width - 40, 68),
      Offset(width - 80, 68),
      Offset(width - 60, 88),
      Offset(width - 46, 78),
      Offset(width - 74, 78),
      Offset(width - 46, 58),
      Offset(width - 74, 58),
    ];
    for (var ray in rays) {
      final center = Offset(width - 60, 68);
      final dir = (ray - center).normalized();
      canvas.drawLine(center + dir * 18, center + dir * 24, rayPaint);
    }

    // B. Grids of dots
    void drawDotGrid(double x, double y) {
      final paint = Paint()
        ..color = const Color(0xFFFF5D8F).withOpacity(0.22)
        ..style = PaintingStyle.fill;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 4; j++) {
          canvas.drawCircle(Offset(x + i * 8, y + j * 8), 1.5, paint);
        }
      }
    }
    drawDotGrid(20, 240);
    drawDotGrid(width - 40, 260);
    drawDotGrid(width - 36, height - 300);

    // C. Cute Sun at Bottom Left
    final sunCenter = Offset(40, height - 230);
    final sunPaint = Paint()
      ..color = const Color(0xFFF97316).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(sunCenter, 8, sunPaint);
    
    // Sun rays
    for (int i = 0; i < 8; i++) {
      final angle = i * (3.14159 / 4);
      final start = sunCenter + Offset(cos(angle) * 11, sin(angle) * 11);
      final end = sunCenter + Offset(cos(angle) * 15, sin(angle) * 15);
      canvas.drawLine(start, end, sunPaint);
    }

    // D. Paper Airplanes with dashed paths
    void drawPaperAirplane(double x, double y, double rotationAngle) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotationAngle);
      
      final planePaint = Paint()
        ..color = const Color(0xFF6366F1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      final path = Path();
      path.moveTo(0, 0);
      path.lineTo(-14, 4);
      path.lineTo(-4, -6);
      path.close();
      canvas.drawPath(path, planePaint);
      
      final line = Path();
      line.moveTo(-14, 4);
      line.lineTo(-8, 0);
      line.lineTo(0, 0);
      canvas.drawPath(line, planePaint);
      
      canvas.restore();
    }

    // Top Right Airplane
    drawPaperAirplane(width - 110, 120, -0.2);
    final pathPaint = Paint()
      ..color = const Color(0xFF94A3B8).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final loop1 = Path();
    loop1.moveTo(width - 200, 160);
    loop1.quadraticBezierTo(width - 150, 180, width - 110, 120);
    _drawDashedPath(canvas, loop1, pathPaint);

    // Bottom Right Airplane
    drawPaperAirplane(width - 50, height - 340, 0.4);
    final loop2 = Path();
    loop2.moveTo(width - 120, height - 280);
    loop2.quadraticBezierTo(width - 80, height - 300, width - 50, height - 340);
    _drawDashedPath(canvas, loop2, pathPaint);

    // E. Cute Stars
    void drawStar(double x, double y, double size, Color color, bool fill) {
      final starPaint = Paint()
        ..color = color
        ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 1.0;
      final path = Path();
      final double angle = 3.14159 / 5;
      for (int i = 0; i < 10; i++) {
        final double r = (i % 2 == 0) ? size : size / 2.2;
        final double currAngle = i * angle - 3.14159 / 2;
        final double px = x + cos(currAngle) * r;
        final double py = y + sin(currAngle) * r;
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, starPaint);
    }
    drawStar(70, 140, 6, const Color(0xFFF59E0B), false);
    drawStar(width - 30, 420, 5, const Color(0xFFF97316), false);
    drawStar(width - 80, height - 280, 5, const Color(0xFFFBBF24), false);

    // F. Pink outline Heart at Bottom Right
    final heartPaint = Paint()
      ..color = const Color(0xFFEC4899).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final heartPath = Path();
    final double hx = width - 110;
    final double hy = height - 250;
    heartPath.moveTo(hx, hy + 4);
    heartPath.cubicTo(hx - 5, hy - 2, hx - 10, hy + 2, hx, hy + 12);
    heartPath.cubicTo(hx + 10, hy + 2, hx + 5, hy - 2, hx, hy + 4);
    canvas.drawPath(heartPath, heartPaint);

    // G. Cloud at Top Left
    final cloudPaint = Paint()
      ..color = const Color(0xFF94A3B8).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final cloudPath = Path();
    cloudPath.moveTo(100, 180);
    cloudPath.cubicTo(90, 175, 80, 185, 90, 195);
    cloudPath.cubicTo(85, 205, 105, 210, 110, 200);
    cloudPath.cubicTo(120, 200, 125, 190, 115, 185);
    cloudPath.cubicTo(115, 175, 105, 175, 100, 180);
    canvas.drawPath(cloudPath, cloudPaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final double dashLength = 4.0;
    final double gapLength = 4.0;
    
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? dashLength : gapLength;
        if (draw) {
          final Path extract = metric.extractPath(distance, distance + length);
          canvas.drawPath(extract, paint);
        }
        distance += length;
        draw = !draw;
      }
    }
  }
}

// Vector math extension helper
extension OffsetExt on Offset {
  Offset normalized() {
    final double len = distance;
    if (len == 0) return Offset.zero;
    return Offset(dx / len, dy / len);
  }
}
