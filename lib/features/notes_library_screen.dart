import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class NotesLibraryScreen extends StatefulWidget {
  const NotesLibraryScreen({Key? key}) : super(key: key);

  @override
  State<NotesLibraryScreen> createState() => _NotesLibraryScreenState();
}

class _NotesLibraryScreenState extends State<NotesLibraryScreen> {
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _isDownloaded = {};

  void _startDownload(String filename) {
    if (_isDownloaded[filename] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📂 Opening $filename offline...'),
          backgroundColor: AdyapanTheme.green,
        ),
      );
      return;
    }

    setState(() {
      _downloadProgress[filename] = 0.0;
    });

    // Simulate progress
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return false;
      setState(() {
        double current = _downloadProgress[filename] ?? 0.0;
        _downloadProgress[filename] = (current + 0.15).clamp(0.0, 1.0);
      });

      if ((_downloadProgress[filename] ?? 0.0) >= 1.0) {
        setState(() {
          _isDownloaded[filename] = true;
          _downloadProgress.remove(filename);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Completed offline download: $filename!'),
            backgroundColor: AdyapanTheme.green,
          ),
        );
        return false;
      }
      return true;
    });
  }

  Widget _buildLibraryTile(String filename, String size, String subject) {
    double? progress = _downloadProgress[filename];
    bool isDone = _isDownloaded[filename] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.82),
          border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.12), width: 1.2),
          borderRadius: BorderRadius.circular(18),
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(filename, style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('$subject • $size', style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textSub)),
                  if (progress != null) ...[
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                      minHeight: 4,
                    )
                  ]
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _startDownload(filename),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDone ? AdyapanTheme.green.withOpacity(0.1) : AdyapanTheme.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: isDone ? AdyapanTheme.green : AdyapanTheme.blueAccent),
                ),
                child: Text(
                  isDone ? 'Open' : (progress != null ? '${(progress * 100).toInt()}%' : 'Download'),
                  style: GoogleFonts.fredoka(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDone ? AdyapanTheme.green : AdyapanTheme.blueAccent,
                  ),
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
        title: Text('📄 Learning Library', style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
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
                    const Text('📚', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Resource Downloads', style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
                          Text('Download PDFs and study guides to read offline anytime.', style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textSub)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Subject-wise Materials', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
              const SizedBox(height: 12),

              _buildLibraryTile('BODMAS_Formulas.pdf', '1.2 MB', 'Mathematics'),
              _buildLibraryTile('Atomic_Structure_Game.pdf', '3.4 MB', 'Science'),
              _buildLibraryTile('Python_Syntax_CheatSheet.pdf', '0.8 MB', 'Computer Science'),
              _buildLibraryTile('English_Grammar_Conjugations.pdf', '1.5 MB', 'English'),
            ],
          ),
        ),
      ),
    );
  }
}
