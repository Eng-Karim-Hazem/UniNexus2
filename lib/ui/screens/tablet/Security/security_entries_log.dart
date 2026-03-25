import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Required for DateFormat
import 'package:uninexus/theme/app_theme.dart';
import 'package:uninexus/theme/uninexus_tab.dart';

class GateLogScreen extends StatelessWidget {
  final void Function(UninexusTab) onNavigate;
  const GateLogScreen({super.key, required this.onNavigate});

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
                  // Pulling directly from gate_scans
                  stream: FirebaseFirestore.instance
                      .collection('gate_scans')
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;

                        // Pass raw database values
                        return _LogEntryItem(
                          name: data['name'] ?? 'Unknown User',
                          status: data['status'] ?? 'unknown',
                          dbTime: data['time'] ?? '',
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

class _LogEntryItem extends StatelessWidget {
  final String name, status, dbTime;
  const _LogEntryItem({
    required this.name,
    required this.status,
    required this.dbTime,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Determine the status dot color
    Color dotColor;
    switch (status.toLowerCase()) {
      case 'approved':
      case 'allowed':
        dotColor = Colors.green;
        break;
      case 'denied':
        dotColor = Colors.red;
        break;
      default:
        dotColor = Colors.yellow;
    }

    // 2. Format Time from Database String
    String displayTime = "N/A";
    if (dbTime.isNotEmpty) {
      try {
        // Parses "20:10:35" into a DateTime object
        final DateTime parsed = DateFormat("HH:mm:ss").parse(dbTime);
        // Formats into "8:10 PM"
        displayTime = DateFormat("h:mm a").format(parsed);
      } catch (e) {
        displayTime = dbTime; // Fallback to raw string if parsing fails
      }
    }

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
            'assets/images/avatar.png',
            width: 32, height: 32,
            errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Container(width: 2, height: 32, color: AppColors.primary.withValues(alpha: 0.2)),
          const SizedBox(width: 16),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: AppColors.textDark, fontSize: 16),
                children: [
                  TextSpan(
                    text: name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: AppFonts.spaceGrotesk),
                  ),
                  const TextSpan(text: " Scanned at the gate"),
                ],
              ),
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 14),
          Text(
            displayTime,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}