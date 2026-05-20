import 'package:flutter/material.dart';

import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';
import 'package:uninexus/ui/screens/tablet/Security/security_announcemnets_screen.dart';
import 'package:uninexus/ui/screens/tablet/Security/security_entries_log.dart';

import 'package:uninexus/ui/widgets/security_sidebar_widget.dart';

import 'package:uninexus/ui/screens/tablet/Security/security_dashboard.dart';
import 'package:uninexus/ui/screens/tablet/Security/security_id_screen.dart';
import 'package:uninexus/ui/screens/tablet/Security/security_gate_entry.dart';
import 'package:uninexus/ui/screens/tablet/Security/security_id_lookup.dart';
import 'package:uninexus/ui/screens/tablet/Security/security_profile_screen.dart';
import 'package:uninexus/ui/screens/tablet/Security/security_settings_screen.dart';

class SecurityShell extends StatefulWidget {
  const SecurityShell({super.key});

  @override
  State<SecurityShell> createState() => _SecurityShellState();
}

class _SecurityShellState extends State<SecurityShell> {

  UninexusTab _currentTab = UninexusTab.dashboard;

  void _navigate(UninexusTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  Widget _buildScreen() {

    switch (_currentTab) {

      case UninexusTab.dashboard:
        return SecurityDashboardScreen(onNavigate: _navigate);

      case UninexusTab.announcements:
        return SecurityAnnouncementsScreen(onNavigate: _navigate);

      case UninexusTab.id:
        return SecurityIdScreen(onNavigate: _navigate);

      case UninexusTab.requests:
        return SecurityGateEntryScreen(onNavigate: _navigate);

      case UninexusTab.hallErrors:
        return GateLogScreen(onNavigate: _navigate);

      case UninexusTab.logs:
        return SecurityIdLookupScreen(onNavigate: _navigate);

      case UninexusTab.profile:
        return SecurityProfileScreen(onNavigate: _navigate);

      case UninexusTab.settings:
        return SecuritySettingsScreen(onNavigate: _navigate);

      default:
        return SecurityDashboardScreen(onNavigate: _navigate);
    }
  }

  @override
  Widget build(BuildContext context) {

    // ADDED: PopScope to intercept the Android Hardware Back Button
    return PopScope(
      canPop: false, // Prevents the app from exiting automatically
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;

        // If the user presses back and they are NOT on the dashboard...
        if (_currentTab != UninexusTab.dashboard) {
          // Send them back to the dashboard!
          _navigate(UninexusTab.dashboard);
        }
        // If they are already on the dashboard, it does nothing.
        // (They must use your actual logout button to leave the app).
      },
      child: Scaffold(
        backgroundColor: AppColors.background,

        body: Row(
          children: [

            SecuritySidebar(
              current: _currentTab,
              onNavigate: _navigate,
            ),

            Expanded(child: _buildScreen()),
          ],
        ),
      ),
    );
  }
}