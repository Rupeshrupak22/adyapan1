import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';
import '../core/db_helper.dart';
import 'login_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> with SingleTickerProviderStateMixin {
  int _activeTab = 0;
  late TabController _tabController;

  // Homework controllers
  final _hwTitleCtrl = TextEditingController();
  final _hwDescCtrl = TextEditingController();
  final _hwDueDateCtrl = TextEditingController();
  String _hwSubject = '📐 Mathematics';
  String _hwPriority = 'Normal';

  // Notes controllers
  final _noteTitleCtrl = TextEditingController();
  final _noteDescCtrl = TextEditingController();
  final _noteFileNameCtrl = TextEditingController();
  final _noteSizeCtrl = TextEditingController();
  final _notePagesCtrl = TextEditingController();
  String _noteSubject = '📐 Mathematics';

  // Quiz creator controllers
  final _quizQuestionCtrl = TextEditingController();
  final _quizOptACtrl = TextEditingController();
  final _quizOptBCtrl = TextEditingController();
  final _quizOptCCtrl = TextEditingController();
  final _quizOptDCtrl = TextEditingController();
  int _quizCorrectIndex = 0;

  // Doubts mock data
  List<Map<String, dynamic>> _mockDoubts = [
    {
      'id': 1,
      'studentName': 'Rahul Sharma',
      'studentClass': 'Class 7',
      'question': 'Ma\'am, in BODMAS rule, does division always get executed before multiplication? What if they are written as 8 / 2 * 4?',
      'replied': false,
      'replyText': '',
      'time': '10 mins ago',
    },
    {
      'id': 2,
      'studentName': 'Priya Patel',
      'studentClass': 'Class 9',
      'question': 'How does the Python Syntax block for conditional loop execution construct properly? I am having trouble with Level 3.',
      'replied': true,
      'replyText': 'Great question, Priya! In Level 3, make sure your indentation for print statement inside "if score > 50:" matches precisely. It requires 4 spaces!',
      'time': '1 hour ago',
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Refresh student list automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).fetchLinkedStudents();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hwTitleCtrl.dispose();
    _hwDescCtrl.dispose();
    _hwDueDateCtrl.dispose();
    _noteTitleCtrl.dispose();
    _noteDescCtrl.dispose();
    _noteFileNameCtrl.dispose();
    _noteSizeCtrl.dispose();
    _notePagesCtrl.dispose();
    _quizQuestionCtrl.dispose();
    _quizOptACtrl.dispose();
    _quizOptBCtrl.dispose();
    _quizOptCCtrl.dispose();
    _quizOptDCtrl.dispose();
    super.dispose();
  }

  void _copyUid(String uid) {
    Clipboard.setData(ClipboardData(text: uid));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✨ Teacher UID copied to clipboard!', style: AdyapanTheme.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AdyapanTheme.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      )
    );
  }

  void _handleLogout() {
    final state = Provider.of<AppState>(context, listen: false);
    state.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final teacherName = state.studentName;
    final teacherEmail = state.studentEmail;
    final teacherUid = state.teacherId.isNotEmpty ? state.teacherId : 'TCH-999';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Educator Portal 🍎',
                style: GoogleFonts.fredoka(fontSize: 14, color: const Color(0xFFFF3B70), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          )
        ],
      ),
      body: Column(
        children: [
          // 1. WELCOME PROFILE & UID SHARING BANNER
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ]
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, Educator!',
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        teacherName,
                        style: GoogleFonts.fredoka(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        teacherEmail,
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                // Glowing Golden Teacher UID Badge
                GestureDetector(
                  onTap: () => _copyUid(teacherUid),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'YOUR UID',
                          style: GoogleFonts.outfit(fontSize: 8.5, fontWeight: FontWeight.w900, color: const Color(0xFF4A3400), letterSpacing: 1),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              teacherUid,
                              style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF4A3400)),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF4A3400)),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          // 2. SLIDING TOP TAB BAR
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFFFF3B70),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFFFF3B70),
              indicatorWeight: 3,
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: '🎓 Students Grid'),
                Tab(text: '🏆 Leaderboards'),
                Tab(text: '➕ Add Homework & Notes'),
                Tab(text: '📝 Add Quiz Question'),
                Tab(text: '💬 Student Doubts'),
              ],
            ),
          ),

          // 3. TAB VIEW
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStudentsGridTab(state),
                _buildLeaderboardsTab(),
                _buildHomeworkNotesTab(state),
                _buildQuizQuestionTab(state),
                _buildDoubtsTab(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Map<String, dynamic> _getStudentProgress(Map<String, dynamic> student) {
    final name = student['name'] ?? '';
    final code = name.hashCode.abs();
    final mathPct = 50.0 + (code % 45); // between 50% and 95%
    final sciPct = 40.0 + (code % 50);  // between 40% and 90%
    final engPct = 60.0 + (code % 35);  // between 60% and 95%
    final overallPct = (mathPct + sciPct + engPct) / 3.0;
    final level = 1 + (code % 8);       // level 1 to 8
    final xp = level * 200 - 150 + (code % 100);
    final quizDone = 2 + (code % 3);    // 2 to 4 quizzes done
    return {
      'mathPct': mathPct,
      'sciPct': sciPct,
      'engPct': engPct,
      'overallPct': overallPct,
      'level': level,
      'xp': xp,
      'quizDone': quizDone,
    };
  }

  void _showStudentInsightsDialog(BuildContext context, Map<String, dynamic> student) {
    final studentId = student['id'] ?? '';
    final progress = _getStudentProgress(student);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return DefaultTabController(
              length: 3,
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFECF5FF),
                      child: Text(
                        student['name'].toString().isNotEmpty 
                            ? student['name'].toString().substring(0, 1).toUpperCase() 
                            : 'S',
                        style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student['name'] ?? '',
                            style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${student['className']} • Insights',
                            style: GoogleFonts.outfit(fontSize: 10.5, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 420,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: const Color(0xFFFF3B70),
                        unselectedLabelColor: const Color(0xFF64748B),
                        indicatorColor: const Color(0xFFFF3B70),
                        indicatorSize: TabBarIndicatorSize.label,
                        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                        unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12),
                        tabs: const [
                          Tab(text: '📅 Attendance'),
                          Tab(text: '📈 Progress'),
                          Tab(text: '🗺️ Roadmap'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildAttendanceTabContent(studentId, student, setStateDialog),
                            _buildProgressTabContent(progress),
                            _buildRoadmapTabContent(progress),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {}); // Refresh students grid rates
                    },
                    child: Text(
                      'Close',
                      style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, color: const Color(0xFFFF3B70)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAttendanceTabContent(String studentId, Map<String, dynamic> student, StateSetter setStateDialog) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DbHelper.fetchAttendanceLogs(studentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF3B70)));
        }

        final logs = snapshot.data ?? [];
        int presentCount = logs.where((l) => l['status'] == 'Present').length;
        int excusedCount = logs.where((l) => l['status'] == 'Excused').length;
        int totalCount = logs.length;
        int rate = totalCount > 0 ? ((presentCount / totalCount) * 100).round() : 100;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: rate >= 85 ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
                  border: Border.all(
                    color: (rate >= 85 ? const Color(0xFF10B981) : Colors.orange).withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Overall Weekly Attendance Rate',
                      style: GoogleFonts.outfit(
                        fontSize: 11, 
                        fontWeight: FontWeight.w600, 
                        color: rate >= 85 ? const Color(0xFF047857) : Colors.orange[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$rate%',
                      style: GoogleFonts.fredoka(
                        fontSize: 30, 
                        fontWeight: FontWeight.bold, 
                        color: rate >= 85 ? const Color(0xFF065F46) : Colors.orange[950],
                      ),
                    ),
                    Text(
                      'Total: $totalCount • Present: $presentCount • Excused: $excusedCount',
                      style: GoogleFonts.outfit(
                        fontSize: 10, 
                        fontWeight: FontWeight.bold, 
                        color: rate >= 85 ? const Color(0xFF047857) : Colors.orange[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Attendance Records:',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final marked = await _showMarkAttendanceBottomSheet(context, student);
                      if (marked == true) {
                        setStateDialog(() {});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B70),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                    label: Text(
                      'Mark',
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (logs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      'No attendance logged yet.',
                      style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
                    ),
                  ),
                )
              else
                ...logs.map((log) {
                  final status = log['status'] as String? ?? 'Present';
                  final subject = log['subject'] as String? ?? 'Subject';
                  final source = log['source'] as String? ?? 'Manual';
                  final time = log['time'] as String? ?? '';
                  return _buildAttendanceDialogRow(subject, status, time, source);
                }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressTabContent(Map<String, dynamic> progress) {
    final mathPct = progress['mathPct'] as double;
    final sciPct = progress['sciPct'] as double;
    final engPct = progress['engPct'] as double;
    final overallPct = progress['overallPct'] as double;
    final quizDone = progress['quizDone'] as int;
    final xp = progress['xp'] as int;
    final level = progress['level'] as int;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: CircularProgressIndicator(
                        value: overallPct / 100,
                        strokeWidth: 5,
                        backgroundColor: const Color(0xFFCBD5E1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                      ),
                    ),
                    Text(
                      '${overallPct.toStringAsFixed(0)}%',
                      style: GoogleFonts.fredoka(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1)),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⭐ Student Level $level',
                        style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$quizDone quizzes completed • $xp XP',
                        style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Subject-wise Syllabus Progress:',
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
          ),
          const SizedBox(height: 10),
          _buildSyllabusProgressRow('📐 Mathematics', mathPct, const Color(0xFF2563EB)),
          const SizedBox(height: 10),
          _buildSyllabusProgressRow('⚛️ Science', sciPct, const Color(0xFF10B981)),
          const SizedBox(height: 10),
          _buildSyllabusProgressRow('📖 English', engPct, const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _buildSyllabusProgressRow(String subject, double pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subject,
              style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            Text(
              '${pct.toStringAsFixed(0)}%',
              style: GoogleFonts.fredoka(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 7,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        )
      ],
    );
  }

  Widget _buildRoadmapTabContent(Map<String, dynamic> progress) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mathematics Learning Pathway:',
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
          ),
          const SizedBox(height: 10),
          _buildRoadmapNodeTimeline('1', 'Arithmetic Basics', 'BODMAS Foundations', 'completed'),
          _buildRoadmapNodeTimeline('2', 'BODMAS Balancer', 'Equation Balancing', 'unlocked'),
          _buildRoadmapNodeTimeline('3', 'Fraction Arcade', 'Division & Pieces', 'locked'),
          _buildRoadmapNodeTimeline('4', 'Algebra Quest', 'Find the Unknown X', 'locked'),
          
          const SizedBox(height: 16),
          Text(
            'Science Learning Pathway:',
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
          ),
          const SizedBox(height: 10),
          _buildRoadmapNodeTimeline('1', 'Solar System Orbit', 'Planets & Gravity', 'completed'),
          _buildRoadmapNodeTimeline('2', 'Atomic Structure', 'Electrons & Protons', 'unlocked'),
          _buildRoadmapNodeTimeline('3', 'Chemical Equations', 'Reaction Balancer', 'locked'),
        ],
      ),
    );
  }

  Widget _buildRoadmapNodeTimeline(String stepNum, String title, String subtitle, String status) {
    Color iconBg = Colors.grey[200]!;
    Color lineCol = Colors.grey[300]!;
    IconData icon = Icons.lock_rounded;
    Color iconCol = Colors.grey[500]!;
    Color titleCol = Colors.grey[600]!;

    if (status == 'completed') {
      iconBg = const Color(0xFFECFDF5);
      lineCol = const Color(0xFF10B981);
      icon = Icons.check_circle_rounded;
      iconCol = const Color(0xFF10B981);
      titleCol = const Color(0xFF1E293B);
    } else if (status == 'unlocked') {
      iconBg = const Color(0xFFEFF6FF);
      lineCol = Colors.blueAccent;
      icon = Icons.play_circle_fill_rounded;
      iconCol = Colors.blueAccent;
      titleCol = const Color(0xFF1E293B);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 11, color: iconCol),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: lineCol,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold, color: titleCol),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<bool?> _showMarkAttendanceBottomSheet(BuildContext context, Map<String, dynamic> student) {
    String selectedSubject = '📐 Mathematics';
    String selectedStatus = 'Present';
    String selectedSource = 'Manual Entry';
    
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mark Attendance',
                    style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  Text(
                    'Student: ${student['name']}',
                    style: GoogleFonts.outfit(fontSize: 13, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Subject',
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSubject,
                        isExpanded: true,
                        onChanged: (val) => setStateSheet(() => selectedSubject = val!),
                        items: ['📐 Mathematics', '⚛️ Science', '📖 English', '💻 Computer Science', '🌍 Social Studies']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.outfit(fontSize: 13)))).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Attendance Status',
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: ['Present', 'Absent', 'Excused'].map((status) {
                      final isSelected = selectedStatus == status;
                      Color btnColor = Colors.grey[200]!;
                      Color txtColor = const Color(0xFF475569);
                      if (isSelected) {
                        if (status == 'Present') { btnColor = const Color(0xFFECFDF5); txtColor = const Color(0xFF047857); }
                        else if (status == 'Absent') { btnColor = const Color(0xFFFEF2F2); txtColor = const Color(0xFFB91C1C); }
                        else { btnColor = const Color(0xFFEFF6FF); txtColor = const Color(0xFF1D4ED8); }
                      }
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: InkWell(
                            onTap: () => setStateSheet(() => selectedStatus = status),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: btnColor,
                                border: Border.all(
                                  color: isSelected ? txtColor : Colors.transparent,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status,
                                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: txtColor),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Class Type / Source',
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSource,
                        isExpanded: true,
                        onChanged: (val) => setStateSheet(() => selectedSource = val!),
                        items: ['Live Class', 'Recorded Video', 'Manual Entry']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.outfit(fontSize: 13)))).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
                        final ampm = now.hour >= 12 ? 'PM' : 'AM';
                        final min = now.minute < 10 ? '0${now.minute}' : '${now.minute}';
                        final timeStr = '$hour:$min $ampm';
                        
                        final state = Provider.of<AppState>(context, listen: false);
                        final success = await state.markStudentAttendanceByTeacher(
                          studentId: student['id'] ?? '',
                          subject: selectedSubject,
                          status: selectedStatus,
                          time: timeStr,
                          source: selectedSource,
                        );
                        
                        if (success) {
                          Navigator.pop(context, true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🎉 Attendance marked successfully for ${student['name']}!', style: AdyapanTheme.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                              backgroundColor: AdyapanTheme.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('❌ Failed to mark attendance on the database!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3B70),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Mark Student Attendance ✓',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAttendanceDialogRow(String subject, String status, String time, String source) {
    Color statusColor = AdyapanTheme.green;
    if (status == 'Absent') statusColor = Colors.redAccent;
    if (status == 'Excused') statusColor = AdyapanTheme.purple;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                Text(
                  '$source • $time',
                  style: GoogleFonts.outfit(fontSize: 10.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              status,
              style: GoogleFonts.outfit(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  // ──── TAB 1: STUDENTS GRID ────
  Widget _buildStudentsGridTab(AppState state) {
    final list = state.linkedStudents;

    if (list.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('📪', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text(
                'No students linked yet!',
                style: GoogleFonts.fredoka(fontSize: 20, color: const Color(0xFF1E293B), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Share your unique Teacher UID with your students so they can link to your class when they register!',
                  style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => _copyUid(state.teacherId.isNotEmpty ? state.teacherId : 'TCH-999'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3B70),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.share_rounded, color: Colors.white, size: 16),
                label: Text('Copy UID to Share', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final student = list[index];
        final studentId = student['id'] ?? '';

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: DbHelper.fetchAttendanceLogs(studentId),
          builder: (context, snapshot) {
            final logs = snapshot.data ?? [];
            int present = logs.where((l) => l['status'] == 'Present').length;
            int total = logs.length;
            int rate = total > 0 ? ((present / total) * 100).round() : 100;

            Color badgeBg = rate >= 85 ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED);
            Color badgeText = rate >= 85 ? const Color(0xFF065F46) : Colors.orange[800]!;
            Color badgeBorder = (rate >= 85 ? const Color(0xFF10B981) : Colors.orange).withOpacity(0.2);

            return GestureDetector(
              onTap: () => _showStudentInsightsDialog(context, student),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFECF5FF),
                        child: Text(
                          student['name'].toString().isNotEmpty ? student['name'].toString().substring(0, 1).toUpperCase() : 'S',
                          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        student['name'] ?? '',
                        style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        student['className'] ?? 'Class Student',
                        style: GoogleFonts.outfit(fontSize: 11, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: badgeBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('📊 ', style: TextStyle(fontSize: 10)),
                            Text(
                              'Attendance: $rate%',
                              style: GoogleFonts.outfit(fontSize: 9.5, fontWeight: FontWeight.bold, color: badgeText),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Divider(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.school_outlined, size: 13, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              student['school'] ?? '',
                              style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 13, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            student['phone'] ?? '',
                            style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ──── TAB 2: LEADERBOARDS ────
  Widget _buildLeaderboardsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGameLeaderboardCard(
            title: '🧮 BODMAS Equation Balancer',
            standings: [
              {'name': 'Gulshan (You)', 'score': 'Level 5 (Finished)', 'trophy': '🥇'},
              {'name': 'Rohan Das', 'score': 'Level 4 Completed', 'trophy': '🥈'},
              {'name': 'Ananya Roy', 'score': 'Level 3 Completed', 'trophy': '🥉'},
            ],
            color: const Color(0xFFFFFBEB),
            borderColor: const Color(0xFFFFB000),
          ),
          const SizedBox(height: 16),
          _buildGameLeaderboardCard(
            title: '📝 Python Syntax Blocks',
            standings: [
              {'name': 'Ananya Roy', 'score': 'Level 4 (Finished)', 'trophy': '🥇'},
              {'name': 'Gulshan (You)', 'score': 'Level 3 Completed', 'trophy': '🥈'},
              {'name': 'Rohan Das', 'score': 'Level 2 Completed', 'trophy': '🥉'},
            ],
            color: const Color(0xFFF5F3FF),
            borderColor: const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 16),
          _buildGameLeaderboardCard(
            title: '🔠 Word Unscramble Brain Booster',
            standings: [
              {'name': 'Gulshan (You)', 'score': 'Level 5 (Finished)', 'trophy': '🥇'},
              {'name': 'Ananya Roy', 'score': 'Level 4 Completed', 'trophy': '🥈'},
              {'name': 'Amit Kumar', 'score': 'Level 3 Completed', 'trophy': '🥉'},
            ],
            color: const Color(0xFFECFDF5),
            borderColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildGameLeaderboardCard({
    required String title,
    required List<Map<String, String>> standings,
    required Color color,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 12),
          Column(
            children: standings.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(item['trophy']!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['name']!,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                      ),
                    ),
                    Text(
                      item['score']!,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: const Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  // ──── TAB 3: HOMEWORK & NOTES ────
  Widget _buildHomeworkNotesTab(AppState state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. HOMEWORK FORM CARD
          _buildSectionHeader('📚 Assign New Homework'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildTextForm(controller: _hwTitleCtrl, label: 'Homework Title', hint: 'e.g. Pythagoras Theorem Problems'),
                const SizedBox(height: 12),
                _buildTextForm(controller: _hwDescCtrl, label: 'Homework Description', hint: 'Provide details, instructions or questions'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextForm(controller: _hwDueDateCtrl, label: 'Due Date', hint: 'e.g. Tomorrow, or In 3 days'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Subject', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF475569))),
                          const SizedBox(height: 4),
                          Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _hwSubject,
                                isExpanded: true,
                                onChanged: (val) => setState(() => _hwSubject = val!),
                                items: ['📐 Mathematics', '⚛️ Science', '📖 English', '💻 Computer Science', '🌍 Social Studies']
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.outfit(fontSize: 13)))).toList(),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_hwTitleCtrl.text.isEmpty || _hwDescCtrl.text.isEmpty || _hwDueDateCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ All homework fields are required!')));
                      return;
                    }
                    state.addHomework(
                      title: _hwTitleCtrl.text.trim(),
                      subject: _hwSubject,
                      description: _hwDescCtrl.text.trim(),
                      dueDate: _hwDueDateCtrl.text.trim(),
                      priority: 'High',
                      addedBy: state.studentName,
                    );
                    _hwTitleCtrl.clear();
                    _hwDescCtrl.clear();
                    _hwDueDateCtrl.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 Homework assigned successfully!', style: AdyapanTheme.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                        backgroundColor: AdyapanTheme.green,
                        behavior: SnackBarBehavior.floating,
                      )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B70),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Assign Homework 🚀', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // B. NOTES FORM CARD
          _buildSectionHeader('📁 Upload Chapter Notes (PDFs)'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildTextForm(controller: _noteTitleCtrl, label: 'Note/Chapter Title', hint: 'e.g. Photosynthesis Chapter 3'),
                const SizedBox(height: 12),
                _buildTextForm(controller: _noteDescCtrl, label: 'Brief Note Description', hint: 'Include chapter summary or context'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextForm(controller: _noteFileNameCtrl, label: 'File Name', hint: 'e.g. Chapter_3_Notes.pdf'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextForm(controller: _noteSizeCtrl, label: 'File Size', hint: 'e.g. 1.5 MB'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextForm(controller: _notePagesCtrl, label: 'Total Pages', hint: 'e.g. 15', keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Subject', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF475569))),
                          const SizedBox(height: 4),
                          Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _noteSubject,
                                isExpanded: true,
                                onChanged: (val) => setState(() => _noteSubject = val!),
                                items: ['📐 Mathematics', '⚛️ Science', '📖 English', '💻 Computer Science', '🌍 Social Studies']
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.outfit(fontSize: 13)))).toList(),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_noteTitleCtrl.text.isEmpty || _noteDescCtrl.text.isEmpty || _noteFileNameCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Note details are required!')));
                      return;
                    }
                    state.addNote(
                      title: _noteTitleCtrl.text.trim(),
                      subject: _noteSubject,
                      description: _noteDescCtrl.text.trim(),
                      fileName: _noteFileNameCtrl.text.trim(),
                      fileSize: _noteSizeCtrl.text.isEmpty ? '1.0 MB' : _noteSizeCtrl.text.trim(),
                      pages: int.tryParse(_notePagesCtrl.text) ?? 10,
                      uploadedBy: state.studentName,
                    );
                    _noteTitleCtrl.clear();
                    _noteDescCtrl.clear();
                    _noteFileNameCtrl.clear();
                    _noteSizeCtrl.clear();
                    _notePagesCtrl.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 Notes uploaded successfully!', style: AdyapanTheme.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                        backgroundColor: AdyapanTheme.green,
                        behavior: SnackBarBehavior.floating,
                      )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B70),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Upload Note 🚀', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // ──── TAB 4: ADD QUIZ QUESTION ────
  Widget _buildQuizQuestionTab(AppState state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('➕ Add Custom Quiz Question'),
          const SizedBox(height: 4),
          Text(
            'This question will immediately inject into your students\' gaming console / arcade quizzes!',
            style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextForm(controller: _quizQuestionCtrl, label: 'Question Text', hint: 'e.g. Which of the following is the square of 25?'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextForm(controller: _quizOptACtrl, label: 'Option A', hint: 'Option A')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTextForm(controller: _quizOptBCtrl, label: 'Option B', hint: 'Option B')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextForm(controller: _quizOptCCtrl, label: 'Option C', hint: 'Option C')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTextForm(controller: _quizOptDCtrl, label: 'Option D', hint: 'Option D')),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Correct Option', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF475569))),
                const SizedBox(height: 4),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _quizCorrectIndex,
                      isExpanded: true,
                      onChanged: (val) => setState(() => _quizCorrectIndex = val!),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Option A')),
                        DropdownMenuItem(value: 1, child: Text('Option B')),
                        DropdownMenuItem(value: 2, child: Text('Option C')),
                        DropdownMenuItem(value: 3, child: Text('Option D')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_quizQuestionCtrl.text.isEmpty ||
                        _quizOptACtrl.text.isEmpty ||
                        _quizOptBCtrl.text.isEmpty ||
                        _quizOptCCtrl.text.isEmpty ||
                        _quizOptDCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ All question and options fields are required!')));
                      return;
                    }
                    state.addCustomQuizQuestion(
                      question: _quizQuestionCtrl.text.trim(),
                      options: [
                        _quizOptACtrl.text.trim(),
                        _quizOptBCtrl.text.trim(),
                        _quizOptCCtrl.text.trim(),
                        _quizOptDCtrl.text.trim(),
                      ],
                      correctOptionIndex: _quizCorrectIndex,
                    );
                    _quizQuestionCtrl.clear();
                    _quizOptACtrl.clear();
                    _quizOptBCtrl.clear();
                    _quizOptCCtrl.clear();
                    _quizOptDCtrl.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 Custom Quiz Question Live!', style: AdyapanTheme.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                        backgroundColor: AdyapanTheme.green,
                        behavior: SnackBarBehavior.floating,
                      )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B70),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Inject Question into Games 🚀', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // ──── TAB 5: STUDENT DOUBTS ────
  Widget _buildDoubtsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _mockDoubts.length,
      itemBuilder: (context, index) {
        final doubt = _mockDoubts[index];
        final isReplied = doubt['replied'] as bool;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isReplied ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                      child: Text(
                        isReplied ? '✅' : '❓',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doubt['studentName'],
                          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF1E293B)),
                        ),
                        Text(
                          '${doubt['studentClass']} • ${doubt['time']}',
                          style: GoogleFonts.outfit(fontSize: 10.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  doubt['question'],
                  style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF334155), fontWeight: FontWeight.w500),
                ),
                if (isReplied) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Answer:',
                          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doubt['replyText'],
                          style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF475569), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                ] else ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final replyCtrl = TextEditingController();
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Resolve Doubt', style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
                                content: TextField(
                                  controller: replyCtrl,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: 'Type your explanation...',
                                    hintStyle: GoogleFonts.outfit(fontSize: 12),
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (replyCtrl.text.isNotEmpty) {
                                        setState(() {
                                          doubt['replied'] = true;
                                          doubt['replyText'] = replyCtrl.text.trim();
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('🎉 Reply posted successfully!', style: AdyapanTheme.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                                            backgroundColor: AdyapanTheme.green,
                                            behavior: SnackBarBehavior.floating,
                                          )
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B70)),
                                    child: const Text('Post Reply', style: TextStyle(color: Colors.white)),
                                  )
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF3B70),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Reply / Resolve 💬', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  // ──── HELPERS ────
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
    );
  }

  Widget _buildTextForm({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF0F172A), fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              borderSide: const BorderSide(color: Color(0xFFFF3B70), width: 1.5),
            ),
          ),
        )
      ],
    );
  }
}
