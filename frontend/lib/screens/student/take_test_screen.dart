import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alerts.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class TakeTestScreen extends StatefulWidget {
  final String title;
  const TakeTestScreen({super.key, required this.title});

  @override
  State<TakeTestScreen> createState() => _TakeTestScreenState();
}

class _TakeTestScreenState extends State<TakeTestScreen> {
  int _currentQuestionIndex = 0;
  String? _selectedOption;
  int _score = 0;

  // Backend-fetched questions
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  String? _error;
  String _topic = 'General';

  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _userId = await AuthService.getUserId();
    await _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getManualQuiz();
      final rawQuestions = data['questions'] as List<dynamic>? ?? [];
      _topic = data['topic'] as String? ?? 'General';
      setState(() {
        _questions = rawQuestions
            .map((q) => {
                  'question': q['question'] as String,
                  'options': List<String>.from(q['options'] as List<dynamic>),
                  'correct': q['correct'] as String,
                })
            .toList();
        _isLoading = false;
        _currentQuestionIndex = 0;
        _score = 0;
        _selectedOption = null;
      });
    } catch (e) {
      // Fallback to local questions if backend is unavailable
      setState(() {
        _questions = [
          {
            'question': 'What is the sum of angles in a triangle?',
            'options': ['90°', '180°', '270°', '360°'],
            'correct': '180°'
          },
          {
            'question': 'Which of the following describes a right angle?',
            'options': ['Exactly 90°', 'Less than 90°', 'More than 90°', 'Exactly 180°'],
            'correct': 'Exactly 90°'
          },
        ];
        _isLoading = false;
        _error = 'Using offline questions (backend unavailable)';
      });
    }
  }

  void _nextQuestion() {
    if (_selectedOption == null) {
      AppAlerts.showError(context, 'Please select an option first!');
      return;
    }

    final correct = _questions[_currentQuestionIndex]['correct'] as String;
    if (_selectedOption == correct) _score++;

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
      });
    } else {
      _submitTest();
    }
  }

  Future<void> _submitTest() async {
    // Submit result to backend
    try {
      await ApiService.submitQuizResult(
        userId: _userId,
        score:  _score,
        total:  _questions.length,
        topic:  _topic,
      );
    } catch (_) {
      // Don't block the user if submission fails
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.emoji_events, size: 48, color: Color(0xFFFFC107)),
            const SizedBox(height: 8),
            const Text('Test Complete!', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'You scored $_score out of ${_questions.length}\n'
          '(${(_score / _questions.length * 100).round()}%) — Saved to your progress!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _loadQuiz();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No questions available', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadQuiz, child: const Text('Try Again')),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppTheme.surfaceBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
              color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentQuestionIndex + 1}/${_questions.length}',
                style: const TextStyle(
                    color: AppTheme.brandPrimary, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: AppTheme.brandPrimary,
              minHeight: 4,
            ),

            // Offline warning banner
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.orange.shade50,
                child: Text(
                  _error!,
                  style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),

            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                      style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question['question'] as String,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          height: 1.3),
                    ),
                    const SizedBox(height: 32),
                    ...List.generate(
                      (question['options'] as List<String>).length,
                      (index) {
                        final option = (question['options'] as List<String>)[index];
                        final isSelected = _selectedOption == option;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => setState(() => _selectedOption = option),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: AppTheme.animFast,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.brandPrimary.withValues(alpha: 0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.brandPrimary
                                      : Colors.grey.shade200,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.brandPrimary
                                            : Colors.grey.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: const BoxDecoration(
                                                color: AppTheme.brandPrimary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? AppTheme.brandPrimary
                                            : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom action
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4)),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentQuestionIndex == _questions.length - 1
                        ? 'Submit Test'
                        : 'Next Question',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
