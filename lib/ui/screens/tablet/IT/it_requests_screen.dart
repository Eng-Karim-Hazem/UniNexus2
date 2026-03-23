import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

import '../../../../services/firebase/it_Logs_service.dart';

class ITRequestsScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;
  const ITRequestsScreen({super.key, required this.onNavigate});

  @override
  State<ITRequestsScreen> createState() => _ITRequestsScreenState();
}

class _ITRequestsScreenState extends State<ITRequestsScreen> {
  int _selectedIndex = 0;

  // Helper to format the Firebase Timestamp into a readable string
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown Date';
    final DateTime date = timestamp.toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Helper to capitalize first letter
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // --- BULLETPROOF USER FETCHER ---
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
            const Text('User Requests', style: AppTextStyles.largeHeading),
            const SizedBox(height: 45),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ForgotPass_request')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading requests: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No reset requests found.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    );
                  }

                  final docs = snapshot.data!.docs.toList();

                  // Sort: Pending first, then by date
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

                  final selectedDoc = docs[_selectedIndex];
                  final Map<String, dynamic> selectedData = selectedDoc.data() as Map<String, dynamic>;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- LEFT PANEL: REQUEST LIST ---
                      Expanded(
                        flex: 45,
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final docData = docs[index].data() as Map<String, dynamic>;
                              final emailOrId = docData['emailOrId'] ?? 'Unknown User';
                              final reqDate = _formatDate(docData['requestDate'] as Timestamp?);

                              final statusStr = docData['status']?.toString().toLowerCase() ?? (docData['isProcessed'] == true ? 'processed' : 'pending');
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
                                        isResolved
                                            ? Icon(
                                          statusStr == 'rejected' ? Icons.cancel_outlined : Icons.check_circle_outline,
                                          size: 28, color: statusStr == 'rejected' ? Colors.red : Colors.green,
                                        )
                                            : Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.person_outline, size: 24, color: AppColors.primary),
                                        ),

                                        const SizedBox(width: 12),
                                        Container(width: 1.5, height: 38, color: isResolved ? Colors.grey.withOpacity(0.3) : AppColors.primary.withOpacity(0.3)),
                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(emailOrId, style: AppTextStyles.hallListNumberStyle.copyWith(
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
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // --- RIGHT PANEL: REQUEST DETAIL ---
                      Expanded(
                        flex: 55,
                        child: GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // HEADER
                                Row(
                                  children: [
                                    const Icon(Icons.lock_reset_rounded, size: 36, color: AppColors.primary),
                                    const SizedBox(width: 16),
                                    Text("Password Reset", style: AppTextStyles.heading.copyWith(color: AppColors.primary, fontSize: 24)),
                                  ],
                                ),
                                const SizedBox(height: 30),

                                // FUTURE BUILDER
                                Expanded(
                                  child: FutureBuilder<Map<String, dynamic>?>(
                                    future: _fetchUserDetails(
                                        selectedData['emailOrId']?.toString() ?? '',
                                        selectedData['userRole']?.toString() ?? ''
                                    ),
                                    builder: (context, userSnap) {
                                      if (userSnap.connectionState == ConnectionState.waiting) {
                                        return const Align(
                                            alignment: Alignment.topCenter,
                                            child: CircularProgressIndicator()
                                        );
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
                                          _buildFigmaDetailRow('Requested by', fullName.isEmpty ? 'Unknown' : fullName),
                                          _buildFigmaDetailRow('User Type', _capitalize(foundRole)),
                                          _buildFigmaDetailRow('ID', userData['ID'] ?? selectedData['emailOrId'] ?? 'N/A'),
                                          _buildFigmaDetailRow('Email', userData['email'] ?? 'N/A'),

                                          // --- NEW: DISPLAY THE NEW PASSWORD ---
                                          _buildFigmaDetailRow('New Password', selectedData['newPassword'] ?? 'Not provided'),

                                          if (userData.containsKey('year'))
                                            _buildFigmaDetailRow('Year', userData['year'].toString()),
                                          if (userData.containsKey('faculty'))
                                            _buildFigmaDetailRow('Faculty', userData['faculty']),

                                          const SizedBox(height: 20),
                                          _buildFigmaDetailRow('Time of Request', _formatDate(selectedData['requestDate'] as Timestamp?)),
                                        ],
                                      );
                                    },
                                  ),
                                ),

                                // ACTION BUTTONS
                                if (selectedData['isProcessed'] != true)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: PillButton(
                                          label: 'Reject',
                                          onTap: () => _updateRequestStatus(selectedDoc, 'rejected'),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: PillButton(
                                          label: 'Approve',
                                          onTap: () => _updateRequestStatus(selectedDoc, 'accepted'),
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

  // --- UPDATED LOGIC TO CHANGE THE ACTUAL PASSWORD ---
  Future<void> _updateRequestStatus(DocumentSnapshot doc, String status) async {
    try {
      final data = doc.data() as Map<String, dynamic>;

      // If accepted, update the user's actual password in their collection
      if (status == 'accepted') {
        final newPassword = data['newPassword'];
        final userRole = data['userRole'];
        final userDocRef = data['userDocRef'];

        if (newPassword != null && userRole != null && userDocRef != null) {
          // Go to the specific user table and update their password field!
          await FirebaseFirestore.instance
              .collection(userRole)
              .doc(userDocRef)
              .update({'pass': newPassword});
        } else {
          throw Exception("Missing user reference or password data in this request.");
        }
      }

      // 1. Update the request database document
      await doc.reference.update({
        'isProcessed': true,
        'status': status,
      });

      // 2. Add it to the logs
      final userId = data['emailOrId'] ?? 'Unknown User';
      final actionStr = status == 'accepted' ? 'approved' : 'rejected';
      await ITLogService.logAction('Password reset $actionStr for $userId');

      // 3. Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'accepted'
                ? 'Request Approved & Password Updated in Database!'
                : 'Request Rejected'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // Figma-style text rows
  Widget _buildFigmaDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label : ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}