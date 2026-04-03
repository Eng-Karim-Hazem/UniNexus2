import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';
import '../../../../services/firebase/it_logs_service.dart';

class ITRequestsScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;
  const ITRequestsScreen({super.key, required this.onNavigate});

  @override
  State<ITRequestsScreen> createState() => _ITRequestsScreenState();
}

class _ITRequestsScreenState extends State<ITRequestsScreen> {
  int _selectedIndex = 0;

  // --- NEW: Filter State Variables ---
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Completed', 'Rejected'];

  // Format timestamp
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown Date';
    final DateTime date = timestamp.toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day
        .toString().padLeft(2, '0')} at ${date.hour.toString().padLeft(
        2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Capitalize string
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Fetch user details from database
  Future<Map<String, dynamic>?> _fetchUserDetails(String emailOrId, String expectedRole) async {
    if (emailOrId.isEmpty) return null;

    final isEmail = emailOrId.contains('@');
    final queryField = isEmail ? 'email' : 'ID';
    final searchValue = isEmail ? emailOrId.toLowerCase() : emailOrId.toUpperCase();

    List<String> collections = expectedRole.isNotEmpty
        ? [expectedRole, 'students', 'faculty', 'staff']
        : ['students', 'faculty', 'staff'];

    for (String col in collections) {
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
      } catch (e) {
        print("Error fetching from $col: $e");
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- NEW: Header with Filter Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const PageHeading('User Requests'),
                _buildStatusFilter(),
              ],
            ),
            const SizedBox(height: 45),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ForgotPass_request')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingState(); // From your theme
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading requests: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                  }

                  List<QueryDocumentSnapshot> rawDocs = snapshot.data?.docs.toList() ?? [];

                  // --- NEW: Apply the selected filter ---
                  List<QueryDocumentSnapshot> docs = rawDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final isProcessed = data['isProcessed'] == true;
                    final status = data['status']?.toString().toLowerCase();

                    if (_selectedFilter == 'Pending') {
                      return !isProcessed;
                    }
                    if (_selectedFilter == 'Completed') {
                      // Show processed items that are NOT rejected (e.g., 'accepted' or old 'processed' ones)
                      return isProcessed && status != 'rejected';
                    }
                    if (_selectedFilter == 'Rejected') {
                      // Only show processed items specifically marked as rejected
                      return isProcessed && status == 'rejected';
                    }

                    return true; // 'All'
                  }).toList();

                  // Sort: pending first, then by date
                  docs.sort((a, b) {
                    final dataA = a.data() as Map<String, dynamic>;
                    final dataB = b.data() as Map<String, dynamic>;

                    final bool isProcessedA = dataA['isProcessed'] == true;
                    final bool isProcessedB = dataB['isProcessed'] == true;

                    if (isProcessedA != isProcessedB) return isProcessedA ? 1 : -1;

                    final Timestamp? timeA = dataA['requestDate'] as Timestamp?;
                    final Timestamp? timeB = dataB['requestDate'] as Timestamp?;

                    if (timeA != null && timeB != null) return timeB.compareTo(timeA);
                    return 0;
                  });

                  if (_selectedIndex >= docs.length) _selectedIndex = 0;

                  final bool hasData = docs.isNotEmpty;
                  final selectedDoc = hasData ? docs[_selectedIndex] : null;
                  final Map<String, dynamic>? selectedData = selectedDoc?.data() as Map<String, dynamic>?;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left panel - Request list
                      Expanded(
                        flex: 45,
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: hasData
                              ? ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final docData = docs[index].data() as Map<String, dynamic>;
                              final emailOrId = docData['emailOrId'] ?? 'Unknown User';
                              final reqDate = _formatDate(docData['requestDate'] as Timestamp?);

                              final statusStr = docData['status']?.toString().toLowerCase() ??
                                  (docData['isProcessed'] == true ? 'processed' : 'pending');
                              final isResolved = statusStr == 'accepted' || statusStr == 'rejected' || statusStr == 'processed';
                              final isSelected = _selectedIndex == index;

                              return GestureDetector(
                                onTap: () => setState(() => _selectedIndex = index),
                                child: Opacity(
                                  opacity: isResolved ? 0.6 : 1.0,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                    decoration: AppDecorations.smallCard(isSelected: isSelected),
                                    child: Row(
                                      children: [
                                        StatusBadge(
                                          status: isResolved ? statusStr : 'pending',
                                          showIcon: true,
                                          isCompact: false,
                                        ),
                                        const SizedBox(width: 12),
                                        Container(width: 1.5, height: 38,
                                            color: isResolved ? Colors.grey.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.3)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(emailOrId,
                                                  style: AppTextStyles.hallListNumberStyle.copyWith(
                                                    decoration: isResolved ? TextDecoration.lineThrough : null,
                                                    color: isResolved ? Colors.grey : null,
                                                  )),
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
                          )
                              : _buildEmptyPlaceholder("No $_selectedFilter requests found."),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Right panel - Request details
                      Expanded(
                        flex: 55,
                        child: GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: hasData && selectedData != null
                                ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.lock_reset_rounded, size: 36, color: AppColors.primary),
                                    const SizedBox(width: 16),
                                    Text("Password Reset", style: AppTextStyles.heading.copyWith(
                                        color: AppColors.primary, fontSize: 24)),
                                  ],
                                ),
                                const SizedBox(height: 30),

                                Expanded(
                                  child: FutureBuilder<Map<String, dynamic>?>(
                                    future: _fetchUserDetails(
                                        selectedData['emailOrId']?.toString() ?? '',
                                        selectedData['userRole']?.toString() ?? ''
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

                                      // --- FIX: Wrapped the details inside a SingleChildScrollView ---
                                      return SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            buildInfoRow(
                                              label: 'Requested by',
                                              value: fullName.isEmpty ? 'Unknown' : fullName,
                                              fontSize: 16,
                                              verticalPadding: 16,
                                              labelWeight: FontWeight.bold,
                                              valueWeight: FontWeight.w500,
                                            ),
                                            buildInfoRow(
                                              label: 'User Type',
                                              value: _capitalize(foundRole),
                                              fontSize: 16,
                                              verticalPadding: 16,
                                              labelWeight: FontWeight.bold,
                                              valueWeight: FontWeight.w500,
                                            ),
                                            buildInfoRow(
                                              label: 'ID',
                                              value: userData['ID'] ?? selectedData['emailOrId'] ?? 'N/A',
                                              fontSize: 16,
                                              verticalPadding: 16,
                                              labelWeight: FontWeight.bold,
                                              valueWeight: FontWeight.w500,
                                            ),
                                            buildInfoRow(
                                              label: 'Email',
                                              value: userData['email'] ?? 'N/A',
                                              fontSize: 16,
                                              verticalPadding: 16,
                                              labelWeight: FontWeight.bold,
                                              valueWeight: FontWeight.w500,
                                            ),
                                            buildInfoRow(
                                              label: 'New Password',
                                              value: selectedData['newPassword'] ?? 'Not provided',
                                              fontSize: 16,
                                              verticalPadding: 16,
                                              labelWeight: FontWeight.bold,
                                              valueWeight: FontWeight.w500,
                                            ),
                                            if (userData.containsKey('year'))
                                              buildInfoRow(
                                                label: 'Year',
                                                value: userData['year'].toString(),
                                                fontSize: 16,
                                                verticalPadding: 16,
                                                labelWeight: FontWeight.bold,
                                                valueWeight: FontWeight.w500,
                                              ),
                                            if (userData.containsKey('faculty'))
                                              buildInfoRow(
                                                label: 'Faculty',
                                                value: userData['faculty'],
                                                fontSize: 16,
                                                verticalPadding: 16,
                                                labelWeight: FontWeight.bold,
                                                valueWeight: FontWeight.w500,
                                              ),
                                            buildInfoRow(
                                              label: 'Time of Request',
                                              value: _formatDate(selectedData['requestDate'] as Timestamp?),
                                              fontSize: 16,
                                              verticalPadding: 16,
                                              labelWeight: FontWeight.bold,
                                              valueWeight: FontWeight.w500,
                                            ),
                                            const SizedBox(height: 20), // Extra padding at the bottom
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Action buttons for pending requests
                                // These stay pinned to the bottom because they are OUTSIDE the scroll view!
                                if (selectedData['isProcessed'] != true)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: PillButton(
                                            label: 'Approve',
                                            onTap: () => _updateRequestStatus(selectedDoc!, 'accepted'),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: PillButton(
                                            label: 'Reject',
                                            onTap: () => _updateRequestStatus(selectedDoc!, 'rejected'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            )
                                : _buildEmptyPlaceholder("Select a request to view details"),
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

  // --- NEW: Filter Buttons Widget ---
  Widget _buildStatusFilter() {
    return Row(
      children: _filters.map((filter) {
        final isSelected = _selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedFilter = filter;
              _selectedIndex = 0; // Reset selection when filter changes
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(filter, style: TextStyle(color: isSelected ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- NEW: Reusable Empty Placeholder ---
  Widget _buildEmptyPlaceholder(String message) {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(message, style: AppTextStyles.hallListErrorStyle),
          ],
        ),
      ),
    );
  }

  // Update request status
  Future<void> _updateRequestStatus(DocumentSnapshot doc, String status) async {
    try {
      final data = doc.data() as Map<String, dynamic>;

      if (status == 'accepted') {
        final newPassword = data['newPassword'];
        final userRole = data['userRole'];
        final userDocRef = data['userDocRef'];

        if (newPassword != null && userRole != null && userDocRef != null) {
          await FirebaseFirestore.instance
              .collection(userRole)
              .doc(userDocRef)
              .update({'pass': newPassword});
        } else {
          throw Exception("Missing user reference or password data in this request.");
        }
      }

      await doc.reference.update({
        'isProcessed': true,
        'status': status,
      });

      final userId = data['emailOrId'] ?? 'Unknown User';
      final actionStr = status == 'accepted' ? 'approved' : 'rejected';
      await ITLogService.logAction('Password reset $actionStr for $userId');

      if (mounted) {
        if (status == 'accepted') {
          showSuccessSnackBar(context, 'Request Approved & Password Updated in Database!');
        } else {
          showSuccessSnackBar(context, 'Request Rejected');
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Error: $e');
      }
    }
  }
}