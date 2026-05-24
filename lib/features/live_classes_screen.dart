import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class LiveClassesScreen extends StatefulWidget {
  const LiveClassesScreen({Key? key}) : super(key: key);

  @override
  State<LiveClassesScreen> createState() => _LiveClassesScreenState();
}

class _LiveClassesScreenState extends State<LiveClassesScreen> {
  void _joinLiveSimulate(String teacherName, String topicName) {
    showDialog(
      context: context,
      builder: (context) {
        bool isMuted = false;
        bool isVideoOff = false;
        return StatefulBuilder(
          builder: (context, setVideoState) {
            return AlertDialog(
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              contentPadding: const EdgeInsets.all(16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(topicName, style: GoogleFonts.fredoka(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            Text('Teacher: $teacherName', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Simulated Zoom Stream Frame
                  Container(
                    height: 180,
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
                        if (isVideoOff)
                          const Text('👤 Video Off', style: TextStyle(color: Colors.white60, fontSize: 16))
                        else ...[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('👩‍🏫', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 8),
                              Text(
                                'Streaming Live Lecture...',
                                style: GoogleFonts.outfit(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                              child: Text('LIVE', style: GoogleFonts.outfit(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                        // Small picture-in-picture student box
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            width: 50,
                            height: 65,
                            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
                            alignment: Alignment.center,
                            child: const Text('🧒', style: TextStyle(fontSize: 20)),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Control Buttons Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: isMuted ? Colors.red : Colors.white24,
                        radius: 22,
                        child: IconButton(
                          icon: Icon(isMuted ? Icons.mic_off : Icons.mic, color: Colors.white),
                          onPressed: () {
                            setVideoState(() {
                              isMuted = !isMuted;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      CircleAvatar(
                        backgroundColor: isVideoOff ? Colors.red : Colors.white24,
                        radius: 22,
                        child: IconButton(
                          icon: Icon(isVideoOff ? Icons.videocam_off : Icons.videocam, color: Colors.white),
                          onPressed: () {
                            setVideoState(() {
                              isVideoOff = !isVideoOff;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      CircleAvatar(
                        backgroundColor: Colors.redAccent,
                        radius: 22,
                        child: IconButton(
                          icon: const Icon(Icons.call_end, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildLiveTile(String topicName, String time, String teacher, String icon, {bool isLive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.82),
          border: Border.all(color: (isLive ? AdyapanTheme.pink : Colors.blueAccent).withOpacity(0.18), width: 1.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isLive ? AdyapanTheme.pink : Colors.blueAccent).withOpacity(0.12),
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
                color: isLive ? const Color(0xFFFFF1F2) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isLive ? const Color(0xFFFECDD3) : const Color(0xFFBFDBFE)),
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
                  Text('$time • $teacher', style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textSub)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => isLive ? _joinLiveSimulate(teacher, topicName) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isLive
                      ? const LinearGradient(colors: [Color(0xFFF43F5E), Color(0xFFE11D48)])
                      : const LinearGradient(colors: [Color(0xFF94A3B8), Color(0xFF64748B)]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: isLive ? [BoxShadow(color: const Color(0xFFE11D48).withOpacity(0.3), offset: const Offset(0, 3), blurRadius: 4)] : null,
                ),
                child: Text(
                  isLive ? 'Join Live' : 'Upcoming',
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
        title: Text('🎥 Active Live Classes', style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
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
                    const Text('🎥', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Direct Zoom Streaming', style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
                          Text('Join active streams of your school classes directly.', style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textSub)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Class Schedule Today', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
              const SizedBox(height: 12),

              _buildLiveTile('Arithmetic & BODMAS Basics', 'LIVE Now', 'Mrs. Sharma', '🧮', isLive: true),
              _buildLiveTile('Atomic Structure & Chemical Bonds', 'Upcoming: 12:30 PM', 'Mr. Verma', '⚛️', isLive: false),
              _buildLiveTile('Active & Passive Grammar Conjugations', 'Upcoming: 01:45 PM', 'Miss Anjali', '📖', isLive: false),
            ],
          ),
        ),
      ),
    );
  }
}
