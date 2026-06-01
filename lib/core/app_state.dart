import 'dart:convert';
import 'db_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _initialized = false;
  bool get initialized => _initialized;

  // Live Class Join Session persistence
  String? _liveClassJoinSubject;
  String? _liveClassJoinTime;
  String? _liveClassJoinClickTime;
  int? _liveClassJoinDurationMinutes;
  bool _isLiveClassJoinSessionActive = false;

  String? get liveClassJoinSubject => _liveClassJoinSubject;
  String? get liveClassJoinTime => _liveClassJoinTime;
  String? get liveClassJoinClickTime => _liveClassJoinClickTime;
  int? get liveClassJoinDurationMinutes => _liveClassJoinDurationMinutes;
  bool get isLiveClassJoinSessionActive => _isLiveClassJoinSessionActive;

  // 1. User Profile Stats
  int _xp = 120;
  int _level = 1;
  int _streak = 3;
  String _avatar = '⚡';

  // User Profile Information
  String _studentName = '';
  String _studentEmail = '';
  String _studentPhone = '';
  String _studentClass = '';
  String _studentSchool = '';
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

  Map<String, List<Map<String, dynamic>>> get roadmaps {
    final keys = ['Math', 'Science', 'English', 'PhyChemBio', 'AccBstEco', 'Humanities', 'SocialScience9', 'SocialScience6'];
    for (final key in keys) {
      if (!_roadmaps.containsKey(key)) {
        if (key.contains('Math')) {
          _roadmaps[key] = [
            {'id': 'm1', 'title': 'Arithmetic Basics', 'subtitle': 'BODMAS Foundations', 'status': 'completed', 'desc': 'Master the order of operations.'},
            {'id': 'm2', 'title': 'BODMAS Balancer', 'subtitle': 'Equation Balancing', 'status': 'unlocked', 'desc': 'Balance left and right equations using math symbols.'},
            {'id': 'm3', 'title': 'Fraction Arcade', 'subtitle': 'Division & Pieces', 'status': 'locked', 'desc': 'Break numbers down into pie charts and ratios.'},
            {'id': 'm4', 'title': 'Algebra Quest', 'subtitle': 'Find the Unknown X', 'status': 'locked', 'desc': 'Unmask the hidden variable in visual equations.'},
          ];
        } else if (key.contains('Science') || key == 'PhyChemBio') {
          _roadmaps[key] = [
            {'id': 's1', 'title': 'Atomic Structure', 'subtitle': 'Planets & Particles', 'status': 'completed', 'desc': 'Explore structure and properties.'},
            {'id': 's2', 'title': 'Chemical Equations', 'subtitle': 'Reaction Balancer', 'status': 'unlocked', 'desc': 'Balance chemistry reactions visually.'},
            {'id': 's3', 'title': 'Organic Chemistry', 'subtitle': 'Carbon Chains', 'status': 'locked', 'desc': 'Understand functional groups and carbon bonding.'},
          ];
        } else if (key.contains('Social')) {
          _roadmaps[key] = [
            {'id': 'h1', 'title': 'Global History & Geography', 'subtitle': 'Mapping & Trade', 'status': 'completed', 'desc': 'Trace historically significant trade routes.'},
            {'id': 'h2', 'title': 'Civic Rights & Systems', 'subtitle': 'Democratic Organs', 'status': 'unlocked', 'desc': 'Analyze democratic frameworks and governance structures.'},
            {'id': 'h3', 'title': 'Economic Frameworks', 'subtitle': 'Supply & Demands', 'status': 'locked', 'desc': 'Learn concepts of resource allocation.'},
          ];
        } else {
          _roadmaps[key] = [
            {'id': 'x1', 'title': 'Core Theories', 'subtitle': 'Conceptual Foundations', 'status': 'completed', 'desc': 'Read core concepts and fundamental rules.'},
            {'id': 'x2', 'title': 'Practical Application', 'subtitle': 'Interactive Scenarios', 'status': 'unlocked', 'desc': 'Solve live scenarios and case studies.'},
            {'id': 'x3', 'title': 'Advanced Capstone', 'subtitle': 'Expert Worksheets', 'status': 'locked', 'desc': 'Complete complex test tasks.'},
          ];
        }
      }
    }
    return _roadmaps;
  }

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

  String _userId = '';
  String get userId => _userId;

  String _userRole = 'student';
  String get userRole => _userRole;

  String _teacherId = '';
  String get teacherId => _teacherId;

  List<Map<String, dynamic>> _linkedStudents = [];
  List<Map<String, dynamic>> get linkedStudents => _linkedStudents;

  List<Map<String, dynamic>> _customQuizQuestions = [];
  List<Map<String, dynamic>> get customQuizQuestions => _customQuizQuestions;

  Map<String, String> _userCredentials = {};
  Map<String, String> get userCredentials => _userCredentials;

  List<Map<String, dynamic>> _customCognitiveLevels = [];
  List<Map<String, dynamic>> get customCognitiveLevels => _customCognitiveLevels;

  List<Map<String, dynamic>> _customSyntaxLevels = [];
  List<Map<String, dynamic>> get customSyntaxLevels => _customSyntaxLevels;

  List<Map<String, dynamic>> _customUnscrambleLevels = [];
  List<Map<String, dynamic>> get customUnscrambleLevels => _customUnscrambleLevels;

  List<Map<String, dynamic>> _recordedLectures = [];
  List<Map<String, dynamic>> get recordedLectures => _recordedLectures;

  List<Map<String, dynamic>> _teacherMessages = [];
  List<Map<String, dynamic>> get teacherMessages => _teacherMessages;

  List<Map<String, dynamic>> _teacherFeedbacks = [];
  List<Map<String, dynamic>> get teacherFeedbacks => _teacherFeedbacks;

  int _studentRank = 4;
  int get studentRank => _studentRank;

  // 6. Attendance Logs
  List<Map<String, dynamic>> _attendanceLogs = [];
  List<Map<String, dynamic>> get attendanceLogs => _attendanceLogs;

  // 8. Homework List (teacher-assigned)
  List<Map<String, dynamic>> _homeworkList = [];
  List<Map<String, dynamic>> get homeworkList => _homeworkList;

  // 8b. Teacher homework submissions list
  List<Map<String, dynamic>> _teacherSubmissions = [];
  List<Map<String, dynamic>> get teacherSubmissions => _teacherSubmissions;

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
    _studentName = _prefs.getString('student_name') ?? '';
    _studentEmail = _prefs.getString('student_email') ?? '';
    _studentPhone = _prefs.getString('student_phone') ?? '';
    _studentClass = _prefs.getString('student_class') ?? '';
    _studentSchool = _prefs.getString('student_school') ?? '';
    _profileImagePath = _prefs.getString('profile_image_path') ?? '';
    _completedQuizzesCount = _prefs.getInt('completed_quizzes_count') ?? 4;

    // Load Auth Database & Session
    _isLoggedIn = _prefs.getBool('is_logged_in') ?? false;
    _userRole = _prefs.getString('user_role') ?? 'student';
    _teacherId = _prefs.getString('teacher_id') ?? '';
    _userId = _prefs.getString('user_id') ?? '';
    final customQsJson = _prefs.getString('custom_quiz_questions');
    if (customQsJson != null) {
      _customQuizQuestions = List<Map<String, dynamic>>.from(jsonDecode(customQsJson));
    }
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
      _attendanceLogs = [];
      _saveAttendance();
    }

    // Load Homework List
    final homeworkJson = _prefs.getString('homework_list');
    if (homeworkJson != null) {
      _homeworkList = List<Map<String, dynamic>>.from(jsonDecode(homeworkJson));
    } else {
      _homeworkList = [];
      _saveHomework();
    }

    // Load Notes / PDF Library
    final notesJson = _prefs.getString('notes_list');
    if (notesJson != null) {
      _notesList = List<Map<String, dynamic>>.from(jsonDecode(notesJson));
    } else {
      _notesList = [];
      _saveNotes();
    }

    // Load Custom Cognitive Levels
    final customCognitiveJson = _prefs.getString('custom_cognitive_levels');
    if (customCognitiveJson != null) {
      _customCognitiveLevels = List<Map<String, dynamic>>.from(jsonDecode(customCognitiveJson));
    }
    
    // Load Custom Syntax Levels
    final customSyntaxJson = _prefs.getString('custom_syntax_levels');
    if (customSyntaxJson != null) {
      _customSyntaxLevels = List<Map<String, dynamic>>.from(jsonDecode(customSyntaxJson));
    }
    
    // Load Custom Unscramble Levels
    final customUnscrambleJson = _prefs.getString('custom_unscramble_levels');
    if (customUnscrambleJson != null) {
      _customUnscrambleLevels = List<Map<String, dynamic>>.from(jsonDecode(customUnscrambleJson));
    }

    // Load Recorded Lectures
    final recordedJson = _prefs.getString('recorded_lectures');
    if (recordedJson != null) {
      _recordedLectures = List<Map<String, dynamic>>.from(jsonDecode(recordedJson));
    } else {
      _recordedLectures = [
        {
          'title': 'BODMAS Foundations & Algebra',
          'duration': 'Recorded • 45 mins',
          'teacher': 'Mrs. Sharma',
          'emoji': '📐',
        },
        {
          'title': 'Solar System Orbit & Velocities',
          'duration': 'Recorded • 50 mins',
          'teacher': 'Mr. Verma',
          'emoji': '⚛️',
        },
        {
          'title': 'Active and Passive Voice Rules',
          'duration': 'Recorded • 40 mins',
          'teacher': 'Miss Anjali',
          'emoji': '📖',
        },
      ];
      _saveRecordedLectures();
    }

    // Load Teacher Messages
    final messagesJson = _prefs.getString('teacher_messages');
    if (messagesJson != null) {
      _teacherMessages = List<Map<String, dynamic>>.from(jsonDecode(messagesJson));
    } else {
      _teacherMessages = [
        {
          'id': 'msg_01',
          'studentName': 'Aarav Sharma',
          'teacherName': 'Mrs. Aarushi Sharma (Maths HOD)',
          'message': 'Dear Parents, Aarav has shown great performance in BODMAS balancing, but we have scheduled a Parents-Teacher Meeting (PTM) for this Friday at 3:00 PM to discuss the upcoming calculus roadmap. Please accept/confirm if you will be attending.',
          'category': 'Meeting Request',
          'isRead': false,
          'date': 'Today',
          'meetingResponse': '',
        },
        {
          'id': 'msg_02',
          'studentName': 'Aarav Sharma',
          'teacherName': 'Mr. Ramesh Verma (Science Head)',
          'message': 'Weekly Alert: Aarav completed the Physics Orbitals modules successfully! He gained +80 XP. However, his daily screen limit on study games should be regulated to 90 mins to maintain balanced health. Focus shield status: Optimal.',
          'category': 'Syllabus Alert',
          'isRead': true,
          'date': 'Yesterday',
          'meetingResponse': '',
        },
        {
          'id': 'msg_03',
          'studentName': 'Aarav Sharma',
          'teacherName': 'Adyapan Smart System',
          'message': 'System Notice: Focus Zen Master Rank badge has been unlocked for Aarav Sharma! Daily average study efficiency is currently at 78% which is outstanding.',
          'category': 'Notice',
          'isRead': true,
          'date': '2 days ago',
          'meetingResponse': '',
        },
      ];
      _saveTeacherMessages();
    }

    // Load Doubts
    final doubtsJson = _prefs.getString('doubts');
    if (doubtsJson != null) {
      _doubts = List<Map<String, dynamic>>.from(jsonDecode(doubtsJson));
    } else {
      _doubts = [];
      _saveDoubts();
    }

    // Load Study Schedules
    final schedulesJson = _prefs.getString('study_schedules');
    if (schedulesJson != null) {
      _studySchedules = List<Map<String, dynamic>>.from(jsonDecode(schedulesJson));
    } else {
      _studySchedules = [
        {
          'id': 'sched_1',
          'title': 'Evening Homework Focus',
          'start': '17:00',
          'end': '19:00',
          'isActive': true,
        },
        {
          'id': 'sched_2',
          'title': 'Morning Revision Lock',
          'start': '08:00',
          'end': '09:00',
          'isActive': false,
        }
      ];
      _saveStudySchedules();
    }

    // Load Live Classes Schedule
    final liveJson = _prefs.getString('live_classes_schedule');
    if (liveJson != null) {
      _liveClassesSchedule = List<Map<String, dynamic>>.from(jsonDecode(liveJson));
    } else {
      _liveClassesSchedule = [];
      _saveLiveClassesSchedule();
    }

    // Load Teacher Feedbacks
    final feedbacksJson = _prefs.getString('teacher_feedbacks');
    if (feedbacksJson != null) {
      _teacherFeedbacks = List<Map<String, dynamic>>.from(jsonDecode(feedbacksJson));
    } else {
      _teacherFeedbacks = [
        {
          'teacherName': 'Mrs. Sharma',
          'subjectName': 'Mathematics',
          'lectureTitle': 'Classroom Session',
          'rating': 5.0,
          'tags': ['Clear Explanations', 'Fun Activities'],
          'comments': 'Great class! Loved the puzzle.',
          'timestamp': DateTime.now().toIso8601String(),
        }
      ];
      _saveTeacherFeedbacks();
    }

    _liveClassJoinSubject = _prefs.getString('live_class_join_subject');
    _liveClassJoinTime = _prefs.getString('live_class_join_time');
    _liveClassJoinClickTime = _prefs.getString('live_class_join_click_time');
    _liveClassJoinDurationMinutes = _prefs.getInt('live_class_join_duration_minutes');
    _isLiveClassJoinSessionActive = _prefs.getBool('live_class_join_session_active') ?? false;

    _parentPin = _prefs.getString('parent_pin') ?? '1234';
    _deviceFrozen = _prefs.getBool('device_frozen') ?? false;

    await _resolveTeacherIdAndSync();

    _initialized = true;
    notifyListeners();

    if (_isLoggedIn) {
      if (_studentEmail.isNotEmpty) {
        _fetchProfileDetailsFromDb(_studentEmail, _userRole);
        syncHomeworkAndNotesFromDb();
        syncSyllabusAndGamesFromDb();
        syncDoubtsFromDb();
        syncTeacherMessagesFromDb();
        syncLiveClassesFromDb();
        syncRecordedLecturesFromDb();
      }
      if (_userRole == 'student') {
        syncAttendanceFromDb();
      } else if (_userRole == 'teacher') {
        fetchLinkedStudents();
        syncTeacherSubmissionsFromDb();
      }
    }
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
      
      _userRole = user['role'] ?? 'student';
      _teacherId = user['teacher_id'] ?? '';
      _userId = user['id'] ?? '';
      
      _prefs.setString('student_name', _studentName);
      _prefs.setString('student_email', _studentEmail);
      _prefs.setString('student_phone', _studentPhone);
      _prefs.setString('student_class', _studentClass);
      _prefs.setString('student_school', _studentSchool);
      _prefs.setString('user_role', _userRole);
      _prefs.setString('teacher_id', _teacherId);
      _prefs.setString('user_id', _userId);
      
      _isLoggedIn = true;
      _prefs.setBool('is_logged_in', true);
      
      if (_userRole == 'teacher') {
        await fetchLinkedStudents();
        await syncTeacherSubmissionsFromDb();
        await syncDoubtsFromDb();
        await syncTeacherMessagesFromDb();
        await syncLiveClassesFromDb();
        await syncRecordedLecturesFromDb();
      } else {
        await syncAttendanceFromDb();
        await syncDoubtsFromDb();
        await syncTeacherMessagesFromDb();
        await syncLiveClassesFromDb();
        await syncRecordedLecturesFromDb();
      }
      await syncHomeworkAndNotesFromDb();
      await syncSyllabusAndGamesFromDb();
      
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
    required String role,
    String? teacherId,
  }) async {
    try {
      final success = await DbHelper.registerUser(
        name: name,
        email: email,
        phone: phone,
        className: className,
        school: school,
        password: password,
        role: role,
        teacherId: teacherId,
      );

      if (!success) return false;

      _userRole = role;
      _teacherId = teacherId ?? '';
      _prefs.setString('user_role', _userRole);
      _prefs.setString('teacher_id', _teacherId);

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

    if (_userId.isNotEmpty) {
      DbHelper.insertOrUpdateAttendance(
        userId: _userId,
        subject: subject,
        status: status,
        time: time,
        source: source,
      ).then((success) {
        if (success) {
          print('✅ Synchronized attendance marking to cloud database!');
        }
      });
    }
  }

  Future<void> syncAttendanceFromDb() async {
    if (_userId.isEmpty) return;
    try {
      final dbLogs = await DbHelper.fetchAttendanceLogs(_userId);
      if (dbLogs.isNotEmpty) {
        _attendanceLogs = dbLogs;
        _saveAttendance();
        notifyListeners();
      } else {
        // If database logs are empty but we have local logs (or default logs), push them to the database!
        if (_attendanceLogs.isNotEmpty) {
          for (final log in _attendanceLogs) {
            await DbHelper.insertOrUpdateAttendance(
              userId: _userId,
              subject: log['subject'] ?? '',
              status: log['status'] ?? '',
              time: log['time'] ?? '',
              source: log['source'] ?? '',
            );
          }
          final fetched = await DbHelper.fetchAttendanceLogs(_userId);
          if (fetched.isNotEmpty) {
            _attendanceLogs = fetched;
            _saveAttendance();
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print('❌ Failed to sync attendance from database: $e');
    }
  }

  Future<bool> markStudentAttendanceByTeacher({
    required String studentId,
    required String subject,
    required String status,
    required String time,
    required String source,
  }) async {
    try {
      final success = await DbHelper.insertOrUpdateAttendance(
        userId: studentId,
        subject: subject,
        status: status,
        time: time,
        source: source,
      );
      if (success) {
        if (_userId == studentId) {
          await syncAttendanceFromDb();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Failed to mark student attendance by teacher: $e');
      return false;
    }
  }

  // ── HOMEWORK MANAGEMENT ──
  void _saveHomework() {
    _prefs.setString('homework_list', jsonEncode(_homeworkList));
  }

  // Teacher adds homework
  Future<void> addHomework({
    required String title,
    required String subject,
    required String description,
    required String dueDate,
    required String priority,
    required String addedBy,
    String? fileName,
    String? filePath,
  }) async {
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
      'fileName': fileName,
      'filePath': filePath,
    });
    _saveHomework();
    notifyListeners();

    try {
      final dbId = await DbHelper.addHomework(
        title: title,
        subject: subject,
        description: description,
        dueDate: dueDate,
        priority: priority,
        addedBy: addedBy,
        teacherId: _teacherId.isNotEmpty ? _teacherId : 'teacher_mps8yshu_48f5p2',
        classLevel: _studentClass,
      );
      if (dbId > 0) {
        _homeworkList[0]['id'] = dbId;
        _saveHomework();
        notifyListeners();
      }
    } catch (e) {
      print('⚠️ Failed to sync homework to cloud database: $e');
    }
  }

  // Student submits homework
  Future<bool> submitHomework(
    int id, {
    String? fileName,
    String? filePath,
    String? studentComment,
  }) async {
    final index = _homeworkList.indexWhere((h) => h['id'] == id);
    if (index == -1 || _homeworkList[index]['submitted'] == true) return false;
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final min = now.minute < 10 ? '0${now.minute}' : '${now.minute}';
    final submittedAt = 'Today, $hour:$min $ampm';

    _homeworkList[index]['submitted'] = true;
    _homeworkList[index]['submittedAt'] = submittedAt;
    _homeworkList[index]['fileName'] = fileName;
    _homeworkList[index]['filePath'] = filePath;
    _homeworkList[index]['studentComment'] = studentComment;
    _saveHomework();
    notifyListeners();

    try {
      await DbHelper.submitHomework(
        homeworkId: id,
        studentEmail: _studentEmail,
        studentName: _studentName,
        submittedAt: submittedAt,
        fileName: fileName,
        filePath: filePath,
        studentComment: studentComment,
      );
      print('✅ Homework $id submission synced successfully to cloud database!');
    } catch (e) {
      print('⚠️ Failed to sync homework submission to cloud database: $e');
    }
    return true;
  }

  // Teacher deletes homework
  void deleteHomework(int id) {
    _homeworkList.removeWhere((h) => h['id'] == id);
    _saveHomework();
    notifyListeners();

    try {
      DbHelper.deleteHomework(id);
    } catch (e) {
      print('⚠️ Failed to delete homework from cloud database: $e');
    }
  }

  // ── NOTES / PDF LIBRARY ──
  void _saveNotes() {
    _prefs.setString('notes_list', jsonEncode(_notesList));
  }

  // Teacher adds a note/PDF
  Future<void> addNote({
    required String title,
    required String subject,
    required String description,
    required String fileName,
    required String fileSize,
    required int pages,
    required String uploadedBy,
    String filePath = '',
  }) async {
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

    try {
      final dbId = await DbHelper.addNote(
        title: title,
        subject: subject,
        description: description,
        fileName: fileName,
        fileSize: fileSize,
        pages: pages,
        uploadedBy: uploadedBy,
        teacherId: _teacherId.isNotEmpty ? _teacherId : 'teacher_mps8yshu_48f5p2',
      );
      if (dbId > 0) {
        _notesList[0]['id'] = dbId;
        _saveNotes();
        notifyListeners();
      }
    } catch (e) {
      print('⚠️ Failed to sync note to cloud database: $e');
    }
  }

  // Teacher deletes a note
  void deleteNote(int id) {
    _notesList.removeWhere((n) => n['id'] == id);
    _saveNotes();
    notifyListeners();

    try {
      DbHelper.deleteNote(id);
    } catch (e) {
      print('⚠️ Failed to delete note from cloud database: $e');
    }
  }

  // Fetch list of students linked to a specific teacher
  Future<void> fetchLinkedStudents() async {
    final searchId = _teacherId.isNotEmpty 
        ? _teacherId 
        : (_studentEmail.isNotEmpty ? _studentEmail : _userId);
    if (searchId.isEmpty) return;
    try {
      final list = await DbHelper.getLinkedStudents(searchId, schoolName: _studentSchool);
      _linkedStudents = list;
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching linked students: $e');
    }
  }


  // ── DYNAMIC TEACHER ID RESOLUTION ON BOOT ──
  Future<void> _resolveTeacherIdAndSync() async {
    if (_userRole == 'teacher' && _teacherId.contains('@')) {
      try {
        final conn = await DbHelper.getConnection();
        final results = await conn.execute(
          'SELECT id FROM users WHERE LOWER(email) = :email AND role = "teacher";',
          {'email': _teacherId.toLowerCase().trim()},
        );
        if (results.rows.isNotEmpty) {
          final dbId = results.rows.first.assoc()['id'] ?? '';
          if (dbId.isNotEmpty) {
            _teacherId = dbId;
            _userId = dbId;
            _prefs.setString('teacher_id', dbId);
            _prefs.setString('user_id', dbId);
            print('✅ Resolved legacy email to correct database teacher ID: $dbId');
          }
        }
      } catch (e) {
        print('⚠️ Failed to resolve legacy teacher ID in background: $e');
      }
    }
  }

  // ── MULTI-LANGUAGE & LOCALIZATION SUPPORT ──
  String _selectedLanguage = 'en';
  String get selectedLanguage => _selectedLanguage;

  void changeLanguage(String langCode) {
    _selectedLanguage = langCode;
    _prefs.setString('selected_language', langCode);
    notifyListeners();
  }

  String translate(String text) {
    if (_selectedLanguage == 'en') return text;
    final map = {
      'hi': {
        'Student': 'छात्र',
        'Teacher': 'शिक्षक',
        'Forgot Password?': 'पासवर्ड भूल गए?',
        'Log In': 'लॉग इन करें',
        'Home': 'होम',
        'Syllabus': 'पाठ्यक्रम',
        'Roadmap': 'रोडमैप',
        'Gamified': 'गेम',
        'Exit Adyapan?': 'अध्यापन से बाहर निकलें?',
        'Are you sure you want to exit Adyapan?': 'क्या आप वाकई अध्यापन से बाहर निकालना चाहते हैं?',
        'Cancel': 'रद्द करें',
        'Exit': 'बाहर निकलें',
        'Select Language': 'भाषा चुनें',
        'Select App Language': 'ऐप की भाषा चुनें',
        'Language': 'भाषा',
        'Understood, thanks!': 'समझ गया, धन्यवाद!',
        'Student Dashboard': 'छात्र डैशबोर्ड',
        'Parent Portal Gate': 'अभिभावक पोर्टल',
        'Focus Shield Settings': 'फोकस शील्ड',
        'Teacher Feedback Hub': 'शिक्षक फीडबैक',
        'Help & FAQ': 'सहायता और अक्सर पूछे जाने वाले प्रश्न',
        'Switch Profile / Logout': 'प्रोफ़ाइल बदलें / लॉगआउट',
        'Help & Navigation Guide': 'नेविगेशन गाइड',
        'Find answers and navigate Adyapan easily': 'उत्तर खोजें और अध्यापन को आसानी से नेविगेट करें',
        'Parent Unlock': 'अभिभावक अनलॉक',
        '📱 Device unlocked. Focus Shield deactivated.': '📱 डिवाइस अनलॉक हो गया। फोकस शील्ड निष्क्रिय हो गई।',
        'Parent Verification': 'अभिभावक सत्यापन',
        'Enter your 4-digit PIN to bypass focus lock': 'फ़ोकस लॉक को बायपास करने के लिए अपना 4-अंकीय पिन दर्ज करें',
      }
    };
    return map[_selectedLanguage]?[text] ?? text;
  }

  // Helper to extract a friendly capitalized name from email
  String _nameFromEmail(String email) {
    final clean = email.split('@')[0];
    // Remove digits and symbols, capitalize
    final name = clean.replaceAll(RegExp(r'[^a-zA-Z]'), ' ');
    return name.trim().split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  Future<void> _fetchProfileDetailsFromDb(String email, String role) async {
    try {
      final conn = await DbHelper.getConnection();
      final results = await conn.execute(
        'SELECT name, phone, class_name, class_level, school, school_name FROM users WHERE LOWER(email) = :email;',
        {'email': email.toLowerCase().trim()},
      );
      if (results.rows.isNotEmpty) {
        final row = results.rows.first.assoc();
        _studentName = row['name'] ?? _studentName;
        _studentPhone = row['phone'] ?? _studentPhone;
        _studentClass = row['class_name'] ?? row['class_level'] ?? _studentClass;
        _studentSchool = row['school'] ?? row['school_name'] ?? _studentSchool;

        _prefs.setString('student_name', _studentName);
        _prefs.setString('student_phone', _studentPhone);
        _prefs.setString('student_class', _studentClass);
        _prefs.setString('student_school', _studentSchool);
        
        notifyListeners();
        print('✅ Database profile sync successful for $email: $_studentName');
      }
    } catch (e) {
      print('⚠️ Database profile sync failed: $e');
    }
  }

  Future<void> syncHomeworkAndNotesFromDb() async {
    if (_studentEmail.isEmpty) return;
    print('🔄 Synchronizing homework and notes from TiDB Cloud database...');
    try {
      final conn = await DbHelper.getConnection();
      
      // 1. Fetch homework from app_homework
      final hwResults = await conn.execute(
        'SELECT id, title, subject, description, due_date, priority, added_by, teacher_id, class_level FROM app_homework ORDER BY id DESC;'
      );
      
      final dbHomework = <Map<String, dynamic>>[];
      for (final row in hwResults.rows) {
        final assoc = row.assoc();
        dbHomework.add({
          'id': int.tryParse(assoc['id'] ?? '') ?? 0,
          'title': assoc['title'] ?? '',
          'subject': assoc['subject'] ?? '',
          'description': assoc['description'] ?? '',
          'dueDate': assoc['due_date'] ?? '',
          'priority': assoc['priority'] ?? 'Normal',
          'submitted': false,
          'submittedAt': null,
          'addedBy': assoc['added_by'] ?? '',
          'fileName': '',
          'filePath': '',
          'studentComment': '',
          'grade': 'Pending Grade',
          'teacherFeedback': '',
        });
      }

      // 2. Fetch student's submissions
      final subResults = await conn.execute(
        'SELECT homework_id, student_email, student_name, submitted_at, file_name, file_path, student_comment, grade, teacher_feedback FROM app_homework_submissions WHERE student_email = :email;',
        {'email': _studentEmail.toLowerCase().trim()},
      );

      final submissionsMap = <int, Map<String, dynamic>>{};
      for (final row in subResults.rows) {
        final assoc = row.assoc();
        final hwId = int.tryParse(assoc['homework_id'] ?? '') ?? 0;
        submissionsMap[hwId] = assoc;
      }

      // 3. Marriage! Match submissions with homework
      for (var hw in dbHomework) {
        final sub = submissionsMap[hw['id']];
        if (sub != null) {
          hw['submitted'] = true;
          hw['submittedAt'] = sub['submitted_at'] ?? 'Today';
          hw['fileName'] = sub['file_name'] ?? '';
          hw['filePath'] = sub['file_path'] ?? '';
          hw['studentComment'] = sub['student_comment'] ?? '';
          hw['grade'] = sub['grade'] ?? 'Pending Grade';
          hw['teacherFeedback'] = sub['teacher_feedback'] ?? '';
        }
      }

      // Update active homework list if any homework was fetched
      if (dbHomework.isNotEmpty) {
        _homeworkList = dbHomework;
        _saveHomework();
      }

      // 4. Fetch notes from app_notes
      final notesResults = await conn.execute(
        'SELECT id, title, subject, description, file_name, file_size, pages, uploaded_by, uploaded_at, file_path, teacher_id FROM app_notes ORDER BY id DESC;'
      );

      final dbNotes = <Map<String, dynamic>>[];
      for (final row in notesResults.rows) {
        final assoc = row.assoc();
        dbNotes.add({
          'id': int.tryParse(assoc['id'] ?? '') ?? 0,
          'title': assoc['title'] ?? '',
          'subject': assoc['subject'] ?? '',
          'description': assoc['description'] ?? '',
          'fileName': assoc['file_name'] ?? '',
          'fileSize': assoc['file_size'] ?? '',
          'pages': int.tryParse(assoc['pages'] ?? '') ?? 1,
          'uploadedBy': assoc['uploaded_by'] ?? '',
          'uploadedAt': assoc['uploaded_at'] ?? 'Just now',
          'type': 'PDF',
          'filePath': assoc['file_path'] ?? '',
        });
      }

      if (dbNotes.isNotEmpty) {
        _notesList = dbNotes;
        _saveNotes();
      }

      notifyListeners();
      print('✅ TiDB Homework and Notes sync complete! Total Homework: ${_homeworkList.length}, Total Notes: ${_notesList.length}');
    } catch (e) {
      print('⚠️ Failed to sync homework/notes from cloud database: $e');
    }
  }

  Future<void> syncTeacherSubmissionsFromDb() async {
    final tId = _teacherId.isNotEmpty ? _teacherId : (_userId.isNotEmpty ? _userId : 'TCH-999');
    print('🔄 Synchronizing teacher submissions from TiDB Cloud for teacherId: $tId...');
    try {
      final dbSubmissions = await DbHelper.getHomeworkSubmissions(tId);
      _teacherSubmissions = dbSubmissions;
      notifyListeners();
      print('✅ TiDB submissions sync complete! Total submissions: ${_teacherSubmissions.length}');
    } catch (e) {
      print('⚠️ Failed to sync teacher submissions: $e');
    }
  }

  Future<void> syncTeacherMessagesFromDb() async {
    print('🔄 Synchronizing teacher messages/alerts from TiDB Cloud database...');
    try {
      List<Map<String, dynamic>> dbMessages = [];
      if (_userRole == 'teacher') {
        dbMessages = await DbHelper.getAllTeacherMessages();
      } else {
        dbMessages = await DbHelper.getTeacherMessages(_studentName);
      }
      if (dbMessages.isNotEmpty) {
        _teacherMessages = dbMessages;
        _saveTeacherMessages();
        notifyListeners();
      }
      print('✅ TiDB teacher messages sync complete! Total: ${_teacherMessages.length}');
    } catch (e) {
      print('⚠️ Failed to sync teacher messages: $e');
    }
  }

  Future<void> syncDoubtsFromDb() async {
    try {
      List<Map<String, dynamic>> dbDoubts = [];
      if (_userRole == 'teacher') {
        final tId = _teacherId.isNotEmpty ? _teacherId : (_userId.isNotEmpty ? _userId : 'TCH-999');
        print('🔄 Syncing doubts from TiDB Cloud for teacherId: $tId...');
        dbDoubts = await DbHelper.getDoubtsForTeacher(tId);
      } else {
        print('🔄 Syncing doubts from TiDB Cloud for studentEmail: $_studentEmail...');
        dbDoubts = await DbHelper.getDoubtsForStudent(_studentEmail);
      }
      _doubts = dbDoubts;
      _saveDoubts();
      notifyListeners();
      print('✅ TiDB doubts sync complete! Total: ${_doubts.length}');
    } catch (e) {
      print('⚠️ Failed to sync doubts from database: $e');
    }
  }

  Future<void> syncLiveClassesFromDb() async {
    final tId = _teacherId.isNotEmpty ? _teacherId : (_userId.isNotEmpty ? _userId : 'all');
    print('🔄 Synchronizing live classes from TiDB Cloud database...');
    try {
      final dbLive = await DbHelper.getLiveClasses(tId);
      if (dbLive.isNotEmpty) {
        _liveClassesSchedule = dbLive;
        _saveLiveClassesSchedule();
        notifyListeners();
      }
      print('✅ TiDB live classes sync complete! Total: ${_liveClassesSchedule.length}');
    } catch (e) {
      print('⚠️ Failed to sync live classes: $e');
    }
  }

  Future<void> syncSyllabusAndGamesFromDb() async {
    print('🔄 Synchronizing syllabus and games from TiDB Cloud database...');
    try {
      final conn = await DbHelper.getConnection();

      // 1. Sync Skills Syllabus
      final syllabusResults = await conn.execute(
        'SELECT class_name, title, syllabus_json FROM app_skills_syllabus;'
      );
      for (final row in syllabusResults.rows) {
        final assoc = row.assoc();
        final className = assoc['class_name'] ?? '';
        final title = assoc['title'] ?? '';
        final syllabusJson = assoc['syllabus_json'] ?? '[]';
        final key = '${className}_$title';
        try {
          final List<dynamic> decoded = jsonDecode(syllabusJson);
          _skillsSyllabus[key] = List<String>.from(decoded);
        } catch (e) {
          print('⚠️ Failed to decode syllabus_json for $key: $e');
        }
      }

      // 2. Sync Custom Games Levels
      final gamesResults = await conn.execute(
        'SELECT game_type, class_level, data_json FROM app_custom_games;'
      );
      
      final loadedCognitive = <Map<String, dynamic>>[];
      final loadedSyntax = <Map<String, dynamic>>[];
      final loadedUnscramble = <Map<String, dynamic>>[];

      for (final row in gamesResults.rows) {
        final assoc = row.assoc();
        final gameType = assoc['game_type'] ?? '';
        final classLevel = assoc['class_level'] ?? '';
        final dataJson = assoc['data_json'] ?? '{}';
        
        try {
          final Map<String, dynamic> data = Map<String, dynamic>.from(jsonDecode(dataJson));
          // Inject class level if missing
          data['class'] = classLevel;
          
          if (gameType == 'cognitive') {
            loadedCognitive.add(data);
          } else if (gameType == 'syntax') {
            loadedSyntax.add(data);
          } else if (gameType == 'unscramble') {
            loadedUnscramble.add(data);
          }
        } catch (e) {
          print('⚠️ Failed to decode game data_json: $e');
        }
      }

      if (loadedCognitive.isNotEmpty) {
        _customCognitiveLevels = loadedCognitive;
        _saveCustomCognitiveLevels();
      }
      if (loadedSyntax.isNotEmpty) {
        _customSyntaxLevels = loadedSyntax;
        _saveCustomSyntaxLevels();
      }
      if (loadedUnscramble.isNotEmpty) {
        _customUnscrambleLevels = loadedUnscramble;
        _saveCustomUnscrambleLevels();
      }

      notifyListeners();
      print('✅ Cloud Syllabus and Games sync complete! Syllabi: ${_skillsSyllabus.length}, Cognitive Games: ${_customCognitiveLevels.length}, Syntax Games: ${_customSyntaxLevels.length}, Unscramble Games: ${_customUnscrambleLevels.length}');
    } catch (e) {
      print('⚠️ Failed to sync syllabus and games from cloud database: $e');
    }
  }

  Future<void> _syncCustomGameLevelToDb(String gameType, String classLevel, Map<String, dynamic> data) async {
    try {
      final conn = await DbHelper.getConnection();
      final dataJson = jsonEncode(data);
      await conn.execute('''
        INSERT INTO app_custom_games (game_type, class_level, data_json)
        VALUES (:gameType, :classLevel, :dataJson);
      ''', {
        'gameType': gameType,
        'classLevel': classLevel,
        'dataJson': dataJson,
      });
      print('✅ Custom Game level ($gameType) successfully synced to TiDB Cloud database!');
    } catch (e) {
      print('⚠️ Failed to sync custom game level to cloud database: $e');
    }
  }

  // ── DIRECT SESSION LOGINS FOR FALLBACKS ──
  Future<void> loginAsTeacher(String email) async {
    _isLoggedIn = true;
    _userRole = 'teacher';
    _teacherId = email;
    _studentEmail = email; // Fallback
    
    // Quick parse name from email first to instantly remove placeholder
    _studentName = _nameFromEmail(email);
    _prefs.setString('student_name', _studentName);
    _prefs.setString('student_email', email);
    
    _prefs.setBool('is_logged_in', true);
    _prefs.setString('user_role', 'teacher');
    _prefs.setString('teacher_id', email);
    await _resolveTeacherIdAndSync();
    
    // Fetch real profile details from DB in background
    _fetchProfileDetailsFromDb(email, 'teacher');
    syncHomeworkAndNotesFromDb();
    syncSyllabusAndGamesFromDb();
    
    notifyListeners();
  }

  Future<void> loginAsStudent(String email) async {
    _isLoggedIn = true;
    _userRole = 'student';
    _userId = email;
    _studentEmail = email;
    
    // Quick parse name from email first to instantly remove placeholder
    _studentName = _nameFromEmail(email);
    _prefs.setString('student_name', _studentName);
    _prefs.setString('student_email', email);
    
    _prefs.setBool('is_logged_in', true);
    _prefs.setString('user_role', 'student');
    _prefs.setString('user_id', email);
    
    // Fetch real profile details from DB in background
    _fetchProfileDetailsFromDb(email, 'student');
    syncHomeworkAndNotesFromDb();
    syncSyllabusAndGamesFromDb();
    
    notifyListeners();
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    return await DbHelper.resetPassword(email, newPassword);
  }

  // ── FOCUS SHIELD & PARENTAL CONTROL STATES ──
  bool _deviceFrozen = false;
  bool get deviceFrozen => _deviceFrozen;

  bool _isStudyScheduleActive = false;
  bool get isStudyScheduleActive => _isStudyScheduleActive;

  String _parentPin = '1234';
  String get parentPin => _parentPin;

  List<Map<String, dynamic>> _studySchedules = [];
  List<Map<String, dynamic>> get studySchedules => _studySchedules;

  void setDeviceFrozen(bool value) {
    _deviceFrozen = value;
    _prefs.setBool('device_frozen', value);
    notifyListeners();
  }

  void toggleStudySchedule(String id) {
    final index = _studySchedules.indexWhere((s) => s['id'] == id);
    if (index != -1) {
      _studySchedules[index]['isActive'] = !(_studySchedules[index]['isActive'] as bool? ?? false);
      _saveStudySchedules();
      notifyListeners();
    }
  }

  void setParentPin(String pin) {
    _parentPin = pin;
    _prefs.setString('parent_pin', pin);
    notifyListeners();
  }

  void _saveStudySchedules() {
    _prefs.setString('study_schedules', jsonEncode(_studySchedules));
  }

  void addStudySchedule(String title, String start, String end) {
    final newId = 'sched_${DateTime.now().millisecondsSinceEpoch}';
    _studySchedules.add({
      'id': newId,
      'title': title,
      'start': start,
      'end': end,
      'isActive': true,
    });
    _saveStudySchedules();
    notifyListeners();
  }

  void deleteStudySchedule(dynamic id) {
    _studySchedules.removeWhere((s) => s['id'] == id);
    _saveStudySchedules();
    notifyListeners();
  }

  // ── TEACHER HUB SCHEDULING & INTERACTIVE STATES ──
  List<Map<String, dynamic>> _liveClassesSchedule = [];
  List<Map<String, dynamic>> get liveClassesSchedule => _liveClassesSchedule;

  List<Map<String, dynamic>> _videoUploadsSchedule = [];
  List<Map<String, dynamic>> get videoUploadsSchedule => _videoUploadsSchedule;

  List<Map<String, dynamic>> _doubts = [];
  List<Map<String, dynamic>> get doubts => _doubts;

  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;

  Map<String, dynamic>? _pushedLiveQuiz;
  Map<String, dynamic>? get pushedLiveQuiz => _pushedLiveQuiz;

  List<Map<String, dynamic>> _liveQuizSubmissions = [];
  List<Map<String, dynamic>> get liveQuizSubmissions => _liveQuizSubmissions;

  // ── NOTIFICATION ACTIONS ──
  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n['isRead'] = true;
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n['id'] == id);
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n['id'] == id);
    if (idx != -1) {
      _notifications[idx]['isRead'] = true;
    }
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // ── LIVE CLASS QUIZ & SCHEDULING OPERATIONS ──
  void updateLiveClass(int index, Map<String, dynamic> data) {
    if (index >= 0 && index < _liveClassesSchedule.length) {
      _liveClassesSchedule[index] = data;
      _saveLiveClassesSchedule();
      notifyListeners();

      final tId = _teacherId.isNotEmpty ? _teacherId : (_userId.isNotEmpty ? _userId : 'teacher_default');
      DbHelper.saveLiveClass(data, tId).catchError((e) {
        print('⚠️ Failed to update live class in cloud database: $e');
        return false;
      });
    }
  }

  void clearLiveQuiz() {
    _pushedLiveQuiz = null;
    _liveQuizSubmissions.clear();
    notifyListeners();
  }

  void removeVideoUpload(int index) {
    if (index >= 0 && index < _videoUploadsSchedule.length) {
      _videoUploadsSchedule.removeAt(index);
      notifyListeners();
    }
  }

  void pushLiveQuiz(Map<String, dynamic> quizData) {
    _pushedLiveQuiz = quizData;
    notifyListeners();
  }

  void removeLiveClass(int index) {
    if (index >= 0 && index < _liveClassesSchedule.length) {
      final cls = _liveClassesSchedule[index];
      final String? id = cls['id'];
      _liveClassesSchedule.removeAt(index);
      _saveLiveClassesSchedule();
      notifyListeners();

      if (id != null) {
        DbHelper.deleteLiveClass(id).catchError((e) {
          print('⚠️ Failed to delete live class from cloud database: $e');
          return false;
        });
      }
    }
  }

  void updateVideoUpload(int index, Map<String, dynamic> data) {
    if (index >= 0 && index < _videoUploadsSchedule.length) {
      _videoUploadsSchedule[index] = data;
      notifyListeners();
    }
  }

  void addLiveClass(Map<String, dynamic> data) {
    final tId = _teacherId.isNotEmpty ? _teacherId : (_userId.isNotEmpty ? _userId : 'teacher_default');
    final String id = data['id'] ?? 'live_${DateTime.now().millisecondsSinceEpoch}';
    final fullData = {
      ...data,
      'id': id,
    };
    _liveClassesSchedule.insert(0, fullData);
    _saveLiveClassesSchedule();
    notifyListeners();

    DbHelper.saveLiveClass(fullData, tId).catchError((e) {
      print('⚠️ Failed to save live class in cloud database: $e');
      return false;
    });
  }

  void addVideoUpload(Map<String, dynamic> data) {
    _videoUploadsSchedule.insert(0, data);
    notifyListeners();
  }

  // ── FUTURE SKILLS PLANNER INTERFACES ──
  final Map<String, List<String>> _skillsSyllabus = {};

  List<String> getSkillSyllabus(String className, String title) {
    final key = '${className}_$title';
    if (_skillsSyllabus.containsKey(key)) {
      return _skillsSyllabus[key]!;
    }
    return [
      'Chapter 1: Foundations of $title',
      'Chapter 2: Core Concepts & Practice',
      'Chapter 3: Real-World Applications',
      'Chapter 4: Intermediate Strategies',
      'Interactive Practice: Comprehensive Capstone Project',
    ];
  }

  Future<void> updateSkillSyllabus(String className, String title, List<String> syllabus) async {
    final key = '${className}_$title';
    _skillsSyllabus[key] = syllabus;
    notifyListeners();

    try {
      final conn = await DbHelper.getConnection();
      final syllabusJson = jsonEncode(syllabus);
      await conn.execute('''
        INSERT INTO app_skills_syllabus (class_name, title, syllabus_json)
        VALUES (:className, :title, :syllabusJson)
        ON DUPLICATE KEY UPDATE syllabus_json = :syllabusJson;
      ''', {
        'className': className,
        'title': title,
        'syllabusJson': syllabusJson,
      });
      print('✅ Future Skills Syllabus synced successfully to cloud database for $key!');
    } catch (e) {
      print('⚠️ Failed to sync Future Skills Syllabus to cloud database: $e');
    }
  }

  int _parseClassNum(String className) {
    final numStr = className.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numStr) ?? 1;
  }

  List<Map<String, dynamic>> getSkillsForClass(String className) {
    final int classNum = _parseClassNum(className);
    if (classNum >= 11) {
      return [
        {
          'title': 'Advance Coding',
          'emoji': '🚀',
          'desc': 'Object-oriented programming, data structures, algorithms, and app building.',
          'modules': getSkillSyllabus(className, 'Advance Coding'),
        },
        {
          'title': 'AI tools & productivity',
          'emoji': '🤖',
          'desc': 'Prompt engineering, using AI models effectively, and productivity automation.',
          'modules': getSkillSyllabus(className, 'AI tools & productivity'),
        },
        {
          'title': 'Coding Basics',
          'emoji': '💻',
          'desc': 'Foundational logic, variables, conditional statements, and algorithm design.',
          'modules': getSkillSyllabus(className, 'Coding Basics'),
        },
        {
          'title': 'College & course counselling',
          'emoji': '🏫',
          'desc': 'Profile building, university search, admissions strategy, and essay writing.',
          'modules': getSkillSyllabus(className, 'College & course counselling'),
        },
        {
          'title': 'Company finance',
          'emoji': '📈',
          'desc': 'Understand balance sheets, revenue streams, stock markets, and entrepreneurship.',
          'modules': getSkillSyllabus(className, 'Company finance'),
        },
        {
          'title': 'Content Creation',
          'emoji': '🎥',
          'desc': 'Graphic design, scripting, video pacing, and building a professional online presence.',
          'modules': getSkillSyllabus(className, 'Content Creation'),
        },
        {
          'title': 'Current Affairs',
          'emoji': '🗳️',
          'desc': 'Global geopolitics, socio-economic analysis, and constitutional awareness.',
          'modules': getSkillSyllabus(className, 'Current Affairs'),
        },
        {
          'title': 'JEE/NEET/KVPY/Olympiads/CUET/IPMAT',
          'emoji': '🎯',
          'desc': 'Extreme problem-solving strategies, past paper analysis, and advanced competitive prep.',
          'modules': getSkillSyllabus(className, 'JEE/NEET/KVPY/Olympiads/CUET/IPMAT'),
        },
        {
          'title': 'Informational sessions on subjects & career options',
          'emoji': '💼',
          'desc': 'Modern high-paying career paths, corporate networking, and portfolio creation.',
          'modules': getSkillSyllabus(className, 'Informational sessions on subjects & career options'),
        },
        {
          'title': 'Extempore',
          'emoji': '🗣️',
          'desc': 'Advanced public speaking, argument structures, impromptu debates, and rhetoric.',
          'modules': getSkillSyllabus(className, 'Extempore'),
        },
      ];
    } else if (classNum >= 9) {
      return [
        {
          'title': 'Personal Finance',
          'emoji': '💳',
          'desc': 'Budgeting, savings, investments, compounding interest, and financial planning.',
          'modules': getSkillSyllabus(className, 'Personal Finance'),
        },
        {
          'title': 'Coding (Python) / SQL',
          'emoji': '🐍',
          'desc': 'Write your first programs, learn variables, loops, database queries, and SQL syntax.',
          'modules': getSkillSyllabus(className, 'Coding (Python) / SQL'),
        },
        {
          'title': 'Microsoft Office',
          'emoji': '📁',
          'desc': 'Professional skills in Word document formatting, PowerPoint slides, and Excel.',
          'modules': getSkillSyllabus(className, 'Microsoft Office'),
        },
        {
          'title': 'Exam Readiness (JEE/NEET/NTSE/Olympiad)',
          'emoji': '📝',
          'desc': 'Strategic test-taking, time-management, and high-yield questions for competitive exams.',
          'modules': getSkillSyllabus(className, 'Exam Readiness (JEE/NEET/NTSE/Olympiad)'),
        },
        {
          'title': 'Current Affairs',
          'emoji': '🌍',
          'desc': 'In-depth analysis of national and international politics, science, and economics.',
          'modules': getSkillSyllabus(className, 'Current Affairs'),
        },
        {
          'title': 'Foreign Language',
          'emoji': '🗺️',
          'desc': 'Intermediate vocabulary, cultural etiquette, and dialogue in global languages.',
          'modules': getSkillSyllabus(className, 'Foreign Language'),
        },
        {
          'title': 'Career Awareness through informational sessions',
          'emoji': '🎓',
          'desc': 'Explore stream selections, professional careers, and future growth areas.',
          'modules': getSkillSyllabus(className, 'Career Awareness through informational sessions'),
        },
        {
          'title': 'Spell Bee',
          'emoji': '🐝',
          'desc': 'Master English spelling patterns, root words, origins, and pronunciation.',
          'modules': getSkillSyllabus(className, 'Spell Bee'),
        },
        {
          'title': 'Extempore',
          'emoji': '🎙️',
          'desc': 'Learn how to speak articulately on random topics with zero preparation time.',
          'modules': getSkillSyllabus(className, 'Extempore'),
        },
        {
          'title': 'Video Editing',
          'emoji': '🎬',
          'desc': 'Learn cutting, transitions, audio mixing, and basic visual effects.',
          'modules': getSkillSyllabus(className, 'Video Editing'),
        },
        {
          'title': 'Nutrition',
          'emoji': '🍎',
          'desc': 'Healthy eating habits, macro-nutrients, dietary guidelines, and sports nutrition.',
          'modules': getSkillSyllabus(className, 'Nutrition'),
        },
      ];
    } else if (classNum >= 6) {
      return [
        {
          'title': 'Communication & Public Speaking (MUN)',
          'emoji': '🎤',
          'desc': 'Master voice modulation, debate strategies, and Model United Nations simulations.',
          'modules': getSkillSyllabus(className, 'Communication & Public Speaking (MUN)'),
        },
        {
          'title': 'Financial Literacy',
          'emoji': '💰',
          'desc': 'Learn personal finance, pocket money budgeting, and smart savings.',
          'modules': getSkillSyllabus(className, 'Financial Literacy'),
        },
        {
          'title': 'Excel (Basics)',
          'emoji': '📊',
          'desc': 'Master spreadsheets, simple formulas, data entry, and graphing.',
          'modules': getSkillSyllabus(className, 'Excel (Basics)'),
        },
        {
          'title': 'HTML',
          'emoji': '🌐',
          'desc': 'Create your first web page, understand tags, styling, and basic structures.',
          'modules': getSkillSyllabus(className, 'HTML'),
        },
        {
          'title': 'Foreign Language',
          'emoji': '🗣️',
          'desc': 'Learn greetings, basic conversation phrases, and vocabulary in global languages.',
          'modules': getSkillSyllabus(className, 'Foreign Language'),
        },
        {
          'title': 'Art Theory',
          'emoji': '🎨',
          'desc': 'Explore historical art movements, color theory, and composition techniques.',
          'modules': getSkillSyllabus(className, 'Art Theory'),
        },
        {
          'title': 'Current Affairs',
          'emoji': '📰',
          'desc': 'Stay updated on weekly national and global news, events, and discoveries.',
          'modules': getSkillSyllabus(className, 'Current Affairs'),
        },
        {
          'title': 'Olympiad Worksheet',
          'emoji': '🏅',
          'desc': 'Advanced logic and problem-solving worksheets for national Olympiads.',
          'modules': getSkillSyllabus(className, 'Olympiad Worksheet'),
        },
        {
          'title': 'Informational session on subjects',
          'emoji': 'ℹ️',
          'desc': 'Deep-dive career and subject exploration sessions to find your interest.',
          'modules': getSkillSyllabus(className, 'Informational session on subjects'),
        },
        {
          'title': 'Digital Marketing and how digital platforms work',
          'emoji': '🚀',
          'desc': 'Introduction to SEO, social media algorithms, and online business platforms.',
          'modules': getSkillSyllabus(className, 'Digital Marketing and how digital platforms work'),
        },
      ];
    } else {
      return [
        {
          'title': 'Spoken English',
          'emoji': '🗣️',
          'desc': 'Build confidence, vocabulary, and grammar for fluent everyday conversations.',
          'modules': getSkillSyllabus(className, 'Spoken English'),
        },
        {
          'title': 'Puzzles',
          'emoji': '🧩',
          'desc': 'Enhance logical reasoning, analytical skills, and pattern recognition.',
          'modules': getSkillSyllabus(className, 'Puzzles'),
        },
        {
          'title': 'Habit tracker',
          'emoji': '📅',
          'desc': 'Form positive daily habits, self-discipline, and track personal goals.',
          'modules': getSkillSyllabus(className, 'Habit tracker'),
        },
        {
          'title': 'Basic Digital Literacy',
          'emoji': '💻',
          'desc': 'Foundational computer skills, internet safety, and interactive learning.',
          'modules': getSkillSyllabus(className, 'Basic Digital Literacy'),
        },
        {
          'title': 'General Knowledge',
          'emoji': '🧠',
          'desc': 'Explore world geography, history, general science, and current events.',
          'modules': getSkillSyllabus(className, 'General Knowledge'),
        },
        {
          'title': 'Show & Tell / Storytelling',
          'emoji': '🎭',
          'desc': 'Learn public speaking confidence, expression, and story narrative structure.',
          'modules': getSkillSyllabus(className, 'Show & Tell / Storytelling'),
        },
        {
          'title': 'Olympiads worksheets',
          'emoji': '🏆',
          'desc': 'Practice worksheets tailored for Math and Science competitive Olympiads.',
          'modules': getSkillSyllabus(className, 'Olympiads worksheets'),
        },
      ];
    }
  }

  // ── RECORDED CLASS LIBRARY METHODS ──
  void _saveRecordedLectures() {
    _prefs.setString('recorded_lectures', jsonEncode(_recordedLectures));
  }

  Future<void> addRecordedLecture(String title, String description, String uploadedBy, String emojiOrFileName) async {
    final newLecture = {
      'title': title,
      'duration': description,
      'teacher': uploadedBy,
      'emoji': emojiOrFileName,
    };
    _recordedLectures.insert(0, newLecture);
    _saveRecordedLectures();
    notifyListeners();

    try {
      final dbId = await DbHelper.addRecordedLecture(
        title: title,
        duration: description,
        teacher: uploadedBy,
        emoji: emojiOrFileName,
      );
      if (dbId > 0) {
        _recordedLectures[0]['id'] = dbId;
        _saveRecordedLectures();
        notifyListeners();
      }
    } catch (e) {
      print('⚠️ Failed to save recorded lecture in cloud: $e');
    }
  }

  Future<void> syncRecordedLecturesFromDb() async {
    print('🔄 Synchronizing recorded lectures from TiDB Cloud database...');
    try {
      final dbLectures = await DbHelper.getRecordedLectures();
      if (dbLectures.isNotEmpty) {
        _recordedLectures = dbLectures;
        _saveRecordedLectures();
        notifyListeners();
      }
      print('✅ TiDB recorded lectures sync complete! Total: ${_recordedLectures.length}');
    } catch (e) {
      print('⚠️ Failed to sync recorded lectures: $e');
    }
  }

  // ── ALERTS AND PARENT MESSAGES METHODS ──
  void _saveTeacherMessages() {
    _prefs.setString('teacher_messages', jsonEncode(_teacherMessages));
  }

  Future<void> addTeacherMessage({
    required String studentName,
    required String teacherName,
    required String message,
    required String category,
  }) async {
    final newId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final msg = {
      'id': newId,
      'studentName': studentName,
      'teacherName': teacherName,
      'message': message,
      'category': category,
      'isRead': false,
      'date': 'Today',
      'meetingResponse': '',
    };
    _teacherMessages.insert(0, msg);
    _saveTeacherMessages();
    notifyListeners();

    try {
      await DbHelper.saveTeacherMessage(msg);
    } catch (e) {
      print('⚠️ Failed to save teacher message in cloud: $e');
    }
  }

  void deleteTeacherMessage(dynamic id) {
    _teacherMessages.removeWhere((m) => m['id'] == id);
    _saveTeacherMessages();
    notifyListeners();
  }

  void markTeacherMessageRead(dynamic id) {
    final index = _teacherMessages.indexWhere((m) => m['id'] == id);
    if (index != -1) {
      _teacherMessages[index]['isRead'] = true;
      _saveTeacherMessages();
      notifyListeners();
    }
  }

  Future<void> respondToMeeting(dynamic id, String response) async {
    final index = _teacherMessages.indexWhere((m) => m['id'] == id);
    if (index != -1) {
      _teacherMessages[index]['meetingResponse'] = response;
      _teacherMessages[index]['isRead'] = true;
      _teacherMessages[index]['message'] += '\n\nResponse: ${response.toUpperCase()}';
      _saveTeacherMessages();
      notifyListeners();

      try {
        final conn = await DbHelper.getConnection();
        await conn.execute('''
          UPDATE app_teacher_messages
          SET meeting_response = :response, is_read = 1
          WHERE id = :id;
        ''', {
          'id': id.toString(),
          'response': response,
        });
      } catch (e) {
        print('⚠️ Failed to sync meeting response: $e');
      }
    }
  }

  // ── DYNAMIC GAME LEVELS METHODS ──
  void _saveCustomCognitiveLevels() {
    _prefs.setString('custom_cognitive_levels', jsonEncode(_customCognitiveLevels));
  }

  void _saveCustomSyntaxLevels() {
    _prefs.setString('custom_syntax_levels', jsonEncode(_customSyntaxLevels));
  }

  void _saveCustomUnscrambleLevels() {
    _prefs.setString('custom_unscramble_levels', jsonEncode(_customUnscrambleLevels));
  }

  Future<void> addCustomCognitiveLevel({
    required String type,
    required String question,
    required String original,
    required List<String> choices,
    required String correct,
    required String desc,
    required String targetClass,
  }) async {
    final data = {
      'type': type,
      'question': question,
      'original': original,
      'choices': choices,
      'correct': correct,
      'desc': desc,
      'class': targetClass,
    };
    _customCognitiveLevels.add(data);
    _saveCustomCognitiveLevels();
    notifyListeners();
    await _syncCustomGameLevelToDb('cognitive', targetClass, data);
  }

  Future<void> addCustomSyntaxLevel({
    required String desc,
    required List<String> tiles,
    required List<String> correct,
    required String targetClass,
  }) async {
    final data = {
      'desc': desc,
      'tiles': tiles,
      'correct': correct,
      'class': targetClass,
    };
    _customSyntaxLevels.add(data);
    _saveCustomSyntaxLevels();
    notifyListeners();
    await _syncCustomGameLevelToDb('syntax', targetClass, data);
  }

  Future<void> addCustomUnscrambleLevel({
    required String word,
    required List<String> scrambled,
    required String category,
    required String hint,
    required String targetClass,
  }) async {
    final data = {
      'word': word,
      'scrambled': scrambled,
      'category': category,
      'hint': hint,
      'class': targetClass,
    };
    _customUnscrambleLevels.add(data);
    _saveCustomUnscrambleLevels();
    notifyListeners();
    await _syncCustomGameLevelToDb('unscramble', targetClass, data);
  }

  void addCustomQuizQuestion({
    required String question,
    required List<String> options,
    required int correctOptionIndex,
    String? targetClass,
  }) {
    _customQuizQuestions.add({
      'question': question,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'class': targetClass,
    });
    _prefs.setString('custom_quiz_questions', jsonEncode(_customQuizQuestions));
    notifyListeners();
  }

  // ── DASHBOARD COUNTERS & SPOTLIGHT GETTERS ──
  void _saveLiveClassesSchedule() {
    _prefs.setString('live_classes_schedule', jsonEncode(_liveClassesSchedule));
  }

  List<Map<String, dynamic>> get activeLiveClasses {
    final now = DateTime.now();
    final currentMins = now.hour * 60 + now.minute;
    return _liveClassesSchedule.where((cls) {
      final startHour = cls['startHour'] as int? ?? 0;
      final startMin = cls['startMin'] as int? ?? 0;
      final endHour = cls['endHour'] as int? ?? 0;
      final endMin = cls['endMin'] as int? ?? 0;
      final startMins = startHour * 60 + startMin;
      final endMins = endHour * 60 + endMin;
      
      final isLive = cls['status'] == 'LIVE NOW' || cls['isLive'] == true || (startMins > 0 && currentMins >= startMins && currentMins <= endMins);
      return isLive;
    }).toList();
  }

  bool get hasLiveClassNow => activeLiveClasses.isNotEmpty;

  double get attendancePercent {
    if (_attendanceLogs.isEmpty) return 100.0;
    final presentCount = _attendanceLogs.where((log) => log['status'] == 'Present' || log['status'] == 'Excused').length;
    return ((presentCount / _attendanceLogs.length) * 100.0).clamp(0.0, 100.0);
  }

  int get homeworkDoneCount => _homeworkList.where((h) => h['submitted'] == true).length;

  List<Map<String, dynamic>> getSubjectsForClass(String className) {
    final int classNum = _parseClassNum(className);
    if (classNum >= 11) {
      return [
        {
          'key': 'Math',
          'name': 'Mathematics',
          'emoji': '📐',
          'color': const Color(0xFF2563EB),
          'bgColor': const Color(0xFFEFF6FF),
          'gradient': [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
        },
        {
          'key': 'PhyChemBio',
          'name': 'Phy, Chem, Bio',
          'emoji': '🧪',
          'color': const Color(0xFF10B981),
          'bgColor': const Color(0xFFECFDF5),
          'gradient': [const Color(0xFF10B981), const Color(0xFF047857)],
        },
        {
          'key': 'AccBstEco',
          'name': 'Acc, BST, Eco',
          'emoji': '📊',
          'color': const Color(0xFFF59E0B),
          'bgColor': const Color(0xFFFFFBEB),
          'gradient': [const Color(0xFFF59E0B), const Color(0xFFB45309)],
        },
        {
          'key': 'Humanities',
          'name': 'Humanities',
          'emoji': '🏛️',
          'color': const Color(0xFF8B5CF6),
          'bgColor': const Color(0xFFF5F3FF),
          'gradient': [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
        },
      ];
    } else if (classNum >= 9) {
      return [
        {
          'key': 'Math',
          'name': 'Mathematics',
          'emoji': '📐',
          'color': const Color(0xFF2563EB),
          'bgColor': const Color(0xFFEFF6FF),
          'gradient': [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
        },
        {
          'key': 'Science',
          'name': 'Science (Bio, Phy, Chem)',
          'emoji': '⚛️',
          'color': const Color(0xFF10B981),
          'bgColor': const Color(0xFFECFDF5),
          'gradient': [const Color(0xFF10B981), const Color(0xFF047857)],
        },
        {
          'key': 'English',
          'name': 'English',
          'emoji': '📖',
          'color': const Color(0xFFF59E0B),
          'bgColor': const Color(0xFFFFFBEB),
          'gradient': [const Color(0xFFF59E0B), const Color(0xFFB45309)],
        },
        {
          'key': 'SocialScience9',
          'name': 'Social Sciences (Civics, History, Geography, Economics)',
          'emoji': '🌍',
          'color': const Color(0xFFEC4899),
          'bgColor': const Color(0xFFFDF2F8),
          'gradient': [const Color(0xFFEC4899), const Color(0xFFBE185D)],
        },
      ];
    } else if (classNum >= 6) {
      return [
        {
          'key': 'Math',
          'name': 'Mathematics',
          'emoji': '📐',
          'color': const Color(0xFF2563EB),
          'bgColor': const Color(0xFFEFF6FF),
          'gradient': [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
        },
        {
          'key': 'Science',
          'name': 'Science (Bio, Phy, Chem)',
          'emoji': '⚛️',
          'color': const Color(0xFF10B981),
          'bgColor': const Color(0xFFECFDF5),
          'gradient': [const Color(0xFF10B981), const Color(0xFF047857)],
        },
        {
          'key': 'English',
          'name': 'English',
          'emoji': '📖',
          'color': const Color(0xFFF59E0B),
          'bgColor': const Color(0xFFFFFBEB),
          'gradient': [const Color(0xFFF59E0B), const Color(0xFFB45309)],
        },
        {
          'key': 'SocialScience6',
          'name': 'Social Sciences (Civics, History, Geography)',
          'emoji': '🌍',
          'color': const Color(0xFFEC4899),
          'bgColor': const Color(0xFFFDF2F8),
          'gradient': [const Color(0xFFEC4899), const Color(0xFFBE185D)],
        },
      ];
    } else {
      return [
        {
          'key': 'Math',
          'name': 'Mathematics',
          'emoji': '📐',
          'color': const Color(0xFF2563EB),
          'bgColor': const Color(0xFFEFF6FF),
          'gradient': [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
        },
        {
          'key': 'Science',
          'name': 'Science',
          'emoji': '⚛️',
          'color': const Color(0xFF10B981),
          'bgColor': const Color(0xFFECFDF5),
          'gradient': [const Color(0xFF10B981), const Color(0xFF047857)],
        },
        {
          'key': 'English',
          'name': 'English',
          'emoji': '📖',
          'color': const Color(0xFFF59E0B),
          'bgColor': const Color(0xFFFFFBEB),
          'gradient': [const Color(0xFFF59E0B), const Color(0xFFB45309)],
        },
      ];
    }
  }

  double getSubjectProgress(String key) {
    if (key == 'Math') return mathSyllabusProgress;
    if (key == 'Science' || key == 'Science (Bio, Phy, Chem)') return scienceSyllabusProgress;
    if (key == 'English') return englishSyllabusProgress;
    final list = _roadmaps[key];
    if (list != null && list.isNotEmpty) {
      final completed = list.where((node) => node['status'] == 'completed').length;
      return (completed / list.length) * 100.0;
    }
    return 50.0;
  }

  // ── HOMEWORK GRADING ──
  Future<void> gradeHomework(
    dynamic id, {
    required String studentEmail,
    required String grade,
    String? feedback,
  }) async {
    final index = _homeworkList.indexWhere((h) => h['id'] == id);
    if (index != -1) {
      _homeworkList[index]['grade'] = grade;
      _homeworkList[index]['feedback'] = feedback;
      _homeworkList[index]['gradedAt'] = 'Today';
      _saveHomework();
    }

    final subIndex = _teacherSubmissions.indexWhere((s) => s['id'] == id && s['studentEmail'] == studentEmail);
    if (subIndex != -1) {
      _teacherSubmissions[subIndex]['grade'] = grade;
      _teacherSubmissions[subIndex]['teacherFeedback'] = feedback;
    }

    notifyListeners();

    try {
      int hwId = 0;
      if (id is int) {
        hwId = id;
      } else if (id is String) {
        hwId = int.tryParse(id) ?? 0;
      }
      await DbHelper.gradeHomework(
        hwId,
        studentEmail,
        grade: grade,
        feedback: feedback,
      );
    } catch (e) {
      print('⚠️ Failed to grade homework on cloud: $e');
    }
  }

  // ── DOUBT SOLVING PERSISTENCE METHODS ──
  void _saveDoubts() {
    _prefs.setString('doubts', jsonEncode(_doubts));
  }

  Future<void> addDoubt({
    required String studentName,
    required String studentClass,
    required String subject,
    required String question,
    required String attachmentType,
    required String attachmentName,
    required String attachmentPath,
  }) async {
    final newId = _doubts.isEmpty
        ? 1
        : (_doubts.map((d) => d['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
    
    _doubts.insert(0, {
      'id': newId,
      'studentName': studentName,
      'studentClass': studentClass,
      'subject': subject,
      'question': question,
      'attachmentType': attachmentType,
      'attachmentName': attachmentName,
      'attachmentPath': attachmentPath,
      'replied': false,
      'replyText': '',
      'replyAttachmentType': 'None',
      'replyAttachmentName': '',
      'replyAttachmentPath': '',
      'time': 'Just now',
    });
    _saveDoubts();
    notifyListeners();

    try {
      final dbId = await DbHelper.addDoubt(
        studentName: studentName,
        studentEmail: _studentEmail,
        studentClass: studentClass,
        subject: subject,
        question: question,
        attachmentType: attachmentType,
        attachmentName: attachmentName,
        attachmentPath: attachmentPath,
        teacherId: _teacherId.isNotEmpty ? _teacherId : 'teacher_mps8yshu_48f5p2',
      );
      if (dbId > 0) {
        _doubts[0]['id'] = dbId;
        _saveDoubts();
        notifyListeners();
      }
    } catch (e) {
      print('⚠️ Failed to persist doubt to TiDB Cloud: $e');
    }
  }

  Future<void> solveDoubt(
    int id,
    String replyText, {
    required String replyAttachmentType,
    required String replyAttachmentName,
    required String replyAttachmentPath,
  }) async {
    final index = _doubts.indexWhere((d) => d['id'] == id);
    if (index != -1) {
      _doubts[index]['replied'] = true;
      _doubts[index]['replyText'] = replyText;
      _doubts[index]['replyAttachmentType'] = replyAttachmentType;
      _doubts[index]['replyAttachmentName'] = replyAttachmentName;
      _doubts[index]['replyAttachmentPath'] = replyAttachmentPath;
      _saveDoubts();
      notifyListeners();

      try {
        await DbHelper.solveDoubt(
          id,
          replyText,
          replyAttachmentType: replyAttachmentType,
          replyAttachmentName: replyAttachmentName,
          replyAttachmentPath: replyAttachmentPath,
        );
      } catch (e) {
        print('⚠️ Failed to sync doubt solution: $e');
      }
    }
  }

  // ── FEEDBACK HUB METHODS ──
  void _saveTeacherFeedbacks() {
    _prefs.setString('teacher_feedbacks', jsonEncode(_teacherFeedbacks));
  }

  void addTeacherFeedback({
    required String teacherName,
    required String subjectName,
    required String lectureTitle,
    required double rating,
    required List<String> tags,
    required String comments,
  }) {
    _teacherFeedbacks.add({
      'teacherName': teacherName,
      'subjectName': subjectName,
      'lectureTitle': lectureTitle,
      'rating': rating,
      'tags': tags,
      'comments': comments,
      'timestamp': DateTime.now().toIso8601String(),
    });
    _saveTeacherFeedbacks();
    notifyListeners();
  }

  // ── LIVE QUIZ ANSWER SUBMISSION ──
  void submitLiveQuizAnswer(String studentName, String chosenOption, bool isCorrect) {
    _liveQuizSubmissions.add({
      'studentName': studentName,
      'answer': chosenOption,
      'isCorrect': isCorrect,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    notifyListeners();
  }

  // ── ROADMAP ANCHOR UPDATES ──
  void addRoadmapNode({
    required String subject,
    required String title,
    required String subtitle,
    required String status,
    required String desc,
    String? pdfName,
    String? pdfPath,
  }) {
    if (!_roadmaps.containsKey(subject)) {
      _roadmaps[subject] = [];
    }
    final newId = 'n_${DateTime.now().millisecondsSinceEpoch}';
    _roadmaps[subject]!.add({
      'id': newId,
      'title': title,
      'subtitle': subtitle,
      'status': status,
      'desc': desc,
      'pdfName': pdfName,
      'pdfPath': pdfPath,
    });
    _prefs.setString('roadmaps', jsonEncode(_roadmaps));
    notifyListeners();
  }

  void updateRoadmapNode({
    required String subject,
    required String nodeId,
    required String title,
    required String subtitle,
    required String status,
  }) {
    final list = _roadmaps[subject];
    if (list != null) {
      final index = list.indexWhere((node) => node['id'] == nodeId);
      if (index != -1) {
        list[index]['title'] = title;
        list[index]['subtitle'] = subtitle;
        list[index]['status'] = status;
        _prefs.setString('roadmaps', jsonEncode(_roadmaps));
        notifyListeners();
      }
    }
  }

  void startLiveClassJoinSession({
    required String subject,
    required String time,
    required int durationMinutes,
  }) {
    _liveClassJoinSubject = subject;
    _liveClassJoinTime = time;
    _liveClassJoinClickTime = DateTime.now().toIso8601String();
    _liveClassJoinDurationMinutes = durationMinutes;
    _isLiveClassJoinSessionActive = true;

    _prefs.setString('live_class_join_subject', subject);
    _prefs.setString('live_class_join_time', time);
    _prefs.setString('live_class_join_click_time', _liveClassJoinClickTime!);
    _prefs.setInt('live_class_join_duration_minutes', durationMinutes);
    _prefs.setBool('live_class_join_session_active', true);
    notifyListeners();
  }

  void clearLiveClassJoinSession() {
    _liveClassJoinSubject = null;
    _liveClassJoinTime = null;
    _liveClassJoinClickTime = null;
    _liveClassJoinDurationMinutes = null;
    _isLiveClassJoinSessionActive = false;

    _prefs.remove('live_class_join_subject');
    _prefs.remove('live_class_join_time');
    _prefs.remove('live_class_join_click_time');
    _prefs.remove('live_class_join_duration_minutes');
    _prefs.remove('live_class_join_session_active');
    notifyListeners();
  }

  void checkZoomAttendanceAndMark(BuildContext context) {
    if (!_isLiveClassJoinSessionActive || _liveClassJoinClickTime == null) return;
    
    final clickTime = DateTime.tryParse(_liveClassJoinClickTime!);
    if (clickTime == null) {
      clearLiveClassJoinSession();
      return;
    }
    
    final now = DateTime.now();
    final elapsedMinutes = now.difference(clickTime).inMinutes;
    final requiredDuration = _liveClassJoinDurationMinutes ?? 60;
    final subject = _liveClassJoinSubject ?? 'Live Class';
    final timeStr = _liveClassJoinTime ?? '10:30 AM';
    
    if (elapsedMinutes >= requiredDuration) {
      // Stayed enough time! Secure attendance.
      markAttendance(subject, 'Present', timeStr, source: 'Live Zoom Class');
      clearLiveClassJoinSession();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 Premium Attendance Secured! You completed the full $requiredDuration-minute session! +30 Focus XP!',
            style: const TextStyle(fontFamily: 'Fredoka', color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF10B981), // Green
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    } else {
      // Returned too early!
      clearLiveClassJoinSession();
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text(
                'Attendance Locked 🔒',
                style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          content: Text(
            'You returned to Adyapan in just $elapsedMinutes minutes. You must attend the full $requiredDuration-minute class on Zoom to automatically secure your attendance. Please join again next time!',
            style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, color: Color(0xFF1E293B)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'OK',
                style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
              ),
            )
          ],
        ),
      );
    }
  }
}

