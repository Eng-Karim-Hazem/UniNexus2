import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../admin_tab.dart';
import '../../../../model/notices_model.dart';
import '../../../../services/firebase/notices_service.dart';
import 'package:uninexus/theme/app_theme.dart';

class AdminNoticesScreen extends StatefulWidget {
  final void Function(AdminTab) onNavigate;

  const AdminNoticesScreen({super.key, required this.onNavigate});

  @override
  State<AdminNoticesScreen> createState() => _AdminNoticesScreenState();
}

class _AdminNoticesScreenState extends State<AdminNoticesScreen> {
  final NoticesService _noticesService = NoticesService();

  String _activeCategory = 'Individual';
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String? _selectedSpecialization;
  String? _selectedGroup;
  String? _selectedProgram;

  bool _isSending = false;
  String _senderName = 'Admin';
  bool _isLoadingSpecializations = true;
  List<String> _specializations = const [];

  static const List<String> _groups = [
    'IT', 'Security', 'Admin', 'Students', 'Faculty',
  ];
  static const List<String> _programs = [
    'ICT', 'Renewable Energy', 'Mechatronics', 'Autotronics', 'Artificial Limbs',
  ];

  @override
  void initState() {
    super.initState();
    _loadSpecializations();
    _loadSenderName();
  }

  @override
  void dispose() {
    _idController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecializations() async {
    try {
      final List<String> loaded = await _noticesService.getAvailableSpecializations();
      if (!mounted) return;
      setState(() {
        _specializations = loaded;
        _isLoadingSpecializations = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _specializations = const [];
        _isLoadingSpecializations = false;
      });
    }
  }

  Future<void> _loadSenderName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String firstName = (prefs.getString('fName') ?? '').trim();
    final String lastName = (prefs.getString('lName') ?? '').trim();

    String composed = '';
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      composed = '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      composed = firstName;
    }

