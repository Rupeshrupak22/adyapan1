import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({Key? key}) : super(key: key);

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  String _selectedSubject = 'Math';

  void _showNodeDetailsDialog(BuildContext context, Map<String, dynamic> node, AppState state) {
    showDialog(
      context: context,
      builder: (context) {
        bool isLocked = node['status'] == 'locked';
        bool isCompleted = node['status'] == 'completed';

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: AdyapanTheme.glassCardDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted 
                          ? AdyapanTheme.green.withOpacity(0.1) 
                          : isLocked 
                            ? AdyapanTheme.textMuted.withOpacity(0.1) 
                            : AdyapanTheme.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        node['status'].toString().toUpperCase(),
                        style: AdyapanTheme.fredoka(
                          fontSize: 10, 
                          color: isCompleted 
                            ? AdyapanTheme.green 
                            : isLocked 
                              ? AdyapanTheme.textMuted 
                              : AdyapanTheme.blueAccent,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AdyapanTheme.textSub, size: 20),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  node['title'],
                  style: AdyapanTheme.fredoka(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  node['subtitle'],
                  style: AdyapanTheme.outfit(fontSize: 12, color: AdyapanTheme.textSub, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  node['desc'],
                  style: AdyapanTheme.outfit(fontSize: 14, color: AdyapanTheme.textMain),
                ),
                const SizedBox(height: 24),
                Text(
                  'SKILLS YOU WILL LEARN:',
                  style: AdyapanTheme.outfit(fontSize: 10, color: AdyapanTheme.textMuted, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ['Problem Solving', 'Logical Math', 'Mental Calculation'].map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AdyapanTheme.bgLightDark,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AdyapanTheme.glassBorder),
                      ),
                      child: Text(
                        skill,
                        style: AdyapanTheme.outfit(fontSize: 10, color: AdyapanTheme.textSub, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.transparent,
                          side: const BorderSide(color: AdyapanTheme.glassBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          minimumSize: const Size(0, 46),
                        ),
                        child: Text('Close Info', style: AdyapanTheme.fredoka(color: AdyapanTheme.textSub)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLocked
                          ? null
                          : () {
                              Navigator.pop(context);
                              if (isCompleted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Topic already completed! Try solving in the Arcade to gain extra XP.'), backgroundColor: AdyapanTheme.green),
                                );
                              } else {
                                state.completeRoadmapNode(_selectedSubject, node['id']);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('🎉 Congratulations on unlocking the next step of $_selectedSubject Roadmap! (+50 XP)'), 
                                    backgroundColor: AdyapanTheme.green
                                  ),
                                );
                              }
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCompleted ? AdyapanTheme.green : AdyapanTheme.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          minimumSize: const Size(0, 46),
                        ),
                        child: Text(
                          isCompleted ? 'Recap Game' : 'Unlock Now', 
                          style: AdyapanTheme.fredoka(color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final nodes = state.roadmaps[_selectedSubject] ?? [];

        return Scaffold(
          backgroundColor: AdyapanTheme.bgDark,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Subject Roadmaps', style: AdyapanTheme.fredoka(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text('Path to academic mastery!', style: AdyapanTheme.outfit(fontSize: 12, color: AdyapanTheme.textSub)),
                        ],
                      ),
                      // Level Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: AdyapanTheme.glassCardDecoration(customRadius: BorderRadius.circular(50)),
                        child: Text(
                          '⭐ LVL ${state.level}',
                          style: AdyapanTheme.fredoka(fontSize: 12, color: AdyapanTheme.blueAccent, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),

                // Subject Selectors
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: ['Math', 'Science'].map((subject) {
                      bool isSelected = _selectedSubject == subject;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: ChoiceChip(
                          label: Text(subject, style: AdyapanTheme.fredoka(fontSize: 13, color: isSelected ? Colors.white : AdyapanTheme.textSub, fontWeight: FontWeight.bold)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedSubject = subject;
                              });
                            }
                          },
                          selectedColor: AdyapanTheme.blueAccent,
                          backgroundColor: Colors.white,
                          elevation: 0,
                          pressElevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50), side: BorderSide(color: isSelected ? Colors.transparent : AdyapanTheme.glassBorder)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Timeline Track Node List
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      child: Row(
                        children: List.generate(nodes.length, (index) {
                          final node = nodes[index];
                          String status = node['status'];
                          bool isCompleted = status == 'completed';
                          bool isUnlocked = status == 'unlocked';
                          bool isLocked = status == 'locked';

                          Color circleColor = Colors.white;
                          Color borderColor = AdyapanTheme.glassBorder;
                          Widget icon = const SizedBox();

                          if (isCompleted) {
                            circleColor = AdyapanTheme.green;
                            borderColor = AdyapanTheme.green;
                            icon = const Icon(Icons.check, color: Colors.white, size: 24);
                          } else if (isUnlocked) {
                            borderColor = AdyapanTheme.blueAccent;
                            icon = const Icon(Icons.play_arrow_rounded, color: AdyapanTheme.blueAccent, size: 28);
                          } else {
                            icon = const Icon(Icons.lock_outline_rounded, color: AdyapanTheme.textMuted, size: 20);
                          }

                          return Row(
                            children: [
                              // Timeline Node
                              GestureDetector(
                                onTap: () => _showNodeDetailsDialog(context, node, state),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: circleColor,
                                        border: Border.all(color: borderColor, width: 4),
                                        shape: BoxShape.circle,
                                        boxShadow: isUnlocked ? [
                                          BoxShadow(color: AdyapanTheme.blueAccent.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)
                                        ] : isCompleted ? [
                                          BoxShadow(color: AdyapanTheme.green.withOpacity(0.2), blurRadius: 10)
                                        ] : [],
                                      ),
                                      alignment: Alignment.center,
                                      child: icon,
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: 130,
                                      child: Text(
                                        node['title'],
                                        style: AdyapanTheme.fredoka(fontSize: 13, fontWeight: FontWeight.bold, color: isLocked ? AdyapanTheme.textMuted : AdyapanTheme.textMain),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      node['subtitle'],
                                      style: AdyapanTheme.outfit(fontSize: 10, color: AdyapanTheme.textMuted, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),

                              // Connecting Line to next node
                              if (index + 1 < nodes.length)
                                Container(
                                  width: 60,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isCompleted 
                                      ? AdyapanTheme.green 
                                      : AdyapanTheme.blueAccent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),

                // Hint
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: AdyapanTheme.glassCardDecoration(customRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AdyapanTheme.blueAccent, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tap on any unlocked node to view learning details, acquire skills, and unlock consecutive levels!',
                            style: AdyapanTheme.outfit(fontSize: 11, color: AdyapanTheme.textSub),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
