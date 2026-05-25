import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final mathPct = state.mathSyllabusProgress;
        final sciPct = state.scienceSyllabusProgress;
        final engPct = state.englishSyllabusProgress;
        final overallPct = state.overallSyllabusProgress;
        final quizDone = state.completedQuizzesCount;
        final xp = state.xp;
        final level = state.level;

        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: Column(
            children: [
              // ── GRADIENT HEADER ──
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button row
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Text(
                                '⭐ Level $level',
                                style: GoogleFonts.fredoka(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Academic Progress',
                                style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                'Your complete learning overview 📈',
                                style: GoogleFonts.outfit(fontSize: 12, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 16),

                              // Overall ring row inside header
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                                ),
                                child: Row(
                                  children: [
                                    // Ring
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 70,
                                          height: 70,
                                          child: CircularProgressIndicator(
                                            value: overallPct / 100,
                                            strokeWidth: 7,
                                            backgroundColor: Colors.white.withOpacity(0.2),
                                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${overallPct.toStringAsFixed(0)}%',
                                              style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Overall Syllabus',
                                            style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                          Text(
                                            '$quizDone quizzes done  •  $xp XP earned',
                                            style: GoogleFonts.outfit(fontSize: 11, color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 8),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: LinearProgressIndicator(
                                              value: (xp % 200) / 200.0,
                                              minHeight: 7,
                                              backgroundColor: Colors.white.withOpacity(0.2),
                                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${xp % 200}/200 XP to Level ${level + 1}',
                                            style: GoogleFonts.outfit(fontSize: 9, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── SCROLLABLE CONTENT ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── QUIZ & GAME PROGRESS ──
                      _sectionTitle('🎮 Quiz & Game Progress'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          children: [
                            _buildQuizRow('🧮 BODMAS Balancer', quizDone >= 1, const Color(0xFF6366F1)),
                            const Divider(height: 16, color: Color(0xFFF1F5F9)),
                            _buildQuizRow('📝 Syntax Blocks', quizDone >= 2, const Color(0xFF6366F1)),
                            const Divider(height: 16, color: Color(0xFFF1F5F9)),
                            _buildQuizRow('🔠 Word Unscramble', quizDone >= 3, const Color(0xFF6366F1)),
                            const Divider(height: 16, color: Color(0xFFF1F5F9)),
                            _buildQuizRow('⚡ Speed Math', quizDone >= 4, const Color(0xFF6366F1)),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$quizDone / 4 Games Completed',
                                style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── CLASS SYLLABUS PROGRESS ──
                      _sectionTitle('📚 Class Syllabus Progress'),
                      const SizedBox(height: 10),
                      _buildSubjectCard('📐 Mathematics', mathPct, const Color(0xFF2563EB), const Color(0xFFEFF6FF), 'Based on roadmap + quizzes'),
                      const SizedBox(height: 10),
                      _buildSubjectCard('⚛️ Science', sciPct, const Color(0xFF10B981), const Color(0xFFECFDF5), 'Based on roadmap + quizzes'),
                      const SizedBox(height: 10),
                      _buildSubjectCard('📖 English', engPct, const Color(0xFF8B5CF6), const Color(0xFFF5F3FF), 'Based on quiz activity'),
                      const SizedBox(height: 24),

                      // ── CLASS ATTENDANCE ──
                      _sectionTitle('🏫 Class Attendance'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Attendance ring
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      height: 80,
                                      child: CircularProgressIndicator(
                                        value: 0.94,
                                        strokeWidth: 8,
                                        backgroundColor: const Color(0xFFFEF3C7),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('94%', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
                                        Text('Present', style: GoogleFonts.outfit(fontSize: 8, color: AdyapanTheme.textMuted, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _attendanceStat('✅ Classes Attended', '118 / 125'),
                                      const SizedBox(height: 6),
                                      _attendanceStat('🟡 Excused Leaves', '4 days'),
                                      const SizedBox(height: 6),
                                      _attendanceStat('❌ Absences', '3 days'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: 0.94,
                                minHeight: 10,
                                backgroundColor: const Color(0xFFFEF3C7),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Minimum required: 75%', style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textMuted, fontWeight: FontWeight.w500)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('Excellent 🎉', style: GoogleFonts.fredoka(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── SUBJECT-WISE ATTENDANCE ──
                      _sectionTitle('📋 Subject-wise Attendance'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          children: [
                            _buildSubjectAttendanceRow('📐 Mathematics', 0.97, '97%', const Color(0xFF2563EB)),
                            const Divider(height: 16, color: Color(0xFFF1F5F9)),
                            _buildSubjectAttendanceRow('⚛️ Science', 0.92, '92%', const Color(0xFF10B981)),
                            const Divider(height: 16, color: Color(0xFFF1F5F9)),
                            _buildSubjectAttendanceRow('📖 English', 0.95, '95%', const Color(0xFF8B5CF6)),
                            const Divider(height: 16, color: Color(0xFFF1F5F9)),
                            _buildSubjectAttendanceRow('🌍 Social Studies', 0.88, '88%', const Color(0xFFF59E0B)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Go to Roadmap button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // Switch to roadmap tab
                            final state = Provider.of<AppState>(context, listen: false);
                            state.setTab(1);
                          },
                          icon: const Icon(Icons.map_outlined, size: 16, color: Colors.white),
                          label: Text('View Full Learning Roadmap', style: GoogleFonts.fredoka(color: Colors.white, fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain));
  }

  Widget _buildQuizRow(String title, bool completed, Color accent) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: completed ? accent : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(color: completed ? accent : const Color(0xFFE2E8F0)),
          ),
          child: Icon(
            completed ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
            size: 14,
            color: completed ? Colors.white : AdyapanTheme.textMuted,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.w600, color: AdyapanTheme.textMain))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: completed ? accent.withOpacity(0.1) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            completed ? 'Completed' : 'Pending',
            style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: completed ? accent : AdyapanTheme.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(String subject, double pct, Color accent, Color bg, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: accent.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject, style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: accent.withOpacity(0.2))),
                child: Text('${pct.toStringAsFixed(0)}%', style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold, color: accent)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textMuted, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 9,
              backgroundColor: accent.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textSub, fontWeight: FontWeight.w500)),
        Text(value, style: GoogleFonts.fredoka(fontSize: 11, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain)),
      ],
    );
  }

  Widget _buildSubjectAttendanceRow(String subject, double val, String pctLabel, Color accent) {
    return Row(
      children: [
        Expanded(child: Text(subject, style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.w600, color: AdyapanTheme.textMain))),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: val,
              minHeight: 7,
              backgroundColor: accent.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(pctLabel, style: GoogleFonts.fredoka(fontSize: 11, fontWeight: FontWeight.bold, color: accent)),
      ],
    );
  }
}
