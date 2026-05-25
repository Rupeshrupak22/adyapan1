import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class ArcadeScreen extends StatefulWidget {
  const ArcadeScreen({super.key});

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
    },
    {
      'question': 'Which planet in our solar system is known as the Red Planet?',
      'options': ['Venus', 'Mars', 'Jupiter', 'Saturn'],
      'correctIdx': 1,
    },
    {
      'question': 'What is the square root of 144?',
      'options': ['10', '12', '14', '16'],
      'correctIdx': 1,
    },
    {
      'question': 'Which is the primary gas in the Earth\'s atmosphere?',
      'options': ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'],
      'correctIdx': 1,
    },
    {
      'question': 'Who invented the incandescent light bulb?',
      'options': ['Albert Einstein', 'Thomas Edison', 'Nikola Tesla', 'Isaac Newton'],
      'correctIdx': 1,
    }
  ];

  // Balancer Game State
  int _currentBalancerLevel = 0;
  bool _isBalanced = false;
  String? _selectedOperator;
  final List<Map<String, dynamic>> _balancerLevels = [
    {
      'left': 16.0,
      'rightVal1': '8',
      'rightVal2': '2',
      'correctOp': '*',
      'desc': '8 * 2 = 16. Master basic multiplication!',
    },
    {
      'left': 12.0,
      'rightVal1': '15',
      'rightVal2': '3',
      'correctOp': '-',
      'desc': '15 - 3 = 12. Basic subtraction balancer.',
    },
    {
      'left': 25.0,
      'rightVal1': '5',
      'rightVal2': '5',
      'correctOp': '*',
      'desc': '5 * 5 = 25. Perfect square multiplier.',
    },
    {
      'left': 9.0,
      'rightVal1': '27',
      'rightVal2': '3',
      'correctOp': '/',
      'desc': '27 / 3 = 9. Division principles.',
    },
    {
      'left': 30.0,
      'rightVal1': '18',
      'rightVal2': '12',
      'correctOp': '+',
      'desc': '18 + 12 = 30. Addition balance scale.',
    },
  ];

  // Syntax Blocks State
  int _currentSyntaxLevel = 0;
  bool _syntaxLevelCompleted = false;
  List<String> _assembledSyntax = [];
  final List<Map<String, dynamic>> _syntaxLevels = [
    {
      'desc': 'Assemble Python code to print "Hello World":',
      'tiles': ['print', '("Hello World")', ';', 'def main():'],
      'correct': ['def main():', 'print', '("Hello World")', ';'],
    },
    {
      'desc': 'Create an If statement checking if score > 50:',
      'tiles': ['if score > 50:', 'print("Pass")', 'else:', 'print("Fail")'],
      'correct': ['if score > 50:', 'print("Pass")', 'else:', 'print("Fail")'],
    },
    {
      'desc': 'Define a function square(x) returning x * x:',
      'tiles': ['def square(x):', 'return', 'x * x', 'result = square(5)'],
      'correct': ['def square(x):', 'return', 'x * x', 'result = square(5)'],
    },
    {
      'desc': 'Assemble a For loop iterating 5 times:',
      'tiles': ['for i in range(5):', 'print(i)', 'x = 0', 'x += i'],
      'correct': ['x = 0', 'for i in range(5):', 'print(i)', 'x += i'],
    },
  ];

  // Word Unscramble State
  int _currentUnscrambleLevel = 0;
  List<int> _tappedLetterIndices = [];
  bool _unscrambleCompleted = false;
  final List<Map<String, dynamic>> _unscrambleLevels = [
    {
      'word': 'ATOM',
      'scrambled': ['O', 'T', 'M', 'A'],
      'category': '⚛️ Science',
      'hint': 'The basic building block of all matter.',
    },
    {
      'word': 'ALGEBRA',
      'scrambled': ['G', 'E', 'R', 'B', 'L', 'A', 'A'],
      'category': '📐 Math',
      'hint': 'The branch of mathematics involving variables.',
    },
    {
      'word': 'GRAVITY',
      'scrambled': ['V', 'I', 'R', 'T', 'G', 'Y', 'A'],
      'category': '🌌 Physics',
      'hint': 'The invisible force that pulls objects toward each other.',
    },
    {
      'word': 'PHOTOSYNTHESIS',
      'scrambled': ['S', 'Y', 'N', 'T', 'H', 'E', 'S', 'I', 'S', 'P', 'H', 'O', 'T', 'O'],
      'category': '🌿 Biology',
      'hint': 'Process by which green plants make food using sunlight.',
    },
    {
      'word': 'METAPHOR',
      'scrambled': ['P', 'H', 'O', 'T', 'M', 'E', 'A', 'R'],
      'category': '📖 English',
      'hint': 'A figure of speech comparing two unrelated things.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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

  // DIALOG PORTAL TO ADD CUSTOM QUESTIONS DYNAMICALLY
  void _showAddQuestionDialog() {
    final questionController = TextEditingController();
    final option0Controller = TextEditingController();
    final option1Controller = TextEditingController();
    final option2Controller = TextEditingController();
    final option3Controller = TextEditingController();
    int selectedCorrectIndex = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                '➕ Add Custom Question',
                style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: AdyapanTheme.blueAccent),
              ),
              content: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Create your own custom question to test your knowledge in the Quiz Arena!',
                      style: GoogleFonts.outfit(fontSize: 11, color: AdyapanTheme.textSub),
                    ),
                    const SizedBox(height: 14),
                    // Question text
                    TextField(
                      controller: questionController,
                      style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        labelText: 'Question Text',
                        labelStyle: GoogleFonts.outfit(fontSize: 12, color: AdyapanTheme.textSub),
                        hintText: 'e.g. What is 7 * 6?',
                        hintStyle: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF94A3B8)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Option 0
                    _buildOptionInputField(option0Controller, 'Option A (Index 0)', 'e.g. 42'),
                    const SizedBox(height: 8),
                    // Option 1
                    _buildOptionInputField(option1Controller, 'Option B (Index 1)', 'e.g. 49'),
                    const SizedBox(height: 8),
                    // Option 2
                    _buildOptionInputField(option2Controller, 'Option C (Index 2)', 'e.g. 35'),
                    const SizedBox(height: 8),
                    // Option 3
                    _buildOptionInputField(option3Controller, 'Option D (Index 3)', 'e.g. 56'),
                    const SizedBox(height: 12),
                    
                    // Correct index dropdown
                    DropdownButtonFormField<int>(
                      value: selectedCorrectIndex,
                      decoration: InputDecoration(
                        labelText: 'Correct Option',
                        labelStyle: GoogleFonts.outfit(fontSize: 12, color: AdyapanTheme.textSub),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Option A', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 1, child: Text('Option B', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 2, child: Text('Option C', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 3, child: Text('Option D', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedCorrectIndex = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.fredoka(color: AdyapanTheme.textSub)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final qText = questionController.text.trim();
                    final opt0 = option0Controller.text.trim();
                    final opt1 = option1Controller.text.trim();
                    final opt2 = option2Controller.text.trim();
                    final opt3 = option3Controller.text.trim();

                    if (qText.isNotEmpty && opt0.isNotEmpty && opt1.isNotEmpty && opt2.isNotEmpty && opt3.isNotEmpty) {
                      setState(() {
                        _quizQuestions.add({
                          'question': qText,
                          'options': [opt0, opt1, opt2, opt3],
                          'correctIdx': selectedCorrectIndex,
                        });
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎉 Custom question successfully added to Quiz Arena!'),
                          backgroundColor: AdyapanTheme.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⚠️ Please fill in all options!'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdyapanTheme.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  child: Text('Add Question', style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildOptionInputField(TextEditingController controller, String label, String hint) {
    return TextField(
      controller: controller,
      style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(fontSize: 12, color: AdyapanTheme.textSub),
        hintText: hint,
        hintStyle: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF94A3B8)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // QUIZ ARENA SUB-WIDGET WITH CUSTOM PROGRESS INDICATORS & ADMIN CONTROL PANEL
  Widget _buildQuizArena() {
    var q = _quizQuestions[_currentQuizIdx];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Question ${_currentQuizIdx + 1}/${_quizQuestions.length}', style: AdyapanTheme.fredoka(fontSize: 14, color: AdyapanTheme.blueAccent, fontWeight: FontWeight.bold)),
            Text('Score: $_quizScore XP', style: AdyapanTheme.fredoka(fontSize: 14, color: AdyapanTheme.green, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        // Linear Progress bar representing progress in the Quiz Arena
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (_currentQuizIdx + 1) / _quizQuestions.length,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: const AlwaysStoppedAnimation<Color>(AdyapanTheme.blueAccent),
          ),
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
    final level = _balancerLevels[_currentBalancerLevel];
    double leftWeight = level['left'];
    String val1 = level['rightVal1'];
    String val2 = level['rightVal2'];
    String correctOp = level['correctOp'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Balance the Equation Scale!',
              style: AdyapanTheme.fredoka(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AdyapanTheme.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(
                'Level ${_currentBalancerLevel + 1}/${_balancerLevels.length}',
                style: AdyapanTheme.fredoka(fontSize: 11, fontWeight: FontWeight.bold, color: AdyapanTheme.green),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Insert the operator so left weight equals right equation.',
          style: AdyapanTheme.outfit(fontSize: 12, color: AdyapanTheme.textSub),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Hint Description
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.amber.withOpacity(0.3))),
          child: Text(
            level['desc'],
            style: AdyapanTheme.outfit(fontSize: 11, color: const Color(0xFFEF6C00), fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),

        // The Scale Visualization
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left Plate
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              transform: Matrix4.translationValues(0, _isBalanced ? 0 : -15, 0),
              padding: const EdgeInsets.all(16),
              decoration: AdyapanTheme.glassCardDecoration(customRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text('⚖️', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text('Weight: ${leftWeight.toInt()}', style: AdyapanTheme.fredoka(fontSize: 13, fontWeight: FontWeight.bold)),
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
                    child: Text(val1, style: AdyapanTheme.fredoka(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  // Drop Target Slot
                  DragTarget<String>(
                    onAccept: (data) {
                      setState(() {
                        _selectedOperator = data;
                        if (data == correctOp) {
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
                    child: Text(val2, style: AdyapanTheme.fredoka(fontWeight: FontWeight.bold)),
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
                if (_currentBalancerLevel + 1 < _balancerLevels.length) {
                  _currentBalancerLevel++;
                } else {
                  _currentBalancerLevel = 0; // restart
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdyapanTheme.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            child: Text(
              _currentBalancerLevel + 1 < _balancerLevels.length ? 'Next Level' : 'Restart Balancer',
              style: AdyapanTheme.fredoka(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ]
      ],
    );
  }

  // SYNTAX BLOCKS SUB-WIDGET (WITH MULTIPLE LEVELS)
  Widget _buildSyntaxBlocks() {
    final level = _syntaxLevels[_currentSyntaxLevel];
    final String description = level['desc'] as String;
    final List<String> tiles = List<String>.from(level['tiles']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Assemble the Code Blocks!',
              style: AdyapanTheme.fredoka(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AdyapanTheme.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(
                'Level ${_currentSyntaxLevel + 1}/${_syntaxLevels.length}',
                style: AdyapanTheme.fredoka(fontSize: 11, fontWeight: FontWeight.bold, color: AdyapanTheme.purple),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
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
          children: tiles.map((tile) {
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
                onPressed: _assembledSyntax.isEmpty || _syntaxLevelCompleted ? null : () {
                  // Check order
                  final correctOrder = List<String>.from(level['correct']);
                  bool isCorrect = true;
                  if (_assembledSyntax.length != correctOrder.length) {
                    isCorrect = false;
                  } else {
                    for (int i = 0; i < correctOrder.length; i++) {
                      if (_assembledSyntax[i] != correctOrder[i]) {
                        isCorrect = false;
                        break;
                      }
                    }
                  }

                  if (isCorrect) {
                    _triggerWin();
                    setState(() {
                      _syntaxLevelCompleted = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🎉 Awesome Assemble! Code Compiled (+30 XP)'), backgroundColor: AdyapanTheme.green),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('❌ Compile Error: Syntax mismatch! Try again.'), backgroundColor: AdyapanTheme.pink),
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
        ),
        if (_syntaxLevelCompleted) ...[
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _assembledSyntax.clear();
                  _syntaxLevelCompleted = false;
                  if (_currentSyntaxLevel + 1 < _syntaxLevels.length) {
                    _currentSyntaxLevel++;
                  } else {
                    _currentSyntaxLevel = 0; // restart
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdyapanTheme.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              child: Text(
                _currentSyntaxLevel + 1 < _syntaxLevels.length ? 'Next Level' : 'Restart Syntax Blocks',
                style: AdyapanTheme.fredoka(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ]
      ],
    );
  }

  // BRAND NEW GAME TAB: WORD UNSCRAMBLE (BRAIN BOOSTER)
  Widget _buildWordUnscramble() {
    final level = _unscrambleLevels[_currentUnscrambleLevel];
    final String targetWord = level['word'];
    final List<String> scrambled = List<String>.from(level['scrambled']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Word Unscramble 🧠', style: AdyapanTheme.fredoka(fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AdyapanTheme.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AdyapanTheme.blueAccent),
              ),
              child: Text(
                level['category'] as String,
                style: AdyapanTheme.fredoka(fontSize: 10, fontWeight: FontWeight.bold, color: AdyapanTheme.blueAccent),
              ),
            )
          ],
        ),
        const SizedBox(height: 6),
        Text('Tap the scrambled letter tiles to assemble the correct term.', style: AdyapanTheme.outfit(fontSize: 12, color: AdyapanTheme.textSub)),
        const SizedBox(height: 16),

        // Hint Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('HINT DEFINITION:', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF1D4ED8), letterSpacing: 1.0)),
              const SizedBox(height: 4),
              Text(
                level['hint'] as String,
                style: GoogleFonts.fredoka(fontSize: 13, color: const Color(0xFF1E3A8A)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Letter Assembly Tray
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AdyapanTheme.bgLightDark,
            border: Border.all(color: AdyapanTheme.glassBorder, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: _tappedLetterIndices.isEmpty
              ? Center(child: Text('Tap letters below to spell!', style: AdyapanTheme.outfit(fontSize: 11, color: AdyapanTheme.textMuted)))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tappedLetterIndices.map((idx) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _tappedLetterIndices.remove(idx);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          scrambled[idx],
                          style: GoogleFonts.fredoka(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 20),

        // Available scrambled letter buttons
        Text('Scrambled Letter Blocks:', style: AdyapanTheme.outfit(fontSize: 13, color: AdyapanTheme.textSub, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(scrambled.length, (idx) {
            bool isUsed = _tappedLetterIndices.contains(idx);
            return GestureDetector(
              onTap: isUsed ? null : () {
                setState(() {
                  _tappedLetterIndices.add(idx);
                });
              },
              child: Opacity(
                opacity: isUsed ? 0.3 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AdyapanTheme.glassBorder),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
                  ),
                  child: Text(
                    scrambled[idx],
                    style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _tappedLetterIndices.isEmpty ? null : () {
                  setState(() {
                    _tappedLetterIndices.clear();
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
                onPressed: _tappedLetterIndices.isEmpty || _unscrambleCompleted ? null : () {
                  // Validate word
                  final assembledWord = _tappedLetterIndices.map((idx) => scrambled[idx]).join('').trim().toUpperCase();
                  if (assembledWord == targetWord) {
                    _triggerWin();
                    setState(() {
                      _unscrambleCompleted = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('🎉 Outstanding! You unscrambled "$targetWord" successfully! (+30 XP)'), backgroundColor: AdyapanTheme.green),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ Mismatch! "$assembledWord" is incorrect. Try again!'), backgroundColor: AdyapanTheme.pink),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdyapanTheme.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                child: Text('Check Word', style: AdyapanTheme.fredoka(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
        if (_unscrambleCompleted) ...[
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _tappedLetterIndices.clear();
                  _unscrambleCompleted = false;
                  if (_currentUnscrambleLevel + 1 < _unscrambleLevels.length) {
                    _currentUnscrambleLevel++;
                  } else {
                    _currentUnscrambleLevel = 0; // restart
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdyapanTheme.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              child: Text(
                _currentUnscrambleLevel + 1 < _unscrambleLevels.length ? 'Next Level' : 'Restart Brain Booster',
                style: AdyapanTheme.fredoka(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ]
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
                        decoration: BoxDecoration(color: AdyapanTheme.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.sports_esports_rounded, color: AdyapanTheme.blueAccent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Arcade Console', style: AdyapanTheme.fredoka(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('Level up your wisdom points!', style: AdyapanTheme.outfit(fontSize: 12, color: AdyapanTheme.textSub)),
                          ],
                        ),
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
                    labelStyle: AdyapanTheme.fredoka(fontSize: 11, fontWeight: FontWeight.bold),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Quiz Arena'),
                      Tab(text: 'Balancer'),
                      Tab(text: 'Syntax Block'),
                      Tab(text: 'Unscramble'),
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
                      SingleChildScrollView(padding: const EdgeInsets.all(20), child: _buildWordUnscramble()),
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
