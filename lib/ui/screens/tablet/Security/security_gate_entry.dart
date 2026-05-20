import 'dart:convert'; // Required for base64 decoding
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uninexus/model/gate_scan_model.dart';
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: LoadingState());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: ErrorState(
                        message: "Error loading gate entries: ${snapshot.error}",
                        onRetry: () => setState(() {}),
                      ),
                    );
                  }

                  List<GateScan> scans = snapshot.data ?? [];

                  // Filter by selected date
                  if (_selectedDate != null) {
                    final String filterString = DateFormat('yyyy-MM-dd').format(_selectedDate!);
                    scans = scans.where((scan) => scan.date == filterString).toList();
                  }

                  // Auto-select first item if needed
                  if (scans.isNotEmpty) {
                    bool currentSelectionStillValid = scans.any((s) => s.id == _selectedScan?.id);

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
                      // Left panel - Gate entry list
                      Expanded(
                        flex: 5,
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: scans.isEmpty
                              ? const Center(
                            child: EmptyState(
                              message: "No gate entries recorded yet.",
                              icon: Icons.door_front_door,
                            ),
                          )
                              : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: scans.length,
                            itemBuilder: (context, index) {
                              final scan = scans[index];
                              final bool isSelected = _selectedScan?.id == scan.id;

                              return AppEntryRow(
                                label: scan.studentId,
                                status: scan.status,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    _selectedScan = scan;
                                    _hasInitialSelection = true;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Right panel - User details
                      Expanded(
                        flex: 4,
                        child: GlassCard(
                          padding: const EdgeInsets.all(32),
                          child: scans.isEmpty
                              ? const Center(child: Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.primary))
                              : (_selectedScan == null
                              ? const Center(child: LoadingState())
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

  // Date filter toggle
  Widget _buildFilterToggle() {
    return Row(
      children: [
        if (_selectedDate != null)
          IconButton(
            onPressed: () => setState(() {
              _selectedDate = null;
              _hasInitialSelection = false;
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
                _hasInitialSelection = false;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
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

// User data panel widget with Base64 photo in top-right
class _UserDataPanel extends StatelessWidget {
  final GateScan scan;
  const _UserDataPanel({required this.scan});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icons/Individual.png',
                    width: 40, height: 40,
                    errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primary, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Container(width: 3, height: 40, color: AppColors.primary.withValues(alpha: 0.4)),
                  const SizedBox(width: 16),
                  const Text("User Data", style: TextStyle(fontFamily: AppFonts.batangas, fontWeight: FontWeight.w800, fontSize: 26, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 36),
              buildInfoRow(
                label: "Name",
                value: scan.name,
                fontSize: 18,
                verticalPadding: 12,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: buildInfoRow(
                      label: "User Type",
                      value: scan.type,
                      fontSize: 18,
                      verticalPadding: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: buildInfoRow(
                      label: "Year",
                      value: scan.year,
                      fontSize: 18,
                      verticalPadding: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              buildInfoRow(
                label: "ID",
                value: scan.studentId,
                fontSize: 18,
                verticalPadding: 12,
              ),
              const SizedBox(height: 24),
              buildInfoRow(
                label: "Faculty",
                value: scan.faculty,
                fontSize: 18,
                verticalPadding: 12,
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: buildInfoRow(
                      label: "Date",
                      value: scan.date,
                      fontSize: 18,
                      verticalPadding: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: buildInfoRow(
                      label: "Time",
                      value: scan.time,
                      fontSize: 18,
                      verticalPadding: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Text(
                      'Status : ',
                      style: TextStyle(
                        fontFamily: AppFonts.spaceGrotesk,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    StatusBadge(status: scan.status, isDot: false),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              buildInfoRow(
                label: "Note",
                value: scan.note,
                fontSize: 18,
                verticalPadding: 12,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // --- TOP RIGHT PHOTO PANEL (Matches ID Lookup style) ---
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
              color: Colors.white.withOpacity(0.3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (scan.photo != null && scan.photo!.isNotEmpty)
                  ? Image.memory(
                base64Decode(scan.photo!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              )
                  : Container(
                color: Colors.grey[200],
                child: const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }
}