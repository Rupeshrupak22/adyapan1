import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({Key? key}) : super(key: key);

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;
  
  // Timer state
  Timer? _timer;
  int _secondsLeft = 25 * 60; // 25 minutes
  bool _isRunning = false;
  
  // App Shield State
  bool _shieldEngaged = false;
  int _blockedNotifsCount = 0;
  final List<Map<String, String>> _mockNotifications = [
    {'app': 'Instagram', 'msg': 'John sent you a reel 🍿', 'time': 'Just now'},
    {'app': 'Snapchat', 'msg': 'New snap from Sarah 📸', 'time': '2m ago'},
    {'app': 'TikTok', 'msg': 'Check out this trending video! 🔥', 'time': '5m ago'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _secondsLeft = 25 * 60;
          _isRunning = false;
        });
        _confettiController.play();
        // Log 25 minutes to AppState & gain XP!
        Provider.of<AppState>(context, listen: false).logStudySession(25);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Outstanding! You completed 25 mins of deep study! (+50 XP)'), backgroundColor: AdyapanTheme.green),
        );
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = 25 * 60;
      _isRunning = false;
    });
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // TAB 1: STUDY ROOM (POMODORO & TASK LIST)
  Widget _buildStudyRoom(AppState state) {
    double progress = (25 * 60 - _secondsLeft) / (25 * 60);

    return Column(
      children: [
        // Circular Clock
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 170,
              height: 170,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 12,
                backgroundColor: AdyapanTheme.bgLightDark,
                color: AdyapanTheme.pink,
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(_secondsLeft),
                  style: AdyapanTheme.fredoka(fontSize: 34, fontWeight: FontWeight.bold),
                ),
                Text(
                  'FOCUS TIMER',
                  style: AdyapanTheme.outfit(fontSize: 10, color: AdyapanTheme.textMuted, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 20),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AdyapanTheme.textSub),
              iconSize: 28,
              onPressed: _resetTimer,
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: _isRunning ? _pauseTimer : _startTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AdyapanTheme.pink,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(18),
                elevation: 4,
              ),
              child: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: Icon(Icons.check_circle_outline_rounded, color: progress > 0 ? AdyapanTheme.green : AdyapanTheme.textMuted),
              iconSize: 28,
              onPressed: progress > 0 ? () {
                _timer?.cancel();
                int minutesStudied = ((25 * 60 - _secondsLeft) / 60).ceil();
                state.logStudySession(minutesStudied);
                _resetTimer();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged $minutesStudied mins of study! (+${minutesStudied * 2} XP)'), backgroundColor: AdyapanTheme.green),
                );
              } : null,
            ),
          ],
        ),
        const SizedBox(height: 30),

        // Interactive Tasks List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Session Checklist', style: AdyapanTheme.fredoka(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AdyapanTheme.blueAccent, size: 22),
              onPressed: () {
                _showAddTaskDialog(context, state);
              },
            )
          ],
        ),
        const SizedBox(height: 10),
        state.todos.isEmpty
            ? Center(child: Text('All tasks completed! Add some now.', style: AdyapanTheme.outfit(fontSize: 12, color: AdyapanTheme.textMuted)))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.todos.length,
                itemBuilder: (context, index) {
                  final todo = state.todos[index];
                  bool completed = todo['completed'];

                  return Card(
                    color: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AdyapanTheme.glassBorder)),
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      dense: true,
                      leading: Checkbox(
                        value: completed,
                        activeColor: AdyapanTheme.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) {
                          state.toggleTodo(todo['id']);
                          if (val == true) {
                            _confettiController.play();
                          }
                        },
                      ),
                      title: Text(
                        todo['title'],
                        style: AdyapanTheme.fredoka(
                          fontSize: 13, 
                          color: completed ? AdyapanTheme.textMuted : AdyapanTheme.textMain,
                          fontWeight: FontWeight.bold,
                        ).copyWith(
                          decoration: completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AdyapanTheme.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(50)),
                        child: Text(
                          todo['tag'],
                          style: AdyapanTheme.outfit(fontSize: 9, color: AdyapanTheme.blueAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              )
      ],
    );
  }

  // TAB 2: FOCUS SPACE HUD (SHIELD ENGAGE)
  Widget _buildFocusSpaceHUD() {
    return Column(
      children: [
        // Engaged Shield Visualizer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: AdyapanTheme.glassCardDecoration(),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: _shieldEngaged ? AdyapanTheme.cyan.withOpacity(0.1) : AdyapanTheme.textMuted.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _shieldEngaged ? AdyapanTheme.cyan : AdyapanTheme.textMuted.withOpacity(0.3),
                    width: 4
                  ),
                  boxShadow: _shieldEngaged ? [
                    BoxShadow(color: AdyapanTheme.cyan.withOpacity(0.3), blurRadius: 20, spreadRadius: 4)
                  ] : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  _shieldEngaged ? '🛡️' : '🔘',
                  style: const TextStyle(fontSize: 40),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _shieldEngaged ? 'FOCUS SHIELD ACTIVE' : 'SHIELD DEACTIVATED',
                style: AdyapanTheme.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: _shieldEngaged ? AdyapanTheme.cyan : AdyapanTheme.textMain),
              ),
              Text(
                _shieldEngaged ? 'Social apps are successfully frozen offline.' : 'Tap freeze switch below to block app notifications!',
                style: AdyapanTheme.outfit(fontSize: 12, color: AdyapanTheme.textSub),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _shieldEngaged = !_shieldEngaged;
                    if (!_shieldEngaged) _blockedNotifsCount = 0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _shieldEngaged ? AdyapanTheme.pink : AdyapanTheme.cyan,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  minimumSize: const Size(180, 48),
                ),
                icon: Icon(_shieldEngaged ? Icons.do_disturb_on_outlined : Icons.offline_bolt_rounded, color: Colors.white),
                label: Text(
                  _shieldEngaged ? 'Disengage Shield' : 'Engage Shield', 
                  style: AdyapanTheme.fredoka(color: Colors.white, fontWeight: FontWeight.bold)
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Notifications Blocker Simulation Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Blocked Distraction Stack', style: AdyapanTheme.fredoka(fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AdyapanTheme.cyan.withOpacity(0.1), borderRadius: BorderRadius.circular(50)),
              child: Text(
                '$_blockedNotifsCount BLOCKED',
                style: AdyapanTheme.fredoka(fontSize: 11, color: AdyapanTheme.cyan, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!_shieldEngaged)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Text('Engage shield to visually trap notifications here!', style: AdyapanTheme.outfit(fontSize: 12, color: AdyapanTheme.textMuted)),
            ),
          )
        else
          Column(
            children: _mockNotifications.map((notif) {
              return Card(
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: AdyapanTheme.cyan.withOpacity(0.2))),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: notif['app'] == 'Instagram' 
                      ? AdyapanTheme.pink.withOpacity(0.1) 
                      : notif['app'] == 'Snapchat' 
                        ? Colors.yellow.withOpacity(0.2) 
                        : AdyapanTheme.cyan.withOpacity(0.1),
                    child: Text(
                      notif['app'] == 'Instagram' ? '📸' : notif['app'] == 'Snapchat' ? '👻' : '🎵',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  title: Text(
                    notif['app']!,
                    style: AdyapanTheme.fredoka(fontSize: 12, color: AdyapanTheme.textMain, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    notif['msg']!,
                    style: AdyapanTheme.outfit(fontSize: 11, color: AdyapanTheme.textSub),
                  ),
                  trailing: Text(
                    notif['time']!,
                    style: AdyapanTheme.outfit(fontSize: 9, color: AdyapanTheme.textMuted),
                  ),
                  onTap: () {
                    setState(() {
                      _blockedNotifsCount++;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🛡️ Deflected notification from ${notif['app']}! (+5 Focus Points)'),
                        backgroundColor: AdyapanTheme.cyan,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          )
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context, AppState state) {
    final titleController = TextEditingController();
    String selectedTag = 'Math';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add New Task', style: AdyapanTheme.fredoka(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'e.g., Learn Fraction rules',
                  hintStyle: AdyapanTheme.outfit(fontSize: 14, color: AdyapanTheme.textMuted),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTag,
                items: ['Math', 'Science', 'Focus', 'General'].map((tag) {
                  return DropdownMenuItem(value: tag, child: Text(tag, style: AdyapanTheme.outfit(fontSize: 14)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) selectedTag = val;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AdyapanTheme.fredoka(color: AdyapanTheme.textSub)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  state.addTodo(titleController.text, selectedTag);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AdyapanTheme.blueAccent),
              child: Text('Add Task', style: AdyapanTheme.fredoka(color: Colors.white)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: AdyapanTheme.bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AdyapanTheme.pink.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.timer_10_rounded, color: AdyapanTheme.pink),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Study Focus Room', style: AdyapanTheme.fredoka(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('Engage shield to sync and destroy distractions!', style: AdyapanTheme.outfit(fontSize: 12, color: AdyapanTheme.textSub)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Focus Tabs
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: AdyapanTheme.focusGradient,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: AdyapanTheme.textSub,
                    labelStyle: AdyapanTheme.fredoka(fontSize: 12, fontWeight: FontWeight.bold),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Study Pomodoro'),
                      Tab(text: 'Focus Shield'),
                    ],
                  ),
                ),

                // Content Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(padding: const EdgeInsets.all(20), child: _buildStudyRoom(state)),
                      SingleChildScrollView(padding: const EdgeInsets.all(20), child: _buildFocusSpaceHUD()),
                    ],
                  ),
                )
              ],
            ),

            // Celebratory Confetti on completions!
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [AdyapanTheme.pink, AdyapanTheme.purple, AdyapanTheme.cyan, AdyapanTheme.green],
              ),
            )
          ],
        ),
      ),
    );
  }
}
