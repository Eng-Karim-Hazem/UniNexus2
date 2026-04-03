import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

import '../../../../services/firebase/it_logs_service.dart';

class ITHallErrorScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;
  const ITHallErrorScreen({super.key, required this.onNavigate});

  @override
  State<ITHallErrorScreen> createState() => _ITHallErrorScreenState();
}

class _ITHallErrorScreenState extends State<ITHallErrorScreen> {
  String? _selectedDocId;

  // Department Filter
  String _selectedDepartment = 'All';
  final List<String> _departments = ['All', 'IT', 'Storage', 'Maintenance'];

  // --- NEW: Status Filter ---
  String _selectedStatus = 'All';
  final List<String> _statuses = ['All', 'Pending', 'In repair', 'Fixed'];

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const PageHeading('Hall Errors'),
                _buildDepartmentFilter(),
              ],
            ),
            const SizedBox(height: 30),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left panel
                  Expanded(
                    flex: 45,
                    // --- FIX: Updated padding to 24 to perfectly match the right card ---
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: _buildErrorsListPanel(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right panel
                  Expanded(
                    flex: 55,
                    // --- FIX: This padding is also 24, so both sides align! ---
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: _selectedDocId != null
                          ? _buildDetailsPanel(_selectedDocId!)
                          : _buildEmptyPlaceholder("Select an error to view details"),
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

  Widget _buildErrorsListPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 4),
            child: _buildStatusFilter(),
          ),
        ),
        Divider(color: AppColors.primary.withValues(alpha: 0.2), height: 1),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('HallErrors').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const LoadingState();
              List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];

              if (_selectedDepartment != 'All') {
                docs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['department']?.toString().toLowerCase() ?? '') == _selectedDepartment.toLowerCase();
                }).toList();
              }
              if (_selectedStatus != 'All') {
                docs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status']?.toString().toLowerCase() ?? 'pending';
                  return status == _selectedStatus.toLowerCase();
                }).toList();
              }

              docs.sort((a, b) {
                final dataA = a.data() as Map<String, dynamic>;
                final dataB = b.data() as Map<String, dynamic>;
                final bool isFixedA = (dataA['status']?.toString().toLowerCase() ?? 'pending') == 'fixed';
                final bool isFixedB = (dataB['status']?.toString().toLowerCase() ?? 'pending') == 'fixed';
                if (isFixedA != isFixedB) return isFixedA ? 1 : -1;
                final Timestamp? timeA = dataA['timestamp'] as Timestamp?;
                final Timestamp? timeB = dataB['timestamp'] as Timestamp?;
                return (timeB ?? Timestamp.now()).compareTo(timeA ?? Timestamp.now());
              });

              if (docs.isEmpty) {
                if (_selectedDocId != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _selectedDocId = null);
                  });
                }
                return _buildEmptyPlaceholder("No issues reported");
              }

              final hasSelected = _selectedDocId != null && docs.any((d) => d.id == _selectedDocId);
              if (!hasSelected) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _selectedDocId = docs.first.id);
                });
              }

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: docs.length,
                itemBuilder: (context, index) => _buildErrorItem(docs[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  // Empty placeholder widget
  Widget _buildEmptyPlaceholder(String message) {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.layers_clear_outlined, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(message, style: AppTextStyles.hallListErrorStyle),
          ],
        ),
      ),
    );
  }

// Error item in list
  Widget _buildErrorItem(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final bool isSelected = _selectedDocId == doc.id;
    final String status = (data['status']?.toString().toLowerCase() ?? 'pending');
    final bool isFixed = status == 'fixed';

    return GestureDetector(
      onTap: () => setState(() => _selectedDocId = doc.id),
      child: Opacity(
        opacity: isFixed ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: AppDecorations.smallCard(isSelected: isSelected),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: StatusBadge(
                    status: isFixed ? 'fixed' : status,
                    showIcon: true,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: 12),
                // --- FIX: Added vertical padding so the line isn't too tall! ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Container(width: 1.5, color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['hallName'] ?? 'Unknown', style: AppTextStyles.hallListNumberStyle),
                      const SizedBox(height: 2),
                      Text(data['errorType'] ?? 'Unknown Issue',
                          style: AppTextStyles.hallListErrorStyle,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsPanel(String docId) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('HallErrors')
          .doc(docId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildEmptyPlaceholder("Select an error to view details");
        }

        final data = snapshot.data!.data()!;
        final docRef = snapshot.data!.reference;
        return _buildDetailsContent(docRef, data);
      },
    );
  }

// Details content for selected error
  Widget _buildDetailsContent(
      DocumentReference<Map<String, dynamic>> docRef,
      Map<String, dynamic> data,
      ) {
    final String status = data['status']?.toString().toLowerCase() ?? 'pending';
    final String hallName = data['hallName'] ?? 'Unknown Hall';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center( // --- FIX: Centered the icon ---
                child: Icon(Icons.warning_amber_rounded, size: 40, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              // --- FIX: Added vertical padding so the line isn't too tall! ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Container(width: 2, color: AppColors.divider),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(hallName, style: AppTextStyles.hallDetailsNumberStyle),
                    const SizedBox(height: 4),
                    Text(data['errorType'] ?? 'No issue', style: AppTextStyles.hallDetailsErrorStyle),
                    const SizedBox(height: 12),
                    StatusBadge(status: status, isDot: false),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildImagePreview(data['attachment']),
        const SizedBox(height: 20),
        Text(data['description'] ?? 'No description.', style: AppTextStyles.hallDetailsDescriptionStyle),
        const Spacer(),
        if (status != 'fixed')
          Row(
            children: [
              Expanded(
                child: PillButton(
                    label: 'In Repair',
                    onTap: () async {
                      try {
                        await docRef.update({'status': 'in repair'});
                        await ITLogService.logAction('Marked $hallName issue as In Repair');
                        if (mounted) showSuccessSnackBar(context, 'Status updated to: In Repair');
                      } catch (e) {
                        if (mounted) showErrorSnackBar(context, 'Error updating status: $e');
                      }
                    }
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PillButton(
                    label: 'Fixed',
                    onTap: () async {
                      try {
                        await docRef.update({'status': 'fixed'});
                        await ITLogService.logAction('Resolved issue in $hallName');
                        if (mounted) showSuccessSnackBar(context, 'Status updated to: Fixed');
                      } catch (e) {
                        if (mounted) showErrorSnackBar(context, 'Error updating status: $e');
                      }
                    }
                ),
              ),
            ],
          ),
      ],
    );
  }

  // Image preview from base64
  Widget _buildImagePreview(dynamic attachment) {
    final String base64 = attachment?.toString() ?? '';
    return Container(
      width: double.infinity,
      height: 220,
      decoration: AppDecorations.blueScreen,
      child: base64.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.memory(base64Decode(base64), fit: BoxFit.cover),
      )
          : Center(child: Text('No Image Provided', style: AppTextStyles.blueScreenLabelStyle)),
    );
  }

  // Department filter buttons
  Widget _buildDepartmentFilter() {
    return Row(
      children: _departments.map((dept) {
        final isSelected = _selectedDepartment == dept;
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedDepartment = dept;
              _selectedDocId = null;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(dept, style: TextStyle(color: isSelected ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- NEW: Status filter buttons ---
  Widget _buildStatusFilter() {
    return Row(
      children: _statuses.map((status) {
        final isSelected = _selectedStatus == status;
        return Padding(
          padding: const EdgeInsets.only(right: 8), // Changed to right padding for horizontal flow
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedStatus = status;
              _selectedDocId = null;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(status, style: TextStyle(color: isSelected ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }).toList(),
    );
  }
}