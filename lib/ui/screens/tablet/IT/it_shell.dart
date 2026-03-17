import 'package:flutter/material.dart';

import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

import 'package:uninexus/ui/widgets/it_sidebar_widget.dart';

import 'package:uninexus/ui/screens/tablet/IT/it_dashboard_screen.dart';
import 'package:uninexus/ui/screens/tablet/IT/it_logs_screen.dart';
import 'package:uninexus/ui/screens/tablet/IT/it_announcements_screen.dart';
import 'package:uninexus/ui/screens/tablet/IT/it_id_screen.dart';
import 'package:uninexus/ui/screens/tablet/IT/it_hall_error_screen.dart';
import 'package:uninexus/ui/screens/tablet/IT/it_requests_screen.dart';
import 'package:uninexus/ui/screens/tablet/IT/it_profile_screen.dart';
import 'package:uninexus/ui/screens/tablet/IT/it_settings_screen.dart';

class ITShell extends StatefulWidget {
  const ITShell({super.key});

  @override
  State<ITShell> createState() => _ITShellState();
}

class _ITShellState extends State<ITShell> {

  UninexusTab _currentTab = UninexusTab.dashboard;

  void _navigate(UninexusTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  Widget _buildScreen() {

    switch (_currentTab) {

      case UninexusTab.dashboard:
        return ITDashboardScreen(onNavigate: _navigate);

      case UninexusTab.logs:
        return ITLogsScreen(onNavigate: _navigate);

      case UninexusTab.announcements:
        return ITAnnouncementsScreen(onNavigate: _navigate);

      case UninexusTab.id:
        return ITIdScreen(onNavigate: _navigate);

      case UninexusTab.hallErrors:
        return ITHallErrorScreen(onNavigate: _navigate);

      case UninexusTab.requests:
        return ITRequestsScreen(onNavigate: _navigate);

      case UninexusTab.profile:
        return ITProfileScreen(onNavigate: _navigate);

      case UninexusTab.settings:
        return ITSettingsScreen(onNavigate: _navigate);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [

          ITSidebar(
            current: _currentTab,
            onNavigate: _navigate,
          ),

          Expanded(child: _buildScreen()),
        ],
      ),
    );
  }
}