import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../admin_tab.dart';
import '../../../../services/firebase/it_logs_service.dart';
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

  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Pending', 'Accepted', 'Rejected'];

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
      final bool isAccepted = status == 'accepted';

      if (isPasswordRequest) {
        // Password Reset logic
        if (isAccepted) {
          final newPassword = data['newPassword'];
          final userRole = data['userRole'];
          final userDocRef = data['userDocRef'];

          if (newPassword != null && userRole != null && userDocRef != null) {
            await FirebaseFirestore.instance.collection(userRole).doc(userDocRef).update({'pass': newPassword});
          }
        }
      } else {
        // Registration Logic: Update isRegistered AND app fields
        final String? universityId = data['universityId']?.toString();
        if (universityId != null) {
          final studentQuery = await FirebaseFirestore.instance
              .collection('students')
              .where('ID', isEqualTo: universityId)
              .limit(1)
              .get();

          if (studentQuery.docs.isNotEmpty) {
            await studentQuery.docs.first.reference.update({
              'isRegistered': isAccepted,
              'app': isAccepted,
            });
          }
        }
      }

      // Mark the request itself as processed
      await doc.reference.update({'isProcessed': true, 'status': status});

      final identifier = data['universityId'] ?? data['emailOrId'] ?? 'User';
      final actionStr = isAccepted ? 'approved' : 'rejected';
      final requestType = isPasswordRequest ? 'Password reset' : 'Registration';
      await ITLogService.logAction('$requestType request $actionStr for $identifier');

      if (!mounted) return;
      showSuccessSnackBar(context, isAccepted ? 'Request Approved!' : 'Request Rejected');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Error: $e');
    }
  }

  Widget buildInfoRow({
    required String label,
    required String value,
    double fontSize = 16,
    double verticalPadding = 8,
    FontWeight labelWeight = FontWeight.bold,
    FontWeight valueWeight = FontWeight.w500,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(fontSize: fontSize, fontWeight: labelWeight, color: Colors.grey[700]))),
          Expanded(flex: 3, child: Text(value, style: TextStyle(fontSize: fontSize, fontWeight: valueWeight))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading('User Requests'),
            const SizedBox(height: 20),

            // Filter Tabs
            Row(
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                      _selectedIndexNotifier.value = 0;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 25),

            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('ForgotPass_request').snapshots(),
                builder: (context, passSnapshot) {
                  if (passSnapshot.connectionState == ConnectionState.waiting) return const LoadingState();
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection('registration_requests').snapshots(),
                    builder: (context, regSnapshot) {
                      if (regSnapshot.connectionState == ConnectionState.waiting) return const LoadingState();

                      List<Map<String, dynamic>> requestItems = [
                        ...(passSnapshot.data?.docs ?? const []).map((doc) => {'id': doc.id, 'doc': doc, 'data': doc.data(), 'kind': 'password'}),
                        ...(regSnapshot.data?.docs ?? const []).map((doc) => {'id': doc.id, 'doc': doc, 'data': doc.data(), 'kind': 'registration'}),
                      ];

                      // Filter logic
                      requestItems = requestItems.where((item) {
                        final docData = item['data'] as Map<String, dynamic>;
                        final statusStr = docData['status']?.toString().toLowerCase() ?? (docData['isProcessed'] == true ? 'processed' : 'pending');
                        final isResolved = statusStr == 'accepted' || statusStr == 'rejected' || statusStr == 'processed';

                        if (_selectedFilter == 'Pending') return !isResolved;
                        if (_selectedFilter == 'Accepted') return statusStr == 'accepted';
                        if (_selectedFilter == 'Rejected') return statusStr == 'rejected';
                        return true;
                      }).toList();

                      // Sort: Pending first, then by date
                      requestItems.sort((a, b) {
                        final dataA = a['data'] as Map<String, dynamic>;
                        final dataB = b['data'] as Map<String, dynamic>;
                        final isPendingA = (dataA['isProcessed'] != true);
                        final isPendingB = (dataB['isProcessed'] != true);
                        if (isPendingA && !isPendingB) return -1;
                        if (!isPendingA && isPendingB) return 1;
                        final tsA = (dataA['requestDate'] ?? dataA['date'] ?? dataA['createdAt']) as Timestamp?;
                        final tsB = (dataB['requestDate'] ?? dataB['date'] ?? dataB['createdAt']) as Timestamp?;
                        if (tsA != null && tsB != null) return tsB.compareTo(tsA);
                        return 0;
                      });

                      if (requestItems.isEmpty) return const EmptyState(message: 'No requests found.');

                      return ValueListenableBuilder<int>(
                        valueListenable: _selectedIndexNotifier,
                        builder: (context, selectedIndex, _) {
                          if (selectedIndex >= requestItems.length) return const SizedBox();
                          final selectedItem = requestItems[selectedIndex];
                          final selectedDoc = selectedItem['doc'] as DocumentSnapshot;
                          final selectedData = selectedItem['data'] as Map<String, dynamic>;
                          final isPasswordRequest = selectedItem['kind'] == 'password';

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Left Panel: Request List
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
                                      final isPass = item['kind'] == 'password';

                                      // Display ID only
                                      final String displayId = isPass
                                          ? (docData['emailOrId'] ?? 'Unknown')
                                          : (docData['universityId'] ?? 'Unknown ID');

                                      final reqDate = _formatDate((docData['requestDate'] ?? docData['date'] ?? docData['createdAt']) as Timestamp?);
                                      final statusStr = docData['status']?.toString().toLowerCase() ?? (docData['isProcessed'] == true ? 'processed' : 'pending');
                                      final isResolved = statusStr == 'accepted' || statusStr == 'rejected' || statusStr == 'processed';

                                      return GestureDetector(
                                        onTap: () => _selectedIndexNotifier.value = index,
                                        child: Opacity(
                                          opacity: isResolved ? 0.6 : 1,
                                          child: Container(
                                            margin: const EdgeInsets.only(bottom: 10),
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                            decoration: AppDecorations.smallCard(isSelected: selectedIndex == index),
                                            child: Row(children: [
                                              StatusBadge(status: isResolved ? statusStr : 'pending', showIcon: true, isCompact: false),
                                              const SizedBox(width: 12),
                                              Container(width: 1.5, height: 38, color: isResolved ? Colors.grey.withOpacity(0.3) : AppColors.primary.withOpacity(0.3)),
                                              const SizedBox(width: 12),
                                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                Text(
                                                    displayId,
                                                    style: AppTextStyles.hallListNumberStyle.copyWith(
                                                        decoration: isResolved ? TextDecoration.lineThrough : null,
                                                        color: isResolved ? Colors.grey : null
                                                    )
                                                ),
                                                const SizedBox(height: 4),
                                                Text(reqDate, style: AppTextStyles.caption),
                                              ])),
                                            ]),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Right Panel: Details
                              Expanded(
                                flex: 55,
                                child: GlassCard(
                                  child: Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Icon(isPasswordRequest ? Icons.lock_reset_rounded : Icons.how_to_reg_rounded, size: 36, color: AppColors.primary),
                                          const SizedBox(width: 16),
                                          Text(isPasswordRequest ? 'Password Reset' : 'Registration Request', style: AppTextStyles.heading.copyWith(color: AppColors.primary, fontSize: 24)),
                                        ]),
                                        const SizedBox(height: 30),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            physics: const BouncingScrollPhysics(),
                                            child: isPasswordRequest
                                                ? FutureBuilder<Map<String, dynamic>?>(
                                              future: _fetchUserDetails(selectedData['emailOrId']?.toString() ?? '', selectedData['userRole']?.toString() ?? ''),
                                              builder: (context, userSnap) {
                                                if (userSnap.connectionState == ConnectionState.waiting) return const LoadingState(isCentered: false);
                                                if (!userSnap.hasData || userSnap.data == null) return const Text("User not found.", style: TextStyle(color: Colors.red));
                                                final userData = userSnap.data!;
                                                final fullName = '${userData['fName'] ?? ''} ${userData['lName'] ?? ''}'.trim();
                                                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                  buildInfoRow(label: 'Requested by', value: fullName.isEmpty ? 'Unknown' : fullName),
                                                  buildInfoRow(label: 'User Type', value: _capitalize(userData['foundRole'] ?? 'Unknown')),
                                                  buildInfoRow(label: 'ID', value: (userData['ID'] ?? selectedData['emailOrId'] ?? 'N/A').toString()),
                                                  buildInfoRow(label: 'Email', value: (userData['email'] ?? 'N/A').toString()),
                                                  buildInfoRow(label: 'New Password', value: (selectedData['newPassword'] ?? 'Not provided').toString()),
                                                  buildInfoRow(label: 'Time of Request', value: _formatDate(selectedData['requestDate'] as Timestamp?)),
                                                ]);
                                              },
                                            )
                                                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              buildInfoRow(label: 'Email', value: (selectedData['email'] ?? 'N/A').toString()),
                                              buildInfoRow(label: 'University ID', value: (selectedData['universityId'] ?? 'N/A').toString()),
                                              if (selectedData['faculty'] != null) buildInfoRow(label: 'Faculty', value: selectedData['faculty'].toString()),
                                              if (selectedData['year'] != null) buildInfoRow(label: 'Year', value: selectedData['year'].toString()),
                                              buildInfoRow(label: 'Time of Request', value: _formatDate((selectedData['createdAt'] ?? selectedData['date']) as Timestamp?)),
                                            ]),
                                          ),
                                        ),
                                        if (selectedData['isProcessed'] != true)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 16),
                                            child: Row(children: [
                                              Expanded(child: PillButton(label: 'Reject', onTap: () => _updateRequestStatus(selectedDoc, 'rejected', isPasswordRequest: isPasswordRequest))),
                                              const SizedBox(width: 16),
                                              Expanded(child: PillButton(label: 'Approve', onTap: () => _updateRequestStatus(selectedDoc, 'accepted', isPasswordRequest: isPasswordRequest))),
                                            ]),
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