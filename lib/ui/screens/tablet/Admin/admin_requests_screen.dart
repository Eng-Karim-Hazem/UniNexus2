import 'package:flutter/material.dart';
import '../../../../admin_tab.dart';
// Ensure AdminTab is imported
import '../theme/app_theme.dart';

// Data model (shared or duplicated for Admin context)
class _AdminRequest {
  final String id;
  final String type; // e.g., 'Password Reset' or 'Registration'
  final String requesterName;
  final String userType;
  final String userId;
  final String email;
  final int year;
  final String faculty;

  const _AdminRequest({
    required this.id,
    required this.type,
    required this.requesterName,
    required this.userType,
    required this.userId,
    required this.email,
    required this.year,
    required this.faculty,
  });
}

class AdminRequestsScreen extends StatefulWidget {
  final void Function(AdminTab) onNavigate; // Updated to AdminTab
  const AdminRequestsScreen({super.key, required this.onNavigate});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  // Mock data matching the Admin dashboard counts
  final List<_AdminRequest> _requests = [
    const _AdminRequest(
      id: '1', type: 'Password Reset',
      requesterName: 'Moaz Osama Gamil', userType: 'Student',
      userId: 'ST20222', email: 'MoazOsama@gmail.com', year: 4, faculty: 'ICT',
    ),
    const _AdminRequest(
      id: '2', type: 'Registration',
      requesterName: 'Ammar Tarek', userType: 'Student',
      userId: 'ST20195', email: 'AmmarTarek@gmail.com', year: 2, faculty: 'Science',
    ),
    const _AdminRequest(
      id: '3', type: 'Registration',
      requesterName: 'Youssef Salama', userType: 'Student',
      userId: 'ST20210', email: 'YoussefS@gmail.com', year: 1, faculty: 'Engineering',
    ),
  ];

  _AdminRequest? _selected;

  @override
  void initState() {
    super.initState();
    if (_requests.isNotEmpty) _selected = _requests.first;
  }

  void _handleAction() {
    if (_selected == null) return;
    setState(() {
      _requests.removeWhere((r) => r.id == _selected!.id);
      _selected = _requests.isNotEmpty ? _requests.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground( // Reusing the established background wrapper
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Requests', style: AppTextStyles.largeHeading),
            const SizedBox(height: 50),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT PANEL: List of Requests
                  Expanded(
                    flex: 4,
                    child: GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: _requests.isEmpty
                          ? const Center(child: Text('No pending requests', style: AppTextStyles.body))
                          : ListView.separated(
                        itemCount: _requests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final r = _requests[i];
                          return _AdminRequestTile(
                            request: r,
                            isSelected: _selected?.id == r.id,
                            onTap: () => setState(() => _selected = r),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // RIGHT PANEL: Details & Actions
                  Expanded(
                    flex: 5,
                    child: _selected == null
                        ? const GlassCard(child: Center(child: Text('Select a request', style: AppTextStyles.emptyStateStyle)))
                        : _AdminDetailPanel(
                      request: _selected!,
                      onApprove: _handleAction,
                      onReject: _handleAction,
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

// Sub-widgets specifically for Admin context

class _AdminRequestTile extends StatelessWidget {
  final _AdminRequest request;
  final bool isSelected;
  final VoidCallback onTap;

  const _AdminRequestTile({required this.request, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Icons based on type
    final IconData icon = request.type == 'Password Reset' ? Icons.lock_reset : Icons.assignment_ind_outlined;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.type, style: AppTextStyles.requestListTitleStyle),
                  Text('${request.requesterName} send a request', style: AppTextStyles.requestListNameStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDetailPanel extends StatelessWidget {
  final _AdminRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _AdminDetailPanel({required this.request, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(request.type == 'Password Reset' ? Icons.lock_reset : Icons.assignment_ind_outlined,
                  color: AppColors.primary, size: 40),
              const SizedBox(width: 14),
              Container(width: 2, height: 36, color: AppColors.divider),
              const SizedBox(width: 14),
              Text(request.type, style: AppTextStyles.requestDetailsHeaderStyle),
            ],
          ),
          const SizedBox(height: 28),
          _InfoRow(label: 'Requested by', value: request.requesterName, bold: true),
          const SizedBox(height: 14),
          _InfoRow(label: 'User Type', value: request.userType),
          const SizedBox(height: 10),
          _InfoRow(label: 'ID', value: request.userId),
          const SizedBox(height: 10),
          _InfoRow(label: 'Email', value: request.email),
          const SizedBox(height: 10),
          _InfoRow(label: 'Year', value: request.year.toString()),
          const SizedBox(height: 10),
          _InfoRow(label: 'Faculty', value: request.faculty),
          const Spacer(),
          Row(
            children: [
              Expanded(child: PillButton(label: 'Approve', onTap: onApprove)),
              const SizedBox(width: 16),
              Expanded(child: PillButton(label: 'Reject', onTap: onReject)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _InfoRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.requestDetailsInfoStyle,
        children: [
          TextSpan(text: '$label : ', style: AppTextStyles.infoRowLabelStyle),
          TextSpan(text: value, style: bold ? AppTextStyles.infoRowValueBoldStyle : AppTextStyles.infoRowValueStyle),
        ],
      ),
    );
  }
}