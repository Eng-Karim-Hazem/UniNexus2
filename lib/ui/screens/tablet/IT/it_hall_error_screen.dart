import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

import '../../../../services/firebase/it_Logs_service.dart';

class ITHallErrorScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;
  const ITHallErrorScreen({super.key, required this.onNavigate});

  @override
  State<ITHallErrorScreen> createState() => _ITHallErrorScreenState();
}

class _ITHallErrorScreenState extends State<ITHallErrorScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading('Hall Errors'),
            const SizedBox(height: 45),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('HallErrors')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingState();
                  }

                  if (snapshot.hasError) {
                    return ErrorState(message: 'Error loading data: ${snapshot.error}');
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const EmptyState(
                      message: 'Hooray! No hall errors reported right now.',
                      icon: Icons.celebration,
                    );
                  }

                  final docs = snapshot.data!.docs.toList();

                  /// Sort: pending/in repair first, then by date
                  docs.sort((a, b) {
                    final dataA = a.data() as Map<String, dynamic>;
                    final dataB = b.data() as Map<String, dynamic>;

                    final statusA = dataA['status']?.toString().toLowerCase() ?? 'pending';
                    final statusB = dataB['status']?.toString().toLowerCase() ?? 'pending';

                    final bool isFixedA = statusA == 'fixed';
                    final bool isFixedB = statusB == 'fixed';

                    if (isFixedA != isFixedB) {
                      return isFixedA ? 1 : -1;
                    }

                    final Timestamp? timeA = dataA['timestamp'] as Timestamp?;
                    final Timestamp? timeB = dataB['timestamp'] as Timestamp?;

                    if (timeA != null && timeB != null) {
                      return timeB.compareTo(timeA);
                    }
                    return 0;
                  });

                  if (_selectedIndex >= docs.length) {
                    _selectedIndex = 0;
                  }

                  final selectedDoc = docs[_selectedIndex];
                  final Map<String, dynamic> selectedData = selectedDoc.data() as Map<String, dynamic>;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// Left panel - error list
                      Expanded(
                        flex: 45,
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final docData = docs[index].data() as Map<String, dynamic>;
                              final hallName = docData['hallName'] ?? 'Unknown';
                              final errorType = docData['errorType'] ?? 'Unknown Issue';
                              final attachment = docData['attachment']?.toString() ?? '';
                              final hasAttachment = attachment.isNotEmpty;

                              final statusStr = docData['status']?.toString().toLowerCase() ?? 'pending';
                              final isFixed = statusStr == 'fixed';
                              final isSelected = _selectedIndex == index;

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
                                        isFixed
                                            ? const Icon(Icons.check_circle_outline, size: 28, color: Colors.green)
                                            : Image.asset('assets/icons/warning.png',
                                            width: 28, height: 28,
                                            errorBuilder: (_, __, ___) => const Icon(
                                                Icons.warning_amber_rounded,
                                                size: 28, color: AppColors.primary)),
                                        const SizedBox(width: 12),
                                        Container(
                                            width: 1.5,
                                            height: 38,
                                            color: isFixed ? Colors.grey.withOpacity(0.3) : AppColors.primary.withOpacity(0.3)
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  hallName,
                                                  style: AppTextStyles.hallListNumberStyle.copyWith(
                                                    decoration: isFixed ? TextDecoration.lineThrough : null,
                                                    color: isFixed ? Colors.grey : null,
                                                  )
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                  errorType,
                                                  style: AppTextStyles.hallListErrorStyle.copyWith(
                                                    decoration: isFixed ? TextDecoration.lineThrough : null,
                                                    color: isFixed ? Colors.grey : null,
                                                  ),
                                                  overflow: TextOverflow.ellipsis
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (hasAttachment)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 6),
                                            child: Icon(Icons.attach_file,
                                                size: 26, color: isFixed ? Colors.grey : AppColors.textLight),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      /// Right panel - error details
                      Expanded(
                        flex: 55,
                        child: GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Header
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset('assets/icons/warning.png',
                                        width: 40, height: 40,
                                        errorBuilder: (_, __, ___) => const Icon(
                                            Icons.warning_amber_rounded,
                                            size: 40, color: AppColors.primary)),
                                    const SizedBox(width: 16),
                                    Container(width: 2, height: 50, color: AppColors.divider),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(selectedData['hallName'] ?? 'Unknown Hall',
                                              style: AppTextStyles.hallDetailsNumberStyle),
                                          const SizedBox(height: 4),
                                          Text(selectedData['errorType'] ?? 'No issue specified',
                                              style: AppTextStyles.hallDetailsErrorStyle),
                                          const SizedBox(height: 10),
                                          StatusBadge(
                                            status: selectedData['status']?.toString() ?? 'pending',
                                            isDot: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                /// Image attachment
                                Builder(
                                    builder: (context) {
                                      final attachmentStr = selectedData['attachment']?.toString() ?? '';
                                      if (attachmentStr.isNotEmpty) {
                                        return Container(
                                          width: double.infinity,
                                          height: 220,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(14),
                                            child: Image.memory(
                                              base64Decode(attachmentStr),
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const Center(child: Text("Invalid Image Data")),
                                            ),
                                          ),
                                        );
                                      }
                                      return Container(
                                        width: double.infinity,
                                        height: 220,
                                        decoration: AppDecorations.blueScreen,
                                        child: Center(
                                          child: Container(
                                            width: 260, height: 155,
                                            decoration: AppDecorations.innerBlueScreen,
                                            child: Center(
                                              child: Text('No Image Provided', style: AppTextStyles.blueScreenLabelStyle),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                ),
                                const SizedBox(height: 20),

                                /// Description
                                Text(selectedData['description'] ?? 'No description provided.',
                                    style: AppTextStyles.hallDetailsDescriptionStyle),
                                const Spacer(),

                                /// Action buttons
                                if (selectedData['status']?.toString().toLowerCase() != 'fixed')
                                  Row(
                                    children: [
                                      Expanded(
                                        child: PillButton(
                                            label: 'In Repair',
                                            onTap: () async {
                                              try {
                                                await selectedDoc.reference.update({'status': 'in repair'});
                                                await ITLogService.logAction('Hall ${selectedData['hallName']} marked as in repair');
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Status updated to: In Repair')),
                                                  );
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Error updating status: $e')),
                                                  );
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
                                                await selectedDoc.reference.update({'status': 'fixed'});
                                                await ITLogService.logAction('Hall ${selectedData['hallName']} marked as fixed');
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Status updated to: Fixed')),
                                                  );
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Error updating status: $e')),
                                                  );
                                                }
                                              }
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
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
}