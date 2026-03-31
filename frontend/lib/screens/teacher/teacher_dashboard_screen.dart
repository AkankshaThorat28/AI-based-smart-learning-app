import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final TextEditingController _topicController = TextEditingController();
  String _selectedBoard = 'CBSE';
  bool _isGenerating = false;

  final List<Map<String, dynamic>> _students = [
    {'name': 'Sanvi Patel', 'board': 'CBSE', 'mode': 'Visual Mode', 'progress': 0.85},
    {'name': 'Rahul Sharma', 'board': 'ICSE', 'mode': 'Auditory', 'progress': 0.72},
    {'name': 'Arjun Singh', 'board': 'CBSE', 'mode': 'Standard', 'progress': 0.94},
    {'name': 'Priya Das', 'board': 'SSC', 'mode': 'Standard', 'progress': 0.65},
    {'name': 'Ananya Rao', 'board': 'ICSE', 'mode': 'Deaf Mode', 'progress': 0.80},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  void _sendNudge(String studentName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Encouragement sent via TTS/Notification to $studentName.'),
        backgroundColor: const Color(0xFF2E7D32), // Emerald Green
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _generateLesson() {
    if (_topicController.text.trim().isEmpty) return;
    setState(() => _isGenerating = true);
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isGenerating = false);
        _topicController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson generated and transposed successfully!'),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Professional Admin background
      appBar: AppBar(
        title: const Text('Admin Console - Saamya AI', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF334155), // Slate Grey
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E7D32), // Emerald Green
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF2E7D32),
          tabs: const [
            Tab(text: 'Classroom Analytics'),
            Tab(text: 'Content & Tests'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAnalyticsTab(),
            _buildContentTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Student Inclusivity Analytics (Top Row)
              Semantics(
                label: 'Student Inclusivity Analytics High-Level Stat Cards',
                child: isWide 
                  ? Row(
                      children: [
                        Expanded(child: _buildStatCard('Total Students', '124', Icons.people_outline, Colors.blue)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard('Accessibility Alerts', '3', Icons.warning_amber_rounded, Colors.orange, subtitle: 'Urgent captioning sync')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard('Engagement Rate', '88%', Icons.trending_up, const Color(0xFF2E7D32), subtitle: 'Average across boards')),
                      ],
                    )
                  : Column(
                      children: [
                        _buildStatCard('Total Students', '124', Icons.people_outline, Colors.blue),
                        const SizedBox(height: 12),
                        _buildStatCard('Accessibility Alerts', '3', Icons.warning_amber_rounded, Colors.orange, subtitle: 'Urgent captioning sync'),
                        const SizedBox(height: 12),
                        _buildStatCard('Engagement Rate', '88%', Icons.trending_up, const Color(0xFF2E7D32), subtitle: 'Average across boards'),
                      ],
                    ),
              ),
              const SizedBox(height: 32),

              // 2. Live "Classroom Health" Monitor (Middle Section)
              Semantics(
                header: true,
                child: const Text('Live Classroom Health Monitor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _students.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (context, index) {
                    final s = _students[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(s['board'], style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(s['mode'], style: const TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: s['progress'],
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation(
                                  s['progress'] > 0.8 ? const Color(0xFF2E7D32) : Colors.orange
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Semantics(
                        button: true,
                        label: 'Send gentle nudge to ${s['name']}',
                        child: OutlinedButton.icon(
                          onPressed: () => _sendNudge(s['name']),
                          icon: const Icon(Icons.favorite_border, size: 16),
                          label: const Text('Nudge'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2E7D32),
                            side: const BorderSide(color: Color(0xFF2E7D32)),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContentTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        final list = [
          Expanded(
            flex: isWide ? 1 : 0,
            child: _buildLessonGenerator(),
          ),
          SizedBox(width: isWide ? 24 : 0, height: isWide ? 0 : 24),
          Expanded(
            flex: isWide ? 1 : 0,
            child: _buildMockTestAnalytics(),
          ),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: isWide 
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: list)
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: list),
        );
      },
    );
  }

  Widget _buildLessonGenerator() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: const Text('Generate Adaptive Lesson', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          ),
          const SizedBox(height: 8),
          const Text('Instantly create inclusive learning modules leveraging AI.', style: TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 24),
          Semantics(
            label: 'Lesson Topic TextField',
            child: TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Lesson Topic (e.g., Photosynthesis)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.science),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedBoard,
            decoration: const InputDecoration(
              labelText: 'Target Board',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'CBSE', child: Text('CBSE')),
              DropdownMenuItem(value: 'ICSE', child: Text('ICSE')),
              DropdownMenuItem(value: 'SSC', child: Text('SSC')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedBoard = val);
            },
          ),
          const SizedBox(height: 24),
          if (_isGenerating) ...[
            const LinearProgressIndicator(color: Color(0xFF2E7D32)),
            const SizedBox(height: 8),
            const Text(
              'AI is transposing lesson for Visual and Auditory modes...',
              style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF2E7D32), fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _generateLesson,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMockTestAnalytics() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: const Text('Class Performance: Mock Tests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          ),
          const SizedBox(height: 24),
          
          // Simple mocked BarChart using Flex/Containers
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar('CBSE\nAvg: 78%', 0.78, Colors.blue),
                _buildBar('ICSE\nAvg: 83%', 0.83, Colors.purple),
                _buildBar('SSC\nAvg: 71%', 0.71, Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double fill, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Semantics(
          label: 'Bar chart item for $label',
          child: Container(
            width: 40,
            height: 150 * fill,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
