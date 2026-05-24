import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';
import 'app_layout.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

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
    // Dynamic height calculation to prevent overflows and keep everything fixed on 1 page!
    double screenHeight = MediaQuery.of(context).size.height;
    double cardPadding = screenHeight < 700 ? 12 : 20;
    double cardContentSpacing = screenHeight < 700 ? 8 : 12;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5), // Soft warm pastel yellow-cream
      body: Stack(
        children: [
          // 1. BACKGROUND PASTEL BLOBS & DOODLES
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5D8F).withOpacity(0.18), // Pastel Pink Top Left
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5D8F).withOpacity(0.12), // Pastel Pink Top Right
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Hanging lightbulb (Top Right)
          Positioned(
            top: 0,
            right: 40,
            child: Column(
              children: [
                Container(width: 1.5, height: 60, color: const Color(0xFF94A3B8)), // Cord
                const Text('💡', style: TextStyle(fontSize: 26)), // Lightbulb
              ],
            ),
          ),

          // scattered doodles
          const Positioned(top: 140, left: 30, child: Text('⭐', style: TextStyle(fontSize: 16, color: Colors.orangeAccent))),
          const Positioned(top: 190, right: 30, child: Text('📐', style: TextStyle(fontSize: 14, color: Colors.grey))),
          const Positioned(top: 110, left: 80, child: Text('☁️', style: TextStyle(fontSize: 18, color: Colors.blueGrey))),

          // 2. MAIN LAYOUT CONTAINER (NON-SCROLLABLE / FIXED)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  const SizedBox(height: 6),

                  // TOP BRANDING HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Gold circular logo
                      Container(
                        width: 50,
                        height: 50,
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
                                fontSize: 13, 
                                fontWeight: FontWeight.bold, 
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'ADYAPAN',
                              style: GoogleFonts.outfit(
                                fontSize: 5, 
                                fontWeight: FontWeight.w900, 
                                color: const Color(0xFF0F172A),
                                letterSpacing: 0.3,
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
                  
                  const Spacer(flex: 1),

                  // 3. MAIN SIGNUP FORM CARD (Highly Rounded, Clean Depth)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: cardPadding, vertical: cardPadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E293B).withOpacity(0.06),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
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
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFB07E), Color(0xFFFF5D7E)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: const Text('🚀', style: TextStyle(fontSize: 22)),
                          ),
                          SizedBox(height: cardContentSpacing),
                          
                          Text(
                            'Start your future skills journey',
                            style: GoogleFonts.fredoka(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold, 
                              color: const Color(0xFF0F172A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Create your student profile and unlock the dashboard.',
                            style: GoogleFonts.outfit(
                              fontSize: 11, 
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: cardContentSpacing * 1.5),

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
                              const SizedBox(width: 10),
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
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 40,
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
                                      style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF0F172A), fontWeight: FontWeight.w600),
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

                          // INPUT ROW 3: Password
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
                              child: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: const Color(0xFF94A3B8),
                                size: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: cardContentSpacing),

                          // INPUT ROW 4: Confirm Password
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
                              child: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: const Color(0xFF94A3B8),
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
                          
                          SizedBox(height: cardContentSpacing * 1.5),

                          // CREATE ACCOUNT GRADIENT BUTTON
                          GestureDetector(
                            onTap: _handleSignup,
                            child: Container(
                              width: double.infinity,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF3366), Color(0xFFFF9E00)], // Vibrant pink-orange-yellow gradient
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF3366).withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
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
                                      fontSize: 14, 
                                      fontWeight: FontWeight.bold, 
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: cardContentSpacing),

                          // GOOGLE SIGN IN BUTTON
                          OutlinedButton.icon(
                            onPressed: _handleSignup,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 42),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            icon: Container(
                              width: 16,
                              height: 16,
                              alignment: Alignment.center,
                              child: const Text('G', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueAccent, fontSize: 13)),
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
                                    color: const Color(0xFFFF3366), 
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
                  
                  const Spacer(flex: 1),

                  // 4. LOWER DESK DECORATION ITEMS (BOOKS, ALARM, CALENDAR, TOY ROCKET) - FIXED ON PAGE
                  _buildDeskDecoration(),
                  const SizedBox(height: 6),
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
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF0F172A), fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 16),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
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

  // FIXED BOTTOM DESK 3D WORKSPACE
  Widget _buildDeskDecoration() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // A. Launching Toy Rocket (Bottom-Left)
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              const Text('☁️', style: TextStyle(fontSize: 34)), // Launching Smoke cloud
              Positioned(
                bottom: 10,
                child: const Text('🚀', style: TextStyle(fontSize: 36)), // Rocket launching
              ),
            ],
          ),

          // B. Stacked Books with Green Succulent Pot
          Column(
            children: [
              const Text('🪴', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 1),
              Container(
                width: 76,
                height: 13,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD600), // Gold yellow book
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                ),
                alignment: Alignment.center,
                child: Text('LEARN', style: GoogleFonts.fredoka(fontSize: 7.5, fontWeight: FontWeight.w800, color: const Color(0xFF4A3E00))),
              ),
              const SizedBox(height: 1.5),
              Container(
                width: 82,
                height: 13,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2D55), // Pink-red book
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                ),
                alignment: Alignment.center,
                child: Text('GROW', style: GoogleFonts.fredoka(fontSize: 7.5, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(height: 1.5),
              Container(
                width: 88,
                height: 15,
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF), // Blue Succeed book
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                ),
                alignment: Alignment.center,
                child: Text('SUCCEED', style: GoogleFonts.fredoka(fontSize: 7.5, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ],
          ),

          // C. Custom standing calendar (Center-Right)
          Container(
            width: 76,
            height: 90,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) => Container(width: 3.5, height: 7, decoration: BoxDecoration(color: const Color(0xFF475569), borderRadius: BorderRadius.circular(2)))),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Center(
                    child: Text(
                      'Every step\ntoday,\na success\ntomorrow.',
                      style: GoogleFonts.outfit(fontSize: 8.5, fontWeight: FontWeight.w700, color: const Color(0xFFFF2D55), height: 1.1),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const Text('😊', style: TextStyle(fontSize: 9)),
              ],
            ),
          ),

          // D. Pencil Cup
          Container(
            width: 30,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB07E),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
              border: Border.all(color: Colors.white, width: 1.2),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            alignment: Alignment.topCenter,
            child: const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text('✏️✒️', style: TextStyle(fontSize: 12)),
            ),
          ),

          // E. Purple Alarm Clock sitting on book (Far-Right)
          Column(
            children: [
              const Text('⏰', style: TextStyle(fontSize: 30)),
              const SizedBox(height: 2),
              Container(
                width: 56,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF5856D6), // Purple book base
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
