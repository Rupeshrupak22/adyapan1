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

  String _selectedClass = 'Class 1';
  final List<String> _classes = List.generate(12, (index) => 'Class ${index + 1}');

  int _currentCognitiveLevel = 0;
  bool _cognitiveSolved = false;
  String? _selectedCognitiveChoice;

  int _currentSyntaxLevel = 0;
  bool _syntaxLevelCompleted = false;
  List<String> _assembledSyntax = [];

  int _currentUnscrambleLevel = 0;
  List<int> _tappedLetterIndices = [];
  bool _unscrambleCompleted = false;

  List<Map<String, dynamic>> _getQuizQuestions() {
    int classNum = int.tryParse(_selectedClass.replaceAll('Class ', '')) ?? 1;
    switch (classNum) {
      case 1:
        return [
          {'question': 'What is 3 + 2?', 'options': ['4', '5', '6', '3'], 'correctIdx': 1},
          {'question': 'Identify the primary color:', 'options': ['Green', 'Orange', 'Blue', 'Purple'], 'correctIdx': 2},
          {'question': 'Which animal barks?', 'options': ['Cat', 'Dog', 'Lion', 'Cow'], 'correctIdx': 1},
        ];
      case 2:
        return [
          {'question': 'What is 12 + 8?', 'options': ['18', '20', '22', '24'], 'correctIdx': 1},
          {'question': 'Where does a fish live?', 'options': ['Land', 'Tree', 'Water', 'Sky'], 'correctIdx': 2},
          {'question': 'Which shape has 3 sides?', 'options': ['Square', 'Circle', 'Triangle', 'Rectangle'], 'correctIdx': 2},
        ];
      case 3:
        return [
          {'question': 'What is 5 * 4?', 'options': ['15', '20', '25', '30'], 'correctIdx': 1},
          {'question': 'Which of these is a Noun?', 'options': ['Run', 'Beautiful', 'Delhi', 'Quickly'], 'correctIdx': 2},
          {'question': 'How many hours are there in a day?', 'options': ['12', '24', '48', '36'], 'correctIdx': 1},
        ];
      case 4:
        return [
          {'question': 'What is 36 / 6?', 'options': ['4', '5', '6', '7'], 'correctIdx': 2},
          {'question': 'Which state of matter is water?', 'options': ['Solid', 'Liquid', 'Gas', 'Plasma'], 'correctIdx': 1},
          {'question': 'How many days are in a leap year?', 'options': ['365', '366', '360', '364'], 'correctIdx': 1},
        ];
      case 5:
        return [
          {'question': 'What is 0.5 + 0.25?', 'options': ['0.75', '0.80', '0.65', '0.70'], 'correctIdx': 0},
          {'question': 'Which is the largest planet in our Solar System?', 'options': ['Earth', 'Mars', 'Jupiter', 'Saturn'], 'correctIdx': 2},
          {'question': 'Choose the pronoun in: "She is reading a book."', 'options': ['She', 'reading', 'book', 'is'], 'correctIdx': 0},
        ];
      case 6:
        return [
          {'question': 'Find x: x - 4 = 10', 'options': ['6', '12', '14', '16'], 'correctIdx': 2},
          {'question': 'Which pigment gives plants their green color?', 'options': ['Carotene', 'Chlorophyll', 'Xanthophyll', 'Melanin'], 'correctIdx': 1},
          {'question': 'An angle of 90 degrees is called a:', 'options': ['Acute angle', 'Obtuse angle', 'Right angle', 'Straight angle'], 'correctIdx': 2},
        ];
      case 7:
        return [
          {'question': 'What is (-5) + (-8)?', 'options': ['-13', '13', '-3', '3'], 'correctIdx': 0},
          {'question': 'Where does chemical digestion of protein start?', 'options': ['Mouth', 'Stomach', 'Small Intestine', 'Esophagus'], 'correctIdx': 1},
          {'question': 'Who was the first Prime Minister of India?', 'options': ['Mahatma Gandhi', 'Jawaharlal Nehru', 'Subhas Chandra Bose', 'Dr. B.R. Ambedkar'], 'correctIdx': 1},
        ];
      case 8:
        return [
          {'question': 'What is the square root of 196?', 'options': ['12', '13', '14', '15'], 'correctIdx': 2},
          {'question': 'What is the chemical symbol for Gold?', 'options': ['Ag', 'Fe', 'Au', 'Cu'], 'correctIdx': 2},
          {'question': 'Solve for y: 2y + 5 = 15', 'options': ['3', '5', '10', '4'], 'correctIdx': 1},
        ];
      case 9:
        return [
          {'question': 'Which organelle is known as the powerhouse of the cell?', 'options': ['Nucleus', 'Mitochondria', 'Ribosome', 'Golgi apparatus'], 'correctIdx': 1},
          {'question': 'What is Newton\'s First Law of Motion also known as?', 'options': ['Law of Action-Reaction', 'Law of Inertia', 'Law of Acceleration', 'Law of Gravitation'], 'correctIdx': 1},
          {'question': 'Find the degree of the polynomial: x^3 + 5x^2 - 4x + 7', 'options': ['1', '2', '3', '4'], 'correctIdx': 2},
        ];
      case 10:
        return [
          {'question': 'If sin(θ) = 4/5, what is cos(θ)?', 'options': ['3/5', '1/5', '2/5', '4/3'], 'correctIdx': 0},
          {'question': 'Which element has the atomic number 6?', 'options': ['Hydrogen', 'Helium', 'Carbon', 'Oxygen'], 'correctIdx': 2},
          {'question': 'What is the unit of electric resistance?', 'options': ['Ampere', 'Volt', 'Ohm', 'Watt'], 'correctIdx': 2},
        ];
      case 11:
        return [
          {'question': 'What is the dot product of two perpendicular vectors?', 'options': ['1', '0', '-1', 'Infinity'], 'correctIdx': 1},
          {'question': 'Which chemical bond involves sharing of electrons?', 'options': ['Ionic Bond', 'Covalent Bond', 'Metallic Bond', 'Hydrogen Bond'], 'correctIdx': 1},
          {'question': 'What is the general formula of Alkanes?', 'options': ['CnH2n', 'CnH2n-2', 'CnH2n+2', 'CnHn'], 'correctIdx': 2},
        ];
      case 12:
      default:
        return [
          {'question': 'Solve the integration: ∫ (1/x) dx', 'options': ['e^x + C', 'ln|x| + C', '-1/x^2 + C', 'x^2/2 + C'], 'correctIdx': 1},
          {'question': 'Which logic gate yields 1 only when both inputs are 1?', 'options': ['AND Gate', 'OR Gate', 'NAND Gate', 'NOR Gate'], 'correctIdx': 0},
          {'question': 'What is the SI unit of electric flux?', 'options': ['Tesla', 'Weber', 'N m^2 C^-1', 'Coulomb'], 'correctIdx': 2},
        ];
    }
  }

  List<Map<String, dynamic>> _getCognitiveLevels() {
    final List<Map<String, dynamic>> baseLevels;
    int classNum = int.tryParse(_selectedClass.replaceAll('Class ', '')) ?? 1;
    switch (classNum) {
      case 1:
        baseLevels = [
          {
            'type': 'spatial',
            'question': 'Shape Identical Challenge: Choose the matching rotated shape for ▲ turned upside down (180°):',
            'original': '▲',
            'choices': ['▲', '▼', '◀', '▶'],
            'correct': '▼',
            'desc': 'Symmetry Match. 180° turns the top-pointer upside down!',
          }
        ];
        break;
      case 2:
        baseLevels = [
          {
            'type': 'spatial',
            'question': 'Which shape matches a 90° clockwise rotation of ◀?',
            'original': '◀',
            'choices': ['▲', '▼', '◀', '▶'],
            'correct': '▲',
            'desc': 'Rotation Match. 90° clockwise points the arrow UP!',
          }
        ];
        break;
      case 3:
        baseLevels = [
          {
            'type': 'spatial',
            'question': 'Symmetry Match: If ● represents 1 and ●● represents 2, what represents 4?',
            'original': '●●\n●●',
            'choices': ['●', '●●', '●●●', '●●\n●●'],
            'correct': '●●\n●●',
            'desc': 'Visual Patterns. A 2x2 grid contains 4 dots!',
          }
        ];
        break;
      case 4:
        baseLevels = [
          {
            'type': 'pathfinder',
            'question': 'Grid Pathfinder: Move robot from bottom-left (0,0) to top-right (1,1) in a 2x2 grid:',
            'grid': '2x2',
            'choices': ['Up, Right', 'Up, Down', 'Right, Left', 'Down, Right'],
            'correct': 'Up, Right',
            'desc': 'Pathfinder. Move 1 step Up and 1 step Right to reach (1,1).',
          }
        ];
        break;
      case 5:
        baseLevels = [
          {
            'type': 'bubbles',
            'question': 'Target Math: Select the bubble formula that sums to exactly 12:',
            'target': 12,
            'choices': ['4 + 4 + 4', '5 + 5 + 1', '6 + 3 + 2', '8 + 1 + 2'],
            'correct': '4 + 4 + 4',
            'desc': 'Numerical Bubbles. Pop 3 bubbles of 4 to reach 12!',
          }
        ];
        break;
      case 6:
        baseLevels = [
          {
            'type': 'pathfinder',
            'question': 'Grid Pathfinder: Move robot from (0,0) to (2,2) in a 3x3 grid:',
            'grid': '3x3',
            'choices': ['Up, Up, Right, Right', 'Up, Right, Down, Up', 'Right, Right, Left, Up', 'Up, Up, Down, Right'],
            'correct': 'Up, Up, Right, Right',
            'desc': 'Pathfinder. Move 2 steps Up and 2 steps Right to reach (2,2).',
          }
        ];
        break;
      case 7:
        baseLevels = [
          {
            'type': 'spatial',
            'question': 'Numerical Aptitude: Complete the Fibonacci sequence: 1, 1, 2, 3, 5, 8, [?]',
            'choices': ['11', '12', '13', '14'],
            'correct': '13',
            'desc': 'Numerical Series. Add the last two terms: 5 + 8 = 13.',
          }
        ];
        break;
      case 8:
        baseLevels = [
          {
            'type': 'spatial',
            'question': 'Stack Challenge: Stack holds [10]. If you push 20, push 30, and pop once, what is on top?',
            'choices': ['10', '20', '30', 'Empty'],
            'correct': '20',
            'desc': 'LIFO Order. Pop removes 30 (the last element), leaving 20 on top.',
          }
        ];
        break;
      case 9:
        baseLevels = [
          {
            'type': 'spatial',
            'question': 'Queue Challenge: Queue has [10]. If you enqueue 20, enqueue 30, and dequeue once, what is at the front?',
            'choices': ['10', '20', '30', 'Empty'],
            'correct': '20',
            'desc': 'FIFO Order. Dequeue removes 10 (the first element), leaving 20 at the front.',
          }
        ];
        break;
      case 10:
        baseLevels = [
          {
            'type': 'spatial',
            'question': 'Cognitive Pattern: Grid [▲, ●] rotates 90° clockwise to become [?, ▲]. What is \'?\'?',
            'choices': ['●', '■', '◆', '▲'],
            'correct': '●',
            'desc': 'Rotating 90° moves top-right ● to top-left position.',
          }
        ];
        break;
      case 11:
        baseLevels = [
          {
            'type': 'flow',
            'question': 'Flow Processor: Calculate final output for Input = 12.',
            'input': 12,
            'flow': '[Input: 12] ➔ [+4] ➔ [/2] ➔ [If > 5: Output, Else: Output * 2]',
            'choices': ['6', '8', '10', '12'],
            'correct': '8',
            'desc': 'Logic Flow. 12 + 4 = 16. 16 / 2 = 8. Since 8 > 5, output is 8.',
          }
        ];
        break;
      case 12:
      default:
        baseLevels = [
          {
            'type': 'flow',
            'question': 'Advanced Flow: Calculate final output for Input = 5.',
            'input': 5,
            'flow': '[Input: 5] ➔ [*3] ➔ [-5] ➔ [If even: Output / 2, Else: Output + 1]',
            'choices': ['5', '6', '10', '11'],
            'correct': '5',
            'desc': 'Advanced Flow. 5 * 3 = 15. 15 - 5 = 10. Since 10 is even, 10 / 2 = 5.',
          }
        ];
        break;
    }

    final state = Provider.of<AppState>(context, listen: false);
    final customLevels = state.customCognitiveLevels
        .where((lvl) => lvl['class'] == _selectedClass)
        .map((lvl) {
          final mappedType = lvl['type'] == 'Spatial Match' ? 'spatial' : 'pathfinder';
          return {
            'type': mappedType,
            'question': lvl['question'],
            'original': lvl['original'],
            'choices': List<String>.from(lvl['choices']),
            'correct': lvl['correct'],
            'desc': lvl['desc'],
          };
        }).toList();

    return [...baseLevels, ...customLevels];
  }

  List<Map<String, dynamic>> _getSyntaxLevels() {
    final List<Map<String, dynamic>> baseLevels;
    int classNum = int.tryParse(_selectedClass.replaceAll('Class ', '')) ?? 1;
    switch (classNum) {
      case 1:
        baseLevels = [
          {
            'desc': 'Assemble Scratch blocks to move forward:',
            'tiles': ['[Start]', '[Move]', '[End]'],
            'correct': ['[Start]', '[Move]', '[End]'],
          }
        ];
        break;
      case 2:
        baseLevels = [
          {
            'desc': 'Assemble Scratch blocks to jump & turn:',
            'tiles': ['[Start]', '[Jump]', '[Turn]', '[End]'],
            'correct': ['[Start]', '[Jump]', '[Turn]', '[End]'],
          }
        ];
        break;
      case 3:
        baseLevels = [
          {
            'desc': 'Order basic commands to print two messages:',
            'tiles': ['print("Hello")', 'print("World")', 'print("End")'],
            'correct': ['print("Hello")', 'print("World")', 'print("End")'],
          }
        ];
        break;
      case 4:
        baseLevels = [
          {
            'desc': 'Assemble HTML blocks to output a paragraph:',
            'tiles': ['<p>', 'Hello World', '</p>'],
            'correct': ['<p>', 'Hello World', '</p>'],
          }
        ];
        break;
      case 5:
        baseLevels = [
          {
            'desc': 'Assemble HTML blocks to output a heading inside body:',
            'tiles': ['<body>', '<h1>Hi</h1>', '</body>'],
            'correct': ['<body>', '<h1>Hi</h1>', '</body>'],
          }
        ];
        break;
      case 6:
        baseLevels = [
          {
            'desc': 'Assemble HTML blocks to output a standard HTML page:',
            'tiles': ['<html>', '<body>', '<h1>Hi</h1>', '</body>', '</html>'],
            'correct': ['<html>', '<body>', '<h1>Hi</h1>', '</body>', '</html>'],
          }
        ];
        break;
      case 7:
        baseLevels = [
          {
            'desc': 'Assemble Python code to assign x = 100:',
            'tiles': ['x', '=', '100'],
            'correct': ['x', '=', '100'],
          }
        ];
        break;
      case 8:
        baseLevels = [
          {
            'desc': 'Assemble Python code to print a variable:',
            'tiles': ['name = "Adyapan"', 'print(name)'],
            'correct': ['name = "Adyapan"', 'print(name)'],
          }
        ];
        break;
      case 9:
        baseLevels = [
          {
            'desc': 'Assemble Python code to assign and print sum:',
            'tiles': ['x = 5', 'y = 10', 'print(x + y)'],
            'correct': ['x = 5', 'y = 10', 'print(x + y)'],
          }
        ];
        break;
      case 10:
        baseLevels = [
          {
            'desc': 'Assemble Python code to print numbers 0 to 2 using loop:',
            'tiles': ['for i in range(3):', 'print(i)'],
            'correct': ['for i in range(3):', 'print(i)'],
          }
        ];
        break;
      case 11:
        baseLevels = [
          {
            'desc': 'Create an If statement checking if score > 50:',
            'tiles': ['if score > 50:', 'print("Pass")', 'else:', 'print("Fail")'],
            'correct': ['if score > 50:', 'print("Pass")', 'else:', 'print("Fail")'],
          }
        ];
        break;
      case 12:
      default:
        baseLevels = [
          {
            'desc': 'Assemble Python code to print "Hello World" inside function:',
            'tiles': ['def main():', 'print', '("Hello World")', ';'],
            'correct': ['def main():', 'print', '("Hello World")', ';'],
          }
        ];
        break;
    }

    final state = Provider.of<AppState>(context, listen: false);
    final customLevels = state.customSyntaxLevels
        .where((lvl) => lvl['class'] == _selectedClass)
        .map((lvl) {
          return {
            'desc': lvl['desc'],
            'tiles': List<String>.from(lvl['tiles']),
            'correct': List<String>.from(lvl['correct']),
          };
        }).toList();

    return [...baseLevels, ...customLevels];
  }

  List<Map<String, dynamic>> _getUnscrambleLevels() {
    final List<Map<String, dynamic>> baseLevels;
    int classNum = int.tryParse(_selectedClass.replaceAll('Class ', '')) ?? 1;
    switch (classNum) {
      case 1:
        baseLevels = [
          {
            'word': 'SUN',
            'scrambled': ['U', 'N', 'S'],
            'category': '🌌 Science',
            'hint': 'The star at the center of our Solar System.',
          },
          {
            'word': 'CAT',
            'scrambled': ['A', 'T', 'C'],
            'category': '🐱 Animals',
            'hint': 'A popular furry pet that meows.',
          }
        ];
        break;
      case 2:
        baseLevels = [
          {
            'word': 'STAR',
            'scrambled': ['A', 'R', 'T', 'S'],
            'category': '🌌 Astronomy',
            'hint': 'A glowing point of light in the night sky.',
          },
          {
            'word': 'MOON',
            'scrambled': ['O', 'O', 'N', 'M'],
            'category': '🌌 Astronomy',
            'hint': 'Earth\'s natural satellite.',
          }
        ];
        break;
      case 3:
        baseLevels = [
          {
            'word': 'ATOM',
            'scrambled': ['O', 'T', 'M', 'A'],
            'category': '⚛️ Science',
            'hint': 'The basic building block of all matter.',
          },
          {
            'word': 'MATH',
            'scrambled': ['T', 'H', 'M', 'A'],
            'category': '📐 Math',
            'hint': 'Science of numbers and shapes.',
          }
        ];
        break;
      case 4:
        baseLevels = [
          {
            'word': 'EARTH',
            'scrambled': ['H', 'T', 'R', 'A', 'E'],
            'category': '🌍 Science',
            'hint': 'Our home planet, third from the Sun.',
          },
          {
            'word': 'PLANT',
            'scrambled': ['T', 'N', 'A', 'P', 'L'],
            'category': '🌿 Biology',
            'hint': 'Living organism that performs photosynthesis.',
          }
        ];
        break;
      case 5:
        baseLevels = [
          {
            'word': 'ANIMAL',
            'scrambled': ['L', 'A', 'M', 'I', 'N', 'A'],
            'category': '🦁 Biology',
            'hint': 'Living creature that can move and feels.',
          },
          {
            'word': 'ENERGY',
            'scrambled': ['Y', 'G', 'R', 'E', 'N', 'E'],
            'category': '⚡ Physics',
            'hint': 'The capacity to do work.',
          }
        ];
        break;
      case 6:
        baseLevels = [
          {
            'word': 'OXYGEN',
            'scrambled': ['G', 'E', 'X', 'Y', 'O', 'N'],
            'category': '🌿 Biology',
            'hint': 'Gas essential for human respiration.',
          },
          {
            'word': 'FOREST',
            'scrambled': ['T', 'S', 'E', 'R', 'O', 'F'],
            'category': '🌳 Ecology',
            'hint': 'Large area covered chiefly with trees.',
          }
        ];
        break;
      case 7:
        baseLevels = [
          {
            'word': 'ALGEBRA',
            'scrambled': ['G', 'E', 'R', 'B', 'L', 'A', 'A'],
            'category': '📐 Math',
            'hint': 'The branch of mathematics involving variables.',
          },
          {
            'word': 'LIQUID',
            'scrambled': ['D', 'I', 'U', 'Q', 'I', 'L'],
            'category': '🧪 Chemistry',
            'hint': 'State of matter between solid and gas.',
          }
        ];
        break;
      case 8:
        baseLevels = [
          {
            'word': 'GRAVITY',
            'scrambled': ['V', 'I', 'R', 'T', 'G', 'Y', 'A'],
            'category': '🌌 Physics',
            'hint': 'The invisible force that pulls objects toward each other.',
          },
          {
            'word': 'FORCE',
            'scrambled': ['E', 'C', 'R', 'O', 'F'],
            'category': '⚡ Physics',
            'hint': 'A push or pull acting upon an object.',
          }
        ];
        break;
      case 9:
        baseLevels = [
          {
            'word': 'CHROMOSOME',
            'scrambled': ['C', 'H', 'R', 'O', 'M', 'O', 'S', 'O', 'M', 'E'],
            'category': '🌿 Biology',
            'hint': 'Thread-like structure carrying genetic information.',
          },
          {
            'word': 'POLYMER',
            'scrambled': ['R', 'E', 'M', 'Y', 'L', 'O', 'P'],
            'category': '🧪 Chemistry',
            'hint': 'Large molecule composed of repeating structural units.',
          }
        ];
        break;
      case 10:
        baseLevels = [
          {
            'word': 'SYNTAX',
            'scrambled': ['X', 'A', 'T', 'N', 'Y', 'S'],
            'category': '💻 Coding',
            'hint': 'Set of rules defining the structure of statements in coding.',
          },
          {
            'word': 'COMPILER',
            'scrambled': ['R', 'E', 'L', 'I', 'P', 'M', 'O', 'C'],
            'category': '💻 Computer Science',
            'hint': 'Program that translates code into machine language.',
          }
        ];
        break;
      case 11:
        baseLevels = [
          {
            'word': 'PHOTOSYNTHESIS',
            'scrambled': ['P', 'H', 'O', 'T', 'O', 'S', 'Y', 'N', 'T', 'H', 'E', 'S', 'I', 'S'],
            'category': '🌿 Biology',
            'hint': 'Process plants use to make food from sunlight.',
          },
          {
            'word': 'REACTION',
            'scrambled': ['N', 'O', 'I', 'T', 'C', 'A', 'E', 'R'],
            'category': '🧪 Chemistry',
            'hint': 'Process that leads to chemical transformation of substances.',
          }
        ];
        break;
      case 12:
      default:
        baseLevels = [
          {
            'word': 'SEMICONDUCTOR',
            'scrambled': ['S', 'E', 'M', 'I', 'C', 'O', 'N', 'D', 'U', 'C', 'T', 'O', 'R'],
            'category': '🔌 Electronics',
            'hint': 'Electrical conductivity between a conductor and insulator.',
          },
          {
            'word': 'THERMODYNAMICS',
            'scrambled': ['T', 'H', 'E', 'R', 'M', 'O', 'D', 'Y', 'N', 'A', 'M', 'I', 'C', 'S'],
            'category': '⚛️ Physics',
            'hint': 'Branch of physics dealing with heat and temperature.',
          }
        ];
        break;
    }

    final state = Provider.of<AppState>(context, listen: false);
    final customLevels = state.customUnscrambleLevels
        .where((lvl) => lvl['class'] == _selectedClass)
        .map((lvl) {
          return {
            'word': lvl['word'],
            'scrambled': List<String>.from(lvl['scrambled']),
            'category': lvl['category'],
            'hint': lvl['hint'],
          };
        }).toList();

    return [...baseLevels, ...customLevels];
  }

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
    // Provider.of<AppState>(context, listen: false).addXp(30); // Disabled: XP restricted solely to Future Skills quiz checklists
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
                      Provider.of<AppState>(context, listen: false).addCustomQuizQuestion(
                        question: qText,
                        options: [opt0, opt1, opt2, opt3],
                        correctOptionIndex: selectedCorrectIndex,
                        targetClass: _selectedClass,
                      );
                      setState(() {});
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
    final state = Provider.of<AppState>(context);
    final activeQuestions = [
      ..._getQuizQuestions(),
      ...state.customQuizQuestions
          .where((q) => q['class'] == null || q['class'] == _selectedClass)
          .map((q) => {
        'question': q['question'],
        'options': List<String>.from(q['options']),
        'correctIdx': q['correctOptionIndex'],
      })
    ];

    if (_currentQuizIdx >= activeQuestions.length) {
      _currentQuizIdx = 0; // safe clamp
    }

    var q = activeQuestions[_currentQuizIdx];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Question ${_currentQuizIdx + 1}/${activeQuestions.length}', style: AdyapanTheme.fredoka(fontSize: 14, color: AdyapanTheme.blueAccent, fontWeight: FontWeight.bold)),
            Text('Score: $_quizScore Points', style: AdyapanTheme.fredoka(fontSize: 14, color: AdyapanTheme.green, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        // Linear Progress bar representing progress in the Quiz Arena
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (_currentQuizIdx + 1) / activeQuestions.length,
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
                if (_currentQuizIdx + 1 < activeQuestions.length) {
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
              _currentQuizIdx + 1 < activeQuestions.length ? 'Next Question' : 'Restart Quiz Arena',
              style: AdyapanTheme.fredoka(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
      ],
    );
  }

  // COGNITIVE LOGIC ARENA (ACCENTURE & MCKINSEY COGNITIVE STYLE)
  Widget _buildCognitiveLogicArena() {
    final levels = _getCognitiveLevels();
    if (_currentCognitiveLevel >= levels.length) {
      _currentCognitiveLevel = 0;
    }
    final level = levels[_currentCognitiveLevel];
    final type = level['type'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              type == 'spatial' ? 'Matrix Rotation 🔄' : (type == 'flow' ? 'Flow Processor ⚙️' : 'Pathfinder 🤖'),
              style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
              ),
              child: Text(
                'Level ${_currentCognitiveLevel + 1}/${levels.length}',
                style: GoogleFonts.fredoka(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          level['question'] as String,
          style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF64748B)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        if (type == 'spatial' && level.containsKey('original')) ...[
          // Draw spatial matching/rotation diagram
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.75), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                )
              ]
            ),
            child: Column(
              children: [
                Text(
                  'Original shape:',
                  style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 8),
                Text(
                  level['original'] as String,
                  style: const TextStyle(fontSize: 72, color: Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ] else if (type == 'flow' && level.containsKey('flow')) ...[
          // Draw Accenture Flowchart diagram
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.75), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  'Accenture Logical Circuit Flowchart:',
                  style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                      child: Text('Input: ${level['input']}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: Color(0xFF64748B), size: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                      child: Text('[+4]', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: Color(0xFF64748B), size: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                      child: Text('[/2]', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Icon(Icons.arrow_downward_rounded, color: Color(0xFF64748B), size: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)),
                  child: Text('Condition: If Value > 5 ➔ Output\nElse ➔ Output * 2', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ] else if (type == 'pathfinder') ...[
          // Grid Pathfinder layout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.75), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  '3x3 Navigation Matrix Grid:',
                  style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                ),
                const SizedBox(height: 12),
                Table(
                  border: TableBorder.all(color: const Color(0xFFCBD5E1), width: 1),
                  defaultColumnWidth: const FixedColumnWidth(40),
                  children: [
                    TableRow(
                      children: [
                        Container(height: 40, alignment: Alignment.center, child: const Text('🏁', style: TextStyle(fontSize: 16))),
                        Container(height: 40),
                        Container(height: 40),
                      ]
                    ),
                    TableRow(
                      children: [
                        Container(height: 40),
                        Container(height: 40),
                        Container(height: 40),
                      ]
                    ),
                    TableRow(
                      children: [
                        Container(height: 40, alignment: Alignment.center, child: const Text('🤖', style: TextStyle(fontSize: 16))),
                        Container(height: 40),
                        Container(height: 40),
                      ]
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Start position: bottom-left (🤖), Destination: top-right (🏁)', style: GoogleFonts.outfit(fontSize: 9.5, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Choice Buttons
        Text(
          'Select the correct answer choice:',
          style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
        ),
        const SizedBox(height: 12),
        Column(
          children: (level['choices'] as List<String>).map((choice) {
            final isSelected = _selectedCognitiveChoice == choice;
            final isCorrect = choice == level['correct'];
            Color btnColor = Colors.white;
            Color textColor = const Color(0xFF1E293B);
            BorderSide border = const BorderSide(color: Color(0xFFE2E8F0), width: 1.5);

            if (_cognitiveSolved) {
              if (isCorrect) {
                btnColor = const Color(0xFFECFDF5);
                textColor = const Color(0xFF059669);
                border = const BorderSide(color: Color(0xFF10B981), width: 1.5);
              } else if (isSelected) {
                btnColor = const Color(0xFFFEF2F2);
                textColor = const Color(0xFFDC2626);
                border = const BorderSide(color: Color(0xFFEF4444), width: 1.5);
              }
            } else if (isSelected) {
              btnColor = const Color(0xFFEFF6FF);
              textColor = const Color(0xFF2563EB);
              border = const BorderSide(color: Color(0xFF3B82F6), width: 1.5);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _cognitiveSolved ? null : () {
                    setState(() {
                      _selectedCognitiveChoice = choice;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    surfaceTintColor: Colors.transparent,
                    elevation: isSelected ? 1 : 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: border,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        choice,
                        style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      if (_cognitiveSolved && isCorrect)
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20)
                      else if (_cognitiveSolved && isSelected)
                        const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 20)
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),
        if (!_cognitiveSolved)
          ElevatedButton(
            onPressed: _selectedCognitiveChoice == null ? null : () {
              setState(() {
                _cognitiveSolved = true;
                if (_selectedCognitiveChoice == level['correct']) {
                  _triggerWin();
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              elevation: 2,
            ),
            child: Text(
              'Submit Answer 🤖',
              style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        else ...[
          // Explanation Card
          Container(
            padding: const EdgeInsets.all(14),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXPLANATION:',
                        style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF1D4ED8), letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        level['desc'] as String,
                        style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF1E3A8A), height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cognitiveSolved = false;
                _selectedCognitiveChoice = null;
                if (_currentCognitiveLevel + 1 < levels.length) {
                  _currentCognitiveLevel++;
                } else {
                  _currentCognitiveLevel = 0; // restart
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            child: Text(
              _currentCognitiveLevel + 1 < levels.length ? 'Next Cognitive Challenge' : 'Restart Cognitive Arena',
              style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ]
      ],
    );
  }

  // SYNTAX BLOCKS SUB-WIDGET (WITH MULTIPLE LEVELS)
  Widget _buildSyntaxBlocks() {
    final levels = _getSyntaxLevels();
    if (_currentSyntaxLevel >= levels.length) {
      _currentSyntaxLevel = 0;
    }
    final level = levels[_currentSyntaxLevel];
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
              style: AdyapanTheme.outfit(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AdyapanTheme.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(
                'Level ${_currentSyntaxLevel + 1}/${levels.length}',
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
                      const SnackBar(content: Text('🎉 Awesome Assemble! Code Compiled'), backgroundColor: AdyapanTheme.green),
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
                  if (_currentSyntaxLevel + 1 < levels.length) {
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
                _currentSyntaxLevel + 1 < levels.length ? 'Next Level' : 'Restart Syntax Blocks',
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
    final levels = _getUnscrambleLevels();
    if (_currentUnscrambleLevel >= levels.length) {
      _currentUnscrambleLevel = 0;
    }
    final level = levels[_currentUnscrambleLevel];
    final String targetWord = level['word'];
    final List<String> scrambled = List<String>.from(level['scrambled']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Word Unscramble 🔠', style: AdyapanTheme.fredoka(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      SnackBar(content: Text('🎉 Outstanding! You unscrambled "$targetWord" successfully!'), backgroundColor: AdyapanTheme.green),
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
                  if (_currentUnscrambleLevel + 1 < levels.length) {
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
                _currentUnscrambleLevel + 1 < levels.length ? 'Next Level' : 'Restart Brain Booster',
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

                // 3D Glassmorphic Class Selector Bar (Class 1 to 12)
                Container(
                  height: 40,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _classes.length,
                    itemBuilder: (context, index) {
                      final cls = _classes[index];
                      final isSelected = cls == _selectedClass;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedClass = cls;
                              // Reset active game states upon grade swapping
                              _currentQuizIdx = 0;
                              _selectedAnswerIdx = null;
                              _quizAnswered = false;
                              _currentCognitiveLevel = 0;
                              _cognitiveSolved = false;
                              _selectedCognitiveChoice = null;
                              _currentSyntaxLevel = 0;
                              _syntaxLevelCompleted = false;
                              _assembledSyntax.clear();
                              _currentUnscrambleLevel = 0;
                              _tappedLetterIndices.clear();
                              _unscrambleCompleted = false;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)])
                                  : LinearGradient(colors: [Colors.white.withOpacity(0.65), Colors.white.withOpacity(0.45)]),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? Colors.white.withOpacity(0.5) : const Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected ? const Color(0xFF2563EB).withOpacity(0.3) : Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cls,
                              style: GoogleFonts.fredoka(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Arcade Custom Navigation Tabs
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
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
                      Tab(text: 'Cognitive Arena'),
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
                      SingleChildScrollView(padding: const EdgeInsets.all(20), child: _buildCognitiveLogicArena()),
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
