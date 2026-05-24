import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';
import 'attendance_screen.dart';
import 'homework_screen.dart';
import 'notes_library_screen.dart';
import 'live_classes_screen.dart';
import 'recorded_classes_screen.dart';
import 'doubt_solver_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  // QUICK ACCESS CARD INTERACTION ROUTER
  void _handleQuickAccessTap(BuildContext context, String cardTitle, AppState state) {
    if (cardTitle == 'Gemified') {
      state.setTab(2); // Switch to Arcade Tab!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎮 Entering Quiz and Game Arcade Arena!'), backgroundColor: AdyapanTheme.blueAccent, duration: Duration(seconds: 1)),
      );
    } else if (cardTitle == 'Progress') {
      state.setTab(1); // Switch to Roadmaps Tab!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📈 Loading academic progress roadmaps!'), backgroundColor: AdyapanTheme.blueAccent, duration: Duration(seconds: 1)),
      );
    } else if (cardTitle == 'Attendance') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
    } else if (cardTitle == 'Homework') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeworkScreen()));
    } else if (cardTitle == 'Notes & PDFs') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesLibraryScreen()));
    } else if (cardTitle == 'Live Classes') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveClassesScreen()));
    } else if (cardTitle == 'Recorded Classes') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordedClassesScreen()));
    } else if (cardTitle == 'Doubt Sessions') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DoubtSolverScreen()));
    }
  }

  // 1. Attendance details modal
  void _showAttendanceDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('📅 Attendance Tracker', style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: AdyapanTheme.blueAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥 Highly Consistent!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AdyapanTheme.green, width: 8),
              ),
              child: Text('94%', style: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.bold, color: AdyapanTheme.green)),
            ),
            const SizedBox(height: 16),
            Text(
              'Attended: 118 classes\nExcused: 4 leaves\nAbsent: 3 classes',
              style: GoogleFonts.outfit(fontSize: 13, color: AdyapanTheme.textSub, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.fredoka(color: AdyapanTheme.textSub)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Excused leave application successfully sent to teacher!'), backgroundColor: AdyapanTheme.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AdyapanTheme.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
            child: Text('Apply Leave', style: GoogleFonts.fredoka(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // 2. Homework list modal
  void _showHomeworkList(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('📝 Homework Dashboard', style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: AdyapanTheme.blueAccent)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Complete to earn immediate XP and rewards!', style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textMuted)),
                  const SizedBox(height: 12),
                  _buildHomeworkTile('📐 Math: Quadratic Equations', 'Due: Today', setDialogState, state, context),
                  _buildHomeworkTile('⚛️ Science: Atomic Orbitals', 'Due: Tomorrow', setDialogState, state, context),
                  _buildHomeworkTile('📖 English: Essay Writing', 'Due: 3 days', setDialogState, state, context),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AdyapanTheme.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                  child: Text('Okay', style: GoogleFonts.fredoka(color: Colors.white)),
                )
              ],
            );
          }
        );
      }
    );
  }

  Widget _buildHomeworkTile(String taskName, String deadline, StateSetter setDialogState, AppState state, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AdyapanTheme.bgLightDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdyapanTheme.glassBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(taskName, style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(deadline, style: GoogleFonts.outfit(fontSize: 9, color: AdyapanTheme.textSub)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: AdyapanTheme.green, size: 20),
              onPressed: () {
                state.addXp(15);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('🎉 Homework "$taskName" Completed! (+15 XP)'), backgroundColor: AdyapanTheme.green),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  // 3. Notes and PDFs modal
  void _showNotesAndPdfs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('📄 Learning Library', style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: AdyapanTheme.blueAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Download and read offline anytime.', style: GoogleFonts.outfit(fontSize: 12, color: AdyapanTheme.textSub)),
            const SizedBox(height: 12),
            _buildPdfTile(context, 'BODMAS_Formulas.pdf', '1.2 MB'),
            _buildPdfTile(context, 'Atomic_Structure_Game.pdf', '3.4 MB'),
            _buildPdfTile(context, 'Python_Syntax_CheatSheet.pdf', '0.8 MB'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AdyapanTheme.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
            child: Text('Close', style: GoogleFonts.fredoka(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildPdfTile(BuildContext context, String filename, String size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 20),
        title: Text(filename, style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold)),
        subtitle: Text(size, style: GoogleFonts.outfit(fontSize: 9, color: AdyapanTheme.textMuted)),
        trailing: const Icon(Icons.download_for_offline_outlined, color: AdyapanTheme.blueAccent, size: 20),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('📂 Completed offline download: $filename!'), backgroundColor: AdyapanTheme.green, duration: const Duration(seconds: 1)),
          );
        },
        dense: true,
      ),
    );
  }

  // 4. Live Classes joining flow modal
  void _showLiveClasses(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('🎥 Active Live Classes', style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: AdyapanTheme.blueAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚡ Mathematics Class is LIVE now!', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AdyapanTheme.pink)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AdyapanTheme.bgLightDark, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Text('🧮', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Arithmetic & BODMAS Basics', style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('Teacher: Mrs. Sharma', style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textSub)),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Not Now', style: GoogleFonts.fredoka(color: AdyapanTheme.textSub)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _joinLiveSimulate(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AdyapanTheme.pink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
            child: Text('Join Zoom Class', style: GoogleFonts.fredoka(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _joinLiveSimulate(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'Connecting to Mrs. Sharma\'s live Mathematics Stream...',
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // close connecting dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎥 Connected successfully! Launching stream inside student screen...'), backgroundColor: AdyapanTheme.green),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        if (!state.initialized) {
          return const Center(child: CircularProgressIndicator(color: AdyapanTheme.blueAccent));
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFEEF2F6), // Soft lavender grey
                  Color(0xFFE0E7FF), // Soft indigo
                  Color(0xFFFFF0F5), // Soft pastel pink
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // 1. LAYERED ULTRA-PREMIUM VIBRANT BLUE HEADER BLOCK
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Base Blue Header container with deep decorative mesh gradient
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFFFFFF), // Pure White
                            Color(0xFFE2EDFF), // Soft Blue-White
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                      padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile details and Status Buttons row
                          Row(
                            children: [
                              // Sleek Profile Initial ring that opens side drawer
                              GestureDetector(
                                onTap: () {
                                  Scaffold.of(context).openDrawer();
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFBBF24), Color(0xFFEA580C)], // Gold-to-Orange
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEA580C).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'AS',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold, 
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Good morning Aarav
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Good morning,',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11, 
                                        color: const Color(0xFF1E3A8A).withOpacity(0.7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Aarav Sharma',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 16, 
                                        color: const Color(0xFF1E3A8A),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Notification Bell Icon with pulse ring
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A8A).withOpacity(0.08),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.15)),
                                ),
                                alignment: Alignment.center,
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    const Icon(Icons.notifications_rounded, color: Color(0xFFFBBF24), size: 18),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Header Image Banner
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Image.asset(
                                'assets/images/dashboard_banner.png',
                                fit: BoxFit.contain,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. OVERLAPPING WHITE SEARCH INPUT PILL
                    Positioned(
                      bottom: -22,
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.25), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E3A8A).withOpacity(0.08),
                              offset: const Offset(0, 4),
                              blurRadius: 0,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, color: Color(0xFF2563EB), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                style: GoogleFonts.outfit(fontSize: 13, color: AdyapanTheme.textMain, fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  hintText: 'Search subjects, topics, teachers...',
                                  hintStyle: GoogleFonts.outfit(fontSize: 13, color: AdyapanTheme.textMuted, fontWeight: FontWeight.w500),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 42),

                // 3. STATS CARD CAPSULE (Lessons, Quests, Rank)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.82),
                      border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.18), width: 1.5),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.15),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          offset: const Offset(-2, -2),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatsCol('📚 42', 'LESSONS'),
                        Container(width: 1.5, height: 28, color: const Color(0xFFEFF6FF)),
                        _buildStatsCol('🎯 8', 'QUESTS'),
                        Container(width: 1.5, height: 28, color: const Color(0xFFEFF6FF)),
                        _buildStatsCol('🏆 #12', 'RANK'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. QUICK ACCESS GRID (6 Rounded White Cards with soft colored tints)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quick access',
                        style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'See all',
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // 3x2 Grid using clean Rows & Columns
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildGridCard(context, state, '📅', 'Attendance', '94%', const Color(0xFFEFF6FF), const Color(0xFF2563EB))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildGridCard(context, state, '📖', 'Homework', '3 due', const Color(0xFFFFFBEB), const Color(0xFFF59E0B))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGridCard(
                              context,
                              state,
                              '🎥', 
                              'Live Classes', 
                              'Live Now', 
                              const Color(0xFFFDF2F8),
                              const Color(0xFFEC4899),
                              isLive: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildGridCard(context, state, '📄', 'Notes & PDFs', '128 files', const Color(0xFFFAF5FF), const Color(0xFF8B5CF6))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGridCard(
                              context,
                              state,
                              '📹', 
                              'Recorded Classes', 
                              '42 videos', 
                              const Color(0xFFECFDF5),
                              const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGridCard(
                              context,
                              state,
                              '🙋', 
                              'Doubt Sessions', 
                              'Ask Tutors', 
                              const Color(0xFFFFF1F2),
                              const Color(0xFFF43F5E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildGridCard(context, state, '🎮', 'Gemified', '3 games', const Color(0xFFF5F3FF), const Color(0xFF6366F1))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildGridCard(context, state, '📈', 'Progress', '+12%', const Color(0xFFEFF6FF), const Color(0xFF2563EB))),
                          const SizedBox(width: 12),
                          const Spacer(), // Perfect layout symmetry
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // 5. TODAY'S LIVE CLASSES SECTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today\'s live classes',
                        style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'View all',
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Premium live class item card with Join status chip
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.82),
                      border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.18), width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.15),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          offset: const Offset(-2, -2),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Abacus Gradient Icon container
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE0F2FE), Color(0xFFEFF6FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFBAE6FD), width: 1.2),
                          ),
                          alignment: Alignment.center,
                          child: const Text('🧮', style: TextStyle(fontSize: 22)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mathematics',
                                style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Starts in 10 mins • 10:30 AM',
                                    style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textSub, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Active Join Button Chip (Clickable!)
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveClassesScreen())),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.3), width: 1.5),
                              boxShadow: [
                                // 3D Button Depth
                                BoxShadow(
                                  color: const Color(0xFF1E3A8A).withOpacity(0.2),
                                  offset: const Offset(0, 3),
                                  blurRadius: 0,
                                )
                              ],
                            ),
                            child: Text(
                              'Join',
                              style: GoogleFonts.fredoka(
                                fontSize: 12, 
                                color: Colors.white, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 26),

                // 6. RECORDED CLASSES SECTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recorded classes',
                        style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain),
                      ),
                      TextButton(
                        onPressed: () => _showRecordedClassesList(context),
                        child: Text(
                          'View all',
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Recorded classes card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.82),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.18), width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          offset: const Offset(-2, -2),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFA7F3D0), width: 1.2),
                          ),
                          alignment: Alignment.center,
                          child: const Text('📹', style: TextStyle(fontSize: 22)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Science: Atomic Structure',
                                style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain),
                              ),
                              Text(
                                'Recorded • 52 mins • Mr. Verma',
                                style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textSub, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordedClassesScreen())),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xFF047857).withOpacity(0.3), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF047857).withOpacity(0.2),
                                  offset: const Offset(0, 3),
                                  blurRadius: 0,
                                )
                              ],
                            ),
                            child: Text(
                              'Play',
                              style: GoogleFonts.fredoka(
                                fontSize: 12, 
                                color: Colors.white, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 26),

                // 7. DOUBT CLEARING SESSIONS SECTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Doubt clearing sessions',
                        style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain),
                      ),
                      TextButton(
                        onPressed: () => _showDoubtSessions(context),
                        child: Text(
                          'Ask Doubt',
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Doubt session card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.82),
                      border: Border.all(color: const Color(0xFFF43F5E).withOpacity(0.18), width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF43F5E).withOpacity(0.15),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          offset: const Offset(-2, -2),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFECDD3), width: 1.2),
                          ),
                          alignment: Alignment.center,
                          child: const Text('🙋', style: TextStyle(fontSize: 22)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mathematics Doubt Room',
                                style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain),
                              ),
                              Text(
                                'LIVE • 12 active students • 2 mentors',
                                style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textSub, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoubtSolverScreen())),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xFFBE123C).withOpacity(0.3), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFBE123C).withOpacity(0.2),
                                  offset: const Offset(0, 3),
                                  blurRadius: 0,
                                )
                              ],
                            ),
                            child: Text(
                              'Connect',
                              style: GoogleFonts.fredoka(
                                fontSize: 12, 
                                color: Colors.white, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      );
      },
    );
  }

  // Column builder inside Stats Card
  Widget _buildStatsCol(String numVal, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          numVal,
          style: GoogleFonts.fredoka(
            fontSize: 18, 
            fontWeight: FontWeight.bold, 
            color: const Color(0xFF1E3A8A), // Dark navy blue
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 9, 
            fontWeight: FontWeight.w800, 
            color: AdyapanTheme.textMuted,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  // Premium Quick Access Card Builder (Fully Clickable!)
  Widget _buildGridCard(BuildContext context, AppState state, String emojiIcon, String title, String subtitle, Color tintColor, Color accentColor, {bool isLive = false}) {
    return GestureDetector(
      onTap: () => _handleQuickAccessTap(context, title, state),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.82),
          border: Border.all(color: accentColor.withOpacity(0.18), width: 1.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.15),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              offset: const Offset(-2, -2),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Box
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: tintColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor.withOpacity(0.12), width: 1.2),
                  ),
                  alignment: Alignment.center,
                  child: Text(emojiIcon, style: const TextStyle(fontSize: 22)),
                ),
                // LIVE Pulsing Red Pill
                if (isLive)
                  Positioned(
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'LIVE', 
                        style: GoogleFonts.outfit(fontSize: 6, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.fredoka(
                fontSize: 12, 
                fontWeight: FontWeight.bold, 
                color: AdyapanTheme.textMain,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 10, 
                fontWeight: FontWeight.bold, 
                color: AdyapanTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 6. Library of Recorded Classes modal
  void _showRecordedClassesList(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('📹 Library of Recorded Classes', style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: AdyapanTheme.blueAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select a class to watch lecture playbacks.', style: GoogleFonts.outfit(fontSize: 12, color: AdyapanTheme.textSub)),
            const SizedBox(height: 12),
            _buildRecordedClassItem(context, '📐 Math: Quadratic Equations (Part 1)', '45 mins • Mrs. Sharma'),
            _buildRecordedClassItem(context, '⚛️ Science: Atomic Orbitals & Shells', '52 mins • Mr. Verma'),
            _buildRecordedClassItem(context, '📖 English: Active & Passive Voices', '30 mins • Miss Anjali'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AdyapanTheme.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
            child: Text('Close', style: GoogleFonts.fredoka(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildRecordedClassItem(BuildContext context, String title, String meta) {
    return Card(
      elevation: 0,
      color: AdyapanTheme.bgLightDark,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.play_circle_outline, color: Colors.green, size: 24),
        title: Text(title, style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold)),
        subtitle: Text(meta, style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textSub)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AdyapanTheme.textMuted),
        onTap: () {
          Navigator.pop(context); // Close selection list
          _simulatePlayVideo(context, title);
        },
      ),
    );
  }

  // 6b. Simulated Video Player
  void _simulatePlayVideo(BuildContext context, String videoTitle) {
    showDialog(
      context: context,
      builder: (context) {
        bool isPlaying = true;
        double progress = 0.15;
        return StatefulBuilder(
          builder: (context, setVideoState) {
            return AlertDialog(
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              contentPadding: const EdgeInsets.all(16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          videoTitle,
                          style: GoogleFonts.fredoka(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📺', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 8),
                            Text(
                              isPlaying ? 'Playing Lecture Video...' : 'Lecture Paused',
                              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                        if (isPlaying)
                          Positioned(
                            bottom: 12,
                            left: 12,
                            right: 12,
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 28),
                        onPressed: () {
                          setVideoState(() {
                            progress = (progress - 0.05).clamp(0.0, 1.0);
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                          color: Colors.greenAccent,
                          size: 54,
                        ),
                        onPressed: () {
                          setVideoState(() {
                            isPlaying = !isPlaying;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 28),
                        onPressed: () {
                          setVideoState(() {
                            progress = (progress + 0.05).clamp(0.0, 1.0);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 52).toStringAsFixed(1)} mins / 52:00 mins',
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  // 7. Doubt Solver Room modal
  void _showDoubtSessions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String activeSubject = 'Mathematics';
        final TextEditingController doubtController = TextEditingController();
        bool isSubmitting = false;
        bool chatSimulated = false;
        List<Map<String, String>> chatMessages = [];

        return StatefulBuilder(
          builder: (context, setDoubtState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('🙋 Doubt Solver Room', style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: AdyapanTheme.pink)),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!chatSimulated) ...[
                      Text('Get answers instantly from active 24/7 mentors!', style: GoogleFonts.outfit(fontSize: 12, color: AdyapanTheme.textSub)),
                      const SizedBox(height: 12),
                      Row(
                        children: ['Mathematics', 'Science', 'English'].map((subject) {
                          bool isSel = activeSubject == subject;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: GestureDetector(
                              onTap: () => setDoubtState(() => activeSubject = subject),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSel ? AdyapanTheme.pink.withOpacity(0.1) : AdyapanTheme.bgLightDark,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: isSel ? AdyapanTheme.pink : AdyapanTheme.glassBorder, width: 1.2),
                                ),
                                child: Text(
                                  subject,
                                  style: GoogleFonts.fredoka(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? AdyapanTheme.pink : AdyapanTheme.textMain),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: doubtController,
                        maxLines: 3,
                        style: GoogleFonts.outfit(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Describe your question or doubt here...',
                          hintStyle: GoogleFonts.outfit(fontSize: 12, color: AdyapanTheme.textMuted),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AdyapanTheme.glassBorder)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AdyapanTheme.pink, width: 1.5)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : () {
                            if (doubtController.text.trim().isEmpty) return;
                            setDoubtState(() {
                              isSubmitting = true;
                            });
                            Future.delayed(const Duration(seconds: 2), () {
                              setDoubtState(() {
                                isSubmitting = false;
                                chatSimulated = true;
                                chatMessages.add({'sender': 'Aarav', 'msg': doubtController.text});
                                chatMessages.add({
                                  'sender': 'Tutor',
                                  'msg': 'Hello Aarav! I am Mr. Verma, your $activeSubject tutor. I see your doubt regarding "${doubtController.text}". That is a fantastic question! Let\'s solve this step by step. Tell me, which part are you finding difficult?'
                                });
                              });
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdyapanTheme.pink,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          ),
                          child: isSubmitting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text('Connect to Live Tutor', style: GoogleFonts.fredoka(color: Colors.white, fontSize: 13)),
                        ),
                      )
                    ] else ...[
                      Container(
                        height: 200,
                        child: ListView.builder(
                          itemCount: chatMessages.length,
                          itemBuilder: (context, index) {
                            var msg = chatMessages[index];
                            bool isMe = msg['sender'] == 'Aarav';
                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isMe ? AdyapanTheme.pink.withOpacity(0.1) : AdyapanTheme.bgLightDark,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(12),
                                    topRight: const Radius.circular(12),
                                    bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                                    bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                                  ),
                                  border: Border.all(color: isMe ? AdyapanTheme.pink.withOpacity(0.3) : AdyapanTheme.glassBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(msg['sender']!, style: GoogleFonts.fredoka(fontSize: 9, fontWeight: FontWeight.bold, color: isMe ? AdyapanTheme.pink : Colors.blueGrey)),
                                    const SizedBox(height: 2),
                                    Text(msg['msg']!, style: GoogleFonts.outfit(fontSize: 11)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Type message...',
                                hintStyle: GoogleFonts.outfit(fontSize: 11),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: AdyapanTheme.pink,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white, size: 14),
                              onPressed: () {},
                            ),
                          )
                        ],
                      )
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close', style: GoogleFonts.fredoka(color: AdyapanTheme.textSub)),
                )
              ],
            );
          }
        );
      }
    );
  }
}
