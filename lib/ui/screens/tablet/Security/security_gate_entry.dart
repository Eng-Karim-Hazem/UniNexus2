import 'package:flutter/material.dart';
import 'package:uninexus/model/gatescan_model.dart';
import 'package:uninexus/services/firebase/gatescan_service.dart';
import 'package:uninexus/theme/app_theme.dart';
import 'package:uninexus/theme/uninexus_tab.dart';

class SecurityGateEntryScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;
  const SecurityGateEntryScreen({super.key, required this.onNavigate});

  @override
  State<SecurityGateEntryScreen> createState() => _SecurityGateEntryScreenState();
}

class _SecurityGateEntryScreenState extends State<SecurityGateEntryScreen> {
  final GateService _gateService = GateService();
  GateScan? _selectedScan;
  bool _hasInitialSelection = false;

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading('Gate Entry'),
            const SizedBox(height: 47),
            Expanded(
              child: StreamBuilder<List<GateScan>>(
                stream: _gateService.getGateScans(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                  final scans = snapshot.data ?? [];

                  // Autoselect the latest entry on first load
                  if (scans.isNotEmpty && !_hasInitialSelection) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _selectedScan = scans.first;
                          _hasInitialSelection = true;
                        });
                      }
                    });
                  }

                  return Row(
                    children: [
                      /// Left side - Scrollable entry list
                      Expanded(
                        flex: 5,
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: scans.length,
                            itemBuilder: (context, index) {
                              final scan = scans[index];
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _selectedScan = scan;
                                  _hasInitialSelection = true;
                                }),
                                child: _EntryRow(
                                  id: scan.studentId, //
                                  status: scan.status, //
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      /// Right side - Detailed user data panel
                      Expanded(
                        flex: 4,
                        child: GlassCard(
                          padding: const EdgeInsets.all(32),
                          child: _selectedScan == null
                              ? const Center(child: CircularProgressIndicator())
                              : _UserDataPanel(scan: _selectedScan!),
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// --- ORIGINAL UI HELPER WIDGETS ---

class _EntryRow extends StatelessWidget {
  final String id, status;
  const _EntryRow({required this.id, required this.status});

  @override
  Widget build(BuildContext context) {
    // Determine the color based on the Firestore status string
    Color dotColor;
    switch (status.toLowerCase()) {
      case 'approved':
      case 'allowed':
        dotColor = Colors.green; // Set to green as requested
        break;
      case 'denied':
        dotColor = Colors.red;
        break;
      default:
        dotColor = Colors.grey; // Keeps the grey for unknown/other statuses
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: AppDecorations.smallCard(),
      child: Row(
        children: [
          Image.asset(
            'assets/images/avatar.png',
            width: 28, height: 28,
            errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Container(width: 4, height: 28, color: AppColors.primary.withOpacity(.35)),
          const SizedBox(width: 14),
          Expanded(
              child: Text(
                  id,
                  style: const TextStyle(
                      fontFamily: AppFonts.spaceGrotesk,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.textDark
                  )
              )
          ),
          // Custom dot replacing the grey StatusBadge
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserDataPanel extends StatelessWidget {
  final GateScan scan;
  const _UserDataPanel({required this.scan});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/avatar.png',
              width: 40, height: 40,
              errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primary, size: 40),
            ),
            const SizedBox(width: 16),
            Container(width: 3, height: 40, color: AppColors.primary.withOpacity(0.4)),
            const SizedBox(width: 16),
            const Text(
                "User Data",
                style: TextStyle(
                    fontFamily: AppFonts.batangas,
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    color: AppColors.primary
                )
            ),
          ],
        ),
        const SizedBox(height: 36),
        buildDataRow("Name", scan.name),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(flex: 3, child: buildDataRow("User Type", scan.type)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: buildDataRow("Year", scan.year)),
          ],
        ),
        const SizedBox(height: 24),
        buildDataRow("ID", scan.studentId),
        const SizedBox(height: 24),
        buildDataRow("Faculty", scan.faculty),
        const SizedBox(height: 24),
        buildDataRow("Status", scan.status),
        const SizedBox(height: 24),
        buildDataRow("Note", scan.note),
      ],
    );
  }
}