    if (!mounted) return;
    setState(() {
      _senderName = composed.isNotEmpty ? composed : 'Admin';
    });
  }

  Widget _buildInputSection() {
    if (_activeCategory == 'Specialization' && _isLoadingSpecializations) {
      return const LoadingState(message: 'Loading specializations...');
    }

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
            _specializations,
            _selectedSpecialization,
                (v) => setState(() => _selectedSpecialization = v),
            hint: _specializations.isEmpty ? 'No specializations available' : 'Choose the Specialization',
          ),
        );
      case 'Groups':
        return _buildFormLayout(
          label: 'Choose Groups',
          child: _buildDropdown(
            _groups,
            _selectedGroup,
                (v) => setState(() => _selectedGroup = v),
            hint: 'Choose the Group',
          ),
        );
      case 'Program':
        return _buildFormLayout(
          label: 'Choose Program',
          child: _buildDropdown(
            _programs,
            _selectedProgram,
                (v) => setState(() => _selectedProgram = v),
            hint: 'Choose the program',
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
        _buildTextField(
          _messageController,
          'Enter Notice Body (max 120 characters)',
          maxLines: 6,
          maxLength: 120,
        ),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hint, {
        int maxLines = 1,
        int? maxLength,
      }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.3)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.7),
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(
      List<String> items,
      String? current,
      ValueChanged<String?> onChanged, {
        required String hint,
      }) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hint,
                style: AppTextStyles.body.copyWith(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: current,
      style: AppTextStyles.body,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.3)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _sendNotice() async {
    final String message = _messageController.text.trim();

    if (message.isEmpty) {
      showErrorSnackBar(context, 'Please enter a notice message.');
      return;
    }

    setState(() => _isSending = true);
    showLoadingOverlay(context, message: 'Sending notice...');

    try {
      late final List<String> recipientIds;
      late final NoticeTargetType targetType;
      late final String targetValue;
      late final String title;

      switch (_activeCategory) {
        case 'Individual':
          final String id = _idController.text.trim();
          if (id.isEmpty) throw Exception('Please enter a user ID.');
          recipientIds = [id];
          targetType = NoticeTargetType.individual;
          targetValue = id;
          title = 'Individual Notice';
          break;
        case 'Groups':
          final String? group = _selectedGroup;
          if (group == null || group.isEmpty) throw Exception('Please choose a group.');
          recipientIds = await _noticesService.getAllUserIdsByGroup(group);
          targetType = NoticeTargetType.group;
          targetValue = group;
          title = 'Group Notice: $group';
          break;
        case 'Specialization':
          final String? specialization = _selectedSpecialization;
          if (specialization == null || specialization.isEmpty) throw Exception('Please choose a specialization.');
          recipientIds = await _noticesService.getFacultyIdsBySubject(specialization);
          targetType = NoticeTargetType.specialization;
          targetValue = specialization;
          title = 'Specialization Notice: $specialization';
          break;
        case 'Program':
          final String? program = _selectedProgram;
          if (program == null || program.isEmpty) throw Exception('Please choose a program.');
          recipientIds = await _noticesService.getStudentIdsByProgram(program);
          targetType = NoticeTargetType.program;
          targetValue = program;
          title = 'Program Notice: $program';
          break;
        default:
          throw Exception('Unknown notice category.');
      }

      if (recipientIds.isEmpty) {
        throw Exception('No users matched the selected target.');
      }

      final NoticeModel notice = NoticeModel(
        title: title,
        description: message,
        targetType: targetType,
        targetValue: targetValue,
        recipientIds: recipientIds,
        createdAt: DateTime.now(),
        sentBy: _senderName,
      );

      await _noticesService.sendNotice(notice);

      if (!mounted) return;

      _messageController.clear();
      if (_activeCategory == 'Individual') {
        _idController.clear();
      }
      setState(() {
        _selectedSpecialization = null;
        _selectedGroup = null;
        _selectedProgram = null;
      });

      hideLoadingOverlay(context);
      showSuccessSnackBar(context, 'Notice sent successfully to ${recipientIds.length} user(s).');

    } catch (e) {
      if (!mounted) return;
      hideLoadingOverlay(context);
      showErrorSnackBar(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading('Notices'),
            const SizedBox(height: 40),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // DYNAMIC LAYOUT SIDEBAR
                  SizedBox(
                    width: 180,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate available space minus the gaps (3 gaps of 16px)
                        final totalSpacing = 16.0 * 3;
                        final availableHeight = constraints.maxHeight - totalSpacing;
                        final dynamicHeight = availableHeight / 4;

                        // Set a safe minimum height so it won't overflow when keyboard appears
                        final safeHeight = dynamicHeight < 110.0 ? 110.0 : dynamicHeight;

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              SizedBox(
                                height: safeHeight,
                                child: _CategoryButton(
                                  imagePath: 'assets/icons/Individual.png',
                                  label: 'Individual',
                                  isActive: _activeCategory == 'Individual',
                                  onTap: () => setState(() {
                                    _activeCategory = 'Individual';
                                    _selectedSpecialization = null;
                                    _selectedGroup = null;
                                    _selectedProgram = null;
                                  }),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: safeHeight,
                                child: _CategoryButton(
                                  imagePath: 'assets/images/multi_users.png',
                                  label: 'Specialization',
                                  isActive: _activeCategory == 'Specialization',
                                  onTap: () => setState(() {
                                    _activeCategory = 'Specialization';
                                    _selectedGroup = null;
                                    _selectedProgram = null;
                                  }),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: safeHeight,
                                child: _CategoryButton(
                                  imagePath: 'assets/images/multi_users.png',
                                  label: 'Groups',
                                  isActive: _activeCategory == 'Groups',
                                  onTap: () => setState(() {
                                    _activeCategory = 'Groups';
                                    _selectedSpecialization = null;
                                    _selectedProgram = null;
                                  }),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: safeHeight,
                                child: _CategoryButton(
                                  imagePath: 'assets/images/multi_users.png',
                                  label: 'Program',
                                  isActive: _activeCategory == 'Program',
                                  onTap: () => setState(() {
                                    _activeCategory = 'Program';
                                    _selectedSpecialization = null;
                                    _selectedGroup = null;
                                  }),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 40),
                  // Form panel
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
                                label: _isSending ? 'Sending...' : 'Send',
                                onTap: () {
                                  if (_isSending) return;
                                  _sendNotice();
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

// Category button widget
class _CategoryButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.imagePath,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            decoration: isActive
                ? BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary, width: 2),
            )
                : GlassDecoration.light,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  width: 50,
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported,
                    size: 30,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppFonts.spaceGrotesk,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
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