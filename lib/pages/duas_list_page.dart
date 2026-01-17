import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dua_detail_page.dart';
import 'bottom_nav.dart';
import 'home_page.dart';
import 'prayer_times_page.dart';
import 'qibla_page.dart';
import 'settings_page.dart';

class DuasListPage extends StatefulWidget {
  const DuasListPage({Key? key}) : super(key: key);

  @override
  State<DuasListPage> createState() => _DuasListPageState();
}

class _DuasListPageState extends State<DuasListPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _allDuas = [];
  List<Map<String, dynamic>> _filteredDuas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDuas();
    _searchController.addListener(_filterDuas);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDuas() async {
    try {
      final snapshot = await _firestore.collection('duas').get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _allDuas = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'title': data['title'] ?? '',
              'arabic': data['arabic'] ?? '',
              'translation': data['translation'] ?? '',
            };
          }).toList();
          _filteredDuas = List.from(_allDuas);
          _isLoading = false;
        });
      } else {
        _loadDefaultDuas();
      }
    } catch (e) {
      _loadDefaultDuas();
    }
  }

  void _loadDefaultDuas() {
    setState(() {
      _allDuas = [
        {
          'id': '1',
          'title': 'Dua du Matin',
          'arabic': 'اللَّهُمَّ أَنْتَ رَبِّي لاَ إِلَهَ إِلاَّ أَنْتَ',
          'translation': 'Ô Allah, Tu es mon Seigneur, il n\'y a de divinité que Toi',
        },
        {
          'id': '2',
          'title': 'Avant de Dormir',
          'arabic': 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي وَبِكَ أَرْفَعُهُ',
          'translation': 'En Ton nom, mon Seigneur, je me couche',
        },
        {
          'id': '3',
          'title': 'En Entrant chez Soi',
          'arabic': 'بِسْمِ اللَّهِ وَلَجْنَا وَبِسْمِ اللَّهِ خَرَجْنَا',
          'translation': 'Au nom d\'Allah nous entrons',
        },
        {
          'id': '4',
          'title': 'Avant de Manger',
          'arabic': 'بِسْمِ اللَّهِ',
          'translation': 'Au nom d\'Allah',
        },
        {
          'id': '5',
          'title': 'Après avoir Mangé',
          'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
          'translation': 'Louange à Allah qui nous a nourris et abreuvés',
        },
        {
          'id': '6',
          'title': 'En Sortant de la Maison',
          'arabic': 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ لاَ حَوْلَ وَلاَ قُوَّةَ إِلاَّ بِاللَّهِ',
          'translation': 'Au nom d\'Allah, je place ma confiance en Allah',
        },
        {
          'id': '7',
          'title': 'En Entrant à la Mosquée',
          'arabic': 'أَعُوذُ بِاللَّهِ الْعَظِيمِ وَبِوَجْهِهِ الْكَرِيمِ',
          'translation': 'Je cherche refuge auprès d\'Allah le Très Grand',
        },
        {
          'id': '8',
          'title': 'En Sortant de la Mosquée',
          'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
          'translation': 'Ô Allah, je Te demande de Ta grâce',
        },
        {
          'id': '9',
          'title': 'Au Réveil',
          'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
          'translation': 'Louange à Allah qui nous a redonné vie après nous avoir fait mourir',
        },
        {
          'id': '10',
          'title': 'En s\'habillant',
          'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلاَ قُوَّةٍ',
          'translation': 'Louange à Allah qui m\'a vêtu de ceci',
        },
        {
          'id': '11',
          'title': 'En entrant aux Toilettes',
          'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
          'translation': 'Ô Allah, je cherche protection auprès de Toi',
        },
        {
          'id': '12',
          'title': 'En sortant des Toilettes',
          'arabic': 'غُفْرَانَكَ',
          'translation': 'Je sollicite Ton pardon',
        },
        {
          'id': '13',
          'title': 'Avant les Ablutions',
          'arabic': 'بِسْمِ اللَّهِ',
          'translation': 'Au nom d\'Allah',
        },
        {
          'id': '14',
          'title': 'Après les Ablutions',
          'arabic': 'أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ',
          'translation': 'J\'atteste qu\'il n\'y a de divinité qu\'Allah',
        },
        {
          'id': '15',
          'title': 'En montant en Voiture',
          'arabic': 'بِسْمِ اللَّهِ سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا',
          'translation': 'Au nom d\'Allah, gloire à Celui qui a mis ceci à notre service',
        },
        {
          'id': '16',
          'title': 'En voyant la Nouvelle Lune',
          'arabic': 'اللَّهُ أَكْبَرُ اللَّهُمَّ أَهِلَّهُ عَلَيْنَا بِالأَمْنِ وَالإِيمَانِ',
          'translation': 'Allah est le Plus Grand, Ô Allah fais-la nous apparaître',
        },
        {
          'id': '17',
          'title': 'Pour la Pluie',
          'arabic': 'اللَّهُمَّ صَيِّبًا نَافِعًا',
          'translation': 'Ô Allah, qu\'elle soit une pluie bénéfique',
        },
        {
          'id': '18',
          'title': 'Après la Pluie',
          'arabic': 'مُطِرْنَا بِفَضْلِ اللَّهِ وَرَحْمَتِهِ',
          'translation': 'Nous avons reçu la pluie par la grâce d\'Allah',
        },
        {
          'id': '19',
          'title': 'En entendant le Tonnerre',
          'arabic': 'سُبْحَانَ الَّذِي يُسَبِّحُ الرَّعْدُ بِحَمْدِهِ وَالْمَلاَئِكَةُ مِنْ خِيفَتِهِ',
          'translation': 'Gloire à Celui que le tonnerre glorifie par Sa louange',
        },
        {
          'id': '20',
          'title': 'Pour les Parents',
          'arabic': 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
          'translation': 'Seigneur, fais-leur miséricorde comme ils m\'ont élevé',
        },
        {
          'id': '21',
          'title': 'Pour demander Pardon',
          'arabic': 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
          'translation': 'Je demande pardon à Allah le Très Grand',
        },
        {
          'id': '22',
          'title': 'Pour la Protection',
          'arabic': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
          'translation': 'Je cherche protection par les paroles parfaites d\'Allah',
        },
        {
          'id': '23',
          'title': 'En cas de Tristesse',
          'arabic': 'اللَّهُمَّ إِنِّي عَبْدُكَ ابْنُ عَبْدِكَ ابْنُ أَمَتِكَ',
          'translation': 'Ô Allah, je suis Ton serviteur',
        },
        {
          'id': '24',
          'title': 'En cas d\'Anxiété',
          'arabic': 'اللَّهُمَّ رَحْمَتَكَ أَرْجُو فَلاَ تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
          'translation': 'Ô Allah, j\'espère Ta miséricorde',
        },
        {
          'id': '25',
          'title': 'Pour les Malades',
          'arabic': 'اللَّهُمَّ رَبَّ النَّاسِ أَذْهِبِ الْبَأْسَ اشْفِ أَنْتَ الشَّافِي',
          'translation': 'Ô Allah, Seigneur des gens, enlève le mal',
        },
        {
          'id': '26',
          'title': 'En visitant un Malade',
          'arabic': 'لاَ بَأْسَ طَهُورٌ إِنْ شَاءَ اللَّهُ',
          'translation': 'Pas de mal, c\'est une purification si Allah le veut',
        },
        {
          'id': '27',
          'title': 'Avant un Voyage',
          'arabic': 'اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَى',
          'translation': 'Ô Allah, nous Te demandons dans ce voyage la piété',
        },
        {
          'id': '28',
          'title': 'En entrant dans un Marché',
          'arabic': 'لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ',
          'translation': 'Il n\'y a de divinité qu\'Allah Seul',
        },
        {
          'id': '29',
          'title': 'Pour la Guidance',
          'arabic': 'اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ',
          'translation': 'Ô Allah, guide-moi parmi ceux que Tu as guidés',
        },
        {
          'id': '30',
          'title': 'Pour la Patience',
          'arabic': 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
          'translation': 'Ô Allah, aide-moi à T\'invoquer, Te remercier',
        },
        {
          'id': '31',
          'title': 'Pour la Facilité',
          'arabic': 'اللَّهُمَّ لاَ سَهْلَ إِلاَّ مَا جَعَلْتَهُ سَهْلاً',
          'translation': 'Ô Allah, rien n\'est facile sauf ce que Tu rends facile',
        },
        {
          'id': '32',
          'title': 'En cas de Dette',
          'arabic': 'اللَّهُمَّ اكْفِنِي بِحَلاَلِكَ عَنْ حَرَامِكَ',
          'translation': 'Ô Allah, suffit-moi par Ton licite',
        },
        {
          'id': '33',
          'title': 'Avant un Examen',
          'arabic': 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
          'translation': 'Seigneur, ouvre-moi ma poitrine et facilite-moi ma tâche',
        },
        {
          'id': '34',
          'title': 'Pour la Réussite',
          'arabic': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً',
          'translation': 'Seigneur, accorde-nous le bien ici-bas et dans l\'au-delà',
        },
        {
          'id': '35',
          'title': 'Contre le Mauvais Œil',
          'arabic': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ',
          'translation': 'Je cherche protection par les paroles parfaites d\'Allah',
        },
        {
          'id': '36',
          'title': 'En voyant quelque chose de Beau',
          'arabic': 'مَا شَاءَ اللَّهُ لاَ قُوَّةَ إِلاَّ بِاللَّهِ',
          'translation': 'Ce qu\'Allah veut ! Il n\'y a de force qu\'en Allah',
        },
        {
          'id': '37',
          'title': 'Dua de Yunus',
          'arabic': 'لاَ إِلَهَ إِلاَّ أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
          'translation': 'Il n\'y a de divinité que Toi, gloire à Toi',
        },
        {
          'id': '38',
          'title': 'Pour augmenter la Science',
          'arabic': 'رَبِّ زِدْنِي عِلْمًا',
          'translation': 'Seigneur, augmente ma science',
        },
        {
          'id': '39',
          'title': 'Avant de Dormir (courte)',
          'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
          'translation': 'En Ton nom, Ô Allah, je meurs et je vis',
        },
        {
          'id': '40',
          'title': 'Tasbih',
          'arabic': 'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَاللَّهُ أَكْبَرُ',
          'translation': 'Gloire à Allah, louange à Allah, Allah est le Plus Grand',
        },
      ];
      _filteredDuas = List.from(_allDuas);
      _isLoading = false;
    });
  }

  void _filterDuas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDuas = _allDuas.where((dua) {
        return dua['title'].toLowerCase().contains(query) ||
               dua['arabic'].contains(query) ||
               dua['translation'].toLowerCase().contains(query);
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
            child: _isLoading
                ? _buildLoadingIndicator()
                : _buildDuaList(isDark),
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
      decoration: const BoxDecoration(
        color: Color(0xFF1B4965),
      ),
      child: const Center(
        child: Text(
          'Duas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
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
          hintText: 'Rechercher...',
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

  Widget _buildDuaList(bool isDark) {
    if (_filteredDuas.isEmpty) {
      return Center(
        child: Text(
          'Aucune dua trouvée',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredDuas.length,
      itemBuilder: (context, index) {
        final dua = _filteredDuas[index];
        return _buildDuaItem(dua, isDark, index);
      },
    );
  }

  Widget _buildDuaItem(Map<String, dynamic> dua, bool isDark, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DuaDetailPage(
                  duaId: dua['id'] ?? '',
                  title: dua['title'],
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Numéro de la dua
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4965),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Titre et preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dua['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (dua['translation'] != null && dua['translation'].isNotEmpty)
                        Text(
                          dua['translation'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Texte arabe
                Flexible(
                  child: Text(
                    dua['arabic'],
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFD4A574) : const Color(0xFF1B4965),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}