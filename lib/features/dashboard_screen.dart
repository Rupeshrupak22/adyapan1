import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

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
                      height: 260,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF2563EB), // Vibrant Blue
                            Color(0xFF1D4ED8), // Royal Blue
                            Color(0xFF1E3A8A), // Indigo Navy
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
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
                              // Sleek Profile Initial ring
                              Container(
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
                              const SizedBox(width: 12),
                              
                              // Good morning Aarav
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Good morning,',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11, 
                                      color: Colors.white.withOpacity(0.75),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Aarav Sharma',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 17, 
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),

                              // Streak Chip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                                ),
                                child: Row(
                                  children: [
                                    const Text('🔥', style: TextStyle(fontSize: 12)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${state.streak}-day streak',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 11, 
                                        color: Colors.white, 
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
                                  color: Colors.white.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.12)),
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
                                  color: Colors.white.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.shield_outlined, color: Colors.white, size: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // Header Text
                          Text(
                            'Ready to learn something new today?',
                            style: GoogleFonts.fredoka(
                              fontSize: 25, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.white,
                              height: 1.15,
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
                          border: Border.all(color: const Color(0xFFEFF6FF), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E3A8A).withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
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
                      border: Border.all(color: const Color(0xFFEFF6FF), width: 1.5),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.06),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                          spreadRadius: -4,
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
                          Expanded(child: _buildGridCard('📅', 'Attendance', '94%', const Color(0xFFEFF6FF), const Color(0xFF2563EB))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildGridCard('📖', 'Homework', '3 due', const Color(0xFFFFFBEB), const Color(0xFFF59E0B))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGridCard(
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
                          Expanded(child: _buildGridCard('📄', 'Notes & PDFs', '128 files', const Color(0xFFFAF5FF), const Color(0xFF8B5CF6))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildGridCard('🎮', 'Gemified', '3 games', const Color(0xFFF5F3FF), const Color(0xFF6366F1))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildGridCard('📈', 'Progress', '+12%', const Color(0xFFECFDF5), const Color(0xFF10B981))),
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
                      border: Border.all(color: const Color(0xFFEFF6FF), width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        )
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
                        
                        // Active Join Button Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
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

  // Premium Quick Access Card Builder
  Widget _buildGridCard(String emojiIcon, String title, String subtitle, Color tintColor, Color accentColor, {bool isLive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEFF6FF), width: 1.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
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
    );
  }
}
