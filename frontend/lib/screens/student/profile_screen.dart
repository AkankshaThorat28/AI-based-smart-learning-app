import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/accessibility_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/tr.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String _board = 'Loading...';
  String _role = 'Student';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await AuthService.getUserName();
    final email = await AuthService.getUserEmail();
    final board = await AuthService.getUserBoard();
    final role = await AuthService.getUserRole();
    if (mounted) {
      setState(() {
        _userName = name;
        _userEmail = email;
        _board = board;
        _role = role;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final a11y = context.watch<AccessibilityProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My Profile'.tr(context)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Hero(
              tag: 'profile_avatar',
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.brandPrimary,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _userName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              _userEmail,
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.brandPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_role • $_board Board',
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.brandPrimary),
              ),
            ),
            const SizedBox(height: 40),

            // Progress Section
            if (!a11y.zenMode) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Learning Progress'.tr(context), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              _buildProgressCard('Mathematics', 0.8),
              const SizedBox(height: 12),
              _buildProgressCard('Physics', 0.65),
              const SizedBox(height: 40),
            ],

            // Certificates Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Earned Certificates'.tr(context), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            _buildCertificateCard('Basic Algebra 101', 'Mr. Anderson', 'Feb 15, 2026'),
            const SizedBox(height: 12),
            _buildCertificateCard('Newtonian Physics Basics', 'Ms. Johnson', 'Mar 10, 2026'),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(String subject, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject.tr(context), style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(color: AppTheme.brandPrimary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.brandPrimary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(String topic, String signedBy, String date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD54F)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFFFFD54F), shape: BoxShape.circle),
            child: const Icon(Icons.workspace_premium, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic.tr(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Signed by: $signedBy', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Text('Issued: $date', style: TextStyle(color: AppTheme.textTertiary, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: AppTheme.brandPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading Certificate for $topic...')));
            },
            tooltip: 'Download Certificate',
          ),
        ],
      ),
    );
  }
}
