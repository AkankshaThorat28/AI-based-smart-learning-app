import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alerts.dart';
import 'take_test_screen.dart';

class StudyMaterial extends StatefulWidget {
  const StudyMaterial({super.key});

  @override
  State<StudyMaterial> createState() => _StudyMaterialState();
}

class _StudyMaterialState extends State<StudyMaterial> {
  final List<Map<String, dynamic>> _materials = [
    {
      'title': 'Midterm Practice Test',
      'subject': 'Mathematics',
      'teacher': 'Mr. Anderson',
      'date': 'Available Now',
      'color': const Color(0xFFE53935),
      'icon': Icons.assignment,
      'isNew': true,
      'isTest': true,
      'description': 'A comprehensive practice test covering algebra, geometry, and trigonometry topics from chapters 1–8.',
    },
    {
      'title': 'Quadratic Equations Guide',
      'subject': 'Mathematics',
      'teacher': 'Mr. Anderson',
      'date': 'Mar 26',
      'color': const Color(0xFF1E88E5),
      'icon': Icons.calculate,
      'isNew': true,
      'description': 'Complete guide to solving quadratic equations using the quadratic formula, factoring, and completing the square. Includes worked examples and practice problems.',
    },
    {
      'title': 'Newton\'s Laws of Motion',
      'subject': 'Physics',
      'teacher': 'Ms. Johnson',
      'date': 'Mar 24',
      'color': const Color(0xFF43A047),
      'icon': Icons.science,
      'isNew': false,
      'description': 'An overview of Newton\'s three laws of motion with real-world applications, free-body diagrams, and problem-solving strategies.',
    },
    {
      'title': 'Climate Change Essay',
      'subject': 'English',
      'teacher': 'Ms. Williams',
      'date': 'Due Apr 2',
      'color': const Color(0xFFFF7043),
      'icon': Icons.edit_note,
      'isNew': false,
      'isAssignment': true,
      'description': 'Write a 1000-word persuasive essay on the impact of climate change, citing at least three scientific sources.',
    },
    {
      'title': 'Human Circulatory System',
      'subject': 'Biology',
      'teacher': 'Dr. Lee',
      'date': 'Mar 22',
      'color': const Color(0xFF8E24AA),
      'icon': Icons.biotech,
      'isNew': false,
      'description': 'Detailed study material covering the heart, blood vessels, blood composition, and the circulatory pathway through the body.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: _materials.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Study Material', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('Materials shared by your teachers', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                ],
              ),
            );
          }
          final material = _materials[index - 1];
          return _MaterialCard(
            material: material,
            onTap: () => _openDetail(context, material),
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, Map<String, dynamic> material) {
    if (material['isTest'] == true) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => TakeTestScreen(title: material['title'] as String),
      ));
    } else {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MaterialDetailView(material: material),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = AppTheme.animCurve;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: AppTheme.animDuration,
        ),
      );
    }
  }
}

class _MaterialCard extends StatelessWidget {
  final Map<String, dynamic> material;
  final VoidCallback onTap;

