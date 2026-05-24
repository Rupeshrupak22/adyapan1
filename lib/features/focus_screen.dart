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
  int _selectedDurationMinutes = 25; // 15, 25, 45, 60 mins configuration
  int _secondsLeft = 25 * 60;
  bool _isRunning = false;
  
  // App Shield State
  bool _shieldEngaged = false;
  int _blockedNotifsCount = 0;
  Timer? _spawnerTimer;
  List<Map<String, String>> _activeShieldNotifications = [];
  String _selectedSoundMode = 'Silence 🤫';

  // Relatable Indian/Student funny notifications pool
  final List<Map<String, String>> _funnyNotificationsPool = [
    {'app': 'Mummy 👩', 'msg': 'Beta, phone rkh ke market se dhaniya le ao! 🌿', 'time': 'Just now'},
    {'app': 'Papa 🧔', 'msg': 'Sharma ji ka beta 98% laya hai. Tum kya kr rhe ho? 📈', 'time': 'Just now'},
    {'app': 'WhatsApp 🟢', 'msg': 'Homework copy krke submit kro fast! 📝', 'time': 'Just now'},
    {'app': 'Bhai 👦', 'msg': 'TV remote kahan chhupaya hai? Pata chala to pitoge! 📺', 'time': 'Just now'},
    {'app': 'Instagram 📸', 'msg': 'Your crush updated their story! Click to view 👀', 'time': 'Just now'},
    {'app': 'Free Fire 🔥', 'msg': 'Squad is waiting! Custom room match starting in 2m! 🎮', 'time': 'Just now'},
    {'app': 'YouTube 🔴', 'msg': 'New video: "Exam in 1 day? Watch this cheat sheet" 🤯', 'time': 'Just now'},
    {'app': 'Didi 👩‍🦰', 'msg': 'Mummy ko tumhari chat dikha dungi agar remote nahi diya! 🤫', 'time': 'Just now'},
    {'app': 'Zomato 🍕', 'msg': 'Junk food is calling! Double cheese pizza at ₹99! 🤤', 'time': 'Just now'},
    {'app': 'Snapchat 👻', 'msg': 'Sarah sent a snap! (Don\'t break 100-day streak!) 🔥', 'time': 'Just now'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _secondsLeft = _selectedDurationMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spawnerTimer?.cancel();
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _changeDuration(int minutes) {
    if (_isRunning) return;
    setState(() {
      _selectedDurationMinutes = minutes;
      _secondsLeft = minutes * 60;
    });
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
          _secondsLeft = _selectedDurationMinutes * 60;
          _isRunning = false;
        });
        _confettiController.play();
        
        // Log study duration to AppState & gain XP!
        Provider.of<AppState>(context, listen: false).logStudySession(_selectedDurationMinutes);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Outstanding! You completed $_selectedDurationMinutes mins of deep study! (+${_selectedDurationMinutes * 2} XP)'), 
            backgroundColor: AdyapanTheme.green,
            behavior: SnackBarBehavior.floating,
          ),
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
      _secondsLeft = _selectedDurationMinutes * 60;
      _isRunning = false;
    });
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _toggleShield() {
    setState(() {
      _shieldEngaged = !_shieldEngaged;
      if (_shieldEngaged) {
        _activeShieldNotifications = [
          {'app': 'WhatsApp 🟢', 'msg': 'Sharma ji: Beta boards ki taiyari chal rhi hai? 🧐', 'time': 'Just now'},
          {'app': 'Instagram 📸', 'msg': 'Crush commented on your post! ❤️', 'time': '1m ago'}
        ];
        _blockedNotifsCount = _activeShieldNotifications.length;
        _startNotificationSpawner();
      } else {
        _spawnerTimer?.cancel();
        _activeShieldNotifications.clear();
        _blockedNotifsCount = 0;
      }
    });
  }

  void _startNotificationSpawner() {
    _spawnerTimer?.cancel();
    _spawnerTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted || !_shieldEngaged) {
        timer.cancel();
        return;
      }
      
      final random = DateTime.now().millisecond % _funnyNotificationsPool.length;
      final newNotif = Map<String, String>.from(_funnyNotificationsPool[random]);
      
      setState(() {
        _activeShieldNotifications.insert(0, newNotif);
        _blockedNotifsCount++;
      });
    });
  }

  void _deflectNotification(int index) {
    if (index >= 0 && index < _activeShieldNotifications.length) {
      setState(() {
        _activeShieldNotifications.removeAt(index);
      });
      
      // Award 5 Focus Points (increment xp or state)
      Provider.of<AppState>(context, listen: false).addXp(5);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚡ Distraction Deflected! +5 Focus XP!'),
          backgroundColor: AdyapanTheme.green,
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // Focus Statistics Dashboard Widget
  Widget _buildFocusStatsCard(AppState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdyapanTheme.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('Current Streak', '${state.streak} Days 🔥', AdyapanTheme.pink),
          Container(width: 1, height: 35, color: AdyapanTheme.glassBorder),
          _buildStatColumn('Total Study', '${state.studySessions.fold(0, (a, b) => a + b)}m 📊', AdyapanTheme.blueAccent),
          Container(width: 1, height: 35, color: AdyapanTheme.glassBorder),
          _buildStatColumn('Focus Rank', _getFocusRank(state.studySessions.length), AdyapanTheme.green),
        ],
      ),
    );
  }

  String _getFocusRank(int sessionCount) {
    if (sessionCount > 6) return 'Zen Master 👑';
    if (sessionCount > 4) return 'Focus Guru 🧠';
    if (sessionCount > 2) return 'Focus Explorer 🚀';
    return 'Rookie Focus 👶';
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: AdyapanTheme.outfit(fontSize: 9, color: AdyapanTheme.textMuted, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AdyapanTheme.fredoka(fontSize: 13, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // TAB 1: STUDY ROOM (POMODORO & TASK LIST)
  Widget _buildStudyRoom(AppState state) {
    double progress = (_selectedDurationMinutes * 60 - _secondsLeft) / (_selectedDurationMinutes * 60);

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

        // Duration selector pills
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [15, 25, 45, 60].map((mins) {
            bool selected = _selectedDurationMinutes == mins;
            return GestureDetector(
              onTap: () => _changeDuration(mins),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AdyapanTheme.pink : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? Colors.transparent : AdyapanTheme.glassBorder,
                  ),
                  boxShadow: selected ? [
                    BoxShadow(
                      color: AdyapanTheme.pink.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ] : [],
                ),
                child: Text(
                  '$mins Mins',
                  style: AdyapanTheme.fredoka(
                    fontSize: 11,
                    color: selected ? Colors.white : AdyapanTheme.textSub,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
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
                int minutesStudied = ((_selectedDurationMinutes * 60 - _secondsLeft) / 60).ceil();
                state.logStudySession(minutesStudied);
                _resetTimer();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logged $minutesStudied mins of study! (+${minutesStudied * 2} XP)'), 
                    backgroundColor: AdyapanTheme.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } : null,
            ),
          ],
        ),
        const SizedBox(height: 25),

        // Ambient Sound Panel
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AdyapanTheme.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.music_note_rounded, color: AdyapanTheme.pink, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Ambient Focus Beats',
                        style: AdyapanTheme.fredoka(fontSize: 13, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain),
                      ),
                    ],
                  ),
                  EqualizerWave(isPlaying: _isRunning && _selectedSoundMode != 'Silence 🤫'),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Silence 🤫', 'Lofi Study 🎵', 'Rainy Day 🌧️', 'Forest Birds 🌲'].map((mode) {
                    bool active = _selectedSoundMode == mode;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSoundMode = mode;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? AdyapanTheme.blueAccent.withOpacity(0.12) : AdyapanTheme.bgLightDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: active ? AdyapanTheme.blueAccent.withOpacity(0.5) : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          mode,
                          style: AdyapanTheme.outfit(
                            fontSize: 11,
                            color: active ? AdyapanTheme.blueAccent : AdyapanTheme.textSub,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 25),

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
                onPressed: _toggleShield,
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
        if (_shieldEngaged) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AdyapanTheme.cyan.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AdyapanTheme.cyan.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.security_rounded, color: AdyapanTheme.cyan, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Silent Mode Active: Distractions are locked away silently to ensure 100% focused study. No interrupting popups!',
                    style: AdyapanTheme.outfit(fontSize: 11, color: AdyapanTheme.cyan, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

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
            children: _activeShieldNotifications.asMap().entries.map((entry) {
              int idx = entry.key;
              var notif = entry.value;
              return Card(
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: AdyapanTheme.cyan.withOpacity(0.2))),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: notif['app']!.contains('Instagram') 
                      ? AdyapanTheme.pink.withOpacity(0.1) 
                      : notif['app']!.contains('Snapchat') 
                        ? Colors.yellow.withOpacity(0.2) 
                        : AdyapanTheme.cyan.withOpacity(0.1),
                    child: Text(
                      notif['app']!.contains('Instagram') 
                          ? '📸' 
                          : notif['app']!.contains('Snapchat') 
                              ? '👻' 
                              : notif['app']!.contains('Mummy') 
                                  ? '👩' 
                                  : notif['app']!.contains('Papa') 
                                      ? '🧔' 
                                      : notif['app']!.contains('WhatsApp')
                                          ? '🟢'
                                          : '🎵',
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        notif['time']!,
                        style: AdyapanTheme.outfit(fontSize: 9, color: AdyapanTheme.textMuted),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.close_rounded, size: 16, color: AdyapanTheme.textMuted),
                    ],
                  ),
                  onTap: () => _deflectNotification(idx),
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
                  padding: const EdgeInsets.only(top: 20, left: 12, right: 20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu_rounded, color: AdyapanTheme.textMain, size: 24),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AdyapanTheme.pink.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.timer_10_rounded, color: AdyapanTheme.pink),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Study Focus Room', style: AdyapanTheme.fredoka(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('Engage shield to sync and destroy distractions!', style: AdyapanTheme.outfit(fontSize: 12, color: AdyapanTheme.textSub)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Focus Stats Dashboard
                _buildFocusStatsCard(state),
                const SizedBox(height: 10),

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

// Bouncing audio wave equalizer widget for premium ambient feel
class EqualizerWave extends StatefulWidget {
  final bool isPlaying;
  const EqualizerWave({Key? key, required this.isPlaying}) : super(key: key);

  @override
  State<EqualizerWave> createState() => _EqualizerWaveState();
}

class _EqualizerWaveState extends State<EqualizerWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _barHeights = [8, 22, 12, 28, 16, 20, 10, 24, 14, 18];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant EqualizerWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_barHeights.length, (index) {
            double animVal = _controller.value;
            double factor = (1.0 + (index % 3) * 0.2);
            double currentHeight = widget.isPlaying 
                ? (_barHeights[index] * (0.2 + 0.8 * (animVal * factor).clamp(0.0, 1.0)))
                : 4.0;

            return Container(
              width: 3,
              height: currentHeight,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AdyapanTheme.pink, AdyapanTheme.cyan],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        );
      },
    );
  }
}
