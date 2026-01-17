import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'quran_detail_page.dart';
import 'bottom_nav.dart';
import 'home_page.dart';
import 'prayer_times_page.dart';
import 'qibla_page.dart';
import 'settings_page.dart';

class QuranListPage extends StatefulWidget {
  const QuranListPage({Key? key}) : super(key: key);

  @override
  State<QuranListPage> createState() => _QuranListPageState();
}

class _QuranListPageState extends State<QuranListPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> _allSurahs = [];
  List<Map<String, dynamic>> _filteredSurahs = [];
  Map<int, Map<String, dynamic>> _readingProgress = {}; // surahNumber -> progress data
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurahsFromFirestore();
    _loadReadingProgress();
    _searchController.addListener(_filterSurahs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReadingProgress() async {
    if (_currentUser == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('reading_progress')
          .get();

      if (mounted) {
        setState(() {
          _readingProgress = {
            for (var doc in snapshot.docs)
              doc.data()['surahNumber'] as int: doc.data()
          };
        });
      }
    } catch (e) {
      print('Error loading reading progress: $e');
    }
  }

  Future<void> _loadSurahsFromFirestore() async {
    try {
      final snapshot = await _firestore
          .collection('quran_surahs')
          .orderBy('number')
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _allSurahs = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name'] ?? '',
              'arabicName': data['arabicName'] ?? '',
              'number': data['number'] ?? 0,
              'verses': data['verses'] ?? 0,
            };
          }).toList();
          _filteredSurahs = _allSurahs;
          _isLoading = false;
        });
      } else {
        setState(() {
          _allSurahs = _getDefaultSurahs();
          _filteredSurahs = _allSurahs;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading surahs: $e');
      setState(() {
        _allSurahs = _getDefaultSurahs();
        _filteredSurahs = _allSurahs;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getDefaultSurahs() {
    return [
      {'name': 'Al-Fatiha', 'arabicName': 'الفاتحة', 'number': 1, 'verses': 7},
      {'name': 'Al-Baqarah', 'arabicName': 'البقرة', 'number': 2, 'verses': 286},
      {'name': 'Al-Imran', 'arabicName': 'آل عمران', 'number': 3, 'verses': 200},
      {'name': 'An-Nisa', 'arabicName': 'النساء', 'number': 4, 'verses': 176},
      {'name': 'Al-Maidah', 'arabicName': 'المائدة', 'number': 5, 'verses': 120},
      {'name': 'Al-Ikhlass', 'arabicName': 'الإخلاص', 'number': 112, 'verses': 4},
      {'name': 'Al-Falaq', 'arabicName': 'الفلق', 'number': 113, 'verses': 5},
      {'name': 'An-Nass', 'arabicName': 'الناس', 'number': 114, 'verses': 6},
    ];
  }

  void _filterSurahs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSurahs = _allSurahs.where((surah) {
        return surah['name'].toLowerCase().contains(query) ||
               surah['arabicName'].contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(isDark),
          Expanded(
            child: _isLoading ? _buildLoadingIndicator() : _buildSurahList(isDark),
          ),
          SharedBottomNav(
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
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1B4965),
            const Color(0xFF2C6E8F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Text(
          'القرآن الكريم',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: 'Rechercher une sourate...',
          hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF1B4965),
      ),
    );
  }

  Widget _buildSurahList(bool isDark) {
    if (_filteredSurahs.isEmpty) {
      return Center(
        child: Text(
          'Aucune sourate trouvée',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredSurahs.length,
      itemBuilder: (context, index) {
        final surah = _filteredSurahs[index];
        final surahNumber = surah['number'] as int;
        final hasProgress = _readingProgress.containsKey(surahNumber);
        final lastVerse = hasProgress ? _readingProgress[surahNumber]!['lastVerse'] as int? : null;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuranDetailPage(
                      surahName: surah['name'],
                      surahArabicName: surah['arabicName'],
                      surahNumber: surah['number'],
                    ),
                  ),
                );
                // Recharger la progression après le retour
                _loadReadingProgress();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: hasProgress
                      ? Border.all(
                          color: const Color(0xFF2E7D32).withOpacity(0.3),
                          width: 2,
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B4965),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${surah['number']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (hasProgress)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.bookmark,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surah['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${surah['verses']} versets',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              if (hasProgress && lastVerse != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF2E7D32),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Verset ${lastVerse + 1}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      surah['arabicName'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFD4A574) : const Color(0xFF1B4965),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}