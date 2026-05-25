import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({Key? key}) : super(key: key);

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confetti;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _confetti.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Color _priorityColor(String priority) {
    if (priority == 'High') return const Color(0xFFEF4444);
    if (priority == 'Medium') return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  Color _priorityBg(String priority) {
    if (priority == 'High') return const Color(0xFFFEF2F2);
    if (priority == 'Medium') return const Color(0xFFFFFBEB);
    return const Color(0xFFECFDF5);
  }

  void _submitHomework(AppState state, int id, String title) {
    final done = state.submitHomework(id);
    if (done) {
      _confetti.play();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 "$title" submitted successfully!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Widget _buildHomeworkCard(AppState state, Map<String, dynamic> hw) {
    final bool submitted = hw['submitted'] == true;
    final priority = hw['priority'] as String;
    final pColor = _priorityColor(priority);
    final pBg = _priorityBg(priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: submitted ? const Color(0xFF10B981).withOpacity(0.3) : pColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                // Subject badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: pBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: pColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    hw['subject'],
                    style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: pColor),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    '$priority Priority',
                    style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: AdyapanTheme.textMuted),
                  ),
                ),
              ],
            ),
          ),

          // Title + description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hw['title'], style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain)),
                const SizedBox(height: 4),
                Text(hw['description'], style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textSub, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: BoxDecoration(
              color: submitted ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 11, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text('Due: ${hw['dueDate']}', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AdyapanTheme.textSub), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 11, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text('By ${hw['addedBy']}', style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textMuted), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      if (submitted && hw['submittedAt'] != null) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 11, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text('Submitted: ${hw['submittedAt']}', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)), overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Submit / Done button
                submitted
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_rounded, size: 13, color: Colors.white),
                            const SizedBox(width: 4),
                            Text('Submitted', style: GoogleFonts.fredoka(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => _submitHomework(state, hw['id'], hw['title']),
                        icon: const Icon(Icons.upload_rounded, size: 13, color: Colors.white),
                        label: Text('Submit', style: GoogleFonts.fredoka(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final pending = state.homeworkList.where((h) => h['submitted'] == false).toList();
    final submitted = state.homeworkList.where((h) => h['submitted'] == true).toList();
    final all = state.homeworkList;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          Column(
            children: [
              // ── HEADER ──
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 16, 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '📝 Homework Portal',
                                    style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  Text(
                                    'Submit assignments & view your school agenda',
                                    style: GoogleFonts.outfit(fontSize: 10, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Stats row
                        Row(
                          children: [
                            _headerStat('${all.length}', 'Total', Icons.assignment_rounded),
                            const SizedBox(width: 10),
                            _headerStat('${pending.length}', 'Pending', Icons.pending_actions_rounded),
                            const SizedBox(width: 10),
                            _headerStat('${submitted.length}', 'Submitted', Icons.task_alt_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── TAB BAR ──
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelStyle: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: GoogleFonts.fredoka(fontSize: 13),
                  labelColor: const Color(0xFF2563EB),
                  unselectedLabelColor: AdyapanTheme.textMuted,
                  indicatorColor: const Color(0xFF2563EB),
                  tabs: [
                    Tab(text: 'Pending (${pending.length})'),
                    Tab(text: 'Submitted (${submitted.length})'),
                  ],
                ),
              ),

              // ── CONTENT ──
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // PENDING TAB
                    pending.isEmpty
                        ? _emptyState('🎉 All Done!', 'No pending homework. Great work!')
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            itemCount: pending.length,
                            itemBuilder: (context, i) => _buildHomeworkCard(state, pending[i]),
                          ),

                    // SUBMITTED TAB
                    submitted.isEmpty
                        ? _emptyState('📭 Nothing submitted yet', 'Complete pending homework to see them here.')
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            itemCount: submitted.length,
                            itemBuilder: (context, i) => _buildHomeworkCard(state, submitted[i]),
                          ),
                  ],
                ),
              ),
            ],
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Color(0xFF2563EB), Color(0xFF10B981), Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(label, style: GoogleFonts.outfit(fontSize: 9, color: Colors.white.withOpacity(0.75), fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎒', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 14),
          Text(title, style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain)),
          const SizedBox(height: 6),
          Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: AdyapanTheme.textMuted), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
