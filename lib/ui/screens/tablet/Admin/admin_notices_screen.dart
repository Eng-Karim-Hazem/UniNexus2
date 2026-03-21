import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../admin_tab.dart';
import '../theme/app_theme.dart';

class AdminNoticesScreen extends StatefulWidget {
  final void Function(AdminTab) onNavigate;
  const AdminNoticesScreen({super.key, required this.onNavigate});

  @override
  State<AdminNoticesScreen> createState() => _AdminNoticesScreenState();
}

class _AdminNoticesScreenState extends State<AdminNoticesScreen> {
  String _activeCategory = 'Individual';
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String? _selectedSpecialization;
  String? _selectedGroup;
  String? _selectedProgram;

  Widget _buildInputSection() {
    switch (_activeCategory) {
      case 'Individual':
        return _buildFormLayout(
          label: 'User ID',
          child: _buildTextField(_idController, 'Enter User ID'),
        );
      case 'Specialization':
        return _buildFormLayout(
          label: 'Choose Specialization',
          child: _buildDropdown(
              ['TA', 'Professors', 'Students' ,'Staff'],
              _selectedSpecialization,
                  (v) => setState(() => _selectedSpecialization = v)
          ),
        );
      case 'Groups':
        return _buildFormLayout(
          label: 'Choose Groups',
          child: _buildDropdown(
              ['Group A', 'Group B', 'Group C'],
              _selectedGroup,
                  (v) => setState(() => _selectedGroup = v)
          ),
        );
      case 'Program':
        return _buildFormLayout(
          label: 'Choose Program',
          child: _buildDropdown(
              ['ICT', 'Mechatronics', 'Ortho','Auto','Renewable Energy','Petro'],
              _selectedProgram,
                  (v) => setState(() => _selectedProgram = v)
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildFormLayout({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.infoRowLabelStyle),
        const SizedBox(height: 12),
        child,
        const SizedBox(height: 32),
        const Text('Notice message', style: AppTextStyles.infoRowLabelStyle),
        const SizedBox(height: 12),
        _buildTextField(_messageController, 'Enter Notice Body (max 100 characters)', maxLines: 6),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? current, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: current,
      style: AppTextStyles.body,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notices', style: AppTextStyles.largeHeading),
            const SizedBox(height: 40),
            Expanded(
              child: Row(
                children: [
                  // FIXED SIDEBAR (Non-scrollable)
                  SizedBox(
                    width: 180,
                    child: Column(
                      children: [
                        Expanded(
                          child: _CategoryButton(
                            imagePath: 'assets/images/avatar.png',
                            label: 'Individual',
                            isActive: _activeCategory == 'Individual',
                            onTap: () => setState(() => _activeCategory = 'Individual'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _CategoryButton(
                            imagePath: 'assets/images/multi_users.png',
                            label: 'Specialization',
                            isActive: _activeCategory == 'Specialization',
                            onTap: () => setState(() => _activeCategory = 'Specialization'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _CategoryButton(
                            imagePath: 'assets/images/multi_users.png',
                            label: 'Groups',
                            isActive: _activeCategory == 'Groups',
                            onTap: () => setState(() => _activeCategory = 'Groups'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _CategoryButton(
                            imagePath: 'assets/images/multi_users.png',
                            label: 'Program',
                            isActive: _activeCategory == 'Program',
                            onTap: () => setState(() => _activeCategory = 'Program'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 40),

                  // Main Form Area
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: _buildInputSection(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: SizedBox(
                              width: 240,
                              child: PillButton(
                                label: 'Send',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Processing Notice...'))
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.imagePath,
    required this.label,
    required this.isActive,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24), // Match your glass card curves
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), // The Glass Effect!
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            decoration: isActive
                ? BoxDecoration(
              color: AppColors.primary.withOpacity(0.15), // Slight purple tint when active
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary, width: 2),
            )
                : GlassDecoration.light, // Your custom theme decoration
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // IMAGE ASSET
                Image.asset(
                  imagePath,
                  width: 50,  // Matched to the design proportions
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported,
                      size: 30,
                      color: AppColors.primary
                  ),
                ),

                const SizedBox(height: 10),

                // BOLD TEXT
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppFonts.spaceGrotesk,
                      fontSize: 18,
                      fontWeight: FontWeight.w800, // Extra bold black text
                      color: Colors.black87,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}