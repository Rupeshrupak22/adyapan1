import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({Key? key}) : super(key: key);

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  bool _isUnlocked = true; // Default to true for premium demo convenience! Can be locked manually with lock icon.
  final TextEditingController _passcodeController = TextEditingController();
  final TextEditingController _questController = TextEditingController();
  double _xpReward = 150;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      if (state.isLoggedIn) {
        state.syncTeacherMessagesFromDb();
        state.syncDoubtsFromDb();
        state.syncHomeworkAndNotesFromDb();
      }
    });
  }

  // Remote app pause state
  bool _remotePauseActivated = false;

  // Real-life rewards milestones state
  final List<Map<String, dynamic>> _customRewards = [
    {
      'title': '1 Hour PlayStation Time 🎮',
      'requirement': 'Reach Level 3 & Complete homework',
      'status': 'Ready to Claim',
      'points': '300 XP'
    },
    {
      'title': 'Pizza Sunday Feast 🍕',
      'requirement': 'Complete 5 Math Quizzes in Quiz Arena',
      'status': 'Locked',
      'points': '500 XP'
    },
    {
      'title': 'New Comic Books Set 📚',
      'requirement': 'Reach Focus Zen Master Rank',
      'status': 'Claimed',
      'points': '800 XP'
    },
  ];

  void _verifyPasscode() {
    if (_passcodeController.text == '1234' || _passcodeController.text == '0000') {
      setState(() {
        _isUnlocked = true;
      });
      _passcodeController.clear();
    } else {
      _passcodeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Invalid PIN! (Hint: Try 1234 or 0000)'), backgroundColor: AdyapanTheme.pink),
      );
    }
  }

  void _showAddRewardDialog() {
    final titleController = TextEditingController();
    final reqController = TextEditingController();
    final xpController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Add Real-Life Reward 🎁', 
            style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: AdyapanTheme.purple)
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Reward Name (e.g., Pizza, Xbox Time)',
                  labelStyle: GoogleFonts.outfit(fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reqController,
                decoration: InputDecoration(
                  labelText: 'Requirement (e.g., Reach Level 5)',
                  labelStyle: GoogleFonts.outfit(fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: xpController,
                decoration: InputDecoration(
                  labelText: 'XP Threshold (e.g., 400 XP)',
                  labelStyle: GoogleFonts.outfit(fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.fredoka(color: AdyapanTheme.textSub)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _customRewards.add({
                      'title': titleController.text,
                      'requirement': reqController.text.isNotEmpty ? reqController.text : 'Complete Study Milestones',
                      'status': 'Locked',
                      'points': xpController.text.isNotEmpty ? '${xpController.text} XP' : '200 XP',
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🎉 New Reward Milestone added!'), backgroundColor: AdyapanTheme.green),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AdyapanTheme.purple),
              child: Text('Add Reward', style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  // BUILD SECURITY PIN ACCESS LOCK
  Widget _buildAccessLock() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AdyapanTheme.purple.withOpacity(0.08), shape: BoxShape.circle),
              child: const Icon(Icons.supervised_user_circle, size: 50, color: AdyapanTheme.purple),
            ),
            const SizedBox(height: 16),
            Text(
              'Parent Portal Gatekeeper',
              style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Please enter your 4-digit PIN to access parent analytics, limit sliders, and quest creators.',
              style: GoogleFonts.outfit(fontSize: 12, color: AdyapanTheme.textSub),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _passcodeController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: GoogleFonts.outfit(color: AdyapanTheme.textMuted),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AdyapanTheme.purple, width: 2), borderRadius: BorderRadius.circular(16)),
                ),
                onSubmitted: (_) => _verifyPasscode(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _verifyPasscode,
              style: ElevatedButton.styleFrom(
                backgroundColor: AdyapanTheme.purple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                minimumSize: const Size(160, 46),
              ),
              child: Text('Unlock Portal', style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Text('(Demo Bypass PIN: 1234)', style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textMuted, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // BUILD DYNAMIC DASHBOARD WHEN UNLOCKED
  Widget _buildParentDashboard(AppState state) {
    return RefreshIndicator(
      onRefresh: () async {
        await state.syncTeacherMessagesFromDb();
        await state.syncDoubtsFromDb();
        await state.syncHomeworkAndNotesFromDb();
      },
      color: AdyapanTheme.purple,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Welcome, Parent!', style: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.bold, color: AdyapanTheme.purple)),
              IconButton(
                icon: const Icon(Icons.lock_reset_rounded, color: AdyapanTheme.textSub),
                onPressed: () {
                  setState(() {
                    _isUnlocked = false;
                  });
                },
              )
            ],
          ),
          Text('Configure study lock metrics, real-life rewards, and remote locks.', style: GoogleFonts.outfit(fontSize: 12, color: AdyapanTheme.textSub)),
          const SizedBox(height: 20),

          // 1. Device Lock/App Pause Switch Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _remotePauseActivated ? Colors.red.withOpacity(0.06) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _remotePauseActivated ? Colors.redAccent.withOpacity(0.3) : AdyapanTheme.glassBorder,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _remotePauseActivated ? Colors.red.withOpacity(0.1) : AdyapanTheme.bgLightDark,
                  child: Text(_remotePauseActivated ? '🛑' : '📱', style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _remotePauseActivated ? 'Remote Device Frozen' : 'Freeze Child Device',
                        style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.bold, color: _remotePauseActivated ? Colors.redAccent : AdyapanTheme.textMain),
                      ),
                      Text(
                        _remotePauseActivated ? 'Broadcast lock is active.' : 'Instantly freeze all study & game rooms.',
                        style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textSub),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _remotePauseActivated,
                  activeColor: Colors.redAccent,
                  onChanged: (val) {
                    setState(() {
                      _remotePauseActivated = val;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _remotePauseActivated 
                              ? '🛑 Device instantly locked! Aarav\'s app is frozen.' 
                              : '📱 Device unlocked. Study rooms are active.',
                          style: GoogleFonts.fredoka(fontSize: 12),
                        ),
                        backgroundColor: _remotePauseActivated ? Colors.redAccent : AdyapanTheme.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Child Stats & Subject Analytics
          Text('Active Study Metrics & Streaks', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: AdyapanTheme.glassCardDecoration(),
                  child: Column(
                    children: [
                      const Text('📈', style: TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text('Study Ratio', style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textMuted, fontWeight: FontWeight.bold)),
                      Text('78% Efficiency', style: GoogleFonts.fredoka(fontSize: 14, color: AdyapanTheme.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: AdyapanTheme.glassCardDecoration(),
                  child: Column(
                    children: [
                      const Text('⏳', style: TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text('Daily Screen Limit', style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textMuted, fontWeight: FontWeight.bold)),
                      Text('${state.screenLimit.toInt()} Mins', style: GoogleFonts.fredoka(fontSize: 14, color: AdyapanTheme.blueAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Detailed Subject Activity Progress List
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AdyapanTheme.glassCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subject Focus Distribution',
                  style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold, color: AdyapanTheme.textMain),
                ),
                const SizedBox(height: 12),
                _buildSubjectProgressBar('Mathematics & BODMAS', 0.80, '120 mins', AdyapanTheme.pink),
                const SizedBox(height: 10),
                _buildSubjectProgressBar('Science & Orbitals', 0.60, '90 mins', AdyapanTheme.blueAccent),
                const SizedBox(height: 10),
                _buildSubjectProgressBar('English & Voices', 0.40, '60 mins', AdyapanTheme.green),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Quest Assigner Form
          Text('Assign Custom Special Quest', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AdyapanTheme.glassCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _questController,
                  style: GoogleFonts.outfit(fontSize: 13, color: AdyapanTheme.textMain),
                  decoration: InputDecoration(
                    hintText: 'e.g., Complete Atomic Shell Game...',
                    hintStyle: GoogleFonts.outfit(fontSize: 12, color: AdyapanTheme.textMuted),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AdyapanTheme.purple, width: 2), borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select XP Reward:', style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('${_xpReward.toInt()} XP', style: GoogleFonts.fredoka(fontSize: 13, color: AdyapanTheme.orange, fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: _xpReward,
                  min: 50,
                  max: 500,
                  divisions: 9,
                  activeColor: AdyapanTheme.purple,
                  inactiveColor: AdyapanTheme.bgLightDark,
                  onChanged: (val) {
                    setState(() {
                      _xpReward = val;
                    });
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_questController.text.isNotEmpty) {
                      state.setParentQuest(_questController.text, _xpReward.toInt());
                      _questController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🎉 Quest successfully synced to Child\'s Dashboard!'), backgroundColor: AdyapanTheme.green),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdyapanTheme.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  child: Text('Assign Quest to Child', style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Daily Screen Time Limits Slider
          Text('Manage Play Limits', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AdyapanTheme.glassCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Max Daily Screen Time:', style: GoogleFonts.outfit(fontSize: 13, color: AdyapanTheme.textSub)),
                    Text(
                      '${state.screenLimit.toInt()} Minutes',
                      style: GoogleFonts.fredoka(fontSize: 14, color: AdyapanTheme.blueAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: state.screenLimit,
                  min: 15,
                  max: 180,
                  divisions: 11,
                  activeColor: AdyapanTheme.blueAccent,
                  inactiveColor: AdyapanTheme.bgLightDark,
                  onChanged: (val) {
                    state.updateScreenLimit(val);
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Once this limit is hit, Focus Mode engaged screens will freeze until verified by parents.',
                  style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4b. Educator Alerts & Feedback
          Text('Educator Alerts & Parent Feedback 🔔', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (state.teacherMessages.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AdyapanTheme.glassCardDecoration(),
              child: Column(
                children: [
                  const Text('📬', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    'No recent alerts from school teachers.',
                    style: GoogleFonts.outfit(fontSize: 12, color: AdyapanTheme.textSub),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.teacherMessages.length,
              itemBuilder: (context, index) {
                final msg = state.teacherMessages[index];
                final isMeeting = msg['category'] == 'Meeting Request';
                final response = msg['meetingResponse'] ?? '';
                final isRead = msg['isRead'] == true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: AdyapanTheme.glassCardDecoration().copyWith(
                    border: Border.all(
                      color: isRead ? AdyapanTheme.glassBorder : AdyapanTheme.purple.withOpacity(0.3),
                      width: isRead ? 1.0 : 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isMeeting ? AdyapanTheme.orange : AdyapanTheme.purple).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              msg['category'] ?? 'Notice',
                              style: GoogleFonts.fredoka(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isMeeting ? AdyapanTheme.orange : AdyapanTheme.purple,
                              ),
                            ),
                          ),
                          Text(
                            msg['date'] ?? 'Today',
                            style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        msg['teacherName'] ?? 'Teacher',
                        style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        msg['message'] ?? '',
                        style: GoogleFonts.outfit(fontSize: 12, color: AdyapanTheme.textMain),
                      ),
                      if (isMeeting) ...[
                        const SizedBox(height: 12),
                        if (response.isEmpty)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    state.respondToMeeting(msg['id'], 'accepted');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('✅ Meeting request accepted! Teacher notified.'),
                                        backgroundColor: AdyapanTheme.green,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AdyapanTheme.green,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 36),
                                  ),
                                  child: Text(
                                    'Accept',
                                    style: GoogleFonts.fredoka(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    state.respondToMeeting(msg['id'], 'declined');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('❌ Meeting request declined. Teacher notified.'),
                                        backgroundColor: AdyapanTheme.pink,
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AdyapanTheme.pink),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 36),
                                  ),
                                  child: Text(
                                    'Decline',
                                    style: GoogleFonts.fredoka(fontSize: 11, fontWeight: FontWeight.bold, color: AdyapanTheme.pink),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (response == 'accepted' ? AdyapanTheme.green : AdyapanTheme.pink).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                response == 'accepted'
                                    ? 'Confirmed ✓ (Teacher notified)'
                                    : 'Declined ✗ (Teacher notified)',
                                style: GoogleFonts.fredoka(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: response == 'accepted' ? AdyapanTheme.green : AdyapanTheme.pink,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 24),

          // 5. Real-Life Incentives milestones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Real-Life Milestones & Shop 🎁', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_box_rounded, color: AdyapanTheme.purple, size: 24),
                onPressed: _showAddRewardDialog,
              )
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _customRewards.length,
            itemBuilder: (context, index) {
              final reward = _customRewards[index];
              String status = reward['status'];
              Color statusColor = status == 'Ready to Claim' 
                  ? AdyapanTheme.green 
                  : status == 'Claimed' 
                      ? AdyapanTheme.textMuted 
                      : AdyapanTheme.pink;

              return Card(
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AdyapanTheme.glassBorder)),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(reward['title'], style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text('${reward['requirement']} (${reward['points']})', style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textSub)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.fredoka(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      if (status == 'Locked') {
                        reward['status'] = 'Ready to Claim';
                      } else if (status == 'Ready to Claim') {
                        reward['status'] = 'Claimed';
                      } else {
                        reward['status'] = 'Locked';
                      }
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
    ));
  }

  Widget _buildSubjectProgressBar(String title, double ratio, String meta, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textMain, fontWeight: FontWeight.bold)),
            Text(meta, style: GoogleFonts.outfit(fontSize: 10, color: AdyapanTheme.textSub, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: AdyapanTheme.bgDark,
      body: SafeArea(
        child: _isUnlocked ? _buildParentDashboard(state) : _buildAccessLock(),
      ),
    );
  }
}
