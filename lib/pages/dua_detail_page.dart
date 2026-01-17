import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DuaDetailPage extends StatefulWidget {
  final String duaId;
  final String title;

  const DuaDetailPage({
    Key? key,
    required this.duaId,
    required this.title,
  }) : super(key: key);

  @override
  State<DuaDetailPage> createState() => _DuaDetailPageState();
}

class _DuaDetailPageState extends State<DuaDetailPage> {
  Map<String, dynamic>? duaData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDuaData();
  }

  void _loadDuaData() {
    // Données des duas avec texte arabe, translittération et traduction
    final Map<String, Map<String, dynamic>> duasData = {
      '1': {
        'title': 'Dua du Matin',
        'arabic': 'اللَّهُمَّ أَنْتَ رَبِّي لاَ إِلَهَ إِلاَّ أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لاَ يَغْفِرُ الذُّنُوبَ إِلاَّ أَنْتَ',
        'transliteration': 'Allahumma anta rabbî lâ ilâha illâ anta, khalaqtanî wa anâ ʿabduka, wa anâ ʿalâ ʿahdika wa waʿdika mâ istaṭaʿtu',
        'translation': 'Ô Allah, Tu es mon Seigneur, il n\'y a de divinité digne d\'adoration que Toi. Tu m\'as créé et je suis Ton serviteur.',
        'reference': 'Rapporté par Al-Bukhârî',
        'benefit': 'Celui qui la récite le jour avec conviction et meurt ce jour-là entrera au Paradis.',
      },
      '2': {
        'title': 'Avant de Dormir',
        'arabic': 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي وَبِكَ أَرْفَعُهُ فَإِن أَمْسَكْتَ نَفْسِي فارْحَمْهَا وَإِنْ أَرْسَلْتَهَا فاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ',
        'transliteration': 'Bismika rabbî wadaʿtu janbî wa bika arfaʿuhu',
        'translation': 'En Ton nom, mon Seigneur, je me couche et en Ton nom je me lève.',
        'reference': 'Rapporté par Al-Bukhârî et Muslim',
        'benefit': 'Protection divine pendant le sommeil.',
      },
      '3': {
        'title': 'En Entrant chez Soi',
        'arabic': 'بِسْمِ اللَّهِ وَلَجْنَا وَبِسْمِ اللَّهِ خَرَجْنَا وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا',
        'transliteration': 'Bismillâhi walajna, wa bismillâhi kharajna',
        'translation': 'Au nom d\'Allah nous entrons, au nom d\'Allah nous sortons.',
        'reference': 'Rapporté par Abou Daoud',
        'benefit': 'Éloigne le diable de la maison.',
      },
      '4': {
        'title': 'Avant de Manger',
        'arabic': 'بِسْمِ اللَّهِ',
        'transliteration': 'Bismillâh',
        'translation': 'Au nom d\'Allah.',
        'reference': 'Rapporté par Al-Bukhârî et Muslim',
        'benefit': 'Empêche le diable de partager notre nourriture.',
      },
      '5': {
        'title': 'Après avoir Mangé',
        'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
        'transliteration': 'Al-hamdu lillâhi-lladhî aṭʿamanâ wa saqânâ',
        'translation': 'Louange à Allah qui nous a nourris et abreuvés.',
        'reference': 'Rapporté par Abou Daoud',
        'benefit': 'Reconnaissance envers Allah pour Ses bienfaits.',
      },
      '6': {
        'title': 'En Sortant de la Maison',
        'arabic': 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلاَ حَوْلَ وَلاَ قُوَّةَ إِلاَّ بِاللَّهِ',
        'transliteration': 'Bismillâh, tawakkaltu ʿalâ Allâh',
        'translation': 'Au nom d\'Allah, je place ma confiance en Allah.',
        'reference': 'Rapporté par Abou Daoud',
        'benefit': 'Protection et guidance durant la journée.',
      },
      '7': {
        'title': 'En Entrant à la Mosquée',
        'arabic': 'أَعُوذُ بِاللَّهِ الْعَظِيمِ وَبِوَجْهِهِ الْكَرِيمِ وَسُلْطَانِهِ الْقَدِيمِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
        'transliteration': 'Aʿûdhu billâhi-l-ʿaẓîm',
        'translation': 'Je cherche refuge auprès d\'Allah le Très Grand.',
        'reference': 'Rapporté par Abou Daoud',
        'benefit': 'Protection contre le diable.',
      },
      '8': {
        'title': 'En Sortant de la Mosquée',
        'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
        'transliteration': 'Allâhumma innî as\'aluka min fadlik',
        'translation': 'Ô Allah, je Te demande de Ta grâce.',
        'reference': 'Rapporté par Muslim',
        'benefit': 'Demander la grâce d\'Allah.',
      },
      '9': {
        'title': 'Au Réveil',
        'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
        'transliteration': 'Al-hamdu lillâhi-lladhî ahyânâ',
        'translation': 'Louange à Allah qui nous a redonné vie.',
        'reference': 'Rapporté par Al-Bukhârî',
        'benefit': 'Gratitude pour un nouveau jour.',
      },
      '10': {
        'title': 'En s\'habillant',
        'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلاَ قُوَّةٍ',
        'transliteration': 'Al-hamdu lillâhi-lladhî kasânî',
        'translation': 'Louange à Allah qui m\'a vêtu de ceci.',
        'reference': 'Rapporté par At-Tirmidhî',
        'benefit': 'Reconnaissance pour les vêtements.',
      },
      '11': {
        'title': 'En entrant aux Toilettes',
        'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
        'transliteration': 'Allâhumma innî aʿûdhu bika',
        'translation': 'Ô Allah, je cherche protection auprès de Toi.',
        'reference': 'Rapporté par Al-Bukhârî',
        'benefit': 'Protection contre les démons.',
      },
      '12': {
        'title': 'En sortant des Toilettes',
        'arabic': 'غُفْرَانَكَ',
        'transliteration': 'Ghufrânak',
        'translation': 'Je sollicite Ton pardon.',
        'reference': 'Rapporté par At-Tirmidhî',
        'benefit': 'Demander le pardon d\'Allah.',
      },
      '13': {
        'title': 'Avant les Ablutions',
        'arabic': 'بِسْمِ اللَّهِ',
        'transliteration': 'Bismillâh',
        'translation': 'Au nom d\'Allah.',
        'reference': 'Sunnah établie',
        'benefit': 'Purification spirituelle et physique.',
      },
      '14': {
        'title': 'Après les Ablutions',
        'arabic': 'أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
        'transliteration': 'Ash-hadu an lâ ilâha illâ Allâh',
        'translation': 'J\'atteste qu\'il n\'y a de divinité qu\'Allah.',
        'reference': 'Rapporté par Muslim',
        'benefit': 'Les portes du Paradis s\'ouvrent.',
      },
      '15': {
        'title': 'En montant en Voiture',
        'arabic': 'بِسْمِ اللَّهِ سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنقَلِبُونَ',
        'transliteration': 'Bismillâh, subhâna-lladhî sakhkhara lanâ',
        'translation': 'Au nom d\'Allah, gloire à Celui qui a mis ceci à notre service.',
        'reference': 'Rapporté dans le Coran (43:13-14)',
        'benefit': 'Protection durant le voyage.',
      },
      '16': {
        'title': 'En voyant la Nouvelle Lune',
        'arabic': 'اللَّهُ أَكْبَرُ اللَّهُمَّ أَهِلَّهُ عَلَيْنَا بِالأَمْنِ وَالإِيمَانِ وَالسَّلاَمَةِ وَالإِسْلاَمِ',
        'transliteration': 'Allâhu akbar, Allâhumma ahillahu ʿalaynâ',
        'translation': 'Allah est le Plus Grand, Ô Allah fais-la nous apparaître.',
        'reference': 'Rapporté par At-Tirmidhî',
        'benefit': 'Bénédiction pour le nouveau mois.',
      },
      '17': {
        'title': 'Pour la Pluie',
        'arabic': 'اللَّهُمَّ صَيِّبًا نَافِعًا',
        'transliteration': 'Allâhumma ṣayyiban nâfiʿan',
        'translation': 'Ô Allah, qu\'elle soit une pluie bénéfique.',
        'reference': 'Rapporté par Al-Bukhârî',
        'benefit': 'Demander la baraka dans la pluie.',
      },
      '18': {
        'title': 'Après la Pluie',
        'arabic': 'مُطِرْنَا بِفَضْلِ اللَّهِ وَرَحْمَتِهِ',
        'transliteration': 'Muṭirnâ bifaḍli-llâh',
        'translation': 'Nous avons reçu la pluie par la grâce d\'Allah.',
        'reference': 'Rapporté par Al-Bukhârî',
        'benefit': 'Gratitude pour la pluie.',
      },
      '19': {
        'title': 'En entendant le Tonnerre',
        'arabic': 'سُبْحَانَ الَّذِي يُسَبِّحُ الرَّعْدُ بِحَمْدِهِ وَالْمَلاَئِكَةُ مِنْ خِيفَتِهِ',
        'transliteration': 'Subhâna-lladhî yusabbihu-r-raʿdu',
        'translation': 'Gloire à Celui que le tonnerre glorifie.',
        'reference': 'Rapporté par Al-Bukhârî',
        'benefit': 'Protection durant l\'orage.',
      },
      '20': {
        'title': 'Pour les Parents',
        'arabic': 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
        'transliteration': 'Rabbi-rhamhumâ kamâ rabbayânî',
        'translation': 'Seigneur, fais-leur miséricorde comme ils m\'ont élevé.',
        'reference': 'Coran (17:24)',
        'benefit': 'Piété filiale récompensée.',
      },
      '21': {
        'title': 'Pour demander Pardon',
        'arabic': 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
        'transliteration': 'Astaghfiru-llâha-l-ʿaẓîm',
        'translation': 'Je demande pardon à Allah le Très Grand.',
        'reference': 'Rapporté par At-Tirmidhî',
        'benefit': 'Pardon des péchés, même majeurs.',
      },
      '22': {
        'title': 'Pour la Protection',
        'arabic': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        'transliteration': 'Aʿûdhu bikalimâti-llâhi-t-tâmmât',
        'translation': 'Je cherche protection par les paroles parfaites d\'Allah.',
        'reference': 'Rapporté par Muslim',
        'benefit': 'Protection complète.',
      },
      '23': {
        'title': 'En cas de Tristesse',
        'arabic': 'اللَّهُمَّ إِنِّي عَبْدُكَ ابْنُ عَبْدِكَ ابْنُ أَمَتِكَ نَاصِيَتِي بِيَدِكَ',
        'transliteration': 'Allâhumma innî ʿabduk',
        'translation': 'Ô Allah, je suis Ton serviteur.',
        'reference': 'Rapporté par Ahmad',
        'benefit': 'Soulagement de la tristesse.',
      },
      '24': {
        'title': 'En cas d\'Anxiété',
        'arabic': 'اللَّهُمَّ رَحْمَتَكَ أَرْجُو فَلاَ تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
        'transliteration': 'Allâhumma rahmatak arjû',
        'translation': 'Ô Allah, j\'espère Ta miséricorde.',
        'reference': 'Rapporté par Abou Daoud',
        'benefit': 'Apaisement de l\'anxiété.',
      },
      '25': {
        'title': 'Pour les Malades',
        'arabic': 'اللَّهُمَّ رَبَّ النَّاسِ أَذْهِبِ الْبَأْسَ اشْفِ أَنْتَ الشَّافِي لاَ شِفَاءَ إِلاَّ شِفَاؤُكَ',
        'transliteration': 'Allâhumma rabba-n-nâs',
        'translation': 'Ô Allah, Seigneur des gens, enlève le mal.',
        'reference': 'Rapporté par Al-Bukhârî',
        'benefit': 'Guérison par la permission d\'Allah.',
      },
      '26': {
        'title': 'En visitant un Malade',
        'arabic': 'لاَ بَأْسَ طَهُورٌ إِنْ شَاءَ اللَّهُ',
        'transliteration': 'Lâ ba\'s ṭahûrun in shâ\'a-llâh',
        'translation': 'Pas de mal, c\'est une purification si Allah le veut.',
        'reference': 'Rapporté par Al-Bukhârî',
        'benefit': 'Réconfort pour le malade.',
      },
      '27': {
        'title': 'Avant un Voyage',
        'arabic': 'اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَى وَمِنَ الْعَمَلِ مَا تَرْضَى',
        'transliteration': 'Allâhumma innâ nas\'aluka fî safarinâ',
        'translation': 'Ô Allah, nous Te demandons dans ce voyage la piété.',
        'reference': 'Rapporté par Muslim',
        'benefit': 'Voyage béni et sécurisé.',
      },
      '28': {
        'title': 'En entrant dans un Marché',
        'arabic': 'لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ يُحْيِي وَيُمِيتُ وَهُوَ حَيٌّ لاَ يَمُوتُ بِيَدِهِ الْخَيْرُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        'transliteration': 'Lâ ilâha illâ-llâhu wahdahu',
        'translation': 'Il n\'y a de divinité qu\'Allah Seul.',
        'reference': 'Rapporté par At-Tirmidhî',
        'benefit': 'Récompense immense.',
      },
      '29': {
        'title': 'Pour la Guidance',
        'arabic': 'اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ',
        'transliteration': 'Allâhumma-hdinî fîman hadayt',
        'translation': 'Ô Allah, guide-moi parmi ceux que Tu as guidés.',
        'reference': 'Rapporté par At-Tirmidhî',
        'benefit': 'Guidance sur le droit chemin.',
      },
      '30': {
        'title': 'Pour la Patience',
        'arabic': 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
        'transliteration': 'Allâhumma aʿinnî ʿalâ dhikrik',
        'translation': 'Ô Allah, aide-moi à T\'invoquer.',
        'reference': 'Rapporté par Abou Daoud',
        'benefit': 'Force pour adorer Allah.',
      },
      '31': {
        'title': 'Pour la Facilité',
        'arabic': 'اللَّهُمَّ لاَ سَهْلَ إِلاَّ مَا جَعَلْتَهُ سَهْلاً وَأَنْتَ تَجْعَلُ الْحَزْنَ إِذَا شِئْتَ سَهْلاً',
        'transliteration': 'Allâhumma lâ sahla illâ mâ jaʿaltahu',
        'translation': 'Ô Allah, rien n\'est facile sauf ce que Tu rends facile.',
        'reference': 'Rapporté par Ibn Hibban',
        'benefit': 'Facilité dans les affaires.',
      },
      '32': {
        'title': 'En cas de Dette',
        'arabic': 'اللَّهُمَّ اكْفِنِي بِحَلاَلِكَ عَنْ حَرَامِكَ وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
        'transliteration': 'Allâhumma-kfinî bihalâlik',
        'translation': 'Ô Allah, suffit-moi par Ton licite.',
        'reference': 'Rapporté par At-Tirmidhî',
        'benefit': 'Libération des dettes.',
      },
      '33': {
        'title': 'Avant un Examen',
        'arabic': 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي يَفْقَهُوا قَوْلِي',
        'transliteration': 'Rabbi-shrah lî ṣadrî',
        'translation': 'Seigneur, ouvre-moi ma poitrine et facilite-moi ma tâche.',
        'reference': 'Coran (20:25-28)',
        'benefit': 'Succès et compréhension.',
      },
      '34': {
        'title': 'Pour la Réussite',
        'arabic': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
        'transliteration': 'Rabbanâ âtinâ fi-d-dunyâ hasanah',
        'translation': 'Seigneur, accorde-nous le bien ici-bas et dans l\'au-delà.',
        'reference': 'Coran (2:201)',
        'benefit': 'Bien dans les deux mondes.',
      },
      '35': {
        'title': 'Contre le Mauvais Œil',
        'arabic': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ وَمِنْ كُلِّ عَيْنٍ لاَمَّةٍ',
        'transliteration': 'Aʿûdhu bikalimâti-llâhi-t-tâmmah',
        'translation': 'Je cherche protection par les paroles parfaites d\'Allah.',
        'reference': 'Rapporté par Al-Bukhârî',
        'benefit': 'Protection contre le mauvais œil.',
      },
      '36': {
        'title': 'En voyant quelque chose de Beau',
        'arabic': 'مَا شَاءَ اللَّهُ لاَ قُوَّةَ إِلاَّ بِاللَّهِ إِنْ تَرَنِ أَنَا أَقَلَّ مِنْكَ مَالاً وَوَلَدًا',
        'transliteration': 'Mâ shâ\'a-llâh lâ quwwata illâ billâh',
        'translation': 'Ce qu\'Allah veut ! Il n\'y a de force qu\'en Allah.',
        'reference': 'Coran (18:39)',
        'benefit': 'Protection contre l\'envie.',
      },
      '37': {
        'title': 'Dua de Yunus',
        'arabic': 'لاَ إِلَهَ إِلاَّ أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
        'transliteration': 'Lâ ilâha illâ anta subhânak',
        'translation': 'Il n\'y a de divinité que Toi, gloire à Toi.',
        'reference': 'Coran (21:87)',
        'benefit': 'Soulagement des difficultés.',
      },
      '38': {
        'title': 'Pour augmenter la Science',
        'arabic': 'رَبِّ زِدْنِي عِلْمًا',
        'transliteration': 'Rabbi zidnî ʿilman',
        'translation': 'Seigneur, augmente ma science.',
        'reference': 'Coran (20:114)',
        'benefit': 'Augmentation du savoir.',
      },
      '39': {
        'title': 'Avant de Dormir (courte)',
        'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
        'transliteration': 'Bismika-llâhumma amûtu wa ahyâ',
        'translation': 'En Ton nom, Ô Allah, je meurs et je vis.',
        'reference': 'Rapporté par Al-Bukhârî',
        'benefit': 'Protection durant le sommeil.',
      },
      '40': {
        'title': 'Tasbih',
        'arabic': 'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلاَ إِلَهَ إِلاَّ اللَّهُ وَاللَّهُ أَكْبَرُ',
        'transliteration': 'Subhâna-llâh wa-l-hamdu lillâh',
        'translation': 'Gloire à Allah, louange à Allah, Allah est le Plus Grand.',
        'reference': 'Rapporté par Muslim',
        'benefit': 'Invocation aimée d\'Allah.',
      },
    };

    setState(() {
      duaData = duasData[widget.duaId];
      isLoading = false;
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copié'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF1B4965),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5DC),
      body: Column(
        children: [
          _buildHeader(context, isDark),
          Expanded(
            child: isLoading
                ? _buildLoadingIndicator()
                : duaData == null
                    ? _buildEmptyState()
                    : _buildDuaContent(isDark),
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
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
            'Dua non disponible',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuaContent(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Texte arabe
          _buildArabicCard(isDark),
          const SizedBox(height: 16),
          
          // Translittération
          if (duaData!['transliteration'] != null)
            _buildTransliterationCard(isDark),
          
          if (duaData!['transliteration'] != null)
            const SizedBox(height: 16),
          
          // Traduction
          _buildTranslationCard(isDark),
          const SizedBox(height: 16),
          
          // Référence
          if (duaData!['reference'] != null)
            _buildReferenceCard(isDark),
          
          if (duaData!['reference'] != null)
            const SizedBox(height: 16),
          
          // Mérite/Bénéfice
          if (duaData!['benefit'] != null)
            _buildBenefitCard(isDark),
        ],
      ),
    );
  }

  Widget _buildArabicCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          color: isDark 
              ? Colors.white.withOpacity(0.1) 
              : const Color(0xFF1B4965).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1B4965),
                      const Color(0xFF2C6E8F),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'العربية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.copy_outlined,
                  color: isDark ? Colors.white54 : Colors.grey,
                  size: 20,
                ),
                onPressed: () => _copyToClipboard(duaData!['arabic'], 'Texte arabe'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            duaData!['arabic'],
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1B4965),
              fontFamily: 'Amiri',
              fontSize: 28,
              height: 2.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransliterationCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.05) 
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.transcribe,
                size: 18,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Translittération',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.copy_outlined,
                  color: isDark ? Colors.white54 : Colors.grey,
                  size: 18,
                ),
                onPressed: () => _copyToClipboard(
                  duaData!['transliteration'], 
                  'Translittération'
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            duaData!['transliteration'],
            style: TextStyle(
              fontSize: 16,
              height: 1.8,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.translate,
                size: 18,
                color: const Color(0xFF1B4965),
              ),
              const SizedBox(width: 8),
              const Text(
                'Traduction',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4965),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.copy_outlined,
                  color: isDark ? Colors.white54 : Colors.grey,
                  size: 18,
                ),
                onPressed: () => _copyToClipboard(
                  duaData!['translation'], 
                  'Traduction'
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            duaData!['translation'],
            style: TextStyle(
              fontSize: 16,
              height: 1.8,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF2C6E8F).withOpacity(0.2) 
            : const Color(0xFF1B4965).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1B4965).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.book,
            size: 20,
            color: isDark ? Colors.white70 : const Color(0xFF1B4965),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              duaData!['reference'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : const Color(0xFF1B4965),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF2E7D32).withOpacity(0.3),
                  const Color(0xFF1B5E20).withOpacity(0.3),
                ]
              : [
                  const Color(0xFFE8F5E9),
                  const Color(0xFFC8E6C9),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2E7D32).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars_rounded,
                size: 20,
                color: isDark ? Colors.white70 : const Color(0xFF2E7D32),
              ),
              const SizedBox(width: 8),
              Text(
                'Mérite',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            duaData!['benefit'],
            style: TextStyle(
              fontSize: 15,
              height: 1.8,
              color: isDark ? Colors.white70 : const Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }
}