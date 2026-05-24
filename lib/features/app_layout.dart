import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_screen.dart';
import 'roadmap_screen.dart';
import 'arcade_screen.dart';
import 'focus_screen.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({Key? key}) : super(key: key);

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _currentIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdyapanTheme.bgDark,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
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
          children: [
            // 4 Navigation tab buttons (Home, Roadmaps, Gamified, Focus)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                  _buildNavItem(1, Icons.public_rounded, Icons.public_outlined, 'Roadmaps'),
                  _buildNavItem(2, Icons.sports_esports_rounded, Icons.sports_esports_outlined, 'Gamified'),
                  _buildNavItem(3, Icons.offline_bolt_rounded, Icons.offline_bolt_outlined, 'Focus'),
                ],
              ),
            ),
            
            // 2. Large Floating Action Button (+) on far right
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: GestureDetector(
                onTap: () => _showQuickAddTaskDialog(context),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)], // Blue accent gradient
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Nav Item Builder
  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    bool isActive = _currentIndex == index;
    Color iconColor = isActive ? AdyapanTheme.blueAccent : AdyapanTheme.textMuted;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
