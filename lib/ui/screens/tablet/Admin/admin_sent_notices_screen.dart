import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../admin_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class AdminSentNoticesScreen extends StatefulWidget {
  final void Function(AdminTab) onNavigate;

  const AdminSentNoticesScreen({super.key, required this.onNavigate});

  @override
  State<AdminSentNoticesScreen> createState() => _AdminSentNoticesScreenState();
}

class _AdminSentNoticesScreenState extends State<AdminSentNoticesScreen> {
  String _senderName = 'Admin';
  String _adminId = '';

  @override
  void initState() {
    super.initState();
    _loadSender();
  }

  // Load admin name and ID from preferences
  Future<void> _loadSender() async {
    final prefs = await SharedPreferences.getInstance();
    final String firstName = (prefs.getString('fName') ?? '').trim();
    final String lastName = (prefs.getString('lName') ?? '').trim();
    final String id = (prefs.getString('ID') ?? '').trim();
    final String fullName = '$firstName $lastName'.trim();
    if (!mounted) return;
    setState(() {
      _senderName = fullName.isEmpty ? 'Admin' : fullName;
      _adminId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading('Sent Notices'),
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

                          // Filter notices sent by current admin
                          final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = (snapshot.data?.docs ?? const [])
                              .where((doc) {
                            final data = doc.data();
                            final sender = (data['sentBy'] ?? data['sender'] ?? '').toString().trim();
                            final legacyId = (data['senderId'] ?? '').toString().trim();
                            return sender == _senderName || (_adminId.isNotEmpty && legacyId == _adminId);
                          }).toList();

                          if (docs.isEmpty) {
                            return const EmptyState(
                              message: 'No sent notices yet.',
                              icon: Icons.send,
                            );
                          }

                          return ListView.separated(
                            itemCount: docs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final Map<String, dynamic> data = docs[index].data();
                              final String sender = (data['sentBy'] ?? data['sender'] ?? 'Admin').toString();
                              final String message = (data['description'] ?? data['message'] ?? '').toString();

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
                                          Text(sender, style: AppTextStyles.senderStyle),
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