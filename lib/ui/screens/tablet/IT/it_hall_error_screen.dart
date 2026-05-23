import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

import '../../../../services/firebase/it_logs_service.dart';

class ITHallErrorScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;
  const ITHallErrorScreen({super.key, required this.onNavigate});

  @override
  State<ITHallErrorScreen> createState() => _ITHallErrorScreenState();
}

class _ITHallErrorScreenState extends State<ITHallErrorScreen> {
  String? _selectedDocId;

  // Department Filter
  String _selectedDepartment = 'All';
  final List<String> _departments = ['All', 'IT', 'Storage', 'Maintenance', 'Scanners'];

  // Status Filter
  String _selectedStatus = 'All';
  final List<String> _statuses = ['All', 'Pending', 'In repair', 'Fixed'];

  // Helper stream to merge Firestore updates with a periodic ticker for real-time downtime calculation
  Stream<QuerySnapshot> _getPeriodicDeviceStream() async* {
    await for (final snapshot in FirebaseFirestore.instance.collection('Devices').snapshots()) {
      yield snapshot;
      yield* Stream.periodic(const Duration(seconds: 5), (_) => snapshot).takeWhile((_) => true);
    }
  }

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const PageHeading('Errors'),
                _buildDepartmentFilter(),
              ],
            ),
            const SizedBox(height: 30),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left panel
                  Expanded(
                    flex: 45,
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: _buildErrorsListPanel(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right panel
                  Expanded(
                    flex: 55,
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: _selectedDocId != null
                          ? _buildDetailsPanel(_selectedDocId!)
                          : _buildEmptyPlaceholder("Select an error to view details"),
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

  Widget _buildErrorsListPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 4),
            child: _buildStatusFilter(),
          ),
        ),
        Divider(color: AppColors.primary.withValues(alpha: 0.2), height: 1),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('HallErrors').snapshots(),
            builder: (context, errorSnapshot) {
              if (errorSnapshot.connectionState == ConnectionState.waiting) return const LoadingState();

              return StreamBuilder<QuerySnapshot>(
                stream: _getPeriodicDeviceStream(),
                builder: (context, deviceSnapshot) {
                  if (deviceSnapshot.connectionState == ConnectionState.waiting) return const LoadingState();

                  List<Map<String, dynamic>> combinedItems = [];

                  // 1. Process regular Hall Errors
                  if (errorSnapshot.hasData) {
                    for (var doc in errorSnapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      combinedItems.add({
                        'id': doc.id,
                        'isDevice': false,
                        'isTamperedType': false,
                        'hallName': data['hallName'] ?? 'Unknown',
                        'errorType': data['errorType'] ?? 'Unknown Issue',
                        'department': data['department'] ?? 'Maintenance',
                        'status': data['status']?.toString().toLowerCase() ?? 'pending',
                        'timestamp': data['timestamp'] as Timestamp?,
                        'attachment': data['attachment'],
                        'description': data['description'] ?? 'No description.',
                      });
                    }
                  }

                  // 2. Process Devices Collection exceptions
                  if (deviceSnapshot.hasData) {
                    final int currentUnixTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

                    for (var doc in deviceSnapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final int? lastHeartbeatRaw = data['lastHeartbeatUnix'] as int?;

                      final int? lastHeartbeat = lastHeartbeatRaw != null && lastHeartbeatRaw > 9999999999
                          ? lastHeartbeatRaw ~/ 1000
                          : lastHeartbeatRaw;

                      final String scannerName = data['scanner'] ?? 'Unknown Scanner';
                      final String deviceStatus = data['status']?.toString().toLowerCase() ?? 'pending';

                      final bool isTampered = data['tampered'] == true;
                      final bool isOffline = lastHeartbeat != null && (currentUnixTime - lastHeartbeat) > 60;

                      final Timestamp deviceTime = lastHeartbeat != null
                          ? Timestamp.fromMillisecondsSinceEpoch(lastHeartbeat * 1000)
                          : Timestamp.now();

                      // Condition A: Downtime Alert
                      if (isOffline || deviceStatus == 'in repair' || deviceStatus == 'fixed') {
                        combinedItems.add({
                          'id': '${doc.id}_downtime',
                          'rawDocId': doc.id,
                          'isDevice': true,
                          'isTamperedType': false,
                          'hallName': scannerName,
                          'errorType': 'Device Downtime Alert',
                          'department': 'Scanners',
                          'status': isOffline ? 'downtime' : deviceStatus, // Uses explicit downtime token for coloring
                          'timestamp': deviceTime,
                          'attachment': null,
                          'description': 'Hardware device metrics show that connection was lost. Ensure system power cords and local network nodes are stable.',
                        });
                      }

                      // Condition B: Tampered Alert
                      if (isTampered) {
                        combinedItems.add({
                          'id': '${doc.id}_tampered',
                          'rawDocId': doc.id,
                          'isDevice': true,
                          'isTamperedType': true,
                          'hallName': scannerName,
                          'errorType': 'Hardware Tampering Detection Alert',
                          'department': 'Scanners',
                          'status': 'tampered', // Uses explicit tampered token for coloring
                          'timestamp': deviceTime,
                          'attachment': null,
                          'description': 'Security alert! Enclosure monitoring switches indicate that this device frame has been altered or opened without validation.',
                        });
                      }
                    }
                  }

                  // Apply Department Filters
                  if (_selectedDepartment != 'All') {
                    combinedItems = combinedItems.where((item) {
                      return item['department'].toString().toLowerCase() == _selectedDepartment.toLowerCase();
                    }).toList();
                  }

                  // Apply Status Filters
                  if (_selectedStatus != 'All') {
                    combinedItems = combinedItems.where((item) {
                      final String itemStatus = item['status'];
                      final String filterTarget = _selectedStatus.toLowerCase();

                      if (filterTarget == 'pending') {
                        // Include customized downtime or tampering exceptions as high-priority pending issues
                        return itemStatus == 'pending' || itemStatus == '' || itemStatus == 'downtime' || itemStatus == 'tampered';
                      }
                      return itemStatus == filterTarget;
                    }).toList();
                  }

                  // Sort items chronologically (Fixed items at the bottom)
                  combinedItems.sort((a, b) {
                    final bool isFixedA = a['status'] == 'fixed';
                    final bool isFixedB = b['status'] == 'fixed';
                    if (isFixedA != isFixedB) return isFixedA ? 1 : -1;
                    final Timestamp? timeA = a['timestamp'] as Timestamp?;
                    final Timestamp? timeB = b['timestamp'] as Timestamp?;
                    return (timeB ?? Timestamp.now()).compareTo(timeA ?? Timestamp.now());
                  });

                  if (combinedItems.isEmpty) {
                    if (_selectedDocId != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => _selectedDocId = null);
                      });
                    }
                    return _buildEmptyPlaceholder("No issues reported");
                  }

                  final hasSelected = _selectedDocId != null && combinedItems.any((item) => item['id'] == _selectedDocId);
                  if (!hasSelected) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedDocId = combinedItems.first['id']);
                    });
                  }

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: combinedItems.length,
                    itemBuilder: (context, index) => _buildErrorItem(combinedItems[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPlaceholder(String message) {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.layers_clear_outlined, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(message, style: AppTextStyles.hallListErrorStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorItem(Map<String, dynamic> item) {
    final bool isSelected = _selectedDocId == item['id'];
    String status = item['status'];
    final bool isFixed = status == 'fixed';
    final bool isTamperedType = item['isTamperedType'] == true;

    if (status == '') {
      status = 'pending';
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedDocId = item['id']),
      child: Opacity(
        opacity: isFixed ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: AppDecorations.smallCard(isSelected: isSelected),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: status == 'downtime'
                      ? _buildCustomBadge(label: 'Down', color: Colors.red)
                      : status == 'tampered'
                      ? _buildCustomBadge(label: 'Tampered', color: Colors.orange)
                      : StatusBadge(
                    status: status,
                    showIcon: true,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Container(width: 1.5, color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['hallName'], style: AppTextStyles.hallListNumberStyle),
                      const SizedBox(height: 2),
                      Text(item['errorType'],
                          style: AppTextStyles.hallListErrorStyle,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to draw standard badges matching your UI theme configuration
  Widget _buildCustomBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel(String combinedId) {
    final String cleanDocId = combinedId
        .replaceAll('_downtime', '')
        .replaceAll('_tampered', '');

    final bool lookingForTamperedType = combinedId.contains('_tampered');

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('HallErrors').doc(cleanDocId).snapshots(),
      builder: (context, errorSnap) {
        if (errorSnap.hasData && errorSnap.data!.exists) {
          final data = errorSnap.data!.data() as Map<String, dynamic>;
          return _buildDetailsContent(errorSnap.data!.reference, data, false, false);
        }

        final Stream<DocumentSnapshot> detailedDeviceStream = FirebaseFirestore.instance
            .collection('Devices')
            .doc(cleanDocId)
            .snapshots();

        return StreamBuilder<DocumentSnapshot>(
          stream: detailedDeviceStream,
          builder: (context, deviceSnap) {
            if (deviceSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!deviceSnap.hasData || !deviceSnap.data!.exists) {
              return _buildEmptyPlaceholder("Select an error to view details");
            }

            final data = deviceSnap.data!.data() as Map<String, dynamic>;
            final String scannerName = data['scanner'] ?? 'Unknown Scanner';
            final int? lastHeartbeatRaw = data['lastHeartbeatUnix'] as int?;

            final int? lastHeartbeat = lastHeartbeatRaw != null && lastHeartbeatRaw > 9999999999
                ? lastHeartbeatRaw ~/ 1000
                : lastHeartbeatRaw;

            final int currentUnixTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

            String deviceStatus = data['status']?.toString().toLowerCase() ?? 'pending';
            final bool isOffline = lastHeartbeat != null && (currentUnixTime - lastHeartbeat) > 60;

            if (isOffline) {
              deviceStatus = 'downtime';
            }

            final Map<String, dynamic> normalizedDeviceData = lookingForTamperedType
                ? {
              'hallName': scannerName,
              'errorType': 'Hardware Tampering Detection Alert',
              'status': 'tampered',
              'attachment': null,
              'description': 'Security alert! Enclosure monitoring switches indicate that this device frame has been altered or opened without validation.',
            }
                : {
              'hallName': scannerName,
              'errorType': 'Device Downtime Alert',
              'status': deviceStatus,
              'attachment': null,
              'description': 'Hardware device metrics show that connection was lost. Ensure system power cords and local network nodes are stable.',
            };

            return _buildDetailsContent(deviceSnap.data!.reference, normalizedDeviceData, true, lookingForTamperedType);
          },
        );
      },
    );
  }

  Widget _buildDetailsContent(
      DocumentReference docRef,
      Map<String, dynamic> data,
      bool isDevice,
      bool isTamperedType,
      ) {
    String status = data['status']?.toString().toLowerCase() ?? 'pending';
    final String hallName = data['hallName'] ?? 'Unknown';
    final bool rawIsFixed = status == 'fixed';

    if (status == '') {
      status = 'pending';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Icon(
                  isDevice ? (isTamperedType ? Icons.gavel_rounded : Icons.router_rounded) : Icons.warning_amber_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Container(width: 2, color: AppColors.divider),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(hallName, style: AppTextStyles.hallDetailsNumberStyle),
                    const SizedBox(height: 4),
                    Text(data['errorType'] ?? 'No issue', style: AppTextStyles.hallDetailsErrorStyle),
                    const SizedBox(height: 12),
                    status == 'downtime'
                        ? _buildCustomBadge(label: 'Scanner Connection Down', color: Colors.red)
                        : status == 'tampered'
                        ? _buildCustomBadge(label: 'Hardware Tampered', color: Colors.orange)
                        : StatusBadge(status: status, isDot: false),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildImagePreview(data['attachment']),
        const SizedBox(height: 20),
        Text(data['description'] ?? 'No description.', style: AppTextStyles.hallDetailsDescriptionStyle),
        const Spacer(),
        if (!rawIsFixed)
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: isTamperedType ? 'Clear Tamper' : 'In Repair',
                  onTap: () async {
                    try {
                      if (isTamperedType) {
                        await docRef.update({'tampered': false});
                        await ITLogService.logAction('Cleared Hardware Tamper warning on Scanner "$hallName"');
                        if (mounted) showSuccessSnackBar(context, 'Tamper alert successfully resolved.');
                      } else {
                        await docRef.update({'status': 'in repair'});
                        final String trackingLabel = isDevice ? 'Scanner "$hallName"' : '$hallName issue';
                        await ITLogService.logAction('Marked $trackingLabel as In Repair');
                        if (mounted) showSuccessSnackBar(context, 'Status updated to: In Repair');
                      }
                    } catch (e) {
                      if (mounted) showErrorSnackBar(context, 'Error updating database parameters: $e');
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PillButton(
                  label: 'Fixed',
                  onTap: () async {
                    try {
                      if (isTamperedType) {
                        await docRef.update({'tampered': false, 'status': 'fixed'});
                        await ITLogService.logAction('Resolved hardware alignment status on Scanner "$hallName"');
                      } else {
                        await docRef.update({'status': 'fixed'});
                        final String trackingLabel = isDevice ? 'Scanner "$hallName"' : 'issue in $hallName';
                        await ITLogService.logAction('Resolved $trackingLabel');
                      }
                      if (mounted) showSuccessSnackBar(context, 'Status updated to: Fixed');
                    } catch (e) {
                      if (mounted) showErrorSnackBar(context, 'Error updating status: $e');
                    }
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildImagePreview(dynamic attachment) {
    final String base64 = attachment?.toString() ?? '';
    return Container(
      width: double.infinity,
      height: 220,
      decoration: AppDecorations.blueScreen,
      child: base64.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.memory(base64Decode(base64), fit: BoxFit.cover),
      )
          : Center(child: Text('No Image Provided', style: AppTextStyles.blueScreenLabelStyle)),
    );
  }

  Widget _buildDepartmentFilter() {
    return Row(
      children: _departments.map((dept) {
        final isSelected = _selectedDepartment == dept;
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedDepartment = dept;
              _selectedDocId = null;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(dept, style: TextStyle(color: isSelected ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusFilter() {
    return Row(
      children: _statuses.map((status) {
        final isSelected = _selectedStatus == status;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedStatus = status;
              _selectedDocId = null;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(status, style: TextStyle(color: isSelected ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }).toList(),
    );
  }
}