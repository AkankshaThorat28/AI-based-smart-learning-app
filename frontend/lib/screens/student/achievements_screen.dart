import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  String _userName = 'User';

  final List<Map<String, dynamic>> _badges = [
    {'title': 'Quick Learner', 'icon': '⚡', 'desc': 'Completed 3 lessons in one day', 'unlocked': true, 'color': Colors.orange},
    {'title': 'Consistency King', 'icon': '🔥', 'desc': 'Maintained a 7-day streak', 'unlocked': true, 'color': Colors.red},
    {'title': 'Quiz Master', 'icon': '🏆', 'desc': 'Scored 100% on 5 quizzes', 'unlocked': false, 'color': Colors.blue},
    {'title': 'Zen Seeker', 'icon': '🧘', 'desc': 'Used Zen Mode for 5 hours', 'unlocked': true, 'color': Colors.teal},
    {'title': 'Night Owl', 'icon': '🦉', 'desc': 'Studied past 10 PM', 'unlocked': false, 'color': Colors.deepPurple},
    {'title': 'Social Star', 'icon': '⭐', 'desc': 'Shared 5 progress reports', 'unlocked': false, 'color': Colors.amber},
  ];

  final List<Map<String, dynamic>> _certificates = [
    {'title': 'Foundation of AI', 'date': 'March 20, 2026', 'grade': 'Distinction'},
    {'title': 'Sustainable Ecosystems', 'date': 'Pending', 'grade': 'In Progress'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await AuthService.getUserName();
    if (mounted) setState(() => _userName = name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Achievements', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Your Badges', Icons.stars_rounded),
            const SizedBox(height: 16),
            _buildBadgesGrid(),
            const SizedBox(height: 32),
            _buildSectionHeader('Certificates of Excellence', Icons.card_membership_rounded),
            const SizedBox(height: 16),
            ..._certificates.map((c) => _buildCertificateCard(c)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.brandPrimary, size: 24),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _buildBadgesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _badges.length,
      itemBuilder: (context, index) {
        final badge = _badges[index];
        final bool unlocked = badge['unlocked'];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: (badge['color'] as Color).withOpacity(unlocked ? 0.15 : 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          badge['icon'],
                          style: TextStyle(fontSize: 32, color: unlocked ? null : Colors.grey.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      badge['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: unlocked ? AppTheme.textPrimary : AppTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      badge['desc'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              if (!unlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(Icons.lock_outline, color: Colors.grey, size: 28),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCertificateCard(Map<String, dynamic> cert) {
    bool isDone = cert['date'] != 'Pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: isDone ? const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF311B92)]) : null,
        color: isDone ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDone ? null : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDone ? () => _showCertificateView(cert) : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDone ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDone ? Icons.military_tech_rounded : Icons.pending_actions_rounded,
                    color: isDone ? Colors.amber : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cert['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isDone ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isDone ? 'Earned on ${cert['date']}' : 'Complete remaining modules to earn',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDone ? Colors.white70 : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDone)
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCertificateView(Map<String, dynamic> cert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Your Certificate', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const Spacer(),
            // --- CERTIFICATE CONTENT ---
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.amber.shade300, width: 8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 50),
                  const SizedBox(height: 20),
                  const Text('CERTIFICATE OF EXCELLENCE', style: TextStyle(fontFamily: 'Serif', fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 10),
                  const Text('PROUDLY PRESENTED TO', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 20),
                  Text(_userName.toUpperCase(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
                  const Divider(indent: 40, endIndent: 40, thickness: 2, height: 40),
                  const Text('FOR OUTSTANDING COMPLETION OF THE COURSE', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Text(cert['title'].toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text('Grade', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(cert['grade'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(cert['date'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Text('Saamya AI Learning Academy', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.brandPrimary)),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(30),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading PDF...')));
                },
                icon: const Icon(Icons.file_download),
                label: const Text('Download Certificate (PDF)'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: AppTheme.brandPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
