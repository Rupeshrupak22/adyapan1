import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _initialized = false;
  bool get initialized => _initialized;

  // 1. User Profile Stats
  int _xp = 120;
  int _level = 1;
  int _streak = 3;
  String _avatar = '⚡';

  int get xp => _xp;
  int get level => _level;
  int get streak => _streak;
  String get avatar => _avatar;

  // 2. Todos
  List<Map<String, dynamic>> _todos = [];
  List<Map<String, dynamic>> get todos => _todos;

  // 3. Roadmap Nodes Progression
  Map<String, List<Map<String, dynamic>>> _roadmaps = {
    'Math': [
      {'id': 'm1', 'title': 'Arithmetic Basics', 'subtitle': 'BODMAS Foundations', 'status': 'completed', 'desc': 'Master the order of operations.'},
      {'id': 'm2', 'title': 'BODMAS Balancer', 'subtitle': 'Equation Balancing', 'status': 'unlocked', 'desc': 'Balance left and right equations using math symbols.'},
      {'id': 'm3', 'title': 'Fraction Arcade', 'subtitle': 'Division & Pieces', 'status': 'locked', 'desc': 'Break numbers down into pie charts and ratios.'},
      {'id': 'm4', 'title': 'Algebra Quest', 'subtitle': 'Find the Unknown X', 'status': 'locked', 'desc': 'Unmask the hidden variable in visual equations.'},
    ],
    'Science': [
      {'id': 's1', 'title': 'Solar System Orbit', 'subtitle': 'Planets & Gravity', 'status': 'completed', 'desc': 'Explore planetary velocities and orbits.'},
      {'id': 's2', 'title': 'Atomic Structure', 'subtitle': 'Electrons & Protons', 'status': 'unlocked', 'desc': 'Build elements on a shell diagram.'},
      {'id': 's3', 'title': 'Chemical Equations', 'subtitle': 'Reaction Balancer', 'status': 'locked', 'desc': 'Balance chemistry reactions visually.'},
    ]
  };

  Map<String, List<Map<String, dynamic>>> get roadmaps => _roadmaps;

  // 4. Analytics log (Study durations in minutes)
  List<int> _studySessions = [15, 25, 10, 30, 45, 20, 35];
  List<int> get studySessions => _studySessions;

  // 5. Parent Settings
  String _parentQuest = 'Read 2 chapters of Physics book';
  int _parentQuestXp = 150;
  bool _parentQuestCompleted = false;
  double _screenLimit = 60.0; // minutes allowed

  String get parentQuest => _parentQuest;
  int get parentQuestXp => _parentQuestXp;
  bool get parentQuestCompleted => _parentQuestCompleted;
  double get screenLimit => _screenLimit;

  AppState() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Load XP & Stats
    _xp = _prefs.getInt('xp') ?? 120;
    _level = _prefs.getInt('level') ?? 1;
    _streak = _prefs.getInt('streak') ?? 3;
    _avatar = _prefs.getString('avatar') ?? '⚡';

    // Load Todos
    final todosJson = _prefs.getString('todos');
    if (todosJson != null) {
      _todos = List<Map<String, dynamic>>.from(jsonDecode(todosJson));
    } else {
      // Default initial tasks
      _todos = [
        {'id': 1, 'title': 'Solve 5 Algebra Quizzes', 'tag': 'Math', 'completed': false},
        {'id': 2, 'title': 'Complete Atomic Shell Game', 'tag': 'Science', 'completed': true},
        {'id': 3, 'title': '25 Mins Focus Session', 'tag': 'Focus', 'completed': false},
      ];
      _saveTodos();
    }

    // Load Roadmaps Progress
    final roadmapJson = _prefs.getString('roadmaps');
    if (roadmapJson != null) {
      _roadmaps = Map<String, List<Map<String, dynamic>>>.from(
        (jsonDecode(roadmapJson) as Map).map(
          (k, v) => MapEntry(k as String, List<Map<String, dynamic>>.from(v)),
        ),
      );
    }

    // Load Analytics Logs
    final sessionsJson = _prefs.getString('study_sessions');
    if (sessionsJson != null) {
      _studySessions = List<int>.from(jsonDecode(sessionsJson));
    }

    // Load Parent Settings
    _parentQuest = _prefs.getString('parent_quest') ?? 'Read 2 chapters of Physics book';
    _parentQuestXp = _prefs.getInt('parent_quest_xp') ?? 150;
    _parentQuestCompleted = _prefs.getBool('parent_quest_completed') ?? false;
    _screenLimit = _prefs.getDouble('screen_limit') ?? 60.0;

    _initialized = true;
    notifyListeners();
  }

  // XP & Leveling Logic
  void addXp(int amount) {
    _xp += amount;
    // Every 200 XP levels up the user!
    int newLevel = (_xp / 200).floor() + 1;
    if (newLevel > _level) {
      _level = newLevel;
    }
    _prefs.setInt('xp', _xp);
    _prefs.setInt('level', _level);
    notifyListeners();
  }

  // Todo operations
  void toggleTodo(int id) {
    final index = _todos.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      final wasCompleted = _todos[index]['completed'];
      _todos[index]['completed'] = !wasCompleted;
      
      // If completed, reward 20 XP!
      if (!wasCompleted) {
        addXp(20);
      }
      _saveTodos();
      notifyListeners();
    }
  }

  void addTodo(String title, String tag) {
    int newId = _todos.isEmpty ? 1 : (_todos.map((t) => t['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
    _todos.add({'id': newId, 'title': title, 'tag': tag, 'completed': false});
    _saveTodos();
    notifyListeners();
  }

  void deleteTodo(int id) {
    _todos.removeWhere((t) => t['id'] == id);
    _saveTodos();
    notifyListeners();
  }

  void _saveTodos() {
    _prefs.setString('todos', jsonEncode(_todos));
  }

  // Roadmap Progress triggers
  void completeRoadmapNode(String subject, String nodeId) {
    final list = _roadmaps[subject];
    if (list != null) {
      final index = list.indexWhere((node) => node['id'] == nodeId);
      if (index != -1 && list[index]['status'] != 'completed') {
        list[index]['status'] = 'completed';
        
        // Add 50 XP on completion!
        addXp(50);

        // Unlock the next node
        if (index + 1 < list.length) {
          list[index + 1]['status'] = 'unlocked';
        }
        
        _prefs.setString('roadmaps', jsonEncode(_roadmaps));
        notifyListeners();
      }
    }
  }

  // Log study session
  void logStudySession(int minutes) {
    _studySessions.add(minutes);
    if (_studySessions.length > 7) {
      _studySessions.removeAt(0); // keep rolling 7 days
    }
    _prefs.setString('study_sessions', jsonEncode(_studySessions));
    addXp(minutes * 2); // 2 XP per minute of focus!
    notifyListeners();
  }

  // Parent configuration settings
  void setParentQuest(String title, int xp) {
    _parentQuest = title;
    _parentQuestXp = xp;
    _parentQuestCompleted = false;
    _prefs.setString('parent_quest', title);
    _prefs.setInt('parent_quest_xp', xp);
    _prefs.setBool('parent_quest_completed', false);
    notifyListeners();
  }

  void toggleParentQuest() {
    _parentQuestCompleted = !_parentQuestCompleted;
    if (_parentQuestCompleted) {
      addXp(_parentQuestXp);
    }
    _prefs.setBool('parent_quest_completed', _parentQuestCompleted);
    notifyListeners();
  }

  void updateScreenLimit(double minutes) {
    _screenLimit = minutes;
    _prefs.setDouble('screen_limit', minutes);
    notifyListeners();
  }
}
