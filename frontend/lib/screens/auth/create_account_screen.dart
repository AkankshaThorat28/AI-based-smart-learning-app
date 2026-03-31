import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/accessibility_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import '../main_nav.dart';
import '../student/blind_dashboard_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController  = TextEditingController();
  final _emailController = TextEditingController();
  final _passController  = TextEditingController();

  bool _agreedToTerms      = false;
  String _selectedRole     = 'student';
  String _selectedDisability = 'none';
  String _selectedBoard    = 'CBSE'; // Default board
  bool _obscurePassword    = true;
  bool _isLoading          = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passController.text.isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }
    if (!_agreedToTerms) {
      _showSnack('Please agree to the Terms of Service');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await ApiService.register(
        name:       _nameController.text.trim(),
        email:      _emailController.text.trim(),
        password:   _passController.text,
        role:       _selectedRole,
        disability: _selectedRole == 'student' ? '${_selectedDisability}|${_selectedBoard}' : 'none',
      );

      // Persist session
      await AuthService.saveSession(user);

      // Apply accessibility defaults based on disability
      if (mounted) {
        final realDisability = (user['disability'] as String).split('|')[0];
        Provider.of<AccessibilityProvider>(context, listen: false)
            .applyDefaults(realDisability);
            
        final isBlind = realDisability == 'visual' || realDisability == 'blind';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => isBlind ? const BlindDashboardScreen() : const MainNav(),
          ),
        );
      }
    } on ApiException catch (e) {

      _showSnack(e.message);
    } catch (e) {
      _showSnack('Could not connect to server. Is the backend running?');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _buildFormCard(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Create an account',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.brandPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Join the professional learning platform.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 28),

          _buildLabel('Full Name'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _nameController,
            icon: Icons.person_outline,
            hint: 'John Doe',
          ),
          const SizedBox(height: 20),

          _buildLabel('Email Address'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _emailController,
            icon: Icons.alternate_email,
            hint: 'name@company.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),

          _buildLabel('Password'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _passController,
            icon: Icons.lock_outline,
            hint: '••••••••••••',
            obscure: _obscurePassword,
            suffix: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: AppTheme.textTertiary,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 16),

          // Terms checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: _agreedToTerms,
                  onChanged: (v) =>
                      setState(() => _agreedToTerms = v ?? false),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.4),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.brandPrimary),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.brandPrimary),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Role selector
          _buildLabel('Select Your Role'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(child: _buildRoleChip('Student', 'student')),
                const SizedBox(width: 4),
                Expanded(child: _buildRoleChip('Teacher', 'teacher')),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (_selectedRole == 'student') ...[
            // Board Selector
            _buildLabel('School Board'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedBoard,
                  items: const [
                    DropdownMenuItem(value: 'CBSE', child: Text('CBSE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                    DropdownMenuItem(value: 'ICSE', child: Text('ICSE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                    DropdownMenuItem(value: 'SSC', child: Text('SSC (State Board)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                  ],
                  onChanged: (v) => setState(() => _selectedBoard = v ?? 'CBSE'),
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textTertiary),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Disability Selector
            _buildLabel('Any Physical Disabilities?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedDisability,
                  items: const [
                    DropdownMenuItem(
                        value: 'none',
                        child: Text('No Physical Disabilities',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500))),
                    DropdownMenuItem(
                        value: 'visual',
                        child: Text('Visually Impaired',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500))),
                    DropdownMenuItem(
                        value: 'deaf',
                        child: Text('Deaf',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500))),
                    DropdownMenuItem(
                        value: 'voice',
                        child: Text('Voice Impaired',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500))),
                  ],
                  onChanged: (v) =>
                      setState(() => _selectedDisability = v ?? 'none'),
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 14),
                  icon: const Icon(Icons.arrow_drop_down,
                      color: AppTheme.textTertiary),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Create Account button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleCreateAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26)),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Create Account',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // Login link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Log In',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.brandPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppTheme.brandPrimary,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: AppTheme.textTertiary),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String label, String value) {
    final selected = _selectedRole == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedRole = value),
        borderRadius: BorderRadius.circular(10),
        hoverColor: AppTheme.brandPrimary.withValues(alpha: 0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.brandPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
