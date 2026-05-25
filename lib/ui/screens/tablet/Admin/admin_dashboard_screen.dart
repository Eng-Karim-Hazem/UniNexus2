import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../admin_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  final void Function(AdminTab) onNavigate;
  const AdminDashboardScreen({super.key, required this.onNavigate});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // SharedPreferences keys
  static const String _requestReadKey = 'admin_read_recent_request_ids';
  static const String _noticeReadKey = 'admin_read_notice_ids';
  static const String _pendingRequestSelectionKey = 'admin_selected_request_id';

  // State variables
  String _adminName = 'Admin';
  int _registrationCount = 0;
  int _passwordResetCount = 0;
  bool _loading = true;
  List<Map<String, String>> _recentRequests = [];
  List<Map<String, String>> _recentNotices = [];
  Set<String> _readRequestIds = <String>{};
  Set<String> _readNoticeIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  // Load dashboard data from Firestore
  Future<void> _loadDashboard() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String fName = (prefs.getString('fName') ?? '').trim();
      final String adminId = (prefs.getString('ID') ?? '').trim();
      _readRequestIds = (prefs.getStringList(_requestReadKey) ?? const []).toSet();
      _readNoticeIds = (prefs.getStringList(_noticeReadKey) ?? const []).toSet();

      final FirebaseFirestore db = FirebaseFirestore.instance;

      final regFuture = db.collection('registration_requests').get();
      final passFuture = db.collection('ForgotPass_request').get();
      final noticeFuture = db
          .collection('Notifications')
          .orderBy('date', descending: true)
          .limit(100)
          .get();

      final results = await Future.wait([regFuture, passFuture, noticeFuture]);

      final reg = results[0];
      final pass = results[1];
      final notices = results[2];

      // Filter pending password reset requests
      final pendingPassDocs = pass.docs.where((doc) {
        final data = doc.data();
        final status = (data['status'] ?? '').toString().toLowerCase();
        final isProcessed = data['isProcessed'] == true;
        final isClosed = status == 'accepted' || status == 'rejected' || status == 'processed';
        // Only keep if NOT processed and NOT closed
        return !(isProcessed || isClosed);
      }).toList();

      final List<Map<String, String>> resetRequests = pendingPassDocs.map((doc) {
        final data = doc.data();
        return {
          'id': 'pass_${doc.id}',
          'text': '${(data['emailOrId'] ?? 'User').toString()} submitted a password reset request',
        };
      }).toList();

      // Filter pending registration requests
      final pendingRegDocs = reg.docs.where((doc) {
        final data = doc.data();
        final status = (data['status'] ?? '').toString().toLowerCase();
        final isProcessed = data['isProcessed'] == true;
        final isClosed = status == 'accepted' || status == 'rejected' || status == 'processed';
        // Only keep if NOT processed and NOT closed
        return !(isProcessed || isClosed);
      }).toList();

      final List<Map<String, String>> registrationRequests = pendingRegDocs.map((doc) {
        final data = doc.data();
        final name = (data['fullName'] ?? data['name'] ?? data['fName'] ?? 'User').toString();
        return {
          'id': 'reg_${doc.id}',
          'text': '$name submitted a registration request',
        };
      }).toList();

      // Combine and limit to 10 recent requests
      final List<Map<String, String>> requestItems = [
        ...registrationRequests,
        ...resetRequests,
      ].take(5).toList();

      // Filter notices meant for this admin
      final List<Map<String, String>> noticesList = notices.docs
          .where((doc) {
        if (_readNoticeIds.contains(doc.id)) return false;
        final data = doc.data();
        final List<String> recipientIds = List<String>.from(data['recipientIds'] ?? const []);
        final String legacyRecipientId = (data['ID'] ?? '').toString().trim();
        final String type = (data['type'] ?? '').toString().toLowerCase();
        final String targetValue = (data['targetValue'] ?? '').toString().toLowerCase();
        final bool sentToMe = recipientIds.contains(adminId) || legacyRecipientId == adminId;
        final bool sentToAdminGroup = type == 'group' && targetValue == 'admin';
        return sentToMe || sentToAdminGroup;
      })
          .take(10)
          .map((doc) {
        final data = doc.data();
        final Timestamp? timestamp = data['date'] as Timestamp?;
        final String receivedAt = timestamp == null ? '' : _formatNoticeTime(timestamp.toDate());
        return {
          'id': doc.id,
          'sender': (data['sentBy'] ?? 'Management').toString(),
          'message': (data['description'] ?? '').toString(),
          'receivedAt': receivedAt,
        };
      })
          .toList();

      if (!mounted) return;
      setState(() {
        _adminName = fName.isNotEmpty ? fName : 'Admin';

        // Use the length of the filtered pending lists instead of the total collection length
        _registrationCount = pendingRegDocs.length;
        _passwordResetCount = pendingPassDocs.length;

        _recentRequests = requestItems;
        _recentNotices = noticesList;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // Get current date string
  String _today() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  // Format notice timestamp
  String _formatNoticeTime(DateTime date) {
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final mo = date.month.toString().padLeft(2, '0');
    return '$dd/$mo ${date.year} $hh:$mm';
  }

  // Open request and mark as read
  Future<void> _openRecentRequest(Map<String, String> request) async {
    final id = request['id'];
    if (id == null || id.isEmpty) return;
    _readRequestIds.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_requestReadKey, _readRequestIds.toList());
    await prefs.setString(_pendingRequestSelectionKey, id.replaceFirst(RegExp(r'^(pass_|reg_)'), ''));
    if (!mounted) return;
    setState(() {});
    widget.onNavigate(AdminTab.requests);
  }

  // Mark notice as read and remove from list
  Future<void> _openNotice(Map<String, String> notice) async {
    final id = notice['id'];
    if (id == null || id.isEmpty) return;
    _readNoticeIds.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_noticeReadKey, _readNoticeIds.toList());
    if (!mounted) return;
    setState(() {
      _recentNotices.removeWhere((item) => item['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppGreetingCard(
              name: _adminName,
              subtitle: 'Good morning',
              date: _today(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column - Requests summary
                  Expanded(
                    flex: 5,
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRequestSummaryRow(
                            'assets/icons/clipboard.png',
                            '$_registrationCount Registration requests',
                            Icons.assignment,
                          ),
                          const SizedBox(height: 15),
                          _buildRequestSummaryRow(
                            'assets/icons/lock_reset.png',
                            '$_passwordResetCount Password reset requests',
                            Icons.lock_reset,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(),
                          ),
                          const Text('Recent Requests',
                              style: AppTextStyles.senderStyle),
                          const SizedBox(height: 12),
                          ..._recentRequests.map(
                                (item) => _buildRecentRequestItem(
                              item['text'] ?? '',
                              Icons.assignment,
                              isRead: _readRequestIds.contains(item['id']),
                              onTap: () => _openRecentRequest(item),
                            ),
                          ),
                          if (_recentRequests.isEmpty)
                            const Text('No recent requests.',
                                style: AppTextStyles.body),
                          const Spacer(),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => widget.onNavigate(AdminTab.requests),
                              child: const Text('View Requests >',
                                  style: AppTextStyles.viewLinkStyle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Right column - Quick actions and notices
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionCard(
                                'User Search',
                                'assets/images/id-card 5.png',
                                onTap: () => widget.onNavigate(AdminTab.userSearch),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildQuickActionCard(
                                'Sent Notice',
                                'assets/images/send_butt.png',
                                onTap: () => widget.onNavigate(AdminTab.sentNotices),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: _loading
                                ? const Center(child: CircularProgressIndicator())
                                : Column(
                              children: [
                                Expanded(
                                  child: _recentNotices.isEmpty
                                      ? const Center(
                                    child: Text('No notices yet.',
                                        style: AppTextStyles.body),
                                  )
                                      : ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: _recentNotices.length,
                                    itemBuilder: (context, index) {
                                      final n = _recentNotices[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: _buildNoticeItem(
                                          n['sender'] ?? 'Management',
                                          n['message'] ?? '',
                                          n['receivedAt'] ?? '',
                                          isRead: _readNoticeIds.contains(n['id']),
                                          onTap: () => _openNotice(n),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () => widget.onNavigate(AdminTab.receivedNotices),
                                    child: const Text('View Notices >',
                                        style: AppTextStyles.viewLinkStyle),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  // Quick action card widget
  Widget _buildQuickActionCard(String title, String imagePath,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  imagePath,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported_outlined,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                fontFamily: AppFonts.spaceGrotesk,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Request summary row
  Widget _buildRequestSummaryRow(String iconPath, String title, IconData fallback) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Icon(fallback, color: AppColors.primary, size: 28),
        ),
        const SizedBox(width: 16),
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
      ],
    );
  }

  // Recent request item
  Widget _buildRecentRequestItem(
      String text,
      IconData icon, {
        required bool isRead,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: AppDecorations.smallCard(),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.logRowBodyStyle.copyWith(
                  fontWeight: isRead ? FontWeight.w400 : FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Notice item
  Widget _buildNoticeItem(
      String sender,
      String msg,
      String receivedAt, {
        required bool isRead,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppDecorations.smallCard(),
        child: Row(
          children: [
            const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          sender,
                          style: AppTextStyles.senderStyle.copyWith(
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(receivedAt, style: AppTextStyles.caption),
                    ],
                  ),
                  Text(
                    msg,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: isRead ? FontWeight.w400 : FontWeight.w700,
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
}