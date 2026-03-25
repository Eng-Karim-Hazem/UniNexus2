import 'package:flutter/material.dart';

// Import your dedicated Admin Tab enum
import 'package:uninexus/theme/app_theme.dart';
import 'package:uninexus/ui/screens/tablet/Admin/admin_id_screen.dart';

import 'package:uninexus/ui/widgets/admin_sidebar_widget.dart';

// Screen Imports
import 'package:uninexus/ui/screens/tablet/Admin/admin_dashboard_screen.dart';
// Make sure this file exists!
import 'package:uninexus/ui/screens/tablet/Admin/admin_requests_screen.dart';
import 'package:uninexus/ui/screens/tablet/Admin/admin_notices_screen.dart';
import 'package:uninexus/ui/screens/tablet/Admin/admin_profile_screen.dart';
import 'package:uninexus/ui/screens/tablet/Admin/admin_settings_screen.dart';
import 'package:uninexus/ui/screens/tablet/Admin/admin_user_search_screen.dart';
import 'package:uninexus/ui/screens/tablet/Admin/admin_sent_notices_screen.dart';
import 'package:uninexus/ui/screens/tablet/Admin/admin_received_notices.dart';

import '../../../../admin_tab.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {

  // Default starting tab
  AdminTab _currentTab = AdminTab.dashboard;

  void _navigate(AdminTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  Widget _buildScreen() {
    switch (_currentTab) {
      case AdminTab.dashboard:
        return AdminDashboardScreen(onNavigate: _navigate);

      case AdminTab.requests:
        return AdminRequestsScreen(onNavigate: _navigate);

      case AdminTab.notices:
        return AdminNoticesScreen(onNavigate: _navigate);

      case AdminTab.profile:
        return AdminProfileScreen(onNavigate: _navigate);

      case AdminTab.settings:
        return AdminSettingsScreen(onNavigate: _navigate);

      case AdminTab.userSearch:
        return AdminUserSearchScreen(onNavigate: _navigate);

      case AdminTab.sentNotices:
        return AdminSentNoticesScreen(onNavigate: _navigate);
      case AdminTab.receivedNotices:
        return AdminReceivedNoticesScreen(onNavigate: _navigate);
      case AdminTab.id:
        return AdminIdScreen(onNavigate: _navigate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [

          AdminSidebar(
            current: _currentTab,
            onNavigate: _navigate,
          ),

          Expanded(child: _buildScreen()),
        ],
      ),
    );
  }
}