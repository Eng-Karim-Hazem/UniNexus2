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
  String _adminName = 'Admin';
  int _registrationCount = 0;
  int _passwordResetCount = 0;
  bool _loading = true;
  List<String> _recentRequests = [];
  List<Map<String, String>> _recentNotices = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String fName = (prefs.getString('fName') ?? '').trim();

      final FirebaseFirestore db = FirebaseFirestore.instance;

      final regFuture = db.collection('registration_requests').get();
      final passFuture = db.collection('ForgotPass_request').get();
      final noticeFuture = db
          .collection('Notifications')
          .orderBy('date', descending: true)
          .limit(4)
          .get();

      final results = await Future.wait([regFuture, passFuture, noticeFuture]);

      final reg = results[0] as QuerySnapshot<Map<String, dynamic>>;
      final pass = results[1] as QuerySnapshot<Map<String, dynamic>>;
      final notices = results[2] as QuerySnapshot<Map<String, dynamic>>;

      final List<String> requestItems = [
        ...reg.docs
            .take(3)
            .map((doc) => '${(doc.data()['fullName'] ?? doc.data()['name'] ?? 'User').toString()} submitted a request'),
        ...pass.docs.take(3).map(
                (doc) => '${(doc.data()['emailOrId'] ?? 'User').toString()} submitted a request'),
      ];

      final List<Map<String, String>> noticesList = notices.docs.map((doc) {
        final data = doc.data();
        return {
          'sender': (data['sentBy'] ?? 'Management').toString(),
          'message': (data['description'] ?? '').toString(),
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _adminName = fName.isNotEmpty ? fName : 'Admin';
        _registrationCount = reg.docs.length;
        _passwordResetCount = pass.docs.length;
        _recentRequests = requestItems.take(3).toList();
        _recentNotices = noticesList;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _today() {
    final now = DateTime.now();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
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
                                item, Icons.assignment),
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
                                'Send Notice',
                                'assets/images/send_butt.png',
                                onTap: () => widget.onNavigate(AdminTab.notices),
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
                                ..._recentNotices.map((n) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildNoticeItem(
                                    n['sender'] ?? 'Management',
                                    n['message'] ?? '',
                                  ),
                                )),
                                if (_recentNotices.isEmpty)
                                  const Expanded(
                                    child: Center(
                                      child: Text('No notices yet.',
                                          style: AppTextStyles.body),
                                    ),
                                  ),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () => widget.onNavigate(AdminTab.sentNotices),
                                    child: const Text('View Sent Notices >',
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
            color: AppColors.primary.withOpacity(0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
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

  Widget _buildRecentRequestItem(String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.smallCard(),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.logRowBodyStyle)),
        ],
      ),
    );
  }

  Widget _buildNoticeItem(String sender, String msg) {
    return Container(
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
                Text(sender, style: AppTextStyles.senderStyle),
                Text(msg, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}