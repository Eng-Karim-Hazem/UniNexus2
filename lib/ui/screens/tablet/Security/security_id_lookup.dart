import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:uninexus/theme/app_theme.dart';
import 'package:uninexus/theme/uninexus_tab.dart';

class SecurityIdLookupScreen extends StatelessWidget {
  final void Function(UninexusTab) onNavigate;

  const SecurityIdLookupScreen({super.key, required this.onNavigate});

  static const users = [
    {'name': 'Ammar Tarek Mohamed', 'status': 'denied'},
    {'name': 'Moaz Osama Gamil', 'status': 'denied'},
    {'name': 'Youssef Salama Selem', 'status': 'approved'},
  ];

  @override
  Widget build(BuildContext context) {

    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE
            Row(
              children: const [
                Text(
                  "ID Lookup",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80),

            /// SEARCH BAR
            Container(
              width: 350,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: AppDecorations.smallCard(),
              child: Row(
                children: [

                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search User By ID",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primary),
                    onPressed: () {},
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Row(
                children: [

                  /// LEFT LIST
                  Expanded(
                    flex: 5,
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: ListView(
                        children: users
                            .map((e) => _UserRow(
                          name: e['name']!,
                          status: e['status']!,
                        ))
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  /// USER DATA PANEL
                  Expanded(
                    flex: 4,
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: const _UserDataPanel(),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final String name;
  final String status;

  const _UserRow({required this.name, required this.status});

  Color get color {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'denied':
        return Colors.red;
      default:
        return Colors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.smallCard(),
      child: Row(
        children: [

          Image.asset(
            'assets/images/avatar.png',
            width: 26,
          ),

          const SizedBox(width: 10),

          Container(
            width: 2,
            height: 26,
            color: AppColors.primary.withOpacity(.35),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: color, shape: BoxShape.circle),
          )
        ],
      ),
    );
  }
}

class _UserDataPanel extends StatelessWidget {
  const _UserDataPanel();

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [

        Row(
          children: [
            Icon(Icons.person, color: AppColors.primary),
            SizedBox(width: 10),
            Text(
              "User Data",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary),
            )
          ],
        ),

        SizedBox(height: 20),

        Text("Name : Ammar Tarek Mohamed",
            style: TextStyle(fontWeight: FontWeight.bold)),

        SizedBox(height: 10),

        Text("User Type: Student   Year: 4",
            style: TextStyle(fontWeight: FontWeight.bold)),

        SizedBox(height: 10),

        Text("ID: ST20222",
            style: TextStyle(fontWeight: FontWeight.bold)),

        SizedBox(height: 10),

        Text("Faculty: ICT",
            style: TextStyle(fontWeight: FontWeight.bold)),

        SizedBox(height: 10),

        Text("Status: Denied",
            style: TextStyle(fontWeight: FontWeight.bold)),

        SizedBox(height: 10),

        Text("Note: Last year's tuition unpaid",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}