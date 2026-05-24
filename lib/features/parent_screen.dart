import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({Key? key}) : super(key: key);

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  bool _isUnlocked = false;
  final TextEditingController _passcodeController = TextEditingController();
  final TextEditingController _questController = TextEditingController();
  double _xpReward = 150;

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
              style: AdyapanTheme.fredoka(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Please enter your 4-digit PIN to access parent analytics, limit sliders, and quest creators.',
              style: AdyapanTheme.outfit(fontSize: 12, color: AdyapanTheme.textSub),
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
                style: AdyapanTheme.fredoka(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: AdyapanTheme.outfit(color: AdyapanTheme.textMuted),
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
              child: Text('Unlock Portal', style: AdyapanTheme.fredoka(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Text('(Demo Bypass PIN: 1234)', style: AdyapanTheme.outfit(fontSize: 10, color: AdyapanTheme.textMuted, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // BUILD DYNAMIC DASHBOARD WHEN UNLOCKED
  Widget _buildParentDashboard(AppState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Welcome, Parent!', style: AdyapanTheme.fredoka(fontSize: 22, fontWeight: FontWeight.bold, color: AdyapanTheme.purple)),
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
          Text('Configure limits, create custom quests, and track active ratios.', style: AdyapanTheme.outfit(fontSize: 12, color: AdyapanTheme.textSub)),
          const SizedBox(height: 24),

          // Child Stats Grid
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
                      Text('Study-to-Play', style: AdyapanTheme.outfit(fontSize: 10, color: AdyapanTheme.textMuted, fontWeight: FontWeight.bold)),
                      Text('75% Ratio', style: AdyapanTheme.fredoka(fontSize: 14, color: AdyapanTheme.green, fontWeight: FontWeight.bold)),
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
                      Text('Daily Limit', style: AdyapanTheme.outfit(fontSize: 10, color: AdyapanTheme.textMuted, fontWeight: FontWeight.bold)),
                      Text('${state.screenLimit.toInt()} Mins', style: AdyapanTheme.fredoka(fontSize: 14, color: AdyapanTheme.blueAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quest Assigner form
          Text('Assign Custom Special Quest', style: AdyapanTheme.fredoka(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AdyapanTheme.glassCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _questController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Complete 3 Math roadmaps, Wash dishes...',
                    hintStyle: AdyapanTheme.outfit(fontSize: 12, color: AdyapanTheme.textMuted),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AdyapanTheme.purple, width: 2), borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select XP Reward:', style: AdyapanTheme.fredoka(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('${_xpReward.toInt()} XP', style: AdyapanTheme.fredoka(fontSize: 13, color: AdyapanTheme.orange, fontWeight: FontWeight.bold)),
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
                  child: Text('Assign Quest to Child', style: AdyapanTheme.fredoka(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Daily Screen Time Limits Slider
          Text('Manage Play Limits', style: AdyapanTheme.fredoka(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    Text('Max Daily Study Screen Time:', style: AdyapanTheme.outfit(fontSize: 13, color: AdyapanTheme.textSub)),
                    Text(
                      '${state.screenLimit.toInt()} Minutes',
                      style: AdyapanTheme.fredoka(fontSize: 14, color: AdyapanTheme.blueAccent, fontWeight: FontWeight.bold),
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
                  style: AdyapanTheme.outfit(fontSize: 10, color: AdyapanTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
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
