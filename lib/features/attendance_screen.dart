import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

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

  Color _getStatusColor(String status) {
    if (status == 'Present') return AdyapanTheme.green;
    if (status == 'Excused') return AdyapanTheme.purple;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final logs = appState.attendanceLogs;

    // Dynamically calculate attendance statistics
    int presentCount = logs.where((l) => l['status'] == 'Present').length;
    int excusedCount = logs.where((l) => l['status'] == 'Excused').length;
    int absentCount = logs.where((l) => l['status'] == 'Absent').length;
    int totalCount = logs.length;
    int attendancePercentage = totalCount > 0 
        ? ((presentCount / totalCount) * 100).round() 
        : 100;

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
                      attendancePercentage >= 85 ? '🔥 Highly Consistent!' : '⚠️ Needs Focus!',
                      style: GoogleFonts.fredoka(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        color: attendancePercentage >= 85 ? AdyapanTheme.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 120,
                      height: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: attendancePercentage >= 85 ? AdyapanTheme.green : Colors.orange, 
                          width: 8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (attendancePercentage >= 85 ? AdyapanTheme.green : Colors.orange).withOpacity(0.2),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Text(
                        '$attendancePercentage%',
                        style: GoogleFonts.fredoka(
                          fontSize: 32, 
                          fontWeight: FontWeight.bold, 
                          color: attendancePercentage >= 85 ? AdyapanTheme.green : Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Attended: $presentCount classes • Excused: $excusedCount leaves • Absent: $absentCount classes',
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
              ...logs.map((log) {
                final status = log['status'] as String;
                final color = _getStatusColor(status);
                final source = log['source'] as String? ?? 'Manual';
                IconData srcIcon = Icons.edit_calendar_rounded;
                Color srcColor = AdyapanTheme.textMuted;
                if (source == 'Live Class') { srcIcon = Icons.videocam_rounded; srcColor = const Color(0xFFEF4444); }
                if (source == 'Recorded Video') { srcIcon = Icons.play_circle_rounded; srcColor = const Color(0xFF8B5CF6); }
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
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(srcIcon, size: 11, color: srcColor),
                                  const SizedBox(width: 4),
                                  Text(source, style: GoogleFonts.outfit(fontSize: 10, color: srcColor, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  Text('• ${log['time']}', style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textMuted)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color),
                          ),
                          child: Text(
                            status,
                            style: GoogleFonts.fredoka(fontSize: 10, fontWeight: FontWeight.bold, color: color),
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
