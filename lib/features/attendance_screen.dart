import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String selectedReason = 'Medical Leave';
  final TextEditingController commentController = TextEditingController();

  void _submitLeave() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Leave Application submitted successfully to Class Teacher!'),
        backgroundColor: AdyapanTheme.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('📅 Attendance Portal', style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
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
              // 1. Attendance Circle Glass Panel
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.82),
                  border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.18), width: 1.5),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.12),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '🔥 Highly Consistent!',
                      style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: AdyapanTheme.green),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 120,
                      height: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AdyapanTheme.green, width: 8),
                        boxShadow: [
                          BoxShadow(
                            color: AdyapanTheme.green.withOpacity(0.2),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Text(
                        '94%',
                        style: GoogleFonts.fredoka(fontSize: 32, fontWeight: FontWeight.bold, color: AdyapanTheme.green),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Attended: 118 classes • Excused: 4 leaves • Absent: 3 classes',
                      style: GoogleFonts.outfit(fontSize: 12, color: AdyapanTheme.textSub, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Class attendance logs
              Text(
                'Weekly Class Records',
                style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A)),
              ),
              const SizedBox(height: 10),
              ...[
                {'subject': '📐 Mathematics', 'status': 'Present', 'color': AdyapanTheme.green, 'time': '10:30 AM'},
                {'subject': '⚛️ Science', 'status': 'Present', 'color': AdyapanTheme.green, 'time': '11:45 AM'},
                {'subject': '📖 English', 'status': 'Present', 'color': AdyapanTheme.green, 'time': '01:30 PM'},
                {'subject': '🌍 Social Studies', 'status': 'Excused', 'color': AdyapanTheme.purple, 'time': '02:45 PM'},
              ].map((log) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
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
                              Text(log['subject'] as String, style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.bold)),
                              Text(log['time'] as String, style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textSub)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (log['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: log['color'] as Color),
                          ),
                          child: Text(
                            log['status'] as String,
                            style: GoogleFonts.fredoka(fontSize: 10, fontWeight: FontWeight.bold, color: log['color'] as Color),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              // 3. Leave Application Form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.82),
                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.18), width: 1.5),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apply for Excused Leave',
                      style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A)),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedReason,
                      items: ['Medical Leave', 'Family Event', 'Out of Station'].map((reason) {
                        return DropdownMenuItem(value: reason, child: Text(reason, style: GoogleFonts.outfit(fontSize: 12)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedReason = val);
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: commentController,
                      maxLines: 2,
                      style: GoogleFonts.outfit(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Type any notes or comments for your teacher...',
                        hintStyle: GoogleFonts.outfit(fontSize: 12, color: AdyapanTheme.textMuted),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitLeave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdyapanTheme.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Submit Application',
                          style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
