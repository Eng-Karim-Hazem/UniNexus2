import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../admin_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class AdminReceivedNoticesScreen extends StatefulWidget {
  final void Function(AdminTab) onNavigate;

  const AdminReceivedNoticesScreen({super.key, required this.onNavigate});

  @override
  State<AdminReceivedNoticesScreen> createState() => _AdminReceivedNoticesScreenState();
}

class _AdminReceivedNoticesScreenState extends State<AdminReceivedNoticesScreen> {
  String _adminId = '';

  @override
  void initState() {
    super.initState();
    _loadAdminId();
  }

  // Load admin ID from preferences
  Future<void> _loadAdminId() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _adminId = (prefs.getString('ID') ?? '').trim();
    });
  }

  // Check if notice is for current admin
  bool _isReceivedByCurrentAdmin(Map<String, dynamic> data) {
    final List<String> recipientIds = List<String>.from(data['recipientIds'] ?? const []);
    final String legacyRecipientId = (data['ID'] ?? '').toString().trim();
    final String type = (data['type'] ?? '').toString().toLowerCase();
    final String targetValue = (data['targetValue'] ?? '').toString().toLowerCase();
    final bool sentToMe = recipientIds.contains(_adminId) || legacyRecipientId == _adminId;
    final bool sentToAdminGroup = type == 'group' && targetValue == 'admin';
    return sentToMe || sentToAdminGroup;
  }

  // Format date for display
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final mo = date.month.toString().padLeft(2, '0');
    return '$dd/$mo/${date.year} $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading('Received Notices'),
            const SizedBox(height: 40),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('Notifications')
                            .orderBy('date', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const LoadingState();
                          }

                          if (snapshot.hasError) {
                            return const ErrorState(
                              message: 'Error loading notices.',
                            );
                          }

                          // Filter notices for current admin
                          final docs = (snapshot.data?.docs ?? const [])
                              .where((doc) => _isReceivedByCurrentAdmin(doc.data()))
                              .toList();

                          if (docs.isEmpty) {
                            return const EmptyState(
                              message: 'No received notices yet.',
                              icon: Icons.inbox,
                            );
                          }

                          return ListView.separated(
                            itemCount: docs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final data = docs[index].data();
                              final sender = (data['sentBy'] ?? 'Management').toString();
                              final message = (data['description'] ?? '').toString();
                              final when = _formatDate(data['date'] as Timestamp?);

                              return Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.notifications_none_rounded,
                                        color: AppColors.primary, size: 28),
                                    const SizedBox(width: 20),
                                    const Text('|', style: TextStyle(fontSize: 24, color: Colors.grey)),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(child: Text(sender, style: AppTextStyles.senderStyle)),
                                              Text(when, style: AppTextStyles.caption),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(message, style: AppTextStyles.bodySmall),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 300),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}