import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_screen.dart';
import 'roadmap_screen.dart';
import 'arcade_screen.dart';
import 'focus_screen.dart';
import 'parent_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({Key? key}) : super(key: key);

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final List<Widget> _screens = const [
    DashboardScreen(),
    RoadmapScreen(),
    ArcadeScreen(),
    FocusScreen(),
  ];

  void _showQuickAddTaskDialog(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    final titleController = TextEditingController();
    String selectedTag = 'Math';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            '⚡ Create Quick Quest', 
            style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: AdyapanTheme.blueAccent),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add a fast study task or chore to your daily checklist directly.',
                style: GoogleFonts.outfit(fontSize: 12, color: AdyapanTheme.textSub),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'e.g., Read Physics Chapter 3',
                  hintStyle: GoogleFonts.outfit(fontSize: 13, color: AdyapanTheme.textMuted),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AdyapanTheme.blueAccent, width: 2), borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTag,
                items: ['Math', 'Science', 'Focus', 'General'].map((tag) {
                  return DropdownMenuItem(value: tag, child: Text(tag, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) selectedTag = val;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.fredoka(color: AdyapanTheme.textSub)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  state.addTodo(titleController.text, selectedTag);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🎉 Quick task successfully added!'), backgroundColor: AdyapanTheme.green),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AdyapanTheme.blueAccent),
              child: Text('Add Quest', style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  void _showChatbotDialog(BuildContext context) {
    final messageController = TextEditingController();
    final List<Map<String, dynamic>> initialMessages = [
      {'sender': 'bot', 'text': 'Hello Aarav! 🤖 I am Adyapan AI Assistant. How can I help you study today? 📚'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        List<Map<String, dynamic>> messages = List.from(initialMessages);
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              contentPadding: EdgeInsets.zero,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🤖', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adyapan AI',
                          style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'Online Assistant',
                          style: GoogleFonts.outfit(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              content: Container(
                width: 320,
                height: 380,
                color: const Color(0xFFF8FAFC),
                child: Column(
                  children: [
                    // Chat Messages list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isBot = msg['sender'] == 'bot';
                          return Align(
                            alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isBot ? Colors.white : const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isBot ? Radius.zero : const Radius.circular(16),
                                  bottomRight: isBot ? const Radius.circular(16) : Radius.zero,
                                ),
                                border: isBot ? Border.all(color: const Color(0xFFE2E8F0)) : null,
                                boxShadow: isBot ? [const BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))] : null,
                              ),
                              child: Text(
                                msg['text'],
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: isBot ? const Color(0xFF1E293B) : Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Input bar
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: TextField(
                                controller: messageController,
                                style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF1E293B)),
                                decoration: InputDecoration(
                                  hintText: 'Ask anything...',
                                  hintStyle: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF94A3B8)),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty) {
                                    final text = value.trim();
                                    messageController.clear();
                                    setDialogState(() {
                                      messages.add({'sender': 'user', 'text': text});
                                    });
                                    // Generate delayed smart reply
                                    Future.delayed(const Duration(milliseconds: 650), () {
                                      String botReply = "That's a great question! Keep studying and you'll master it! 🚀";
                                      if (text.toLowerCase().contains('math') || text.toLowerCase().contains('homework')) {
                                        botReply = "Math is all about practice! Try playing the Quiz Arena in the Gamified tab to earn +20 XP! 🧮";
                                      } else if (text.toLowerCase().contains('xp') || text.toLowerCase().contains('level')) {
                                        botReply = "You can earn XP by completing focus sessions, homework, and roadmaps! 🏆";
                                      } else if (text.toLowerCase().contains('hello') || text.toLowerCase().contains('hi')) {
                                        botReply = "Hello Aarav! How are you doing today? Ready to learn something new? 🌟";
                                      }
                                      setDialogState(() {
                                        messages.add({'sender': 'bot', 'text': botReply});
                                      });
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Send button
                          GestureDetector(
                            onTap: () {
                              if (messageController.text.trim().isNotEmpty) {
                                final text = messageController.text.trim();
                                messageController.clear();
                                setDialogState(() {
                                  messages.add({'sender': 'user', 'text': text});
                                });
                                // Generate delayed smart reply
                                Future.delayed(const Duration(milliseconds: 650), () {
                                  String botReply = "That's a great question! Keep studying and you'll master it! 🚀";
                                  if (text.toLowerCase().contains('math') || text.toLowerCase().contains('homework')) {
                                    botReply = "Math is all about practice! Try playing the Quiz Arena in the Gamified tab to earn +20 XP! 🧮";
                                  } else if (text.toLowerCase().contains('xp') || text.toLowerCase().contains('level')) {
                                    botReply = "You can earn XP by completing focus sessions, homework, and roadmaps! 🏆";
                                  } else if (text.toLowerCase().contains('hello') || text.toLowerCase().contains('hi')) {
                                    botReply = "Hello Aarav! How are you doing today? Ready to learn something new? 🌟";
                                  }
                                  setDialogState(() {
                                    messages.add({'sender': 'bot', 'text': botReply});
                                  });
                                });
                              }
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.send_rounded, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('💡 How to Navigate Adyapan', style: AdyapanTheme.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: AdyapanTheme.blueAccent)),
        content: Text(
          '1. Home: Check lessons, access grid tools, and view live classes.\n'
          '2. Roadmaps: Switch subjects and unlock milestone nodes (+50 XP).\n'
          '3. Gamified: Play Quiz Arena, balance equations, and code blocks!\n'
          '4. Focus: Activate Pomodoro timers and toggle the Focus Shield blocker.\n'
          '5. Parent Gate: Accessible via the Side Drawer! Configure daily screen time limits and assign quests.',
          style: AdyapanTheme.outfit(fontSize: 12, color: AdyapanTheme.textSub),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AdyapanTheme.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
            child: Text('Understood!', style: AdyapanTheme.fredoka(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, Color? iconColor, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: iconColor ?? AdyapanTheme.blueAccent, size: 20),
          title: Text(
            title,
            style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onTap: onTap,
          dense: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    
    return Scaffold(
      backgroundColor: AdyapanTheme.bgDark,
      // 1. Sleek Navigation Drawer (Secondary controls)
      drawer: Drawer(
        backgroundColor: Colors.transparent, // Allow glass gradient to show
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFEEF2F6).withOpacity(0.96), // Frosted glass soft lavender
                const Color(0xFFE0E7FF).withOpacity(0.96), // Frosted glass soft indigo
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Consumer<AppState>(
            builder: (context, state, child) {
              double xpProgress = (state.xp % 200) / 200.0;
              int xpInCurrentLevel = state.xp % 200;
              
              return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // A. Sleek Gradient Drawer Header (Tapping goes to Profile Screen)
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close side drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: ClipOval(
                                child: state.profileImagePath.isNotEmpty
                                    ? Image.file(
                                        File(state.profileImagePath),
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                      )
                                    : Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Color(0xFFFBBF24), Color(0xFFEA580C)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: () {
                                          String initials = '';
                                          if (state.studentName.trim().isNotEmpty) {
                                            List<String> parts = state.studentName.trim().split(' ');
                                            if (parts.isNotEmpty && parts[0].isNotEmpty) {
                                              initials += parts[0][0];
                                            }
                                            if (parts.length > 1 && parts[1].isNotEmpty) {
                                              initials += parts[1][0];
                                            }
                                          }
                                          if (initials.isEmpty) initials = 'SL';
                                          return Text(
                                            initials.toUpperCase(),
                                            style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                          );
                                        }(),
                                      ),
                              ),
                            ),
                            const Spacer(),
                            // Streak Counter
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                children: [
                                  const Text('🔥', style: TextStyle(fontSize: 12)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${state.streak}',
                                    style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.studentName,
                                    style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    state.studentEmail,
                                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
<<<<<<< Updated upstream
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                          ],
                        ),
                      ],
                    ),
=======
                          ),
                          const Spacer(),
                          const SizedBox.shrink(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aarav Sharma',
                        style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'aarav.sharma@school.com',
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
                      ),
                    ],
>>>>>>> Stashed changes
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // B. Student Progress Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.65), // Translucent white glass
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Level ${state.level}',
                              style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A)),
                            ),
                            Text(
                              '$xpInCurrentLevel / 200 XP',
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: xpProgress,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Keep crushing it! ${200 - xpInCurrentLevel} XP left to next level!',
                          style: GoogleFonts.outfit(fontSize: 9, color: AdyapanTheme.textMuted, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // C. Navigation List Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(
                        icon: Icons.dashboard_outlined,
                        title: 'Student Dashboard',
                        onTap: () {
                          Navigator.pop(context);
                          state.setTab(0);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.supervised_user_circle_outlined,
                        title: 'Parent Portal Gate',
                        iconColor: AdyapanTheme.purple,
                        onTap: () {
                          Navigator.pop(context); // close drawer
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ParentScreen()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.shield_outlined,
                        title: 'Focus Shield Settings',
                        onTap: () {
                          Navigator.pop(context);
                          state.setTab(3);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & FAQ',
                        onTap: () {
                          Navigator.pop(context);
                          _showHelpDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFEFF6FF))),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          'Switch Profile / Logout',
                          style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
      body: IndexedStack(
        index: state.currentTab,
        children: _screens,
      ),
      // 2. High-floating Add Quick Quest Button (Doesn't overlap and floats nicely!)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showChatbotDialog(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)], // Vibrant blue gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 24),
        ),
      ),
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AdyapanTheme.glassBorder, width: 1.5)),
          boxShadow: [
            BoxShadow(
              color: AdyapanTheme.blueAccent.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home', state),
            _buildNavItem(1, Icons.public_rounded, Icons.public_outlined, 'Roadmaps', state),
            _buildNavItem(2, Icons.sports_esports_rounded, Icons.sports_esports_outlined, 'Gamified', state),
            _buildNavItem(3, Icons.offline_bolt_rounded, Icons.offline_bolt_outlined, 'Focus', state),
          ],
        ),
      ),
    );
  }

  // Nav Item Builder
  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, AppState state) {
    bool isActive = state.currentTab == index;
    Color iconColor = isActive ? AdyapanTheme.blueAccent : AdyapanTheme.textMuted;
    
    return GestureDetector(
      onTap: () {
        state.setTab(index);
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon, 
              color: iconColor,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 10, 
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
