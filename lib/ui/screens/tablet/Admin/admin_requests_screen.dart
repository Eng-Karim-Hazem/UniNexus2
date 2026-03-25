import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../admin_tab.dart';
import '../../../../services/firebase/it_Logs_service.dart';
import 'package:uninexus/theme/app_theme.dart';

class AdminRequestsScreen extends StatefulWidget {
  final void Function(AdminTab) onNavigate;
  const AdminRequestsScreen({super.key, required this.onNavigate});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  static const String _pendingRequestSelectionKey = 'admin_selected_request_id';
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);
  String? _pendingRequestId;

  @override
  void initState() {
    super.initState();
    _loadPendingSelection();
  }

  Future<void> _loadPendingSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_pendingRequestSelectionKey);
    if (!mounted) return;
    setState(() => _pendingRequestId = saved);
  }

  @override
  void dispose() {
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown Date';
    final DateTime date = timestamp.toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} at '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<Map<String, dynamic>?> _fetchUserDetails(String emailOrId, String expectedRole) async {
    if (emailOrId.isEmpty) return null;

    final isEmail = emailOrId.contains('@');
    final queryField = isEmail ? 'email' : 'ID';
    final searchValue = isEmail ? emailOrId.toLowerCase() : emailOrId.toUpperCase();

    final collections = expectedRole.isNotEmpty
        ? [expectedRole, 'students', 'faculty', 'staff']
        : ['students', 'faculty', 'staff'];

    for (final col in collections) {
      try {
        final query = await FirebaseFirestore.instance
            .collection(col)
            .where(queryField, isEqualTo: searchValue)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          final data = query.docs.first.data();
          data['foundRole'] = col;
          return data;
        }
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  Future<void> _updateRequestStatus(DocumentSnapshot doc, String status, {required bool isPasswordRequest}) async {
    try {
      final data = doc.data() as Map<String, dynamic>;

      if (status == 'accepted' && isPasswordRequest) {
        final newPassword = data['newPassword'];
        final userRole = data['userRole'];
        final userDocRef = data['userDocRef'];

        if (newPassword != null && userRole != null && userDocRef != null) {
          await FirebaseFirestore.instance.collection(userRole).doc(userDocRef).update({'pass': newPassword});
        } else {
          throw Exception('Missing user reference or password data in this request.');
        }
      }

      await doc.reference.update({'isProcessed': true, 'status': status});

      final userId = data['emailOrId'] ?? data['fullName'] ?? data['name'] ?? 'Unknown User';
      final actionStr = status == 'accepted' ? 'approved' : 'rejected';
      final requestType = isPasswordRequest ? 'Password reset' : 'Registration';
      await ITLogService.logAction('$requestType request $actionStr for $userId');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'accepted' ? 'Request Approved!' : 'Request Rejected',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
            const Text('User Requests', style: AppTextStyles.largeHeading),
            const SizedBox(height: 45),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('ForgotPass_request').snapshots(),
                builder: (context, passSnapshot) {
                  if (passSnapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingState();
                  }
                  if (passSnapshot.hasError) {
                    return ErrorState(message: 'Error loading requests: ${passSnapshot.error}');
                  }
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection('registration_requests').snapshots(),
                    builder: (context, regSnapshot) {
                      if (regSnapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingState();
                      }
                      if (regSnapshot.hasError) {
                        return ErrorState(message: 'Error loading requests: ${regSnapshot.error}');
                      }

                      final List<Map<String, dynamic>> requestItems = [
                        ...(passSnapshot.data?.docs ?? const []).map((doc) => {
                          'id': doc.id,
                          'doc': doc,
                          'data': doc.data(),
                          'kind': 'password',
                        }),
                        ...(regSnapshot.data?.docs ?? const []).map((doc) => {
                          'id': doc.id,
                          'doc': doc,
                          'data': doc.data(),
                          'kind': 'registration',
                        }),
                      ];

                      requestItems.sort((a, b) {
                        final dataA = a['data'] as Map<String, dynamic>;
                        final dataB = b['data'] as Map<String, dynamic>;
                        final tsA = (dataA['requestDate'] ?? dataA['date']) as Timestamp?;
                        final tsB = (dataB['requestDate'] ?? dataB['date']) as Timestamp?;
                        if (tsA != null && tsB != null) return tsB.compareTo(tsA);
                        return 0;
                      });

                      if (requestItems.isEmpty) {
                        return const EmptyState(message: 'No requests found.');
                      }

                      if (_pendingRequestId != null && _pendingRequestId!.isNotEmpty) {
                        final idx = requestItems.indexWhere((item) => item['id'] == _pendingRequestId);
                        if (idx != -1) {
                          _selectedIndexNotifier.value = idx;
                        }
                        SharedPreferences.getInstance().then((prefs) => prefs.remove(_pendingRequestSelectionKey));
                        _pendingRequestId = null;
                      }

                      if (_selectedIndexNotifier.value >= requestItems.length) {
                        _selectedIndexNotifier.value = 0;
                      }

                      return ValueListenableBuilder<int>(
                        valueListenable: _selectedIndexNotifier,
                        builder: (context, selectedIndex, _) {
                          final selectedItem = requestItems[selectedIndex];
                          final selectedDoc = selectedItem['doc'] as DocumentSnapshot;
                          final selectedData = selectedItem['data'] as Map<String, dynamic>;
                          final isPasswordRequest = selectedItem['kind'] == 'password';

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 45,
                                child: GlassCard(
                                  padding: const EdgeInsets.all(12),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: requestItems.length,
                                    itemBuilder: (context, index) {
                                      final item = requestItems[index];
                                      final docData = item['data'] as Map<String, dynamic>;
                                      final isPassword = item['kind'] == 'password';
                                      final emailOrId = isPassword
                                          ? (docData['emailOrId'] ?? 'Unknown User')
                                          : (docData['fullName'] ?? docData['name'] ?? 'Unknown User');
                                      final reqDate = _formatDate((docData['requestDate'] ?? docData['date']) as Timestamp?);

                                      final statusStr = docData['status']?.toString().toLowerCase() ??
                                          (docData['isProcessed'] == true ? 'processed' : 'pending');
                                      final isResolved =
                                          statusStr == 'accepted' || statusStr == 'rejected' || statusStr == 'processed';
                                      final isSelected = selectedIndex == index;

                                      return GestureDetector(
                                        onTap: () => _selectedIndexNotifier.value = index,
                                        child: Opacity(
                                          opacity: isResolved ? 0.6 : 1,
                                          child: Container(
                                            margin: const EdgeInsets.only(bottom: 10),
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                            decoration: AppDecorations.smallCard(isSelected: isSelected),
                                            child: Row(
                                              children: [
                                                isResolved
                                                    ? Icon(
                                                  statusStr == 'rejected'
                                                      ? Icons.cancel_outlined
                                                      : Icons.check_circle_outline,
                                                  size: 28,
                                                  color: statusStr == 'rejected' ? Colors.red : Colors.green,
                                                )
                                                    : Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary.withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.person_outline,
                                                    size: 24,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Container(
                                                  width: 1.5,
                                                  height: 38,
                                                  color: isResolved
                                                      ? Colors.grey.withOpacity(0.3)
                                                      : AppColors.primary.withOpacity(0.3),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        isPassword ? emailOrId : '$emailOrId (Registration)',
                                                        style: AppTextStyles.hallListNumberStyle.copyWith(
                                                          decoration: isResolved ? TextDecoration.lineThrough : null,
                                                          color: isResolved ? Colors.grey : null,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(reqDate, style: AppTextStyles.caption),
                                                    ],
                                                  ),
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
                              Expanded(
                                flex: 55,
                                child: GlassCard(
                                  child: Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              isPasswordRequest ? Icons.lock_reset_rounded : Icons.how_to_reg_rounded,
                                              size: 36,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 16),
                                            Text(
                                              isPasswordRequest ? 'Password Reset' : 'Registration Request',
                                              style: AppTextStyles.heading.copyWith(
                                                color: AppColors.primary,
                                                fontSize: 24,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 30),
                                        Expanded(
                                          child: isPasswordRequest
                                              ? FutureBuilder<Map<String, dynamic>?>(
                                            future: _fetchUserDetails(
                                              selectedData['emailOrId']?.toString() ?? '',
                                              selectedData['userRole']?.toString() ?? '',
                                            ),
                                            builder: (context, userSnap) {
                                              if (userSnap.connectionState == ConnectionState.waiting) {
                                                return const LoadingState(isCentered: false);
                                              }

                                              if (!userSnap.hasData || userSnap.data == null) {
                                                return Text(
                                                  "Warning: User '${selectedData['emailOrId']}' could not be found in any database collection.",
                                                  style: const TextStyle(color: Colors.red),
                                                );
                                              }

                                              final userData = userSnap.data!;
                                              final fName = userData['fName'] ?? '';
                                              final lName = userData['lName'] ?? '';
                                              final fullName = '$fName $lName'.trim();
                                              final foundRole = userData['foundRole'] ?? 'Unknown';

                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  buildFigmaDetailRow('Requested by', fullName.isEmpty ? 'Unknown' : fullName),
                                                  buildFigmaDetailRow('User Type', _capitalize(foundRole)),
                                                  buildFigmaDetailRow(
                                                    'ID',
                                                    userData['ID'] ?? selectedData['emailOrId'] ?? 'N/A',
                                                  ),
                                                  buildFigmaDetailRow('Email', userData['email'] ?? 'N/A'),
                                                  buildFigmaDetailRow(
                                                    'New Password',
                                                    selectedData['newPassword'] ?? 'Not provided',
                                                  ),
                                                  if (userData.containsKey('year'))
                                                    buildFigmaDetailRow('Year', userData['year'].toString()),
                                                  if (userData.containsKey('faculty'))
                                                    buildFigmaDetailRow('Faculty', userData['faculty']),
                                                  const SizedBox(height: 20),
                                                  buildFigmaDetailRow(
                                                    'Time of Request',
                                                    _formatDate(selectedData['requestDate'] as Timestamp?),
                                                  ),
                                                ],
                                              );
                                            },
                                          )
                                              : Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              buildFigmaDetailRow('Requested by', (selectedData['fullName'] ?? selectedData['name'] ?? 'Unknown').toString()),
                                              buildFigmaDetailRow('Email', (selectedData['email'] ?? 'N/A').toString()),
                                              buildFigmaDetailRow('ID', (selectedData['ID'] ?? 'N/A').toString()),
                                              if (selectedData['faculty'] != null)
                                                buildFigmaDetailRow('Faculty', selectedData['faculty'].toString()),
                                              if (selectedData['year'] != null)
                                                buildFigmaDetailRow('Year', selectedData['year'].toString()),
                                              const SizedBox(height: 20),
                                              buildFigmaDetailRow(
                                                'Time of Request',
                                                _formatDate((selectedData['requestDate'] ?? selectedData['date']) as Timestamp?),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (selectedData['isProcessed'] != true)
                                          Row(
                                            children: [
                                              Expanded(
                                                child: PillButton(
                                                  label: 'Reject',
                                                  onTap: () => _updateRequestStatus(
                                                    selectedDoc,
                                                    'rejected',
                                                    isPasswordRequest: isPasswordRequest,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: PillButton(
                                                  label: 'Approve',
                                                  onTap: () => _updateRequestStatus(
                                                    selectedDoc,
                                                    'accepted',
                                                    isPasswordRequest: isPasswordRequest,
                                                  ),
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
                      );
                    },
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