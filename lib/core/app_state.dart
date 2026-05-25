import 'dart:convert';
import 'db_helper.dart';
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

  // User Profile Information
  String _studentName = 'Aarav Sharma';
  String _studentEmail = 'aarav.sharma@school.com';
  String _studentPhone = '9876543210';
  String _studentClass = 'Class 10';
  String _studentSchool = 'Adyapan Public School';
  String _profileImagePath = '';

  int get xp => _xp;
  int get level => _level;
  int get streak => _streak;
  String get avatar => _avatar;

  String get studentName => _studentName;
  String get studentEmail => _studentEmail;
  String get studentPhone => _studentPhone;
  String get studentClass => _studentClass;
  String get studentSchool => _studentSchool;
  String get profileImagePath => _profileImagePath;

  // 1b. Reactive Bottom Bar Tab Index
  int _currentTab = 0;
  int get currentTab => _currentTab;

  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

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

  // 5b. Auth Database & Session
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Map<String, String> _userCredentials = {};
  Map<String, String> get userCredentials => _userCredentials;

  // 6. Attendance Logs
  List<Map<String, dynamic>> _attendanceLogs = [];
  List<Map<String, dynamic>> get attendanceLogs => _attendanceLogs;

  // 8. Homework List (teacher-assigned)
  List<Map<String, dynamic>> _homeworkList = [];
  List<Map<String, dynamic>> get homeworkList => _homeworkList;

  int get pendingHomeworkCount => _homeworkList.where((h) => h['submitted'] == false).length;
  int get submittedHomeworkCount => _homeworkList.where((h) => h['submitted'] == true).length;

  // 9. Notes / PDF Library (teacher-uploaded)
  List<Map<String, dynamic>> _notesList = [];
  List<Map<String, dynamic>> get notesList => _notesList;

  // 7. Completed Quizzes Progress & Syllabus Getters
  int _completedQuizzesCount = 4;
  int get completedQuizzesCount => _completedQuizzesCount;

  double get mathSyllabusProgress {
    final list = _roadmaps['Math'];
    if (list == null || list.isEmpty) return 50.0;
    int completed = list.where((node) => node['status'] == 'completed').length;
    return (((completed + (_completedQuizzesCount >= 2 ? 2 : 1)) / (list.length + 2)) * 100.0).clamp(0.0, 100.0);
  }

  double get scienceSyllabusProgress {
    final list = _roadmaps['Science'];
    if (list == null || list.isEmpty) return 40.0;
    int completed = list.where((node) => node['status'] == 'completed').length;
    return (((completed + (_completedQuizzesCount >= 4 ? 2 : 1)) / (list.length + 2)) * 100.0).clamp(0.0, 100.0);
  }

  double get englishSyllabusProgress {
    return ((_completedQuizzesCount * 12.0) + 20.0).clamp(0.0, 100.0);
  }

  double get overallSyllabusProgress {
    return (mathSyllabusProgress + scienceSyllabusProgress + englishSyllabusProgress) / 3.0;
  }

  void incrementCompletedQuizzes() {
    _completedQuizzesCount++;
    _prefs.setInt('completed_quizzes_count', _completedQuizzesCount);
    addXp(25); // ✅ Only games give XP!
    notifyListeners();
  }


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

    // Load Profile Information
    _studentName = _prefs.getString('student_name') ?? 'Aarav Sharma';
    _studentEmail = _prefs.getString('student_email') ?? 'aarav.sharma@gmail.com';
    _studentPhone = _prefs.getString('student_phone') ?? '9876543210';
    _studentClass = _prefs.getString('student_class') ?? 'Class 10';
    _studentSchool = _prefs.getString('student_school') ?? 'Adyapan Public School';
    _profileImagePath = _prefs.getString('profile_image_path') ?? '';
    _completedQuizzesCount = _prefs.getInt('completed_quizzes_count') ?? 4;

    // Load Auth Database & Session
    _isLoggedIn = _prefs.getBool('is_logged_in') ?? false;
    final credsJson = _prefs.getString('user_credentials');
    if (credsJson != null) {
      _userCredentials = Map<String, String>.from(jsonDecode(credsJson));
    } else {
      _userCredentials = {
        'aarav.sharma@gmail.com': 'password123',
      };
      _saveCredentials();
    }

    // Load Attendance Logs
    final attendanceJson = _prefs.getString('attendance_logs');
    if (attendanceJson != null) {
      _attendanceLogs = List<Map<String, dynamic>>.from(jsonDecode(attendanceJson));
    } else {
      _attendanceLogs = [
        {'subject': '📐 Mathematics', 'status': 'Present', 'time': '10:30 AM', 'source': 'Live Class'},
        {'subject': '⚛️ Science', 'status': 'Present', 'time': '11:45 AM', 'source': 'Live Class'},
        {'subject': '📖 English', 'status': 'Present', 'time': '01:30 PM', 'source': 'Recorded Video'},
        {'subject': '🌍 Social Studies', 'status': 'Excused', 'time': '02:45 PM', 'source': 'Manual'},
      ];
      _saveAttendance();
    }

    // Load Homework List
    final homeworkJson = _prefs.getString('homework_list');
    if (homeworkJson != null) {
      _homeworkList = List<Map<String, dynamic>>.from(jsonDecode(homeworkJson));
    } else {
      _homeworkList = [
        {
          'id': 1,
          'title': 'Quadratic Equations',
          'subject': '📐 Mathematics',
          'description': 'Solve problems 1-15 from Chapter 4. Show all steps clearly.',
          'dueDate': 'Today',
          'priority': 'High',
          'submitted': false,
          'submittedAt': null,
          'addedBy': 'Mrs. Sharma',
        },
        {
          'id': 2,
          'title': 'Atomic Orbitals Diagram',
          'subject': '⚛️ Science',
          'description': 'Draw and label the first 4 atomic orbitals. Include electron configuration.',
          'dueDate': 'Tomorrow',
          'priority': 'Medium',
          'submitted': false,
          'submittedAt': null,
          'addedBy': 'Mr. Verma',
        },
        {
          'id': 3,
          'title': 'Essay on Climate Change',
          'subject': '📖 English',
          'description': 'Write a 500-word essay on climate change and its impact on future generations.',
          'dueDate': 'In 3 days',
          'priority': 'Normal',
          'submitted': false,
          'submittedAt': null,
          'addedBy': 'Miss Anjali',
        },
        {
          'id': 4,
          'title': 'Map Labeling - Rivers of India',
          'subject': '🌍 Social Studies',
          'description': 'Label all major rivers of India on the outline map provided.',
          'dueDate': 'In 5 days',
          'priority': 'Normal',
          'submitted': true,
          'submittedAt': 'Yesterday, 4:30 PM',
          'addedBy': 'Mr. Kapoor',
        },
      ];
      _saveHomework();
    }

    // Load Notes / PDF Library
    final notesJson = _prefs.getString('notes_list');
    if (notesJson != null) {
      _notesList = List<Map<String, dynamic>>.from(jsonDecode(notesJson));
    } else {
      _notesList = [
        {
          'id': 1,
          'title': 'BODMAS & Order of Operations',
          'subject': '📐 Mathematics',
          'description': 'Complete notes on BODMAS rules, solved examples, and practice problems.',
          'fileName': 'BODMAS_Notes.pdf',
          'fileSize': '1.2 MB',
          'pages': 12,
          'uploadedBy': 'Mrs. Sharma',
          'uploadedAt': 'Today',
          'type': 'PDF',
          'filePath': '', // real path filled when backend is added
        },
        {
          'id': 2,
          'title': 'Atomic Structure & Periodic Table',
          'subject': '⚛️ Science',
          'description': 'Detailed notes on atomic orbitals, electron configuration, and periodic trends.',
          'fileName': 'Atomic_Structure.pdf',
          'fileSize': '3.4 MB',
          'pages': 24,
          'uploadedBy': 'Mr. Verma',
          'uploadedAt': 'Yesterday',
          'type': 'PDF',
          'filePath': '',
        },
        {
          'id': 3,
          'title': 'English Grammar – Active & Passive Voice',
          'subject': '📖 English',
          'description': 'Rules, examples, and exercises for transforming active voice to passive voice.',
          'fileName': 'Grammar_Voice.pdf',
          'fileSize': '0.8 MB',
          'pages': 8,
          'uploadedBy': 'Miss Anjali',
          'uploadedAt': '2 days ago',
          'type': 'PDF',
          'filePath': '',
        },
        {
          'id': 4,
          'title': 'Python Syntax Cheat Sheet',
          'subject': '💻 Computer Science',
          'description': 'Quick reference for Python syntax, built-in functions, and common patterns.',
          'fileName': 'Python_CheatSheet.pdf',
          'fileSize': '0.6 MB',
          'pages': 5,
          'uploadedBy': 'Mr. Kapoor',
          'uploadedAt': '3 days ago',
          'type': 'PDF',
          'filePath': '',
        },
        {
          'id': 5,
          'title': 'Quadratic Equations – Full Chapter',
          'subject': '📐 Mathematics',
          'description': 'Complete chapter notes including derivation of quadratic formula and graph sketching.',
          'fileName': 'Quadratic_Equations.pdf',
          'fileSize': '2.1 MB',
          'pages': 18,
          'uploadedBy': 'Mrs. Sharma',
          'uploadedAt': '1 week ago',
          'type': 'PDF',
          'filePath': '',
        },
      ];
      _saveNotes();
    }

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
      _todos[index]['completed'] = !_todos[index]['completed'];
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
      _studySessions.removeAt(0);
    }
    _prefs.setString('study_sessions', jsonEncode(_studySessions));
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
    _prefs.setBool('parent_quest_completed', _parentQuestCompleted);
    notifyListeners();
  }

  void updateScreenLimit(double minutes) {
    _screenLimit = minutes;
    _prefs.setDouble('screen_limit', minutes);
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String email,
    required String phone,
    required String className,
    required String school,
    String? imagePath,
  }) {
    _studentName = name;
    _studentEmail = email;
    _studentPhone = phone;
    _studentClass = className;
    _studentSchool = school;
    if (imagePath != null) {
      _profileImagePath = imagePath;
    }
    
    _prefs.setString('student_name', _studentName);
    _prefs.setString('student_email', _studentEmail);
    _prefs.setString('student_phone', _studentPhone);
    _prefs.setString('student_class', _studentClass);
    _prefs.setString('student_school', _studentSchool);
    if (imagePath != null) {
      _prefs.setString('profile_image_path', _profileImagePath);
    }
    
    notifyListeners();
  }

  void updateProfileImage(String path) {
    _profileImagePath = path;
    _prefs.setString('profile_image_path', path);
    notifyListeners();
  }

  // Session & Auth Registry helpers
  void _saveCredentials() {
    _prefs.setString('user_credentials', jsonEncode(_userCredentials));
  }

  void login() {
    _isLoggedIn = true;
    _prefs.setBool('is_logged_in', true);
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _prefs.setBool('is_logged_in', false);
    notifyListeners();
  }

  // Validate credentials against remote TiDB Database strictly (no local fallbacks)
  Future<bool> loginUser(String email, String password) async {
    try {
      final user = await DbHelper.loginUser(email, password);
      if (user == null) {
        return false;
      }
      
      // Update local profile state
      _studentName = user['name'];
      _studentEmail = user['email'];
      _studentPhone = user['phone'];
      _studentClass = user['className'];
      _studentSchool = user['school'];
      
      _prefs.setString('student_name', _studentName);
      _prefs.setString('student_email', _studentEmail);
      _prefs.setString('student_phone', _studentPhone);
      _prefs.setString('student_class', _studentClass);
      _prefs.setString('student_school', _studentSchool);
      
      _isLoggedIn = true;
      _prefs.setBool('is_logged_in', true);
      notifyListeners();
      
      return true;
    } catch (e) {
      print('❌ Database login strictly failed: $e');
      // Rethrow to let the UI catch and display the exact database connection error!
      throw Exception('Database Connection Error: $e');
    }
  }

  // Register a new user in remote TiDB Database strictly (no local fallbacks)
  Future<bool> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String className,
    required String school,
  }) async {
    try {
      final success = await DbHelper.registerUser(
        name: name,
        email: email,
        phone: phone,
        className: className,
        school: school,
        password: password,
      );

      if (!success) return false;

      updateProfile(
        name: name,
        email: email,
        phone: phone,
        className: className,
        school: school,
      );

      return true;
    } catch (e) {
      print('❌ Database registration strictly failed: $e');
      // Rethrow to let the UI catch and display the exact database connection error!
      throw Exception('Database Connection Error: $e');
    }
  }

  // Attendance Persistence helpers
  void _saveAttendance() {
    _prefs.setString('attendance_logs', jsonEncode(_attendanceLogs));
  }

  void markAttendance(String subject, String status, String time, {String source = 'Manual'}) {
    final index = _attendanceLogs.indexWhere((log) => log['subject'].trim().toLowerCase() == subject.trim().toLowerCase());
    if (index != -1) {
      _attendanceLogs[index]['status'] = status;
      _attendanceLogs[index]['time'] = time;
      _attendanceLogs[index]['source'] = source;
    } else {
      _attendanceLogs.add({
        'subject': subject,
        'status': status,
        'time': time,
        'source': source,
      });
    }
    _saveAttendance();
    notifyListeners();
  }

  // ── HOMEWORK MANAGEMENT ──
  void _saveHomework() {
    _prefs.setString('homework_list', jsonEncode(_homeworkList));
  }

  // Teacher adds homework
  void addHomework({
    required String title,
    required String subject,
    required String description,
    required String dueDate,
    required String priority,
    required String addedBy,
  }) {
    final newId = _homeworkList.isEmpty
        ? 1
        : (_homeworkList.map((h) => h['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
    _homeworkList.insert(0, {
      'id': newId,
      'title': title,
      'subject': subject,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'submitted': false,
      'submittedAt': null,
      'addedBy': addedBy,
    });
    _saveHomework();
    notifyListeners();
  }

  // Student submits homework
  bool submitHomework(int id) {
    final index = _homeworkList.indexWhere((h) => h['id'] == id);
    if (index == -1 || _homeworkList[index]['submitted'] == true) return false;
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final min = now.minute < 10 ? '0${now.minute}' : '${now.minute}';
    _homeworkList[index]['submitted'] = true;
    _homeworkList[index]['submittedAt'] = 'Today, $hour:$min $ampm';
    _saveHomework();
    notifyListeners();
    return true;
  }

  // Teacher deletes homework
  void deleteHomework(int id) {
    _homeworkList.removeWhere((h) => h['id'] == id);
    _saveHomework();
    notifyListeners();
  }

  // ── NOTES / PDF LIBRARY ──
  void _saveNotes() {
    _prefs.setString('notes_list', jsonEncode(_notesList));
  }

  // Teacher adds a note/PDF
  void addNote({
    required String title,
    required String subject,
    required String description,
    required String fileName,
    required String fileSize,
    required int pages,
    required String uploadedBy,
    String filePath = '',
  }) {
    final newId = _notesList.isEmpty
        ? 1
        : (_notesList.map((n) => n['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
    _notesList.insert(0, {
      'id': newId,
      'title': title,
      'subject': subject,
      'description': description,
      'fileName': fileName,
      'fileSize': fileSize,
      'pages': pages,
      'uploadedBy': uploadedBy,
      'uploadedAt': 'Just now',
      'type': 'PDF',
      'filePath': filePath,
    });
    _saveNotes();
    notifyListeners();
  }

  // Teacher deletes a note
  void deleteNote(int id) {
    _notesList.removeWhere((n) => n['id'] == id);
    _saveNotes();
    notifyListeners();
  }
}

