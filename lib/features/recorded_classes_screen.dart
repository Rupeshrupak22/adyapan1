import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class RecordedClassesScreen extends StatefulWidget {
  const RecordedClassesScreen({Key? key}) : super(key: key);

  @override
  State<RecordedClassesScreen> createState() => _RecordedClassesScreenState();
}

class _RecordedClassesScreenState extends State<RecordedClassesScreen> {
  void _simulatePlayVideo(String videoTitle) {
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
                          style: GoogleFonts.fredoka(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
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
                      color: Colors.black,
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

  Widget _buildRecordedTile(String topicName, String meta, String teacher, String icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.82),
          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.18), width: 1.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.12),
              offset: const Offset(0, 4),
              blurRadius: 10,
            )
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
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              alignment: Alignment.center,
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topicName, style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('$meta • $teacher', style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textSub)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _simulatePlayVideo(topicName),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF059669).withOpacity(0.3), offset: const Offset(0, 3), blurRadius: 4),
                  ],
                ),
                child: Text(
                  'Play',
                  style: GoogleFonts.fredoka(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('📹 Library of Recorded Classes', style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
      ),
      body: Container(
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
              // Intro
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.82),
                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.18), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    const Text('📹', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Class Video Library', style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
                          Text('Watch past lecture recordings of your classroom at your own convenience.', style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textSub)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Past Recorded Lectures', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
              const SizedBox(height: 12),

              _buildRecordedTile('📐 Math: Quadratic Equations (Part 1)', 'Recorded • 45 mins', 'Mrs. Sharma', '🧮'),
              _buildRecordedTile('⚛️ Science: Atomic Orbitals & Shells', 'Recorded • 52 mins', 'Mr. Verma', '⚛️'),
              _buildRecordedTile('📖 English: Active & Passive Voices', 'Recorded • 30 mins', 'Miss Anjali', '📖'),
              _buildRecordedTile('🌍 Social: French Revolution (Part 1)', 'Recorded • 40 mins', 'Mrs. Sharma', '🌍'),
            ],
          ),
        ),
      ),
    );
  }
}
