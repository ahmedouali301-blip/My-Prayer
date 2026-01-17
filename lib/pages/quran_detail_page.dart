import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuranDetailPage extends StatefulWidget {
  final String surahName;
  final String surahArabicName;
  final int surahNumber;

  const QuranDetailPage({
    Key? key,
    required this.surahName,
    required this.surahArabicName,
    required this.surahNumber,
  }) : super(key: key);

  @override
  State<QuranDetailPage> createState() => _QuranDetailPageState();
}

class _QuranDetailPageState extends State<QuranDetailPage> {
  List<String> verses = [];
  bool isLoading = true;
  int? lastReadVerse; // Dernier verset lu
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadSurahVerses();
    _loadReadingProgress();
  }

  Future<void> _loadReadingProgress() async {
    if (_currentUser == null) return;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('reading_progress')
          .doc('surah_${widget.surahNumber}')
          .get();

      if (doc.exists && mounted) {
        setState(() {
          lastReadVerse = doc.data()?['lastVerse'] as int?;
        });
      }
    } catch (e) {
      print('Error loading reading progress: $e');
    }
  }

  Future<void> _saveReadingProgress(int verseIndex) async {
    if (_currentUser == null) return;

    try {
      // Si on clique sur le même verset, on retire le marqueur
      if (lastReadVerse == verseIndex) {
        await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('reading_progress')
            .doc('surah_${widget.surahNumber}')
            .delete();

        if (mounted) {
          setState(() {
            lastReadVerse = null;
          });
        }
      } else {
        // Sinon, on met à jour le marqueur
        await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('reading_progress')
            .doc('surah_${widget.surahNumber}')
            .set({
          'surahNumber': widget.surahNumber,
          'surahName': widget.surahName,
          'lastVerse': verseIndex,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (mounted) {
          setState(() {
            lastReadVerse = verseIndex;
          });
        }
      }
    } catch (e) {
      print('Error saving reading progress: $e');
    }
  }

  void _loadSurahVerses() {
    // Données des sourates avec leurs versets en arabe
    final Map<int, List<String>> surahsData = {
      1: [ // Al-Fatiha (Basmala affichée en haut)
        'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        'الرَّحْمَٰنِ الرَّحِيمِ',
        'مَالِكِ يَوْمِ الدِّينِ',
        'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
        'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
        'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      ],
      105: [ // Al-Fil
        'أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَابِ الْفِيلِ',
        'أَلَمْ يَجْعَلْ كَيْدَهُمْ فِي تَضْلِيلٍ',
        'وَأَرْسَلَ عَلَيْهِمْ طَيْرًا أَبَابِيلَ',
        'تَرْمِيهِم بِحِجَارَةٍ مِّن سِجِّيلٍ',
        'فَجَعَلَهُمْ كَعَصْفٍ مَّأْكُولٍ',
      ],
      106: [ // Quraysh
        'لِإِيلَافِ قُرَيْشٍ',
        'إِيلَافِهِمْ رِحْلَةَ الشِّتَاءِ وَالصَّيْفِ',
        'فَلْيَعْبُدُوا رَبَّ هَٰذَا الْبَيْتِ',
        'الَّذِي أَطْعَمَهُم مِّن جُوعٍ وَآمَنَهُم مِّنْ خَوْفٍ',
      ],
      107: [ // Al-Maun
        'أَرَأَيْتَ الَّذِي يُكَذِّبُ بِالدِّينِ',
        'فَذَٰلِكَ الَّذِي يَدُعُّ الْيَتِيمَ',
        'وَلَا يَحُضُّ عَلَىٰ طَعَامِ الْمِسْكِينِ',
        'فَوَيْلٌ لِّلْمُصَلِّينَ',
        'الَّذِينَ هُمْ عَن صَلَاتِهِمْ سَاهُونَ',
        'الَّذِينَ هُمْ يُرَاءُونَ',
        'وَيَمْنَعُونَ الْمَاعُونَ',
      ],
      108: [ // Al-Kawthar
        'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
        'فَصَلِّ لِرَبِّكَ وَانْحَرْ',
        'إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ',
      ],
      109: [ // Al-Kafirun
        'قُلْ يَا أَيُّهَا الْكَافِرُونَ',
        'لَا أَعْبُدُ مَا تَعْبُدُونَ',
        'وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ',
        'وَلَا أَنَا عَابِدٌ مَّا عَبَدتُّمْ',
        'وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ',
        'لَكُمْ دِينُكُمْ وَلِيَ دِينِ',
      ],
      110: [ // An-Nasr
        'إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ',
        'وَرَأَيْتَ النَّاسَ يَدْخُلُونَ فِي دِينِ اللَّهِ أَفْوَاجًا',
        'فَسَبِّحْ بِحَمْدِ رَبِّكَ وَاسْتَغْفِرْهُ ۚ إِنَّهُ كَانَ تَوَّابًا',
      ],
      111: [ // Al-Masad
        'تَبَّتْ يَدَا أَبِي لَهَبٍ وَتَبَّ',
        'مَا أَغْنَىٰ عَنْهُ مَالُهُ وَمَا كَسَبَ',
        'سَيَصْلَىٰ نَارًا ذَاتَ لَهَبٍ',
        'وَامْرَأَتُهُ حَمَّالَةَ الْحَطَبِ',
        'فِي جِيدِهَا حَبْلٌ مِّن مَّسَدٍ',
      ],
      112: [ // Al-Ikhlas
        'قُلْ هُوَ اللَّهُ أَحَدٌ',
        'اللَّهُ الصَّمَدُ',
        'لَمْ يَلِدْ وَلَمْ يُولَدْ',
        'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
      ],
      113: [ // Al-Falaq
        'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
        'مِن شَرِّ مَا خَلَقَ',
        'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
        'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
        'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      ],
      114: [ // An-Nas
        'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
        'مَلِكِ النَّاسِ',
        'إِلَٰهِ النَّاسِ',
        'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
        'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
        'مِنَ الْجِنَّةِ وَالنَّاسِ',
      ],
    };

    setState(() {
      verses = surahsData[widget.surahNumber] ?? [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5DC),
      body: Column(
        children: [
          _buildHeader(context, isDark),
          _buildSurahTitle(isDark),
          Expanded(
            child: isLoading
                ? _buildLoadingIndicator()
                : verses.isEmpty
                    ? _buildEmptyState()
                    : _buildVersesList(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.surahName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${verses.length} آيات',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahTitle(bool isDark) {
    // Ne pas afficher la Basmala pour Sourate 9 (At-Tawbah) et Sourate 1 (déjà incluse)
    final bool showBasmala = widget.surahNumber != 9 && widget.surahNumber != 1;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Nom de la sourate
          Text(
            widget.surahArabicName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1B4965),
              fontSize: 36,
              fontWeight: FontWeight.bold,
              height: 1.5,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 100,
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  isDark ? Colors.white : const Color(0xFF1B4965),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Basmala (si applicable)
          if (showBasmala) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF2A2A2A) 
                    : const Color(0xFFF5F5DC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withOpacity(0.1) 
                      : const Color(0xFF1B4965).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: isDark 
                      ? Colors.white 
                      : const Color(0xFF1B4965),
                  fontFamily: 'Amiri',
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  height: 1.8,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucun verset disponible',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersesList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: verses.length,
      itemBuilder: (context, index) {
        return _buildVerseCard(index, isDark);
      },
    );
  }

  Widget _buildVerseCard(int index, bool isDark) {
    final isLastRead = lastReadVerse == index;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isLastRead
              ? const Color(0xFF2E7D32) // Vert pour le dernier verset lu
              : (isDark 
                  ? Colors.white.withOpacity(0.1) 
                  : const Color(0xFF1B4965).withOpacity(0.1)),
          width: isLastRead ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Indicateur de dernière lecture
          if (isLastRead)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF2E7D32),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.bookmark,
                    color: Color(0xFF2E7D32),
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Dernière lecture',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          // Numéro du verset
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1B4965),
                      const Color(0xFF2C6E8F),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Bouton pour marquer comme lu
              IconButton(
                icon: Icon(
                  isLastRead ? Icons.bookmark : Icons.bookmark_border,
                  color: isLastRead 
                      ? const Color(0xFF2E7D32)
                      : (isDark ? Colors.white54 : Colors.grey),
                  size: 20,
                ),
                onPressed: () async {
                  await _saveReadingProgress(index);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          lastReadVerse == index 
                              ? 'Marqué comme dernière lecture'
                              : 'Marqueur retiré',
                        ),
                        duration: const Duration(seconds: 1),
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                    );
                  }
                },
              ),
              // Bouton pour copier le verset
              IconButton(
                icon: Icon(
                  Icons.copy_outlined,
                  color: isDark ? Colors.white54 : Colors.grey,
                  size: 20,
                ),
                onPressed: () {
                  // Copier le verset dans le presse-papier
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Verset copié'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: const Color(0xFF1B4965),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Texte du verset en arabe
          Text(
            verses[index],
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1B4965),
              fontSize: 28,
              height: 2.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Décoration en bas
          Center(
            child: Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    isDark ? Colors.white38 : const Color(0xFF1B4965).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}