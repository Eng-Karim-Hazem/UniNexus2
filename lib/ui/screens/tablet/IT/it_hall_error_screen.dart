import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class ITHallErrorScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;
  const ITHallErrorScreen({super.key, required this.onNavigate});

  @override
  State<ITHallErrorScreen> createState() => _ITHallErrorScreenState();
}

class _ITHallErrorScreenState extends State<ITHallErrorScreen> {
  int _selectedIndex = 0;
  String _selectedDepartment = 'All';
  final List<String> _departments = ['All', 'IT', 'Storage', 'Maintenance'];

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
              children: [
                const PageHeading('Hall Errors'),
                _buildDepartmentFilter(),
              ],
            ),
            const SizedBox(height: 45),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('HallErrors')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingState(); // Assuming this is defined in your theme
                  }

                  List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];

                  // Filter by department
                  if (_selectedDepartment != 'All') {
                    docs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return (data['department']?.toString().toLowerCase() ?? '') ==
                          _selectedDepartment.toLowerCase();
                    }).toList();
                  }

                  // Sort: pending first, then by date
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

                  if (_selectedIndex >= docs.length) _selectedIndex = 0;

                  final bool hasData = docs.isNotEmpty;
                  final Map<String, dynamic>? selectedData = hasData
                      ? docs[_selectedIndex].data() as Map<String, dynamic>
                      : null;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left panel - Error list
                      Expanded(
                        flex: 45,
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: hasData
                              ? ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: docs.length,
                            itemBuilder: (context, index) => _buildErrorItem(docs[index], index),
                          )
                              : _buildEmptyPlaceholder("No issues reported"),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Right panel - Error details
                      Expanded(
                        flex: 55,
                        child: GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: hasData && selectedData != null
                              ? _buildDetailsContent(docs[_selectedIndex], selectedData)
                              : _buildEmptyPlaceholder("Select an error to view details"),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
  Widget _buildErrorItem(QueryDocumentSnapshot doc, int index) {
    final data = doc.data() as Map<String, dynamic>;
    final bool isSelected = _selectedIndex == index;
    final String status = (data['status']?.toString().toLowerCase() ?? 'pending');
    final bool isFixed = status == 'fixed';

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Opacity(
        opacity: isFixed ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: AppDecorations.smallCard(isSelected: isSelected),
          child: Row(
            children: [
              StatusBadge(
                status: isFixed ? 'fixed' : 'pending',
                showIcon: true,
                isCompact: true,
              ),
              const SizedBox(width: 12),
              Container(width: 1.5, height: 38, color: AppColors.primary.withValues(alpha: 0.3)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
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
    );
  }

  // Details content for selected error
  Widget _buildDetailsContent(QueryDocumentSnapshot doc, Map<String, dynamic> data) {
    final String status = data['status']?.toString().toLowerCase() ?? 'pending';
    final String hallName = data['hallName'] ?? 'Unknown Hall';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 40, color: AppColors.primary),
            const SizedBox(width: 16),
            Container(width: 2, height: 50, color: AppColors.divider),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 24),
        _buildImagePreview(data['attachment']),
        const SizedBox(height: 20),
        Text(data['description'] ?? 'No description.', style: AppTextStyles.hallDetailsDescriptionStyle),
        const Spacer(),
        // Action buttons for pending errors
        if (status != 'fixed')
          Row(
            children: [
              Expanded(
                child: PillButton(
                    label: 'In Repair',
                    onTap: () async {
                      try {
                        // 1. Update the error status
                        await doc.reference.update({'status': 'in repair'});

                        // 2. Log the action to IT_Logs
                        await FirebaseFirestore.instance.collection('IT_Logs').add({
                          'message': 'Marked $hallName issue as In Repair',
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        if (mounted) {
                          showSuccessSnackBar(context, 'Status updated to: In Repair');
                        }
                      } catch (e) {
                        if (mounted) {
                          showErrorSnackBar(context, 'Error updating status: $e');
                        }
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
                        // 1. Update the error status
                        await doc.reference.update({'status': 'fixed'});

                        // 2. Log the action to IT_Logs
                        await FirebaseFirestore.instance.collection('IT_Logs').add({
                          'message': 'Resolved issue in $hallName',
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        if (mounted) {
                          showSuccessSnackBar(context, 'Status updated to: Fixed');
                        }
                      } catch (e) {
                        if (mounted) {
                          showErrorSnackBar(context, 'Error updating status: $e');
                        }
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
              _selectedIndex = 0;
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
}