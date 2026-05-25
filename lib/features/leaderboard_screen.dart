import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _selectedTab = 0; // 0=BODMAS, 1=Syntax, 2=Word

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'BODMAS', 'emoji': '🧮', 'color': const Color(0xFF2563EB)},
    {'label': 'Syntax', 'emoji': '📝', 'color': const Color(0xFF8B5CF6)},
    {'label': 'Words', 'emoji': '🔠', 'color': const Color(0xFF10B981)},
  ];

  List<Map<String, dynamic>> _getLeaderboard(AppState state, int tab) {
    if (tab == 0) {
      return [
        {'rank': 1, 'name': 'Anya Verma', 'score': 2450, 'avatar': '🧠', 'medal': '🥇', 'change': '+2'},
        {'rank': 2, 'name': 'Kabir Gupta', 'score': 2310, 'avatar': '⚡', 'medal': '🥈', 'change': '-1'},
        {'rank': 3, 'name': 'Rohan Malhotra', 'score': 2190, 'avatar': '🎨', 'medal': '🥉', 'change': '+1'},
        {'rank': 4, 'name': state.studentName, 'score': 1980, 'avatar': '🚀', 'isUser': true, 'change': '0'},
        {'rank': 5, 'name': 'Diya Sen', 'score': 1850, 'avatar': '🧬', 'change': '-2'},
        {'rank': 6, 'name': 'Meera Iyer', 'score': 1720, 'avatar': '📖', 'change': '+1'},
        {'rank': 7, 'name': 'Ishaan Mehta', 'score': 1580, 'avatar': '🍕', 'change': '-1'},
      ];
    } else if (tab == 1) {
      return [
        {'rank': 1, 'name': 'Kabir Gupta', 'score': 3100, 'avatar': '⚡', 'medal': '🥇', 'change': '+1'},
        {'rank': 2, 'name': 'Anya Verma', 'score': 2950, 'avatar': '🧠', 'medal': '🥈', 'change': '-1'},
        {'rank': 3, 'name': 'Ishaan Mehta', 'score': 2800, 'avatar': '🍕', 'medal': '🥉', 'change': '+3'},
        {'rank': 4, 'name': state.studentName, 'score': 2750, 'avatar': '🚀', 'isUser': true, 'change': '+1'},
        {'rank': 5, 'name': 'Meera Iyer', 'score': 2500, 'avatar': '📖', 'change': '-2'},
        {'rank': 6, 'name': 'Rohan Malhotra', 'score': 2200, 'avatar': '🎨', 'change': '0'},
        {'rank': 7, 'name': 'Diya Sen', 'score': 1990, 'avatar': '🧬', 'change': '-1'},
      ];
    } else {
      return [
        {'rank': 1, 'name': 'Diya Sen', 'score': 1900, 'avatar': '🧬', 'medal': '🥇', 'change': '+2'},
        {'rank': 2, 'name': state.studentName, 'score': 1850, 'avatar': '🚀', 'isUser': true, 'medal': '🥈', 'change': '+1'},
        {'rank': 3, 'name': 'Anya Verma', 'score': 1720, 'avatar': '🧠', 'medal': '🥉', 'change': '-2'},
        {'rank': 4, 'name': 'Rohan Malhotra', 'score': 1600, 'avatar': '🎨', 'change': '0'},
        {'rank': 5, 'name': 'Ishaan Mehta', 'score': 1450, 'avatar': '🍕', 'change': '+1'},
        {'rank': 6, 'name': 'Kabir Gupta', 'score': 1320, 'avatar': '⚡', 'change': '-1'},
        {'rank': 7, 'name': 'Meera Iyer', 'score': 1180, 'avatar': '📖', 'change': '0'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final board = _getLeaderboard(state, _selectedTab);
        final tabColor = _tabs[_selectedTab]['color'] as Color;
        final top3 = board.take(3).toList();
        final rest = board.skip(3).toList();

        // Find user row
        final userRow = board.firstWhere((r) => r['isUser'] == true, orElse: () => {});

        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: Column(
            children: [
              // ── HEADER ──
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [tabColor, Color.lerp(tabColor, Colors.black, 0.25)!],
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
                  child: Column(
                    children: [
                      // Back button + title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('🏆 School Leaderboard', style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text('Live game rankings · Weekly reset', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white.withOpacity(0.75), fontWeight: FontWeight.w500)),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                                  const SizedBox(width: 5),
                                  Text('LIVE', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Game Tab Selector
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: List.generate(_tabs.length, (i) {
                            bool isSelected = _selectedTab == i;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTab = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(_tabs[i]['emoji'], style: const TextStyle(fontSize: 18)),
                                      const SizedBox(height: 2),
                                      Text(
                                        _tabs[i]['label'],
                                        style: GoogleFonts.fredoka(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? tabColor : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // ── TOP 3 PODIUM ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: _buildPodium(top3, tabColor),
                      ),
                    ],
                  ),
                ),
              ),

              // ── REST OF LIST ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // User rank highlight (if not in top 3)
                      if (userRow.isNotEmpty && (userRow['rank'] as int) > 3)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: tabColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: tabColor.withOpacity(0.25)),
                            ),
                            child: Row(
                              children: [
                                Text('🚀', style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'You are ranked #${userRow['rank']} — keep playing to climb up!',
                                    style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold, color: tabColor),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: tabColor, borderRadius: BorderRadius.circular(20)),
                                  child: Text('${userRow['score']} pts', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                        child: Column(
                          children: List.generate(rest.length, (i) {
                            final row = rest[i];
                            final isUser = row['isUser'] == true;
                            final change = row['change'] as String;
                            final isUp = change.startsWith('+') && change != '+0';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isUser ? tabColor.withOpacity(0.07) : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isUser ? tabColor.withOpacity(0.3) : const Color(0xFFF1F5F9),
                                  width: isUser ? 1.5 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Rank number
                                  SizedBox(
                                    width: 28,
                                    child: Text(
                                      '#${row['rank']}',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isUser ? tabColor : AdyapanTheme.textMuted,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Avatar circle
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: isUser ? tabColor.withOpacity(0.15) : const Color(0xFFF1F5F9),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: isUser ? tabColor.withOpacity(0.4) : const Color(0xFFE2E8F0)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(row['avatar'], style: const TextStyle(fontSize: 18)),
                                  ),
                                  const SizedBox(width: 12),

                                  // Name
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isUser ? '${row['name']} (You)' : row['name'],
                                          style: GoogleFonts.fredoka(
                                            fontSize: 13,
                                            fontWeight: isUser ? FontWeight.bold : FontWeight.w600,
                                            color: isUser ? tabColor : AdyapanTheme.textMain,
                                          ),
                                        ),
                                        if (change != '0')
                                          Row(
                                            children: [
                                              Icon(
                                                isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                                size: 11,
                                                color: isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                isUp ? '$change ranks' : '${change.replaceAll('-', '')} ranks down',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Score
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isUser ? tabColor : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${row['score']} pts',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isUser ? Colors.white : AdyapanTheme.textSub,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),

                      // Play to earn more CTA
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [tabColor.withOpacity(0.08), tabColor.withOpacity(0.02)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: tabColor.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Text('🎮', style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Play more to rank higher!', style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.bold, color: tabColor)),
                                    Text('Each game win earns you score points. Reset happens every Monday.', style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textSub, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
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

  Widget _buildPodium(List<Map<String, dynamic>> top3, Color tabColor) {
    if (top3.length < 3) return const SizedBox.shrink();

    // Podium order: 2nd, 1st, 3rd
    final order = [top3[1], top3[0], top3[2]];
    final heights = [100.0, 130.0, 80.0];
    final medals = ['🥈', '🥇', '🥉'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        final row = order[i];
        final isCenter = i == 1;
        return Expanded(
          child: Column(
            children: [
              // Avatar + name
              Text(row['avatar'], style: TextStyle(fontSize: isCenter ? 32 : 24)),
              const SizedBox(height: 4),
              Text(
                medals[i],
                style: TextStyle(fontSize: isCenter ? 22 : 18),
              ),
              const SizedBox(height: 4),
              Text(
                (row['name'] as String).split(' ')[0],
                style: GoogleFonts.fredoka(fontSize: isCenter ? 13 : 11, fontWeight: FontWeight.bold, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${row['score']} pts',
                style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.75)),
              ),
              const SizedBox(height: 6),

              // Podium block
              Container(
                height: heights[i],
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isCenter ? 0.25 : 0.15),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#${row['rank']}',
                  style: GoogleFonts.fredoka(fontSize: isCenter ? 22 : 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
