import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uninexus/theme/app_theme.dart';
import 'package:uninexus/theme/uninexus_tab.dart';

class GateLogScreen extends StatelessWidget {
  final void Function(UninexusTab) onNavigate;
  const GateLogScreen({super.key, required this.onNavigate});

  // Format time from DB format to display format
  String _formatTime(String dbTime) {
    if (dbTime.isEmpty) return "N/A";
    try {
      final DateTime parsed = DateFormat("HH:mm:ss").parse(dbTime);
      return DateFormat("h:mm a").format(parsed);
    } catch (e) {
      return dbTime;
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
            const PageHeading('Gate Log'),
            const SizedBox(height: 32),

            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('gate_scans')
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingState();
                    }

                    if (snapshot.hasError) {
                      return ErrorState(
                        message: "Error loading gate logs: ${snapshot.error}",
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const EmptyState(
                        message: "No gate entries recorded yet.",
                        icon: Icons.door_front_door,
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/icons/Individual.png',
                                width: 32, height: 32,
                                errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primary, size: 32),
                              ),
                              const SizedBox(width: 16),
                              Container(width: 2, height: 32, color: AppColors.primary.withValues(alpha: 0.2)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  data['name'] ?? 'Unknown User',
                                  style: AppTextStyles.entryRowNameStyle,
                                ),
                              ),
                              StatusBadge(
                                status: data['status'] ?? 'unknown',
                                isDot: true,
                                isCompact: true,
                              ),
                              const SizedBox(width: 14),
                              Text(
                                _formatTime(data['time'] ?? ''),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}