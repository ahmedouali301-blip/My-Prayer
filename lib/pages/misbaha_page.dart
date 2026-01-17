import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'bottom_nav.dart';
import 'home_page.dart';
import 'prayer_times_page.dart';
import 'qibla_page.dart';
import 'settings_page.dart';

class MisbahaPage extends StatelessWidget {
  const MisbahaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final misbahaRef =
        FirebaseFirestore.instance.collection('myprayer').doc('misbaha_stats');

    return Scaffold(
      backgroundColor: const Color(0xFF0F3460),
      appBar: AppBar(
        title: const Text("Misbaha"),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F3460),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: misbahaRef.snapshots(),
        builder: (context, snapshot) {
          int count = 0;
          int target = 33;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            count = data['count'] ?? 0;
            target = data['target'] ?? 33;
          }

          return Column(
            children: [
              const SizedBox(height: 20),

              /// OBJECTIF
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Objectif",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [33, 99, 100].map((value) {
                        final isSelected = value == target;
                        return GestureDetector(
                          onTap: () {
                            misbahaRef.set(
                              {'target': value, 'count': 0},
                              SetOptions(merge: true),
                            );
                          },
                          child: Container(
                            width: 70,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFD4A84E)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              value.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              /// CERCLE COMPTEUR
              Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  color: Color(0xFFD4A84E),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "$count\n",
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F3460),
                          ),
                        ),
                        TextSpan(
                          text: "/$target",
                          style: const TextStyle(
                            fontSize: 24,
                            color: Color(0xFF0F3460),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// BOUTON COMPTER
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (count < target) {
                    misbahaRef.update({
                      'count': FieldValue.increment(1),
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A84E),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 60, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Compter",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              
              const Spacer(),
            ],
          );
        },
      ),
      bottomNavigationBar: SharedBottomNav(
        currentIndex: 0,
        onHomePressed: (context) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        },
        onTimesPressed: (context) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PrayerTimesPage()),
          );
        },
        onQiblaPressed: (context) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const QiblaPage()),
          );
        },
        onSettingsPressed: (context) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          );
        },
      ),
    );
  }
}