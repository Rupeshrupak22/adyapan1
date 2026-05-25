import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({Key? key}) : super(key: key);

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> with SingleTickerProviderStateMixin {
  int _selectedSubjectIndex = 0;
  late TabController _tabController;

  final List<Map<String, dynamic>> _subjects = [
    {
      'name': 'Mathematics',
      'emoji': '📐',
      'color': const Color(0xFF2563EB),
      'bgColor': const Color(0xFFEFF6FF),
      'gradient': [const Color(0xFF2563EB), const Color(0xFF1E40AF)],
      'key': 'Math',
    },
    {
      'name': 'Science',
      'emoji': '⚛️',
      'color': const Color(0xFF10B981),
      'bgColor': const Color(0xFFECFDF5),
      'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
      'key': 'Science',
    },
    {
      'name': 'English',
      'emoji': '📖',
      'color': const Color(0xFF8B5CF6),
      'bgColor': const Color(0xFFF5F3FF),
      'gradient': [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
      'key': 'English',
    },
  ];

  // English roadmap nodes (not in AppState, we define here)
  final List<Map<String, dynamic>> _englishNodes = [
    {'id': 'e1', 'title': 'Grammar Basics', 'subtitle': 'Nouns & Verbs', 'status': 'completed', 'desc': 'Master fundamental grammar rules and parts of speech.', 'xp': 50},
    {'id': 'e2', 'title': 'Active & Passive', 'subtitle': 'Voice Transformations', 'status': 'unlocked', 'desc': 'Convert sentences between active and passive voice.', 'xp': 75},
    {'id': 'e3', 'title': 'Essay Writing', 'subtitle': 'Structure & Flow', 'status': 'locked', 'desc': 'Write compelling essays with introduction, body, and conclusion.', 'xp': 100},
    {'id': 'e4', 'title': 'Comprehension', 'subtitle': 'Reading & Analysis', 'status': 'locked', 'desc': 'Analyze and interpret complex reading passages.', 'xp': 125},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedSubjectIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getNodes(AppState state) {
    if (_selectedSubjectIndex == 0) return state.roadmaps['Math'] ?? [];
    if (_selectedSubjectIndex == 1) return state.roadmaps['Science'] ?? [];
    return _englishNodes;
  }

  void _showNodeDetailsDialog(BuildContext context, Map<String, dynamic> node, AppState state) {
    final subject = _subjects[_selectedSubjectIndex];
    final Color accentColor = subject['color'];
    bool isLocked = node['status'] == 'locked';
    bool isCompleted = node['status'] == 'completed';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badge + close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : isLocked
                              ? const Color(0xFFF1F5F9)
                              : accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle_rounded : isLocked ? Icons.lock_rounded : Icons.play_circle_rounded,
                          size: 12,
                          color: isCompleted ? const Color(0xFF10B981) : isLocked ? AdyapanTheme.textMuted : accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCompleted ? 'COMPLETED' : isLocked ? 'LOCKED' : 'IN PROGRESS',
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? const Color(0xFF10B981) : isLocked ? AdyapanTheme.textMuted : accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
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
              const SizedBox(height: 16),

              // Subject emoji + title
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: subject['bgColor'],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accentColor.withOpacity(0.2)),
                    ),
                    alignment: Alignment.center,
                    child: Text(subject['emoji'], style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(node['title'], style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain)),
                        Text(node['subtitle'], style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textSub, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // XP Reward chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '+${node['xp'] ?? 50} XP on completion',
                      style: GoogleFonts.fredoka(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD97706)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Description
              Text(node['desc'], style: GoogleFonts.outfit(fontSize: 13, color: AdyapanTheme.textMain, height: 1.5)),
              const SizedBox(height: 16),

              // Skills
              Text('SKILLS YOU\'LL GAIN', style: GoogleFonts.outfit(fontSize: 9, color: AdyapanTheme.textMuted, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ['Problem Solving', 'Logical Thinking', 'Exam Ready'].map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentColor.withOpacity(0.2)),
                    ),
                    child: Text(skill, style: GoogleFonts.outfit(fontSize: 10, color: accentColor, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        minimumSize: const Size(0, 44),
                      ),
                      child: Text('Close', style: GoogleFonts.fredoka(color: AdyapanTheme.textSub)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLocked
                          ? null
                          : () {
                              Navigator.pop(context);
                              if (!isCompleted) {
                                final stateKey = _subjects[_selectedSubjectIndex]['key'];
                                if (stateKey != 'English') {
                                  state.completeRoadmapNode(stateKey, node['id']);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('🎉 ${node['title']} unlocked! Topic marked complete.'),
                                    backgroundColor: const Color(0xFF10B981),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ Already completed! Play Arcade games to earn bonus XP.'),
                                    backgroundColor: Color(0xFF10B981),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted ? const Color(0xFF10B981) : isLocked ? const Color(0xFFE2E8F0) : accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        minimumSize: const Size(0, 44),
                        disabledBackgroundColor: const Color(0xFFE2E8F0),
                      ),
                      child: Text(
                        isCompleted ? 'Revise Topic' : isLocked ? '🔒 Locked' : 'Start Now',
                        style: GoogleFonts.fredoka(
                          color: isLocked ? AdyapanTheme.textMuted : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final nodes = _getNodes(state);
        final subject = _subjects[_selectedSubjectIndex];
        final Color accentColor = subject['color'];
        final List<Color> gradient = subject['gradient'];

        // Calculate subject-specific progress
        int completedCount = nodes.where((n) => n['status'] == 'completed').length;
        double progressPct = nodes.isEmpty ? 0 : completedCount / nodes.length;

        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: Column(
            children: [
              // ── HEADER ──
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
                              onPressed: () => Scaffold.of(context).openDrawer(),
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
                                '⭐ Level ${state.level}  •  ${state.xp} XP',
                                style: GoogleFonts.fredoka(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Learning Roadmap',
                                style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                'Your path to academic excellence 🚀',
                                style: GoogleFonts.outfit(fontSize: 12, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Subject Tab Row
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: _subjects.length,
                            itemBuilder: (context, i) {
                              bool isSelected = _selectedSubjectIndex == i;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedSubjectIndex = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(_subjects[i]['emoji'], style: const TextStyle(fontSize: 14)),
                                      const SizedBox(width: 6),
                                      Text(
                                        _subjects[i]['name'],
                                        style: GoogleFonts.fredoka(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? accentColor : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── CONTENT ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // ── SUBJECT PROGRESS CARD ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Progress ring
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: CircularProgressIndicator(
                                      value: progressPct,
                                      strokeWidth: 6,
                                      backgroundColor: accentColor.withOpacity(0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                    ),
                                  ),
                                  Text(
                                    '${(progressPct * 100).toStringAsFixed(0)}%',
                                    style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold, color: accentColor),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${subject['emoji']} ${subject['name']}',
                                      style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain),
                                    ),
                                    Text(
                                      '$completedCount of ${nodes.length} topics completed',
                                      style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textSub, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: progressPct,
                                        minHeight: 6,
                                        backgroundColor: accentColor.withOpacity(0.1),
                                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: subject['bgColor'],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '+${completedCount * 50} XP',
                                  style: GoogleFonts.fredoka(fontSize: 11, fontWeight: FontWeight.bold, color: accentColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── SECTION TITLE ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text('Learning Path', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain)),
                            const Spacer(),
                            Text('${nodes.length} topics', style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textMuted, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── ZIGZAG PATH NODES ──
                      ...List.generate(nodes.length, (index) {
                        final node = nodes[index];
                        bool isCompleted = node['status'] == 'completed';
                        bool isUnlocked = node['status'] == 'unlocked';
                        bool isLocked = node['status'] == 'locked';

                        // Alternating left / right
                        bool isRight = index % 2 == 1;

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () => _showNodeDetailsDialog(context, node, state),
                                    child: Container(
                                      width: 260,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? const Color(0xFFECFDF5)
                                            : isUnlocked
                                                ? Colors.white
                                                : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isCompleted
                                              ? const Color(0xFF10B981).withOpacity(0.3)
                                              : isUnlocked
                                                  ? accentColor.withOpacity(0.3)
                                                  : const Color(0xFFE2E8F0),
                                          width: 1.5,
                                        ),
                                        boxShadow: isUnlocked
                                            ? [
                                                BoxShadow(
                                                  color: accentColor.withOpacity(0.12),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                )
                                              ]
                                            : [],
                                      ),
                                      child: Row(
                                        children: [
                                          // Node icon circle
                                          Container(
                                            width: 46,
                                            height: 46,
                                            decoration: BoxDecoration(
                                              color: isCompleted
                                                  ? const Color(0xFF10B981)
                                                  : isUnlocked
                                                      ? accentColor
                                                      : const Color(0xFFE2E8F0),
                                              shape: BoxShape.circle,
                                              boxShadow: isUnlocked
                                                  ? [
                                                      BoxShadow(
                                                        color: accentColor.withOpacity(0.35),
                                                        blurRadius: 10,
                                                        spreadRadius: 1,
                                                      )
                                                    ]
                                                  : [],
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              isCompleted
                                                  ? Icons.check_rounded
                                                  : isUnlocked
                                                      ? Icons.play_arrow_rounded
                                                      : Icons.lock_rounded,
                                              color: isLocked ? AdyapanTheme.textMuted : Colors.white,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 12),

                                          // Node info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Step ${index + 1}',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: isLocked ? AdyapanTheme.textMuted : accentColor,
                                                    letterSpacing: 0.8,
                                                  ),
                                                ),
                                                Text(
                                                  node['title'],
                                                  style: GoogleFonts.fredoka(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: isLocked ? AdyapanTheme.textMuted : AdyapanTheme.textMain,
                                                  ),
                                                ),
                                                Text(
                                                  node['subtitle'],
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 10,
                                                    color: AdyapanTheme.textMuted,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Status badge
                                          if (isCompleted)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF10B981).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text('✅', style: const TextStyle(fontSize: 10)),
                                            )
                                          else if (isUnlocked)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: accentColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'GO',
                                                style: GoogleFonts.fredoka(fontSize: 9, fontWeight: FontWeight.bold, color: accentColor),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Connector arrow between nodes
                            if (index < nodes.length - 1)
                              Padding(
                                padding: EdgeInsets.only(
                                  left: isRight ? 20 : 0,
                                  right: isRight ? 0 : 20,
                                ),
                                child: Align(
                                  alignment: isRight ? Alignment.centerLeft : Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 2),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 2,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: accentColor.withOpacity(0.25),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        Icon(Icons.keyboard_arrow_down_rounded, color: accentColor.withOpacity(0.4), size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                      const SizedBox(height: 20),

                      // ── UPCOMING TOPICS TEASER ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accentColor.withOpacity(0.07), accentColor.withOpacity(0.02)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: accentColor.withOpacity(0.15)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: Text('🔭', style: const TextStyle(fontSize: 22)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'More coming soon!',
                                      style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.bold, color: accentColor),
                                    ),
                                    Text(
                                      'Complete current path to unlock advanced topics & bonus challenges.',
                                      style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textSub, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── WEEKLY TARGET CARD ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('🎯', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Text('This Week\'s Target', style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain)),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF7ED),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                                    ),
                                    child: Text('3 days left', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFFD97706))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildWeeklyTarget('Complete 1 ${subject['name']} topic', true, accentColor),
                              const SizedBox(height: 6),
                              _buildWeeklyTarget('Play 2 Arcade games', false, accentColor),
                              const SizedBox(height: 6),
                              _buildWeeklyTarget('Log 3 study sessions', false, accentColor),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: 1 / 3,
                                  minHeight: 6,
                                  backgroundColor: accentColor.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('1 of 3 weekly goals completed', style: GoogleFonts.outfit(fontSize: 9, color: AdyapanTheme.textMuted, fontWeight: FontWeight.w500)),
                            ],
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

  Widget _buildWeeklyTarget(String title, bool done, Color accentColor) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: done ? accentColor : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(color: done ? accentColor : const Color(0xFFE2E8F0)),
          ),
          child: Icon(
            done ? Icons.check_rounded : Icons.circle_outlined,
            size: 10,
            color: done ? Colors.white : AdyapanTheme.textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: done ? AdyapanTheme.textMuted : AdyapanTheme.textMain,
            decoration: done ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }
}
