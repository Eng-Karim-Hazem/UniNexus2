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
// Helper to color-code the status badges
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'fixed':
        return Colors.green;
      case 'in repair':
        return Colors.orange;
      case 'informed':
      case 'pending':
        return AppColors.primary; // Or Colors.blue
      default:
        return Colors.grey;
    }
  }
  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hall Errors', style: AppTextStyles.largeHeading),
            const SizedBox(height: 45),

            Expanded(
              // --- FIREBASE STREAM BUILDER ---
              child: StreamBuilder<QuerySnapshot>(
                // Listening to the 'HallErrors' collection, newest first
                stream: FirebaseFirestore.instance
                    .collection('HallErrors')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {

                  // 1. Handle Loading State
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 2. Handle Error State
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading data: ${snapshot.error}'));
                  }

                  // 3. Handle Empty State
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Hooray! No hall errors reported right now.',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  // Safety check: if a document is deleted, the index might go out of bounds
                  if (_selectedIndex >= docs.length) {
                    _selectedIndex = 0;
                  }

                  // Get the currently selected document for the Right Panel
                  final selectedDoc = docs[_selectedIndex];
                  final Map<String, dynamic> selectedData = selectedDoc.data() as Map<String, dynamic>;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      // --- LEFT PANEL: ERROR LIST ---
                      Expanded(
                        flex: 45,
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: docs.length,
                            itemBuilder: (context, index) {

                              // Extract data from Firestore document
                              final docData = docs[index].data() as Map<String, dynamic>;
                              final hallName = docData['hallName'] ?? 'Unknown';
                              final errorType = docData['errorType'] ?? 'Unknown Issue';
                              final attachment = docData['attachment']?.toString() ?? '';
                              final hasAttachment = attachment.isNotEmpty;

                              // Check if the status is fixed
                              final statusStr = docData['status']?.toString().toLowerCase() ?? 'pending';
                              final isFixed = statusStr == 'fixed';

                              final isSelected = _selectedIndex == index;

                              return GestureDetector(
                                onTap: () => setState(() => _selectedIndex = index),
                                child: Opacity(
                                  // Dim the entire card slightly if it's already fixed
                                  opacity: isFixed ? 0.6 : 1.0,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: AppDecorations.smallCard(isSelected: isSelected),
                                    child: Row(
                                      children: [

                                        // Change the icon to a checkmark if fixed, otherwise keep the warning
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
                                                    // Add the strikethrough here
                                                    decoration: isFixed ? TextDecoration.lineThrough : null,
                                                    color: isFixed ? Colors.grey : null,
                                                  )
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                  errorType,
                                                  style: AppTextStyles.hallListErrorStyle.copyWith(
                                                    // And add the strikethrough here
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

                      // --- RIGHT PANEL: ERROR DETAIL ---
                      Expanded(
                        flex: 55,
                        child: GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // HEADER
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
                                    // ... (Image warning icon and divider are above this) ...
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

                                          // --- THE NEW DYNAMIC STATUS BADGE ---
                                          Builder(
                                              builder: (context) {
                                                final statusStr = selectedData['status']?.toString() ?? 'pending';
                                                final badgeColor = _getStatusColor(statusStr);

                                                return Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: badgeColor.withOpacity(0.15),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: badgeColor.withOpacity(0.5)),
                                                  ),
                                                  child: Text(
                                                    statusStr.toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 0.5,
                                                      color: badgeColor,
                                                    ),
                                                  ),
                                                );
                                              }
                                          ),
                                          // ------------------------------------

                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // IMAGE ATTACHMENT OR FALLBACK
                                Builder(
                                    builder: (context) {
                                      final attachmentStr = selectedData['attachment']?.toString() ?? '';

                                      // If there is a Base64 image, decode and show it
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

                                      // Otherwise, show your original Blue Screen UI
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

                                // DESCRIPTION
                                Text(selectedData['description'] ?? 'No description provided.',
                                    style: AppTextStyles.hallDetailsDescriptionStyle),

                                const Spacer(),

                                // ACTION BUTTONS
                                Row(
                                  children: [
                                    Expanded(
                                      child: PillButton(
                                          label: 'In Repair',
                                          onTap: () async {
                                            try {
                                              // Update the status field in Firestore
                                              await selectedDoc.reference.update({'status': 'in repair'});

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
                                              // Update the status field in Firestore
                                              await selectedDoc.reference.update({'status': 'fixed'});

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