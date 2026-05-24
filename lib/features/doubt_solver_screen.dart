import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class DoubtSolverScreen extends StatefulWidget {
  const DoubtSolverScreen({Key? key}) : super(key: key);

  @override
  State<DoubtSolverScreen> createState() => _DoubtSolverScreenState();
}

class _DoubtSolverScreenState extends State<DoubtSolverScreen> {
  String activeSubject = 'Mathematics';
  final TextEditingController doubtController = TextEditingController();
  bool isSubmitting = false;
  bool chatSimulated = false;
  List<Map<String, String>> chatMessages = [];

  void _connectTutor() {
    if (doubtController.text.trim().isEmpty) return;
    setState(() {
      isSubmitting = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        isSubmitting = false;
        chatSimulated = true;
        chatMessages.add({'sender': 'Aarav', 'msg': doubtController.text});
        chatMessages.add({
          'sender': 'Tutor',
          'msg': 'Hello Aarav! I am Mr. Verma, your $activeSubject tutor. I see your doubt regarding "${doubtController.text}". That is a fantastic question! Let\'s solve this step by step. Tell me, which part are you finding difficult?'
        });
      });
    });
  }

  Widget _buildDoubtTile(String topicName, String meta, String teacher, String icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.82),
          border: Border.all(color: const Color(0xFFF43F5E).withOpacity(0.18), width: 1.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF43F5E).withOpacity(0.12),
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
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFECDD3)),
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
              onTap: () {
                setState(() {
                  doubtController.text = 'Help me solve $topicName question.';
                  activeSubject = 'Mathematics';
                  _connectTutor();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFF43F5E), Color(0xFFE11D48)]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFE11D48).withOpacity(0.3), offset: const Offset(0, 3), blurRadius: 4),
                  ],
                ),
                child: Text(
                  'Connect',
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
        title: Text('🙋 Doubt Solver Room', style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
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
              if (!chatSimulated) ...[
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
                      const Text('🙋', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('24/7 Doubt Connect', style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
                            Text('Get answers instantly from active 24/7 school mentors!', style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textSub)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Doubt Entry card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.82),
                    border: Border.all(color: const Color(0xFFF43F5E).withOpacity(0.18), width: 1.5),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ask a Doubt Live', style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
                      const SizedBox(height: 12),
                      Row(
                        children: ['Mathematics', 'Science', 'English'].map((subject) {
                          bool isSel = activeSubject == subject;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: GestureDetector(
                              onTap: () => setState(() => activeSubject = subject),
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
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _connectTutor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdyapanTheme.pink,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: isSubmitting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text('Connect to Live Tutor', style: GoogleFonts.fredoka(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text('Active Doubt Rooms', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
                const SizedBox(height: 12),

                _buildDoubtTile('Mathematics Doubt Room', 'LIVE • 12 active students • 2 mentors', 'Mrs. Sharma', '🧮'),
                _buildDoubtTile('Science Doubt Solving Channel', 'LIVE • 8 active students • 1 mentor', 'Mr. Verma', '⚛️'),
              ] else ...[
                // Simulated Full Screen Chat Room
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.82),
                    border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.18), width: 1.5),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(backgroundColor: AdyapanTheme.pink, radius: 18, child: Text('👩‍🏫', style: TextStyle(fontSize: 20))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Mr. Verma (Tutor)', style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.bold)),
                                Text('Online • $activeSubject Room', style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textSub)),
                              ],
                            ),
                          )
                        ],
                      ),
                      const Divider(height: 20),
                      Container(
                        height: 300,
                        child: ListView.builder(
                          itemCount: chatMessages.length,
                          itemBuilder: (context, index) {
                            var msg = chatMessages[index];
                            bool isMe = msg['sender'] == 'Aarav';
                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isMe ? AdyapanTheme.pink.withOpacity(0.1) : AdyapanTheme.bgLightDark,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                                    bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                                  ),
                                  border: Border.all(color: isMe ? AdyapanTheme.pink.withOpacity(0.3) : AdyapanTheme.glassBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(msg['sender']!, style: GoogleFonts.fredoka(fontSize: 9, fontWeight: FontWeight.bold, color: isMe ? AdyapanTheme.pink : Colors.blueGrey)),
                                    const SizedBox(height: 4),
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
                                hintText: 'Type message to your mentor...',
                                hintStyle: GoogleFonts.outfit(fontSize: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          CircleAvatar(
                            backgroundColor: AdyapanTheme.pink,
                            radius: 20,
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white, size: 16),
                              onPressed: () {},
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
