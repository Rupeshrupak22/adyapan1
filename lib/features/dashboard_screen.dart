import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

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
      _showAttendanceDetails(context);
    } else if (cardTitle == 'Homework') {
      _showHomeworkList(context, state);
    } else if (cardTitle == 'Notes & PDFs') {
      _showNotesAndPdfs(context);
    } else if (cardTitle == 'Live Classes') {
      _showLiveClasses(context);
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
          backgroundColor: const Color(0xFFF8FAFC), // Ultra-clean brightness slate
          body: SingleChildScrollView(
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

                              // Streak Chip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A8A).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.15)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🔥', style: TextStyle(fontSize: 12)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${state.streak}',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 11, 
                                        color: const Color(0xFF1E3A8A), 
                                        fontWeight: FontWeight.bold,
                                      ),
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
                              const SizedBox(width: 8),

                              // Shield Icon
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A8A).withOpacity(0.08),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.15)),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.shield_outlined, color: Color(0xFF1E3A8A), size: 16),
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
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.25), width: 2),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        // 3D Solid Depth Shadow
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.12),
                          offset: const Offset(0, 6),
                          blurRadius: 0,
                        ),
                        // Soft ambient
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.04),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
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
                          Expanded(child: _buildGridCard(context, state, '🎮', 'Gemified', '3 games', const Color(0xFFF5F3FF), const Color(0xFF6366F1))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildGridCard(context, state, '📈', 'Progress', '+12%', const Color(0xFFECFDF5), const Color(0xFF10B981))),
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
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.25), width: 2),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        // 3D Depth
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.12),
                          offset: const Offset(0, 6),
                          blurRadius: 0,
                        ),
                        // Ambient
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.04),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
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
                          onTap: () => _showLiveClasses(context),
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
                const SizedBox(height: 40),
              ],
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
          color: Colors.white,
          border: Border.all(color: accentColor.withOpacity(0.25), width: 2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // 3D Solid Colored Bottom Shadow
            BoxShadow(
              color: accentColor.withOpacity(0.12),
              offset: const Offset(0, 6),
              blurRadius: 0,
            ),
            // Soft ambient
            BoxShadow(
              color: accentColor.withOpacity(0.04),
              offset: const Offset(0, 2),
              blurRadius: 8,
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
}
