import 'package:flutter/material.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

// Data model

class _UserRequest {
  final String id;
  final String type;
  final String requesterName;
  final String userType;
  final String userId;
  final String email;
  final int year;
  final String faculty;

  const _UserRequest({
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

// Screen

class ITRequestsScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;
  const ITRequestsScreen({super.key, required this.onNavigate});

  @override
  State<ITRequestsScreen> createState() => _ITRequestsScreenState();
}

class _ITRequestsScreenState extends State<ITRequestsScreen> {
  final List<_UserRequest> _requests = [
    const _UserRequest(
      id: '1', type: 'Password Reset',
      requesterName: 'Moaz Osama Gamil', userType: 'Student',
      userId: 'ST20222', email: 'MoazOsama@gmail.com', year: 4, faculty: 'ICT',
    ),
    const _UserRequest(
      id: '2', type: 'Password Reset',
      requesterName: 'Eslam Bahy', userType: 'Student',
      userId: 'ST20180', email: 'EslamBahy@gmail.com', year: 3, faculty: 'Engineering',
    ),
    const _UserRequest(
      id: '3', type: 'Password Reset',
      requesterName: 'Ammar Tarek', userType: 'Student',
      userId: 'ST20195', email: 'AmmarTarek@gmail.com', year: 2, faculty: 'Science',
    ),
    const _UserRequest(
      id: '4', type: 'Password Reset',
      requesterName: 'Hossam Medhat', userType: 'Staff',
      userId: 'ST20100', email: 'HossamMedhat@gmail.com', year: 1, faculty: 'Arts',
    ),
  ];

  _UserRequest? _selected;

  @override
  void initState() {
    super.initState();
    if (_requests.isNotEmpty) _selected = _requests.first;
  }

  void _approve() {
    if (_selected == null) return;
    setState(() {
      _requests.removeWhere((r) => r.id == _selected!.id);
      _selected = _requests.isNotEmpty ? _requests.first : null;
    });
  }

  void _reject() {
    if (_selected == null) return;
    setState(() {
      _requests.removeWhere((r) => r.id == _selected!.id);
      _selected = _requests.isNotEmpty ? _requests.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('User Requests', style: AppTextStyles.largeHeading),
            const SizedBox(height: 45),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left panel
                  Expanded(
                    flex: 45,
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: _requests.isEmpty
                          ? Center(
                          child: Text('No pending requests',
                              style: AppTextStyles.emptyStateStyle))
                          : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _requests.length,
                        itemBuilder: (_, i) {
                          final r = _requests[i];
                          return _RequestTile(
                            request: r,
                            isSelected: _selected?.id == r.id,
                            onTap: () => setState(() => _selected = r),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Right panel
                  Expanded(
                    flex: 55,
                    child: _selected == null
                        ? GlassCard(
                      child: Center(
                        child: Text(
                          'Select a request to view details',
                          style: AppTextStyles.emptyStateStyle,
                        ),
                      ),
                    )
                        : _RequestDetailPanel(
                      request: _selected!,
                      onApprove: _approve,
                      onReject: _reject,
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

// Request tile

class _RequestTile extends StatelessWidget {
  final _UserRequest request;
  final bool isSelected;
  final VoidCallback onTap;

  const _RequestTile({
    required this.request,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: AppDecorations.smallCard(isSelected: isSelected),
        child: Row(
          children: [
            Image.asset(
              'assets/icons/rotation_lock.png',
              width: 28, height: 28,
              fit: BoxFit.contain,
              color: AppColors.primary,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.lock_reset_rounded, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 12),
            Container(
              width: 1.5,
              height: 38,
              color: AppColors.primary.withOpacity(0.3),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.type, style: AppTextStyles.requestListTitleStyle),
                  const SizedBox(height: 2),
                  Text(
                    '${request.requesterName} send a request',
                    style: AppTextStyles.requestListNameStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

// Request detail panel

class _RequestDetailPanel extends StatelessWidget {
  final _UserRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RequestDetailPanel({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/icons/rotation_lock.png',
                width: 40, height: 40,
                fit: BoxFit.contain,
                color: AppColors.primary,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.lock_reset_rounded, color: AppColors.primary, size: 40),
              ),
              const SizedBox(width: 16),
              Container(width: 2, height: 50, color: AppColors.divider),
              const SizedBox(width: 16),
              Expanded(
                child: Text(request.type, style: AppTextStyles.requestDetailsHeaderStyle),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Fields
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

          // Buttons
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

// Info row widget

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.requestDetailsInfoStyle,
        children: [
          TextSpan(
            text: '$label : ',
            style: AppTextStyles.infoRowLabelStyle,
          ),
          TextSpan(
            text: value,
            style: bold
                ? AppTextStyles.infoRowValueBoldStyle
                : AppTextStyles.infoRowValueStyle,
          ),
        ],
      ),
    );
  }
}