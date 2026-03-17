import 'package:flutter/material.dart';

import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

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

      case UninexusTab.id:
        return SecurityIdScreen(onNavigate: _navigate);

      case UninexusTab.requests:
        return SecurityGateEntryScreen(onNavigate: _navigate);

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

    return Scaffold(
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
    );
  }
}