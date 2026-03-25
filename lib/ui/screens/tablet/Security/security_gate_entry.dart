import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const PageHeading('Gate Entry'),
                _buildFilterToggle(),
              ],
            ),
            const SizedBox(height: 47),
            Expanded(
              child: StreamBuilder<List<GateScan>>(
                stream: _gateService.getGateScans(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));

                  List<GateScan> scans = snapshot.data ?? [];

                  // 1. Filter by date string matching your model
                  if (_selectedDate != null) {
                    final String filterString = DateFormat('yyyy-MM-dd').format(_selectedDate!);
                    scans = scans.where((scan) => scan.date == filterString).toList();
                  }

                  // 2. FIXED AUTOSELECT LOGIC
                  if (scans.isNotEmpty) {
                    // Check if the current selection is still part of the visible list
                    bool currentSelectionStillValid = scans.any((s) => s.id == _selectedScan?.id);

                    // Only force a selection if we haven't picked anyone yet,
                    // or if the person we were looking at disappeared (e.g., date filter changed)
                    if (!_hasInitialSelection || !currentSelectionStillValid) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _selectedScan = scans.first;
                            _hasInitialSelection = true;
                          });
                        }
                      });
                    }
                  }

                  return Row(
                    children: [
                      /// Left side - Scrollable entry list
                      Expanded(
                        flex: 5,
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: scans.isEmpty
                              ? const Center(child: Text("No entries found", style: TextStyle(color: AppColors.textDark)))
                              : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: scans.length,
                            itemBuilder: (context, index) {
                              final scan = scans[index];
                              final bool isSelected = _selectedScan?.id == scan.id;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedScan = scan;
                                    _hasInitialSelection = true; // Mark that we have an active selection
                                  });
                                },
                                child: _EntryRow(
                                  id: scan.studentId,
                                  status: scan.status,
                                  isSelected: isSelected,
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
                          child: scans.isEmpty
                              ? const Center(child: Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.primary))
                              : (_selectedScan == null
                              ? const Center(child: CircularProgressIndicator())
                              : _UserDataPanel(scan: _selectedScan!)),
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

  Widget _buildFilterToggle() {
    return Row(
      children: [
        if (_selectedDate != null)
          IconButton(
            onPressed: () => setState(() {
              _selectedDate = null;
              _hasInitialSelection = false; // Allow autoselect to trigger for "All Time"
            }),
            icon: const Icon(Icons.refresh, color: Colors.redAccent),
            tooltip: "Show All",
          ),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
                _hasInitialSelection = false; // Reset so it autoselects the first person on the new date
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  _selectedDate == null ? "All Time" : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EntryRow extends StatelessWidget {
  final String id, status;
  final bool isSelected;
  const _EntryRow({required this.id, required this.status, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    Color dotColor = (status.toLowerCase() == 'denied') ? Colors.red : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: (AppDecorations.smallCard() as BoxDecoration).copyWith(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
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
            child: Text(id, style: const TextStyle(fontFamily: AppFonts.spaceGrotesk, fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textDark)),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
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
            const Text("User Data", style: TextStyle(fontFamily: AppFonts.batangas, fontWeight: FontWeight.w800, fontSize: 26, color: AppColors.primary)),
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