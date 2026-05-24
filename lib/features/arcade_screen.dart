import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class ArcadeScreen extends StatefulWidget {
  const ArcadeScreen({Key? key}) : super(key: key);

  @override
  State<ArcadeScreen> createState() => _ArcadeScreenState();
}

class _ArcadeScreenState extends State<ArcadeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;


  int _currentQuizIdx = 0;
  int? _selectedAnswerIdx;
  bool _quizAnswered = false;
  int _quizScore = 0;

  final List<Map<String, dynamic>> _quizQuestions = [
    {
      'question': 'What is the correct value of (5 + 3) * (8 / 2) under BODMAS?',
      'options': ['32', '16', '24', '40'],
      'correctIdx': 0,
    },
    {
      'question': 'Solve: 12 - 4 * 2 + 6 / 2 = ?',
      'options': ['7', '19', '11', '15'],
      'correctIdx': 0,
    },
    {
      'question': 'Which atomic shell holds a maximum of 8 electrons?',
      'options': ['K Shell', 'L Shell', 'M Shell', 'N Shell'],
      'correctIdx': 1,
    }
  ];

  // Balancer Game State
  double _leftScaleWeight = 16.0;
  List<String> _rightScaleSlots = ['8', '?', '2'];
  String? _selectedOperator;
  bool _isBalanced = false;

  // Syntax Blocks State
  List<String> _assembledSyntax = [];
  final List<String> _availableSyntaxTiles = ['print', '("Hello World")', ';', 'def main():'];
  final List<String> _correctSyntaxOrder = ['def main():', 'print', '("Hello World")', ';'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _triggerWin() {
    _confettiController.play();
    Provider.of<AppState>(context, listen: false).addXp(30);
  }

  // QUIZ ARENA SUB-WIDGET
  Widget _buildQuizArena() {
    var q = _quizQuestions[_currentQuizIdx];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Question ${_currentQuizIdx + 1}/${_quizQuestions.length}', style: AdyapanTheme.fredoka(fontSize: 14, color: AdyapanTheme.blueAccent, fontWeight: FontWeight.bold)),
            Text('Score: $_quizScore', style: AdyapanTheme.fredoka(fontSize: 14, color: AdyapanTheme.green, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AdyapanTheme.glassCardDecoration(customBg: AdyapanTheme.bgLightDark),
          child: Text(
            q['question'],
            style: AdyapanTheme.fredoka(fontSize: 16, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(q['options'].length, (index) {
          bool isSelected = _selectedAnswerIdx == index;
          bool isCorrect = index == q['correctIdx'];
          Color tileBg = Colors.white;
          Color tileBorder = AdyapanTheme.glassBorder;
          Color textColor = AdyapanTheme.textMain;

          if (_quizAnswered) {
            if (isCorrect) {
              tileBg = AdyapanTheme.green.withOpacity(0.08);
              tileBorder = AdyapanTheme.green;
              textColor = AdyapanTheme.green;
            } else if (isSelected) {
              tileBg = AdyapanTheme.pink.withOpacity(0.08);
              tileBorder = AdyapanTheme.pink;
              textColor = AdyapanTheme.pink;
            }
          } else if (isSelected) {
            tileBorder = AdyapanTheme.blueAccent;
            tileBg = AdyapanTheme.blueAccent.withOpacity(0.05);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: _quizAnswered ? null : () {
                setState(() {
                  _selectedAnswerIdx = index;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: tileBg,
                  border: Border.all(color: tileBorder, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      q['options'][index],
                      style: AdyapanTheme.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    if (_quizAnswered && isCorrect)
                      const Icon(Icons.check_circle_rounded, color: AdyapanTheme.green, size: 20)
                    else if (_quizAnswered && isSelected)
                      const Icon(Icons.cancel_rounded, color: AdyapanTheme.pink, size: 20),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        if (!_quizAnswered)
          ElevatedButton(
            onPressed: _selectedAnswerIdx == null ? null : () {
              setState(() {
                _quizAnswered = true;
                if (_selectedAnswerIdx == q['correctIdx']) {
                  _quizScore += 10;
                  _triggerWin();
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdyapanTheme.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              minimumSize: const Size(double.infinity, 50),
              elevation: 4,
            ),
            child: Text('Submit Answer', style: AdyapanTheme.fredoka(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        else
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (_currentQuizIdx + 1 < _quizQuestions.length) {
                  _currentQuizIdx++;
                  _selectedAnswerIdx = null;
                  _quizAnswered = false;
                } else {
                  // Reset quiz
                  _currentQuizIdx = 0;
                  _selectedAnswerIdx = null;
                  _quizAnswered = false;
                  _quizScore = 0;
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdyapanTheme.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              _currentQuizIdx + 1 < _quizQuestions.length ? 'Next Question' : 'Restart Quiz Arena',
              style: AdyapanTheme.fredoka(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
      ],
    );
  }

  // EQUATION BALANCER SUB-WIDGET
  Widget _buildEquationBalancer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Balance the Equation Scale!',
          style: AdyapanTheme.fredoka(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          'Insert the operator so left weight equals right equation.',
          style: AdyapanTheme.outfit(fontSize: 12, color: AdyapanTheme.textSub),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // The Scale Visualization
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left Plate (Weight 16)
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              transform: Matrix4.translationValues(0, _isBalanced ? 0 : -15, 0),
              padding: const EdgeInsets.all(16),
              decoration: AdyapanTheme.glassCardDecoration(customRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text('⚖️', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text('Weight: ${_leftScaleWeight.toInt()}', style: AdyapanTheme.fredoka(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Text(
              '=',
              style: AdyapanTheme.fredoka(fontSize: 32, fontWeight: FontWeight.bold, color: _isBalanced ? AdyapanTheme.green : AdyapanTheme.textMuted),
            ),
            const SizedBox(width: 20),
            // Right Plate
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              transform: Matrix4.translationValues(0, _isBalanced ? 0 : 15, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: AdyapanTheme.glassCardDecoration(customRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AdyapanTheme.bgLightDark, borderRadius: BorderRadius.circular(8)),
                    child: Text('8', style: AdyapanTheme.fredoka(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  // Drop Target Slot
                  DragTarget<String>(
                    onAccept: (data) {
                      setState(() {
                        _selectedOperator = data;
                        if (data == '*') {
                          _isBalanced = true;
                          _triggerWin();
                        } else {
                          _isBalanced = false;
                        }
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _selectedOperator == null ? Colors.white : AdyapanTheme.blueAccent,
                          border: Border.all(color: AdyapanTheme.blueAccent, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _selectedOperator ?? '?',
                          style: AdyapanTheme.fredoka(
                            fontWeight: FontWeight.bold, 
                            color: _selectedOperator == null ? AdyapanTheme.blueAccent : Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AdyapanTheme.bgLightDark, borderRadius: BorderRadius.circular(8)),
                    child: Text('2', style: AdyapanTheme.fredoka(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),

        // Draggable Operators Box
        Text('Drag Symbol into the Empty Slot:', style: AdyapanTheme.outfit(fontSize: 13, color: AdyapanTheme.textSub, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['+', '-', '*', '/'].map((op) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Draggable<String>(
                data: op,
                feedback: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AdyapanTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: AdyapanTheme.blueAccent.withOpacity(0.3), blurRadius: 10)],
                    ),
                    alignment: Alignment.center,
                    child: Text(op, style: AdyapanTheme.fredoka(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AdyapanTheme.bgLightDark, borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: Text(op, style: AdyapanTheme.fredoka(fontSize: 16, color: AdyapanTheme.textMuted)),
                  ),
                ),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AdyapanTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(op, style: AdyapanTheme.fredoka(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 40),
        if (_isBalanced) ...[
          Text('🎉 Perfect BODMAS Balance! (+30 XP)', style: AdyapanTheme.fredoka(fontSize: 14, color: AdyapanTheme.green, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isBalanced = false;
                _selectedOperator = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdyapanTheme.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            child: Text('Play Another Level', style: AdyapanTheme.fredoka(color: Colors.white)),
          )
        ]
      ],
    );
  }

  // SYNTAX BLOCKS SUB-WIDGET
  Widget _buildSyntaxBlocks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assemble the Python Code!',
          style: AdyapanTheme.fredoka(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          'Drag the tiles into the assembly tray to print "Hello World".',
          style: AdyapanTheme.outfit(fontSize: 12, color: AdyapanTheme.textSub),
        ),
        const SizedBox(height: 20),

        // Assembly Tray
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AdyapanTheme.bgLightDark,
            border: Border.all(color: AdyapanTheme.glassBorder, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: _assembledSyntax.isEmpty
              ? Center(child: Text('Assembly Tray Empty. Tap blocks below to load!', style: AdyapanTheme.outfit(fontSize: 11, color: AdyapanTheme.textMuted)))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _assembledSyntax.map((tile) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: AdyapanTheme.purple, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(tile, style: AdyapanTheme.fredoka(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _assembledSyntax.remove(tile);
                              });
                            },
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 20),

        // Available Blocks
        Text('Available Blocks:', style: AdyapanTheme.outfit(fontSize: 13, color: AdyapanTheme.textSub, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSyntaxTiles.map((tile) {
            bool isUsed = _assembledSyntax.contains(tile);
            return GestureDetector(
              onTap: isUsed ? null : () {
                setState(() {
                  _assembledSyntax.add(tile);
                });
              },
              child: Opacity(
                opacity: isUsed ? 0.4 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AdyapanTheme.glassBorder),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(tile, style: AdyapanTheme.fredoka(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _assembledSyntax.isEmpty ? null : () {
                  setState(() {
                    _assembledSyntax.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  side: const BorderSide(color: AdyapanTheme.glassBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                child: Text('Reset', style: AdyapanTheme.fredoka(color: AdyapanTheme.textSub)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Check order
                  bool isCorrect = true;
                  if (_assembledSyntax.length != _correctSyntaxOrder.length) {
                    isCorrect = false;
                  } else {
                    for (int i = 0; i < _correctSyntaxOrder.length; i++) {
                      if (_assembledSyntax[i] != _correctSyntaxOrder[i]) {
                        isCorrect = false;
                        break;
                      }
                    }
                  }

                  if (isCorrect) {
                    _triggerWin();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🎉 Awesome Assemble! Code Compiled (+30 XP)'), backgroundColor: AdyapanTheme.green),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('❌ Compile Error: Syntax syntax mismatch! Try again.'), backgroundColor: AdyapanTheme.pink),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdyapanTheme.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                child: Text('Compile Code', style: AdyapanTheme.fredoka(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdyapanTheme.bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Arcade Banner Header
                Container(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AdyapanTheme.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.sports_esports_rounded, color: AdyapanTheme.blueAccent),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Arcade Console', style: AdyapanTheme.fredoka(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('Level up your wisdom points!', style: AdyapanTheme.outfit(fontSize: 12, color: AdyapanTheme.textSub)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Arcade Custom Navigation Tabs
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: AdyapanTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: AdyapanTheme.textSub,
                    labelStyle: AdyapanTheme.fredoka(fontSize: 12, fontWeight: FontWeight.bold),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Quiz Arena'),
                      Tab(text: 'Balancer'),
                      Tab(text: 'Syntax Block'),
                    ],
                  ),
                ),

                // Arcade Tab Content View
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(padding: const EdgeInsets.all(20), child: _buildQuizArena()),
                      SingleChildScrollView(padding: const EdgeInsets.all(20), child: _buildEquationBalancer()),
                      SingleChildScrollView(padding: const EdgeInsets.all(20), child: _buildSyntaxBlocks()),
                    ],
                  ),
                )
              ],
            ),

            // Embedded Confetti Overlay on top!
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [AdyapanTheme.blueAccent, AdyapanTheme.cyan, AdyapanTheme.green, AdyapanTheme.purple],
              ),
            )
          ],
        ),
      ),
    );
  }
}
