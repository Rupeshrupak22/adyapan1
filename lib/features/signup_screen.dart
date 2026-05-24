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
    // Set the username in our persistent state
    final state = Provider.of<AppState>(context, listen: false);
    // Give initial XP reward for signing up!
    state.addXp(50);
    
    String displayName = _nameController.text.trim();
    if (displayName.isEmpty) {
      displayName = 'Super Learner';
    }
    
    // Show success modal instantly without validation blocking for easy presentation!
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
          'Welcome $displayName! Your student profile has been created and you have unlocked the learning dashboard. (+50 Sign Up XP)',
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F9), // Creamy pastel background
      body: Stack(
        children: [
          // 1. BACKGROUND ORBS & ILLUSTRATIONS
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFFF7E9D).withOpacity(0.18), // Pastel pink
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB07E).withOpacity(0.15), // Pastel Orange
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Whimsical Doodle Emojis scattered around the background
          const Positioned(top: 80, left: 40, child: Text('✨', style: TextStyle(fontSize: 24))),
          const Positioned(top: 150, right: 60, child: Text('💡', style: TextStyle(fontSize: 28))),
          const Positioned(top: 80, right: 120, child: Text('📐', style: TextStyle(fontSize: 18))),
          const Positioned(top: 380, left: 16, child: Text('☀️', style: TextStyle(fontSize: 22))),

          // 2. MAIN SCROLLABLE WRAPPER
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Top Logo Brand Banner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Orange Logo
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF9B800), // Gold yellow
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

                    // 3. CENTRAL SIGNUP GLASS CARD
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                        children: [
                          // Rocket icon box
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFB07E), Color(0xFFFF5D7E)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: const Text('🚀', style: TextStyle(fontSize: 26)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Start your future skills journey',
                            style: GoogleFonts.fredoka(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold, 
                              color: const Color(0xFF0F172A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Create your student profile and unlock the dashboard.',
                            style: GoogleFonts.outfit(
                              fontSize: 12, 
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // ROW 1: Student Name & Phone (Two columns)
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: _nameController,
                                  hint: 'Student name',
                                  icon: Icons.person_outline_rounded,
                                  validator: (v) => v!.isEmpty ? 'Enter name' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInputField(
                                  controller: _phoneController,
                                  hint: 'Phone',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: (v) => v!.isEmpty ? 'Enter phone' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // ROW 2: Email & Class Dropdown (Two columns)
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: _emailController,
                                  hint: 'Email',
                                  icon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedClass,
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                                      style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF0F172A), fontWeight: FontWeight.w600),
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
                                              const Icon(Icons.school_outlined, size: 16, color: Color(0xFF94A3B8)),
                                              const SizedBox(width: 8),
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
                          const SizedBox(height: 12),

                          // ROW 3: Password with validation
                          _buildInputField(
                            controller: _passwordController,
                            hint: 'Password with uppercase and number',
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
                            validator: (v) {
                              if (v!.length < 6) return 'Password must be 6+ chars';
                              if (!v.contains(RegExp(r'[A-Z]'))) return 'Need uppercase letter';
                              if (!v.contains(RegExp(r'[0-9]'))) return 'Need a number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // ROW 4: Confirm Password
                          _buildInputField(
                            controller: _confirmPasswordController,
                            hint: 'Confirm password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: const Color(0xFF94A3B8),
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            validator: (v) {
                              if (v != _passwordController.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // ROW 5: School Name
                          _buildInputField(
                            controller: _schoolController,
                            hint: 'School name',
                            icon: Icons.domain_outlined,
                            validator: (v) => v!.isEmpty ? 'Enter school name' : null,
                          ),
                          const SizedBox(height: 24),

                          // CREATE ACCOUNT GRADIENT BUTTON
                          GestureDetector(
                            onTap: _handleSignup,
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF3366), Color(0xFFFF9E00)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF3366).withOpacity(0.25),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
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
                                      fontSize: 15, 
                                      fontWeight: FontWeight.bold, 
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // GOOGLE SIGN IN BUTTON
                          OutlinedButton.icon(
                            onPressed: _handleSignup, // demo login
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFFF1F5F9)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
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

                          // Footer Navigation Text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
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
                                    fontSize: 12, 
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
                    const SizedBox(height: 30),

                    // 4. LOWER DECORATION ITEMS (BOOKS, ALARM, CALENDAR)
                    _buildDeskDecoration(),
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

  // REUSABLE FORM TEXTFIELD BUILDER
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
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
        validator: validator,
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
            borderSide: const BorderSide(color: Color(0xFFFFB07E), width: 1.5),
          ),
          errorStyle: const TextStyle(fontSize: 9, height: 0.5),
        ),
      ),
    );
  }

  // BUILD BOTTOM DESK STUDY 3D ILLUSIONS USING WIDGETS
  Widget _buildDeskDecoration() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // STACKED BOOKS
          Column(
            children: [
              Container(
                width: 90,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE033),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                alignment: Alignment.center,
                child: Text('LEARN', style: GoogleFonts.fredoka(fontSize: 8, fontWeight: FontWeight.w800, color: const Color(0xFF3B2E00))),
              ),
              const SizedBox(height: 2),
              Container(
                width: 96,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3366),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                alignment: Alignment.center,
                child: Text('GROW', style: GoogleFonts.fredoka(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(height: 2),
              Container(
                width: 104,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF3388FF),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                alignment: Alignment.center,
                child: Text('SUCCEED', style: GoogleFonts.fredoka(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ],
          ),

          // CALENDAR LOG
          Container(
            width: 80,
            height: 90,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                // rings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) => Container(width: 4, height: 8, decoration: BoxDecoration(color: const Color(0xFF475569), borderRadius: BorderRadius.circular(2)))),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      'Every step\ntoday,\na success\ntomorrow.',
                      style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFF4F46E5), height: 1.1),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const Text('😊', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),

          // PENCILS CUP
          Container(
            width: 32,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB07E),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            alignment: Alignment.topCenter,
            child: const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text('✏️✒️', style: TextStyle(fontSize: 14)),
            ),
          ),

          // ALARM CLOCK
          Column(
            children: [
              const Text('⏰', style: TextStyle(fontSize: 34)),
              const SizedBox(height: 4),
              Container(
                width: 40,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