  const _MaterialCard({required this.material, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = material['color'] as Color;
    final isAssignment = material['isAssignment'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          child: AnimatedContainer(
            duration: AppTheme.animDuration,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(material['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(material['subject'] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
                          if (isAssignment) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFFF7043).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                              child: const Text('Assignment', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFFE64A19))),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(material['title'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 4),
                      Text(
                        (material['description'] as String?) ?? 'No description provided.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 14, color: AppTheme.textTertiary),
                          const SizedBox(width: 4),
                          Text(material['teacher'] as String, style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                          const Spacer(),
                          Text(material['date'] as String, style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.download_for_offline_outlined, size: 22),
                  color: AppTheme.textTertiary,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Downloading "${material['title']}"...'), behavior: SnackBarBehavior.floating),
                    );
                  },
                  tooltip: 'Download for offline',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MaterialDetailView extends StatefulWidget {
  final Map<String, dynamic> material;

  const MaterialDetailView({super.key, required this.material});

  @override
  State<MaterialDetailView> createState() => _MaterialDetailViewState();
}

class _MaterialDetailViewState extends State<MaterialDetailView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _turnedIn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final material = widget.material;
    final color = material['color'] as Color;
    final isAssignment = material['isAssignment'] == true;
    final description = (material['description'] as String?) ?? 'No description available.';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Collapsing hero header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: color,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.download_for_offline_outlined, size: 18, color: Colors.white),
                ),
                onPressed: () {
                  AppAlerts.showInfo(context, 'Downloading "${material['title']}"...');
                },
                tooltip: 'Download',
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Subject badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(material['icon'] as IconData, color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                material['subject'] as String,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Title
                        Text(
                          material['title'] as String,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                        ),
                        const SizedBox(height: 8),
                        // Teacher + date
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(material['teacher'] as String, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                            const SizedBox(width: 16),
                            const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(material['date'] as String, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Description card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: color),
                      const SizedBox(width: 8),
                      Text('About this material', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
          ),

          // Tabs
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    splashBorderRadius: BorderRadius.circular(10),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme.textSecondary,
                    labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    dividerHeight: 0,
                    tabs: const [
                      Tab(text: '📄 Text'),
                      Tab(text: '🔊 Audio'),
                      Tab(text: '💬 Captions'),
                      Tab(text: '🖼 Visuals'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTextContent(color),
                  _buildAudioContent(color),
                  _buildCaptionsContent(color),
                  _buildVisualsContent(color),
                ],
              ),
            ),
          ),
        ],
      ),

      // Assignment bottom bar
      bottomNavigationBar: isAssignment ? _buildAssignmentBar() : null,
    );
  }

  Widget _buildTextContent(Color color) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContentSection(
              icon: Icons.menu_book,
              title: 'Reading Material',
              color: color,
              child: Text(
                'Full text content will appear here.\n\nThis section displays the complete written material shared by the teacher in an accessible, readable format with proper line spacing and font sizing.\n\nKey topics covered include definitions, worked examples, and summary notes with highlighted formulas and important concepts.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  height: 1.7,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildContentSection(
              icon: Icons.lightbulb_outline,
              title: 'Key Takeaways',
              color: const Color(0xFFFF9800),
              child: Column(
                children: [
                  _buildBulletPoint('Understand the core concepts and definitions', color),
                  _buildBulletPoint('Practice with the provided examples', color),
                  _buildBulletPoint('Review highlighted formulas before the test', color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioContent(Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.headphones, color: color, size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'Audio Playback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Listen to this material read aloud with adjustable speed controls.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            // Mock audio player
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.0,
                      backgroundColor: color.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.replay_10, color: color, size: 24),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.forward_10, color: color, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0:00', style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                      Text('12:34', style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptionsContent(Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.subtitles_outlined, color: color, size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'Captions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Live captions and synchronized text will appear here for audio/video content.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualsContent(Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.image_outlined, color: color, size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'Visual Content',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Diagrams, charts, and images from this material will be displayed here with alt text descriptions.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection({
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6, height: 6,
            margin: const EdgeInsets.only(top: 6, right: 10),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7043).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.assignment_turned_in, size: 16, color: Color(0xFFE65100)),
                ),
                const SizedBox(width: 10),
                const Text('Your Work', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFE65100))),
                const Spacer(),
                if (_turnedIn)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43A047).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Color(0xFF43A047)),
                        SizedBox(width: 4),
                        Text('Submitted', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF43A047))),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _turnedIn ? null : () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles();
                      if (result != null && mounted) {
                        AppAlerts.showSuccess(context, 'Uploaded: ${result.files.single.name}');
                      }
                    },
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text('Upload'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE65100),
                      side: const BorderSide(color: Color(0xFFFF9800)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedContainer(
                    duration: AppTheme.animDuration,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _turnedIn = !_turnedIn),
                      icon: Icon(_turnedIn ? Icons.undo : Icons.send, size: 18),
                      label: Text(_turnedIn ? 'Undo' : 'Turn In'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _turnedIn ? const Color(0xFF43A047) : const Color(0xFFE65100),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
