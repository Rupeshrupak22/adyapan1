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

class _HomeworkScreenState extends State<HomeworkScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Widget _buildHomeworkRow(BuildContext context, AppState state, String taskName, String deadline, String level) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.82),
          border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.12), width: 1.2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(taskName, style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFEF3C7)),
                        ),
                        child: Text(
                          level,
                          style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(deadline, style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textSub)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: AdyapanTheme.green, size: 28),
              onPressed: () {
                state.addXp(15);
                _confettiController.play();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎉 Homework "$taskName" Completed! (+15 XP Gain!)'),
                    backgroundColor: AdyapanTheme.green,
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('📝 Homework Dashboard', style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFEEF2F6),
                  Color(0xFFE0E7FF),
                  Color(0xFFFFF0F5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header intro
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.82),
                      border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.18), width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pending Assignments',
                                style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A)),
                              ),
                              Text(
                                'Complete assignments to earn immediate XP levels!',
                                style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textSub),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildHomeworkRow(context, state, '📐 Math: Quadratic Equations', 'Due: Today', 'HIGH PRIORITY'),
                  _buildHomeworkRow(context, state, '⚛️ Science: Atomic Orbitals', 'Due: Tomorrow', 'MEDIUM PRIORITY'),
                  _buildHomeworkRow(context, state, '📖 English: Essay Writing', 'Due: 3 days', 'NORMAL PRIORITY'),
                  _buildHomeworkRow(context, state, '🌍 Social: Map Labeling', 'Due: 5 days', 'NORMAL PRIORITY'),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ],
      ),
    );
  }
}
