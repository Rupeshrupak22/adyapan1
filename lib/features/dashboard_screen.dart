import 'dart:io';
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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedLeaderboardTab = 0;

  String _getDynamicGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning ☀️,';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon 🌤️,';
    } else if (hour >= 17 && hour < 22) {
      return 'Good evening 🌙,';
    } else {
      return 'Happy late night study 🦉,';
    }
  }

  // QUICK ACCESS CARD INTERACTION ROUTER
  void _handleQuickAccessTap(BuildContext context, String cardTitle, AppState state) {
    if (cardTitle == 'Gemified') {
      state.setTab(2); // Switch to Arcade Tab!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎮 Entering Quiz and Game Arcade Arena!'), backgroundColor: AdyapanTheme.blueAccent, duration: Duration(seconds: 1)),
      );
    } else if (cardTitle == 'Progress') {
      _showProgressDialog(context, state);
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
    } else if (cardTitle == 'Leaderboard') {
      _showLeaderboardDialog(context, state);
    }
  }

  // 0. Progress & Quiz Overview Dialog
  void _showProgressDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final mathPct = state.mathSyllabusProgress;
          final sciPct = state.scienceSyllabusProgress;
          final engPct = state.englishSyllabusProgress;
          final overallPct = state.overallSyllabusProgress;
          final quizDone = state.completedQuizzesCount;
          final xp = state.xp;
          final level = state.level;

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Academic Progress',
                      style: GoogleFonts.fredoka(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A)),
                    ),
                    Text(
                      'Your learning journey overview',
                      style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textMuted, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),

                    // === OVERALL PROGRESS RING SUMMARY ===
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          // Ring indicator
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 64,
                                height: 64,
                                child: CircularProgressIndicator(
                                  value: overallPct / 100,
                                  strokeWidth: 7,
                                  backgroundColor: const Color(0xFFBFDBFE),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                                ),
                              ),
                              Text(
                                '${overallPct.toStringAsFixed(0)}%',
                                style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A)),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Overall Syllabus',
                                  style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$quizDone quizzes completed • Level $level',
                                  style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textSub, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 6),
                                // XP bar
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: (xp % 200) / 200.0,
                                          minHeight: 6,
                                          backgroundColor: const Color(0xFFBFDBFE),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${xp % 200}/200 XP',
                                      style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // === QUIZ PROGRESS ===
                    Text(
                      '🎮 Quiz & Game Progress',
                      style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          _buildProgressQuizRow('🧮 BODMAS Balancer', quizDone >= 1, quizDone >= 1 ? 'Completed' : 'Not started', const Color(0xFF6366F1)),
                          const SizedBox(height: 8),
                          _buildProgressQuizRow('📝 Syntax Blocks', quizDone >= 2, quizDone >= 2 ? 'Completed' : 'Not started', const Color(0xFF6366F1)),
                          const SizedBox(height: 8),
                          _buildProgressQuizRow('🔠 Word Unscramble', quizDone >= 3, quizDone >= 3 ? 'Completed' : 'Not started', const Color(0xFF6366F1)),
                          const SizedBox(height: 8),
                          _buildProgressQuizRow('⚡ Speed Math', quizDone >= 4, quizDone >= 4 ? 'Completed' : 'Not started', const Color(0xFF6366F1)),
                          const Divider(height: 16, color: Color(0xFFE9D5FF)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Completed', style: GoogleFonts.fredoka(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF4C1D95))),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('$quizDone / 4 Quizzes', style: GoogleFonts.fredoka(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // === CLASS / SYLLABUS PROGRESS ===
                    Text(
                      '📚 Class Syllabus Progress',
                      style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain),
                    ),
                    const SizedBox(height: 8),
                    _buildSubjectProgressBar('📐 Mathematics', mathPct, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
                    const SizedBox(height: 8),
                    _buildSubjectProgressBar('⚛️ Science', sciPct, const Color(0xFF10B981), const Color(0xFFECFDF5)),
                    const SizedBox(height: 8),
                    _buildSubjectProgressBar('📖 English', engPct, const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
                    const SizedBox(height: 16),

                    // === ATTENDANCE / CLASS ATTENDANCE PROGRESS ===
                    Text(
                      '🏫 Class Attendance',
                      style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.25)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Big attendance percentage
                              Column(
                                children: [
                                  Text('94%', style: GoogleFonts.fredoka(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
                                  Text('Attendance', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: AdyapanTheme.textMuted)),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildAttendanceStat('Classes Attended', '118 / 125'),
                                    const SizedBox(height: 4),
                                    _buildAttendanceStat('Excused Leaves', '4 days'),
                                    const SizedBox(height: 4),
                                    _buildAttendanceStat('Absences', '3 days'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: 0.94,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFFEF3C7),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '✅ Excellent! Keep it up — minimum 75% required',
                            style: GoogleFonts.outfit(fontSize: 9, color: AdyapanTheme.textMuted, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: GoogleFonts.fredoka(color: AdyapanTheme.textSub, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  state.setTab(1); // Go to Roadmaps tab for full details
                },
                icon: const Icon(Icons.map_outlined, size: 14, color: Colors.white),
                label: Text('View Roadmap', style: GoogleFonts.fredoka(color: Colors.white, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressQuizRow(String title, bool completed, String status, Color accent) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: completed ? accent.withOpacity(0.15) : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(color: completed ? accent : const Color(0xFFE2E8F0)),
          ),
          child: Icon(
            completed ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
            size: 12,
            color: completed ? accent : AdyapanTheme.textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: GoogleFonts.fredoka(fontSize: 11, fontWeight: FontWeight.w600, color: AdyapanTheme.textMain)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: completed ? accent.withOpacity(0.1) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: completed ? accent.withOpacity(0.3) : const Color(0xFFE2E8F0)),
          ),
          child: Text(
            status,
            style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.bold, color: completed ? accent : AdyapanTheme.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectProgressBar(String subject, double pct, Color accentColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject, style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain)),
              Text('${pct.toStringAsFixed(0)}%', style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold, color: accentColor)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 7,
              backgroundColor: accentColor.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textSub, fontWeight: FontWeight.w500)),
        Text(value, style: GoogleFonts.fredoka(fontSize: 10, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain)),
      ],
    );
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
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: state.profileImagePath.isNotEmpty
                                        ? Image.file(
                                            File(state.profileImagePath),
                                            fit: BoxFit.cover,
                                            width: 46,
                                            height: 46,
                                          )
                                        : Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Color(0xFFFBBF24), Color(0xFFEA580C)], // Gold-to-Orange
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
                                                style: GoogleFonts.fredoka(
                                                  fontSize: 16, 
                                                  fontWeight: FontWeight.bold, 
                                                  color: Colors.white,
                                                ),
                                              );
                                            }(),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Dynamic real-time greeting based on hour
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _getDynamicGreeting(),
                                      style: GoogleFonts.outfit(
                                        fontSize: 11, 
                                        color: const Color(0xFF1E3A8A).withOpacity(0.7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      state.studentName,
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
                          Expanded(child: _buildGridCard(context, state, '🏆', 'Leaderboard', 'Standings', const Color(0xFFFFFBEB), const Color(0xFFFFB000))),
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

                // 6. DOUBT CLEARING SESSIONS SECTION
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

  // LEADBOARD COMPONENT DRAWING
  Widget _buildLeaderboardSection(AppState state) {
    // Dynamic mappings of top 5 students for each game
    final List<Map<String, dynamic>> bodmasLeaderboard = [
      {'rank': 1, 'name': 'Anya Verma', 'score': 2450, 'avatar': '🧠', 'medal': '🥇'},
      {'rank': 2, 'name': 'Kabir Gupta', 'score': 2310, 'avatar': '⚡', 'medal': '🥈'},
      {'rank': 3, 'name': 'Rohan Malhotra', 'score': 2190, 'avatar': '🎨', 'medal': '🥉'},
      {'rank': 4, 'name': state.studentName, 'score': 1980, 'avatar': '🚀', 'isUser': true},
      {'rank': 5, 'name': 'Diya Sen', 'score': 1850, 'avatar': '🧬', 'medal': ''},
    ];

    final List<Map<String, dynamic>> syntaxLeaderboard = [
      {'rank': 1, 'name': 'Kabir Gupta', 'score': 3100, 'avatar': '⚡', 'medal': '🥇'},
      {'rank': 2, 'name': 'Anya Verma', 'score': 2950, 'avatar': '🧠', 'medal': '🥈'},
      {'rank': 3, 'name': 'Ishaan Mehta', 'score': 2800, 'avatar': '🍕', 'medal': '🥉'},
      {'rank': 4, 'name': state.studentName, 'score': 2750, 'avatar': '🚀', 'isUser': true},
      {'rank': 5, 'name': 'Meera Iyer', 'score': 2500, 'avatar': '📖', 'medal': ''},
    ];

    final List<Map<String, dynamic>> wordLeaderboard = [
      {'rank': 1, 'name': 'Diya Sen', 'score': 1900, 'avatar': '🧬', 'medal': '🥇'},
      {'rank': 2, 'name': state.studentName, 'score': 1850, 'avatar': '🚀', 'isUser': true, 'medal': '🥈'},
      {'rank': 3, 'name': 'Anya Verma', 'score': 1720, 'avatar': '🧠', 'medal': '🥉'},
      {'rank': 4, 'name': 'Rohan Malhotra', 'score': 1600, 'avatar': '🎨', 'medal': ''},
      {'rank': 5, 'name': 'Ishaan Mehta', 'score': 1450, 'avatar': '🍕', 'medal': ''},
    ];

    List<Map<String, dynamic>> activeLeaderboard;
    String gameTitle;
    if (_selectedLeaderboardTab == 0) {
      activeLeaderboard = bodmasLeaderboard;
      gameTitle = '🧮 BODMAS Balancer';
    } else if (_selectedLeaderboardTab == 1) {
      activeLeaderboard = syntaxLeaderboard;
      gameTitle = '📝 Syntax Blocks';
    } else {
      activeLeaderboard = wordLeaderboard;
      gameTitle = '🔠 Word Unscramble';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🏆 School-wide Leaderboards',
                style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50]?.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Live Standings',
                      style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green[800]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'See where you stand among all students in Adyapan School games!',
            style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textMuted, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 14),

          // TABS ROW FOR SELECTING GAME LEADERBOARD
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildLeaderboardTabButton(0, 'BODMAS Balancer', '🧮'),
                const SizedBox(width: 8),
                _buildLeaderboardTabButton(1, 'Syntax Blocks', '📝'),
                const SizedBox(width: 8),
                _buildLeaderboardTabButton(2, 'Word Unscramble', '🔠'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // LEADBOARD CONTAINER CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.82),
              border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.18), width: 1.5),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.08),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.4),
                  offset: const Offset(-2, -2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              children: [
                // Active game title header
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.orangeAccent, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      gameTitle,
                      style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A)),
                    ),
                    const Spacer(),
                    Text(
                      'Scores reset weekly',
                      style: GoogleFonts.outfit(fontSize: 9, color: AdyapanTheme.textMuted, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFEFF6FF), thickness: 1.5),

                // Leaderboard list rows
                ...List.generate(activeLeaderboard.length, (index) {
                  final row = activeLeaderboard[index];
                  final isUser = row['isUser'] == true;
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser 
                          ? const Color(0xFFEFF6FF).withOpacity(0.9)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUser 
                            ? const Color(0xFFBFDBFE) 
                            : Colors.transparent, 
                        width: 1.2
                      ),
                      boxShadow: isUser ? [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ] : null,
                    ),
                    child: Row(
                      children: [
                        // Rank display
                        SizedBox(
                          width: 28,
                          child: () {
                            if (row['medal'] != null && row['medal'].isNotEmpty) {
                              return Text(row['medal'], style: const TextStyle(fontSize: 18), textAlign: TextAlign.center);
                            }
                            return Text(
                              '#${row['rank']}', 
                              style: GoogleFonts.fredoka(
                                fontSize: 13, 
                                fontWeight: FontWeight.w800, 
                                color: isUser ? const Color(0xFF2563EB) : AdyapanTheme.textMuted
                              ),
                              textAlign: TextAlign.center,
                            );
                          }(),
                        ),
                        const SizedBox(width: 8),

                        // Avatar / Symbol
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isUser ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0), 
                              width: 1.2
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(row['avatar'], style: const TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(width: 12),

                        // Name
                        Expanded(
                          child: Text(
                            isUser ? '${row['name']} (You)' : row['name'],
                            style: GoogleFonts.fredoka(
                              fontSize: 12, 
                              fontWeight: isUser ? FontWeight.bold : FontWeight.w600,
                              color: isUser ? const Color(0xFF1E3A8A) : AdyapanTheme.textMain,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Score
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isUser ? [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ] : null,
                          ),
                          child: Text(
                            '${row['score']} pts',
                            style: GoogleFonts.outfit(
                              fontSize: 10, 
                              fontWeight: FontWeight.bold, 
                              color: isUser ? Colors.white : const Color(0xFF475569)
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTabButton(int index, String title, String emoji) {
    bool isSelected = _selectedLeaderboardTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLeaderboardTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF2563EB).withOpacity(0.5)
                : const Color(0xFF3B82F6).withOpacity(0.12),
            width: 1.2
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.fredoka(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AdyapanTheme.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // DIALOG-BASED INTERACTIVE LEADERBOARD
  void _showLeaderboardDialog(BuildContext context, AppState state) {
    int localSelectedTab = 0; // 0: BODMAS, 1: Syntax, 2: Word

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Dynamic mappings of top 5 students for each game
            final List<Map<String, dynamic>> bodmasLeaderboard = [
              {'rank': 1, 'name': 'Anya Verma', 'score': 2450, 'avatar': '🧠', 'medal': '🥇'},
              {'rank': 2, 'name': 'Kabir Gupta', 'score': 2310, 'avatar': '⚡', 'medal': '🥈'},
              {'rank': 3, 'name': 'Rohan Malhotra', 'score': 2190, 'avatar': '🎨', 'medal': '🥉'},
              {'rank': 4, 'name': state.studentName, 'score': 1980, 'avatar': '🚀', 'isUser': true},
              {'rank': 5, 'name': 'Diya Sen', 'score': 1850, 'avatar': '🧬', 'medal': ''},
            ];

            final List<Map<String, dynamic>> syntaxLeaderboard = [
              {'rank': 1, 'name': 'Kabir Gupta', 'score': 3100, 'avatar': '⚡', 'medal': '🥇'},
              {'rank': 2, 'name': 'Anya Verma', 'score': 2950, 'avatar': '🧠', 'medal': '🥈'},
              {'rank': 3, 'name': 'Ishaan Mehta', 'score': 2800, 'avatar': '🍕', 'medal': '🥉'},
              {'rank': 4, 'name': state.studentName, 'score': 2750, 'avatar': '🚀', 'isUser': true},
              {'rank': 5, 'name': 'Meera Iyer', 'score': 2500, 'avatar': '📖', 'medal': ''},
            ];

            final List<Map<String, dynamic>> wordLeaderboard = [
              {'rank': 1, 'name': 'Diya Sen', 'score': 1900, 'avatar': '🧬', 'medal': '🥇'},
              {'rank': 2, 'name': state.studentName, 'score': 1850, 'avatar': '🚀', 'isUser': true, 'medal': '🥈'},
              {'rank': 3, 'name': 'Anya Verma', 'score': 1720, 'avatar': '🧠', 'medal': '🥉'},
              {'rank': 4, 'name': 'Rohan Malhotra', 'score': 1600, 'avatar': '🎨', 'medal': ''},
              {'rank': 5, 'name': 'Ishaan Mehta', 'score': 1450, 'avatar': '🍕', 'medal': ''},
            ];

            List<Map<String, dynamic>> activeLeaderboard;
            String gameTitle;
            if (localSelectedTab == 0) {
              activeLeaderboard = bodmasLeaderboard;
              gameTitle = '🧮 BODMAS Balancer';
            } else if (localSelectedTab == 1) {
              activeLeaderboard = syntaxLeaderboard;
              gameTitle = '📝 Syntax Blocks';
            } else {
              activeLeaderboard = wordLeaderboard;
              gameTitle = '🔠 Word Unscramble';
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              titlePadding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🏆 School Leaderboards',
                    style: GoogleFonts.fredoka(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: const Color(0xFF1E3A8A)
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live standings of Adyapan School game players.',
                      style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textMuted, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),

                    // Toggle Game Tabs Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildDialogTabButton(0, 'BODMAS', '🧮', localSelectedTab, () {
                            setDialogState(() {
                              localSelectedTab = 0;
                            });
                          }),
                          const SizedBox(width: 6),
                          _buildDialogTabButton(1, 'Syntax', '📝', localSelectedTab, () {
                            setDialogState(() {
                              localSelectedTab = 1;
                            });
                          }),
                          const SizedBox(width: 6),
                          _buildDialogTabButton(2, 'Words', '🔠', localSelectedTab, () {
                            setDialogState(() {
                              localSelectedTab = 2;
                            });
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Active game header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: Colors.orangeAccent, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            gameTitle,
                            style: GoogleFonts.fredoka(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A)),
                          ),
                          const Spacer(),
                          Text(
                            'Scores reset weekly',
                            style: GoogleFonts.outfit(fontSize: 8, color: AdyapanTheme.textMuted, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Leaderboard items list inside dialog
                    Container(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: activeLeaderboard.length,
                        itemBuilder: (context, index) {
                          final row = activeLeaderboard[index];
                          final isUser = row['isUser'] == true;
                          
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 3.0),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isUser 
                                  ? const Color(0xFFEFF6FF)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isUser 
                                    ? const Color(0xFFBFDBFE) 
                                    : Colors.transparent, 
                                width: 1.0
                              ),
                            ),
                            child: Row(
                              children: [
                                // Medal/Rank
                                SizedBox(
                                  width: 24,
                                  child: () {
                                    if (row['medal'] != null && row['medal'].isNotEmpty) {
                                      return Text(row['medal'], style: const TextStyle(fontSize: 14), textAlign: TextAlign.center);
                                    }
                                    return Text(
                                      '#${row['rank']}', 
                                      style: GoogleFonts.fredoka(
                                        fontSize: 11, 
                                        fontWeight: FontWeight.w800, 
                                        color: isUser ? const Color(0xFF2563EB) : AdyapanTheme.textMuted
                                      ),
                                      textAlign: TextAlign.center,
                                    );
                                  }(),
                                ),
                                const SizedBox(width: 6),

                                // Avatar icon
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: isUser ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isUser ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0), 
                                      width: 1.0
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(row['avatar'], style: const TextStyle(fontSize: 12)),
                                ),
                                const SizedBox(width: 8),

                                // Dynamic name with dynamic profile
                                Expanded(
                                  child: Text(
                                    isUser ? '${row['name']} (You)' : row['name'],
                                    style: GoogleFonts.fredoka(
                                      fontSize: 11, 
                                      fontWeight: isUser ? FontWeight.bold : FontWeight.w600,
                                      color: isUser ? const Color(0xFF1E3A8A) : AdyapanTheme.textMain,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Score pts
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isUser ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${row['score']} pts',
                                    style: GoogleFonts.outfit(
                                      fontSize: 9, 
                                      fontWeight: FontWeight.bold, 
                                      color: isUser ? Colors.white : const Color(0xFF475569)
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close', 
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.bold, 
                      color: AdyapanTheme.textSub
                    )
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTabButton(int index, String title, String emoji, int currentTab, VoidCallback onTap) {
    bool isSelected = currentTab == index;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
            width: 1.0
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 10)),
            const SizedBox(width: 4),
            Text(
              title,
              style: GoogleFonts.fredoka(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AdyapanTheme.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
