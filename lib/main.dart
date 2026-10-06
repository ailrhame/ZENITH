// lib/main.dart — ZENITH v4 Flutter single-file port
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ZenithApp());
}

// ═══════════════════════════════════════════════════════════════
// THEME SYSTEM
// ═══════════════════════════════════════════════════════════════
class ZenithTheme {
  final String id, name;
  final Color bg, surface, surface2, primary, primary2, accent, text, textDim, textMuted;
  final List<Color> userBubble;
  final Color userText, botBubble, botText, modalBg, inputBg, chatBg;
  final Color online, danger, success, warning, border;
  final bool isDark;

  const ZenithTheme({
    required this.id, required this.name, required this.bg,
    required this.surface, required this.surface2,
    required this.primary, required this.primary2, required this.accent,
    required this.text, required this.textDim, required this.textMuted,
    required this.userBubble, required this.userText,
    required this.botBubble, required this.botText,
    required this.modalBg, required this.inputBg, required this.chatBg,
    required this.online, required this.danger, required this.success,
    required this.warning, required this.border, required this.isDark,
  });
}

const kThemes = <String, ZenithTheme>{
  'night': ZenithTheme(
    id: 'night', name: 'ليلي',
    bg: Color(0xFF0B0B14), surface: Color(0xFF1A1A2E), surface2: Color(0xFF232338),
    primary: Color(0xFFB06BFF), primary2: Color(0xFFFF6BB0), accent: Color(0xFF6B9BFF),
    text: Color(0xFFE8E8F2), textDim: Color(0xFF8A8AA0), textMuted: Color(0xFF5A5A72),
    userBubble: [Color(0xFFFF6BB0), Color(0xFFB06BFF)], userText: Colors.white,
    botBubble: Color(0xFF232338), botText: Color(0xFFE8E8F2),
    modalBg: Color(0xFF1A1A2E), inputBg: Color(0xFF1A1A2E), chatBg: Color(0xFF0B0B14),
    online: Color(0xFF22E06B), danger: Color(0xFFFF4D6D),
    success: Color(0xFF22E06B), warning: Color(0xFFFFB84D),
    border: Color(0x0FFFFFFF), isDark: true,
  ),
  'day': ZenithTheme(
    id: 'day', name: 'نهاري',
    bg: Color(0xFFF2F4F8), surface: Colors.white, surface2: Color(0xFFEEF1F6),
    primary: Color(0xFF7A3EE8), primary2: Color(0xFFE83E94), accent: Color(0xFF3E7AE8),
    text: Color(0xFF1A1A2E), textDim: Color(0xFF5A5A72), textMuted: Color(0xFF8A8AA0),
    userBubble: [Color(0xFFE83E94), Color(0xFF7A3EE8)], userText: Colors.white,
    botBubble: Colors.white, botText: Color(0xFF1A1A2E),
    modalBg: Colors.white, inputBg: Color(0xFFF2F4F8), chatBg: Color(0xFFF2F4F8),
    online: Color(0xFF12B85A), danger: Color(0xFFE83E5C),
    success: Color(0xFF12B85A), warning: Color(0xFFE89B3E),
    border: Color(0x14000000), isDark: false,
  ),
  'midnight': ZenithTheme(
    id: 'midnight', name: 'منتصف الليل',
    bg: Color(0xFF05060D), surface: Color(0xFF0F1428), surface2: Color(0xFF161D36),
    primary: Color(0xFF4D7CFF), primary2: Color(0xFF6B5CFF), accent: Color(0xFF22D3EE),
    text: Color(0xFFD8E0FF), textDim: Color(0xFF7A86B8), textMuted: Color(0xFF4A5478),
    userBubble: [Color(0xFF4D7CFF), Color(0xFF22D3EE)], userText: Colors.white,
    botBubble: Color(0xFF161D36), botText: Color(0xFFD8E0FF),
    modalBg: Color(0xFF0F1428), inputBg: Color(0xFF0F1428), chatBg: Color(0xFF05060D),
    online: Color(0xFF22E0D3), danger: Color(0xFFFF4D6D),
    success: Color(0xFF22E0D3), warning: Color(0xFFFFB84D),
    border: Color(0x1F4D7CFF), isDark: true,
  ),
  'forest': ZenithTheme(
    id: 'forest', name: 'غابة',
    bg: Color(0xFF0D1410), surface: Color(0xFF16241C), surface2: Color(0xFF1E3126),
    primary: Color(0xFF3FB87A), primary2: Color(0xFF7BC74D), accent: Color(0xFFB8D94D),
    text: Color(0xFFDCEFE0), textDim: Color(0xFF7A9A82), textMuted: Color(0xFF4A6A52),
    userBubble: [Color(0xFF3FB87A), Color(0xFFB8D94D)], userText: Color(0xFF0D1410),
    botBubble: Color(0xFF1E3126), botText: Color(0xFFDCEFE0),
    modalBg: Color(0xFF16241C), inputBg: Color(0xFF16241C), chatBg: Color(0xFF0D1410),
    online: Color(0xFF7BC74D), danger: Color(0xFFE85D5D),
    success: Color(0xFF7BC74D), warning: Color(0xFFE8B84D),
    border: Color(0x1F3FB87A), isDark: true,
  ),
  'sunset': ZenithTheme(
    id: 'sunset', name: 'غروب',
    bg: Color(0xFF1A0F1E), surface: Color(0xFF2C1832), surface2: Color(0xFF3A2040),
    primary: Color(0xFFFF6B6B), primary2: Color(0xFFFFB84D), accent: Color(0xFFFF4D9B),
    text: Color(0xFFFFE8F0), textDim: Color(0xFFB88AA0), textMuted: Color(0xFF7A4A60),
    userBubble: [Color(0xFFFF4D9B), Color(0xFFFFB84D)], userText: Colors.white,
    botBubble: Color(0xFF3A2040), botText: Color(0xFFFFE8F0),
    modalBg: Color(0xFF2C1832), inputBg: Color(0xFF2C1832), chatBg: Color(0xFF1A0F1E),
    online: Color(0xFFFFB84D), danger: Color(0xFFFF4D6D),
    success: Color(0xFFFFB84D), warning: Color(0xFFFFB84D),
    border: Color(0x1FFF6B6B), isDark: true,
  ),
  'ocean': ZenithTheme(
    id: 'ocean', name: 'محيط',
    bg: Color(0xFF061620), surface: Color(0xFF0E2940), surface2: Color(0xFF153652),
    primary: Color(0xFF22D3EE), primary2: Color(0xFF4D7CFF), accent: Color(0xFF5EEAD4),
    text: Color(0xFFD4F0FF), textDim: Color(0xFF6FA3C4), textMuted: Color(0xFF3D6682),
    userBubble: [Color(0xFF22D3EE), Color(0xFF4D7CFF)], userText: Color(0xFF061620),
    botBubble: Color(0xFF153652), botText: Color(0xFFD4F0FF),
    modalBg: Color(0xFF0E2940), inputBg: Color(0xFF0E2940), chatBg: Color(0xFF061620),
    online: Color(0xFF5EEAD4), danger: Color(0xFFFF6B6B),
    success: Color(0xFF5EEAD4), warning: Color(0xFFFBBF24),
    border: Color(0x1F22D3EE), isDark: true,
  ),
  'mono': ZenithTheme(
    id: 'mono', name: 'أحادي',
    bg: Color(0xFF0A0A0A), surface: Color(0xFF1A1A1A), surface2: Color(0xFF262626),
    primary: Color(0xFFE5E5E5), primary2: Color(0xFFA3A3A3), accent: Color(0xFFD4D4D4),
    text: Color(0xFFF5F5F5), textDim: Color(0xFFA3A3A3), textMuted: Color(0xFF525252),
    userBubble: [Color(0xFF525252), Color(0xFF262626)], userText: Color(0xFFF5F5F5),
    botBubble: Color(0xFF1A1A1A), botText: Color(0xFFE5E5E5),
    modalBg: Color(0xFF1A1A1A), inputBg: Color(0xFF1A1A1A), chatBg: Color(0xFF0A0A0A),
    online: Color(0xFFE5E5E5), danger: Color(0xFFF87171),
    success: Color(0xFFE5E5E5), warning: Color(0xFFFBBF24),
    border: Color(0x14FFFFFF), isDark: true,
  ),
  'sakura': ZenithTheme(
    id: 'sakura', name: 'ساكورا',
    bg: Color(0xFFFFF5F8), surface: Colors.white, surface2: Color(0xFFFFE4EC),
    primary: Color(0xFFEC4899), primary2: Color(0xFFF472B6), accent: Color(0xFFFB7185),
    text: Color(0xFF4A1A2C), textDim: Color(0xFFA8758A), textMuted: Color(0xFFD4A8B8),
    userBubble: [Color(0xFFF472B6), Color(0xFFFB7185)], userText: Colors.white,
    botBubble: Colors.white, botText: Color(0xFF4A1A2C),
    modalBg: Colors.white, inputBg: Color(0xFFFFF5F8), chatBg: Color(0xFFFFF5F8),
    online: Color(0xFFF472B6), danger: Color(0xFFEF4444),
    success: Color(0xFFEC4899), warning: Color(0xFFF59E0B),
    border: Color(0x1FEC4899), isDark: false,
  ),
  'cyberpunk': ZenithTheme(
    id: 'cyberpunk', name: 'سايبربانك',
    bg: Color(0xFF0D0221), surface: Color(0xFF1F0335), surface2: Color(0xFF2A054A),
    primary: Color(0xFFFF00AA), primary2: Color(0xFF00FFF7), accent: Color(0xFFFAFF00),
    text: Color(0xFFFFE8FF), textDim: Color(0xFFB866D4), textMuted: Color(0xFF6D1A8A),
    userBubble: [Color(0xFFFF00AA), Color(0xFF00FFF7)], userText: Color(0xFF0D0221),
    botBubble: Color(0xFF2A054A), botText: Color(0xFFFFE8FF),
    modalBg: Color(0xFF1F0335), inputBg: Color(0xFF1F0335), chatBg: Color(0xFF0D0221),
    online: Color(0xFF00FFF7), danger: Color(0xFFFF004D),
    success: Color(0xFF00FFF7), warning: Color(0xFFFAFF00),
    border: Color(0x2EFF00AA), isDark: true,
  ),
  'coffee': ZenithTheme(
    id: 'coffee', name: 'قهوة',
    bg: Color(0xFF1A120B), surface: Color(0xFF2D1F15), surface2: Color(0xFF3D2A1C),
    primary: Color(0xFFD4A574), primary2: Color(0xFFB8763F), accent: Color(0xFFE6C090),
    text: Color(0xFFF5E6D3), textDim: Color(0xFFA89078), textMuted: Color(0xFF6B5844),
    userBubble: [Color(0xFFB8763F), Color(0xFFD4A574)], userText: Color(0xFF1A120B),
    botBubble: Color(0xFF3D2A1C), botText: Color(0xFFF5E6D3),
    modalBg: Color(0xFF2D1F15), inputBg: Color(0xFF2D1F15), chatBg: Color(0xFF1A120B),
    online: Color(0xFFD4A574), danger: Color(0xFFE85D5D),
    success: Color(0xFFD4A574), warning: Color(0xFFE6C090),
    border: Color(0x24D4A574), isDark: true,
  ),
};

const kAccents = <String, Color?>{
  'default': null,
  'purple': Color(0xFFB06BFF),
  'pink': Color(0xFFFF6BB0),
  'blue': Color(0xFF4D7CFF),
  'cyan': Color(0xFF22D3EE),
  'green': Color(0xFF22E06B),
  'lime': Color(0xFFB8D94D),
  'yellow': Color(0xFFFFB84D),
  'orange': Color(0xFFFF8C42),
  'red': Color(0xFFFF4D6D),
  'magenta': Color(0xFFFF00AA),
  'white': Color(0xFFE8E8F2),
};

// ═══════════════════════════════════════════════════════════════
// CHARACTERS — 50 deterministic
// ═══════════════════════════════════════════════════════════════
class CharacterColors {
  final int id;
  final Color skin, hair, hair2, eye, dress, accessory;
  final int style;
  const CharacterColors(this.id, this.skin, this.hair, this.hair2, this.eye,
      this.dress, this.accessory, this.style);
}

class Characters {
  static const _skin = [Color(0xFFFFE4EC), Color(0xFFFCD5CE), Color(0xFFF3C4B3),
    Color(0xFFE6B999), Color(0xFFD4A373), Color(0xFFFFD1DC), Color(0xFFFFB3B3)];
  static const _hair = [Color(0xFF8B3A5F), Color(0xFF333333), Color(0xFF6B4423),
    Color(0xFFE6B800), Color(0xFFFF4D4D), Color(0xFF4D79FF), Color(0xFFD96B8C),
    Color(0xFFCC99FF), Color(0xFF99CCFF), Color(0xFFFFB3B3), Color(0xFF1A1A1A),
    Color(0xFFB76E92)];
  static const _eye = [Color(0xFF4FACFE), Color(0xFF00F2FE), Color(0xFF8B5A2B),
    Color(0xFF2ECC71), Color(0xFFFFA751), Color(0xFF9B59B6), Color(0xFFFF6B6B),
    Color(0xFF3498DB)];
  static const _dress = [Color(0xFFFF8FAB), Color(0xFFF7CAE0), Color(0xFFFFC3A0),
    Color(0xFF9B59B6), Color(0xFF3498DB), Color(0xFFE74C3C), Color(0xFF2ECC71),
    Color(0xFFF1C40F), Color(0xFF95A5A6), Color(0xFFFFA502), Color(0xFFA29BFE),
    Color(0xFF55EFC4)];
  static const _acc = [Color(0xFFFF8FAB), Color(0xFFFF6B6B), Color(0xFF4FACFE),
    Color(0xFFF1C40F), Color(0xFFFD79A8), Color(0xFF00CEC9), Color(0xFF6C5CE7),
    Color(0xFFFDCB6E)];

  static int _seed(int n) {
    var s = n * 7919 + 13;
    return s & 0xFFFFFFFF;
  }
  static double _rand(int s) {
    s = (s * 1664525 + 1013904223) & 0xFFFFFFFF;
    return s / 0x100000000;
  }

  static final List<CharacterColors> all = () {
    final list = <CharacterColors>[
      const CharacterColors(0, Color(0xFFFFE4EC), Color(0xFF8B3A5F), Color(0xFFD96B8C),
          Color(0xFF4FACFE), Color(0xFFA29BFE), Color(0xFFFF8FAB), 0),
    ];
    for (var i = 1; i < 50; i++) {
      var s = _seed(i);
      T pick<T>(List<T> arr) {
        s = (s * 1664525 + 1013904223) & 0xFFFFFFFF;
        return arr[(s / 0x100000000 * arr.length).floor().clamp(0, arr.length - 1)];
      }
      list.add(CharacterColors(
        i, pick(_skin), pick(_hair), pick(_hair), pick(_eye),
        pick(_dress), pick(_acc), i % 6,
      ));
    }
    return list;
  }();
}

// ═══════════════════════════════════════════════════════════════
// KNOWLEDGE ENGINE
// ═══════════════════════════════════════════════════════════════
class QAItem {
  String question, answer;
  List<String>? _kw;
  QAItem(this.question, this.answer);
  Map<String, dynamic> toJson() => {'question': question, 'answer': answer};
  List<String> get keywords => _kw ??= KnowledgeEngine._extract(question);
}

class KnowledgeEngine {
  final List<QAItem> _items = [];
  int get length => _items.length;
  List<QAItem> get items => _items;
  QAItem random() => _items[Random().nextInt(_items.length)];

  void seedDefaults(String name) {
    _items.addAll([
      QAItem('من أنت', 'أنا $name، أتحدث معك وأتعلم من ملفاتك.'),
      QAItem('كم عمرك', 'عمري ليس مهماً، المهم أنني هنا لمساعدتك.'),
      QAItem('كيف الحال', 'بخير، شكراً لسؤالك! كيف حالك أنت اليوم؟'),
    ]);
  }

  void loadFromJson(List list) {
    _items.clear();
    for (final e in list) {
      final m = Map<String, dynamic>.from(e as Map);
      _items.add(QAItem(m['question'] ?? '', m['answer'] ?? ''));
    }
  }

  List<Map<String, dynamic>> toJson() => _items.map((i) => i.toJson()).toList();
  void addQA(String q, String a) {
    final i = _items.indexWhere((x) => x.question == q);
    if (i >= 0) { _items[i].answer = a; } else { _items.add(QAItem(q, a)); }
  }
  void clear() => _items.clear();

  void parseAndAdd(String content) {
    final re = RegExp(r'سؤال:\s*([\s\S]*?)\s*جواب:\s*([\s\S]*?)(?=سؤال:|$)');
    for (final m in re.allMatches(content)) {
      final q = m.group(1)!.trim();
      final a = m.group(2)!.trim();
      if (q.isNotEmpty && a.isNotEmpty) addQA(q, a);
    }
  }

  static const Set<String> _stop = {
    'هل','ما','هو','هي','ال','من','في','على','إلى','و','ف','ك','ل',
    'وش','شو','هذا','ذلك','كان','يكون','انتم','انها','ايش','حب',
    'عندك','عندي','ليش','بس','كل','نفس','أي','بدي','ابي','كيف',
    'قد','لي','له','لها','عنه','عنها','علي','عليها','ثم','او','أو'
  };

  static List<String> _extract(String text) {
    final norm = _norm(text);
    return norm.split(RegExp(r'[\s،؟!.\-,]+'))
        .where((w) => w.length >= 2 && !_stop.contains(w)).toList();
  }

  static String _norm(String s) => s
      .replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا')
      .replaceAll('ة', 'ه').replaceAll('ى', 'ي').toLowerCase();

  static int _lev(String a, String b) {
    final m = a.length, n = b.length;
    if (m == 0) return n;
    if (n == 0) return m;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
    for (var i = 0; i <= m; i++) dp[i][0] = i;
    for (var j = 0; j <= n; j++) dp[0][j] = j;
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        final c = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + c]
            .reduce((x, y) => x < y ? x : y);
      }
    }
    return dp[m][n];
  }

  static bool _sim(String a, String b) {
    if (a == b) return true;
    final la = a.length, lb = b.length;
    final mx = la > lb ? la : lb;
    if (mx < 4) return false;
    final allow = mx <= 6 ? 1 : (mx <= 10 ? 2 : 3);
    if ((la - lb).abs() > allow) return false;
    if (a[0] != b[0]) return false;
    return _lev(a, b) <= allow;
  }

  Map<String, dynamic> findAnswer(String question) {
    if (_items.isEmpty) return {'text': 'عذراً، لا توجد بيانات في الذاكرة.'};
    final uk = _extract(question);
    if (uk.isEmpty) return {'text': 'اسأل سؤالاً واضحاً 😊'};

    final scored = <MapEntry<QAItem, double>>[];
    for (final item in _items) {
      final sk = item.keywords;
      var hit = 0;
      for (final u in uk) if (sk.any((s) => _sim(u, s))) hit++;
      scored.add(MapEntry(item, hit / uk.length));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    final best = scored.first;

    if (best.value >= 0.6) {
      final related = _items
          .where((i) => i.question != best.key.question)
          .where((i) => i.keywords.any((k) => uk.any((u) => _sim(u, k))))
          .take(2).map((i) => i.question).toList();
      final alternates = scored.skip(1)
          .where((e) => e.value >= 0.35 && e.value < 0.6)
          .take(2)
          .map((e) => {'q': e.key.question, 'a': e.key.answer}).toList();
      return {
        'text': best.key.answer,
        'matchedQuestion': best.key.question,
        'suggestions': related.isEmpty ? null : related,
        'alternates': alternates.isEmpty ? null : alternates,
      };
    }

    final top = scored.where((e) => e.value >= 0.25 && e.value < 0.6).take(3).toList();
    if (top.isNotEmpty) {
      return {
        'text': 'ما فهمت سؤالك بالضبط 🤔 تقصد أحد هذي الأسئلة؟',
        'suggestions': top.map((e) => e.key.question).toList(),
      };
    }
    return {'text': null};
  }

  String? handleSelfIdentity(String q, String name, int age) {
    final n = _norm(q).trim();
    if (n.contains('وش اسمك') || n.contains('ما اسمك') || n.contains('شو اسمك') ||
        n.contains('ايش اسمك') || n == 'اسمك' ||
        n.contains('من انتي') || n.contains('من انت') ||
        n.contains('مين انتي') || n.contains('مين انت')) {
      return 'اسمي $name! 😊';
    }
    if (n.contains('كم عمرك') || n.contains('وش عمرك') ||
        n.contains('ايش عمرك') || n.contains('عمرك كم') || n == 'عمرك') {
      return 'عمري $age سنة يا فضولي! 😄';
    }
    return null;
  }

  String? handleSmallTalk(String q) {
    final n = _norm(q).replaceAll(RegExp(r'[!؟?.,،]+$'), '').trim();
    const g = ['السلام عليكم','سلام عليكم','هاي','هلا','مرحبا','اهلا','صباح الخير','مساء الخير'];
    if (g.any((x) => n == x || n.startsWith(x))) {
      return 'وعليكم السلام ورحمة الله وبركاته! 😊';
    }
    const f = ['مع السلامه','باي','وداعا','تصبح على خير'];
    if (f.any((x) => n == x || n.startsWith(x))) return 'مع السلامة! 🌙';
    const t = ['شكرا','شكرا لك','يعطيك العافيه','thank you'];
    if (t.any((x) => n == x || n.startsWith(x))) return 'العفو! 💖';
    return null;
  }

  String? handleMemoryCommands(String q, Map<String, String> mem) {
    final n = _norm(q);
    if (n.contains('ماذا تعرف عني') || n.contains('معلوماتك عني')) {
      if (mem.isEmpty) return 'لا أعرف شيئاً عنك بعد. أخبرني عن نفسك!';
      final sb = StringBuffer('إليك ما أعرفه عنك: 📝\n');
      mem.forEach((k, v) => sb.writeln('• $k: $v'));
      return sb.toString();
    }
    if (n.contains('امسح معلوماتي') || n.contains('احذف معلوماتي')) {
      mem.clear();
      return 'تم مسح جميع معلوماتك الشخصية. 🗑️';
    }
    return null;
  }

  String? handleUserMemory(String q, Map<String, String> mem) {
    final n = _norm(q);
    if (n.contains('احب اللون') || n.contains('لوني المفضل')) {
      final m = RegExp(r'اللون\s+(\S+)').firstMatch(q);
      if (m != null) {
        mem['favorite_color'] = m.group(1)!;
        return 'جميل! سأحفظ أن لونك المفضل هو ${m.group(1)}. 🎨';
      }
    }
    if (n.contains('اسمي') || n.contains('اتصل بي')) {
      final c = q.replaceAll(RegExp(r'اسمي|انا اسمي|اتصل بي'), '').trim();
      if (c.isNotEmpty) {
        mem['user_name'] = c;
        return 'تشرفت بمعرفتك يا $c! 😊';
      }
    }
    if (n.contains('انا من') || n.contains('اسكن في')) {
      final c = q.replaceAll(RegExp(r'انا من|اسكن في|اعيش في'), '').trim();
      if (c.isNotEmpty) {
        mem['city'] = c;
        return 'رائع! سأتذكر أنك من $c. 🌍';
      }
    }
    return null;
  }
}

// ═══════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════
class ChatMessage {
  final String id, sender, text;
  final String? question;
  final int timestamp;
  final List<String>? suggestions;
  final List<Map<String, String>>? alternates;
  final bool needsTeaching;
  ChatMessage({
    required this.id, required this.sender, required this.text,
    this.question, required this.timestamp, this.suggestions,
    this.alternates, this.needsTeaching = false,
  });
  Map<String, dynamic> toJson() => {
    'id': id, 'sender': sender, 'text': text, 'question': question,
    'timestamp': timestamp, 'suggestions': suggestions,
    'alternates': alternates, 'needsTeaching': needsTeaching,
  };
  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
    id: j['id'] ?? '', sender: j['sender'] ?? 'bot', text: j['text'] ?? '',
    question: j['question'], timestamp: j['timestamp'] ?? 0,
    suggestions: (j['suggestions'] as List?)?.cast<String>(),
    alternates: (j['alternates'] as List?)?.map((e) => Map<String, String>.from(e)).toList(),
    needsTeaching: j['needsTeaching'] ?? false,
  );
}

class PinnedMessage {
  final String id, sender, text;
  PinnedMessage({required this.id, required this.sender, required this.text});
}

// ═══════════════════════════════════════════════════════════════
// APP STATE
// ═══════════════════════════════════════════════════════════════
class AppState extends ChangeNotifier {
  bool bootstrapped = false;
  bool onboarded = false;

  String themeId = 'night';
  String accentId = 'default';
  String weather = '';

  int charId = 0;
  String charName = 'زوجه علاوي';
  int botAge = 18;
  String mood = 'neutral';
  bool nrsActive = false;
  int nrsShapeIndex = 0;

  int coins = 0, userXP = 0, userLevel = 1;
  bool unlimited = false;

  int statLikes = 0, statDislikes = 0, statQuestions = 0;
  Map<String, int> questionFreq = {};
  List<Map<String, dynamic>> unanswered = [];

  final List<ChatMessage> messages = [];
  final List<PinnedMessage> pinned = [];
  final Map<String, String> userMemory = {};
  Map<String, dynamic>? pendingCorrection;
  Map<String, dynamic>? gameState;
  Timer? challengeTimer;

  final KnowledgeEngine engine = KnowledgeEngine();
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool recording = false;

  ZenithTheme get theme => kThemes[themeId] ?? kThemes['night']!;
  Color get primaryColor => kAccents[accentId] ?? theme.primary;
  CharacterColors get character => Characters.all[charId];

  double get bubbleRadius => const {
    'round': 30.0, 'normal': 20.0, 'soft': 12.0, 'square': 6.0,
  }[themeId == 'never' ? 'normal' : 'normal'] ?? 20.0;

  Future<void> bootstrap() async {
    final p = await SharedPreferences.getInstance();
    onboarded = p.getBool('zenith_onboarded') ?? false;
    themeId = p.getString('zenith_theme') ?? 'night';
    accentId = p.getString('zenith_accent') ?? 'default';
    weather = p.getString('zenith_weather') ?? '';
    charId = p.getInt('selectedCharacterId') ?? 0;
    charName = p.getString('robotName') ?? 'زوجه علاوي';
    botAge = p.getInt('robotAge') ?? 18;
    mood = p.getString('robotMood') ?? 'neutral';
    nrsActive = p.getBool('nrsActive') ?? false;
    nrsShapeIndex = p.getInt('nrsShapeIndex') ?? 0;
    coins = p.getInt('robotCoins') ?? 0;
    userXP = p.getInt('robotXP') ?? 0;
    userLevel = p.getInt('robotLevel') ?? 1;

    final st = p.getString('robotStats');
    if (st != null) {
      final m = jsonDecode(st);
      statLikes = m['totalLikes'] ?? 0;
      statDislikes = m['totalDislikes'] ?? 0;
      statQuestions = m['totalQuestions'] ?? 0;
    }
    final fq = p.getString('robotQuestionFreq');
    if (fq != null) questionFreq = Map<String, int>.from(jsonDecode(fq));
    final ua = p.getString('robotUnanswered');
    if (ua != null) unanswered.addAll((jsonDecode(ua) as List).cast<Map<String, dynamic>>());
    final um = p.getString('zenith_user_memory');
    if (um != null) userMemory.addAll(Map<String, String>.from(jsonDecode(um)));

    final kb = p.getString('robotKnowledgeBase');
    if (kb != null) {
      engine.loadFromJson(jsonDecode(kb) as List);
    } else {
      engine.seedDefaults(charName);
    }

    final snap = p.getString('zenith_v4_state');
    if (snap != null) {
      try {
        final d = jsonDecode(snap) as Map<String, dynamic>;
        for (final m in (d['messages'] as List? ?? [])) {
          messages.add(ChatMessage.fromJson(m as Map<String, dynamic>));
        }
        for (final pi in (d['pinned'] as List? ?? [])) {
          pinned.add(PinnedMessage(
            id: UniqueKey().toString(),
            sender: pi['sender'], text: pi['text'],
          ));
        }
      } catch (_) {}
    }

    try {
      await _tts.setLanguage('ar-SA');
      await _tts.setSpeechRate(1.0);
    } catch (_) {}

    bootstrapped = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    onboarded = true;
    final p = await SharedPreferences.getInstance();
    await p.setBool('zenith_onboarded', true);
    notifyListeners();
  }

  Future<void> saveAll() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('zenith_theme', themeId);
    await p.setString('zenith_accent', accentId);
    await p.setString('zenith_weather', weather);
    await p.setInt('selectedCharacterId', charId);
    await p.setString('robotName', charName);
    await p.setInt('robotAge', botAge);
    await p.setString('robotMood', mood);
    await p.setBool('nrsActive', nrsActive);
    await p.setInt('nrsShapeIndex', nrsShapeIndex);
    await p.setInt('robotCoins', coins);
    await p.setInt('robotXP', userXP);
    await p.setInt('robotLevel', userLevel);
    await p.setString('robotStats', jsonEncode({
      'totalLikes': statLikes, 'totalDislikes': statDislikes,
      'totalQuestions': statQuestions,
    }));
    await p.setString('robotQuestionFreq', jsonEncode(questionFreq));
    await p.setString('robotUnanswered', jsonEncode(unanswered));
    await p.setString('zenith_user_memory', jsonEncode(userMemory));
    await p.setString('robotKnowledgeBase', jsonEncode(engine.toJson()));
    await p.setString('zenith_v4_state', jsonEncode({
      'messages': messages.map((m) => m.toJson()).toList(),
      'pinned': pinned.map((p) => {'sender': p.sender, 'text': p.text}).toList(),
    }));
  }

  void setTheme(String id) { themeId = id; notifyListeners(); saveAll(); }
  void setAccent(String id) { accentId = id; notifyListeners(); saveAll(); }
  void setWeather(String w) { weather = w; notifyListeners(); saveAll(); }
  void setCharId(int id) { charId = id; notifyListeners(); saveAll(); }
  void setCharName(String n) { charName = n; notifyListeners(); saveAll(); }
  void setBotAge(int a) { botAge = a; notifyListeners(); saveAll(); }
  void toggleNrs() { nrsActive = !nrsActive; notifyListeners(); saveAll(); }
  void setNrsShape(int i) { nrsShapeIndex = i; nrsActive = true; notifyListeners(); saveAll(); }

  void addCoins(int n) {
    if (unlimited) return;
    coins += n; notifyListeners(); saveAll();
  }
  void setUnlimited() { unlimited = true; notifyListeners(); }
  void addXP(int n) {
    userXP += n;
    final nl = (userXP ~/ 1000) + 1;
    if (nl > userLevel) {
      userLevel = nl;
      addMessage(ChatMessage(
        id: UniqueKey().toString(), sender: 'bot',
        text: '🎉 مبروك! وصلت إلى المستوى $userLevel!',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    notifyListeners(); saveAll();
  }

  void addMessage(ChatMessage m) {
    messages.add(m);
    notifyListeners();
    saveAll();
  }

  void clearChat() {
    messages.clear();
    pinned.clear();
    notifyListeners();
    saveAll();
  }

  void deleteMessages(Set<String> ids) {
    messages.removeWhere((m) => ids.contains(m.id));
    notifyListeners();
    saveAll();
  }

  void togglePin(ChatMessage m) {
    final idx = pinned.indexWhere((p) => p.text == m.text && p.sender == m.sender);
    if (idx >= 0) { pinned.removeAt(idx); }
    else { pinned.add(PinnedMessage(id: m.id, sender: m.sender, text: m.text)); }
    notifyListeners(); saveAll();
  }

  ChatMessage? replyTo(String question) {
    final self = engine.handleSelfIdentity(question, charName, botAge);
    if (self != null) return _bot(self, question);

    final s = engine.handleSmallTalk(question);
    if (s != null) return _bot(s, question);

    final m = engine.handleMemoryCommands(question, userMemory);
    if (m != null) return _bot(m, question);

    final ms = engine.handleUserMemory(question, userMemory);
    if (ms != null) return _bot(ms, question);

    final result = engine.findAnswer(question);
    if (result['text'] != null) {
      final q = result['matchedQuestion'] as String?;
      if (q != null) questionFreq[q] = (questionFreq[q] ?? 0) + 1;
      statQuestions++;
      return ChatMessage(
        id: UniqueKey().toString(), sender: 'bot',
        text: result['text'] as String, question: q,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        suggestions: (result['suggestions'] as List?)?.cast<String>(),
        alternates: (result['alternates'] as List?)
            ?.map((e) => Map<String, String>.from(e as Map)).toList(),
        needsTeaching: result['needsTeaching'] == true,
      );
    }

    unanswered.add({'question': question, 'time': DateTime.now().millisecondsSinceEpoch});
    pendingCorrection = {'question': question};
    return ChatMessage(
      id: UniqueKey().toString(), sender: 'bot',
      text: 'آسف، ما عندي جواب لهذا السؤال 🤔 علّمني الجواب الصحيح (أو اكتب "تجاهل").',
      question: question, needsTeaching: true,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  ChatMessage _bot(String text, String? q) => ChatMessage(
    id: UniqueKey().toString(), sender: 'bot', text: text,
    question: q, timestamp: DateTime.now().millisecondsSinceEpoch,
  );

  void teach(String answer) {
    final q = pendingCorrection?['question'] as String?;
    if (q == null) return;
    engine.addQA(q, answer);
    addXP(15);
    pendingCorrection = null;
    saveAll();
  }

  void skipTeach() { pendingCorrection = null; }

  Future<void> speak(String text) async {
    try { await _tts.stop(); await _tts.speak(text); } catch (_) {}
  }

  Future<void> toggleMic(Function(String) onText) async {
    if (recording) {
      await _stt.stop();
      recording = false;
      notifyListeners();
      return;
    }
    final ok = await _stt.initialize();
    if (!ok) return;
    recording = true;
    notifyListeners();
    await _stt.listen(
      localeId: 'ar-SA',
      onResult: (r) => onText(r.recognizedWords),
      listenFor: const Duration(seconds: 30),
    );
  }

  void startQuiz() {
    if (engine.length < 5) return;
    final it = engine.random();
    gameState = {'type': 'quiz', 'answer': it.answer};
    addMessage(_bot('🎮 لعبة الأسئلة! أجب:\n\n"${it.question}"', null));
    addCoins(2);
  }

  void startSpeed() {
    if (engine.length < 5) return;
    final it = engine.random();
    gameState = {'type': 'challenge', 'answer': it.answer};
    addMessage(_bot('⚡ تحدي السرعة! 10 ثواني:\n\n"${it.question}"', null));
    challengeTimer?.cancel();
    challengeTimer = Timer(const Duration(seconds: 10), () {
      if (gameState?['type'] == 'challenge') {
        addMessage(_bot('⏰ انتهى الوقت! الإجابة: ${gameState!['answer']}', null));
        gameState = null;
      }
    });
  }

  Future<void> exportBackup() async {
    final data = {
      'version': 4,
      'exportedAt': DateTime.now().toIso8601String(),
      'knowledgeBase': engine.toJson(),
      'coins': coins, 'xp': userXP, 'level': userLevel,
      'charId': charId, 'charName': charName, 'botAge': botAge,
      'theme': themeId, 'accent': accentId, 'weather': weather,
      'questionFreq': questionFreq, 'unanswered': unanswered,
      'userMemory': userMemory,
      'messages': messages.map((m) => m.toJson()).toList(),
      'pinned': pinned.map((p) => {'sender': p.sender, 'text': p.text}).toList(),
    };
    final tmp = await getTemporaryDirectoryWrapper();
    final file = File('${tmp.path}/zenith_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    await Share.shareXFiles([XFile(file.path)], subject: 'ZENITH v4 backup');
  }

  Future<String> getTemporaryDirectoryWrapper() async {
    // ignore: avoid_slow_async_io
    final dir = await _tempDir();
    return dir.path;
  }
  Future<dynamic> _tempDir() async {
    // path_provider not imported to keep file self-contained; use a simple fallback
    return Directory.systemTemp;
  }
}

// ═══════════════════════════════════════════════════════════════
// SVG RENDERER (character)
// ═══════════════════════════════════════════════════════════════
String _hex(Color c) =>
    '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}';

String buildCharacterSvg(CharacterColors c) {
  final skin = _hex(c.skin);
  final hair = _hex(c.hair);
  final hair2 = _hex(c.hair2);
  final eye = _hex(c.eye);
  final dress = _hex(c.dress);
  final acc = _hex(c.accessory);

  String backHair, frontHair;
  switch (c.style) {
    case 1:
      backHair = '''
        <path d="M55 80 C42 105 40 130 48 150 C58 145 64 128 66 108 Z" fill="$hair"/>
        <path d="M145 80 C158 105 160 130 152 150 C142 145 136 128 134 108 Z" fill="$hair"/>''';
      frontHair = '''
        <path d="M60 78 C64 46 82 32 100 32 C118 32 136 46 140 78 C133 60 118 48 100 47 C82 48 67 60 60 78 Z" fill="$hair"/>
        <path d="M63 68 L137 68 L134 79 L66 79 Z" fill="$hair"/>''';
      break;
    case 2:
      backHair = '''
        <path d="M58 82 C50 100 50 118 56 132 C64 126 68 108 68 92 Z" fill="$hair"/>
        <path d="M142 82 C150 100 150 118 144 132 C136 126 132 108 132 92 Z" fill="$hair"/>
        <path d="M136 58 C160 70 170 112 154 162 C147 150 141 118 139 88 Z" fill="$hair"/>
        <ellipse cx="137" cy="60" rx="6" ry="4" fill="$acc"/>''';
      frontHair = '''
        <path d="M62 76 C66 47 82 34 100 34 C118 34 132 47 137 74 C130 58 116 47 100 46 C85 47 69 58 62 76 Z" fill="$hair"/>''';
      break;
    case 3:
      backHair = '''
        <path d="M56 82 C44 104 42 126 50 144 C60 138 65 120 66 104 Z" fill="$hair"/>
        <path d="M144 82 C156 104 158 126 150 144 C140 138 135 120 134 104 Z" fill="$hair"/>
        <path d="M55 88 C28 92 18 116 28 142 C40 132 49 112 58 96 Z" fill="$hair"/>
        <path d="M145 88 C172 92 182 116 172 142 C160 132 151 112 142 96 Z" fill="$hair"/>''';
      frontHair = '''
        <path d="M62 76 C66 47 82 34 100 34 C118 34 134 47 138 76 C132 58 116 47 100 46 C84 47 68 58 62 76 Z" fill="$hair"/>''';
      break;
    case 4:
      backHair = '''
        <path d="M53 78 C44 100 50 118 40 140 C50 150 44 170 50 190 C58 175 64 160 58 145 C68 135 60 118 68 100 Z" fill="$hair"/>
        <path d="M147 78 C156 100 150 118 160 140 C150 150 156 170 150 190 C142 175 136 160 142 145 C132 135 140 118 132 100 Z" fill="$hair"/>''';
      frontHair = '''
        <path d="M62 76 C66 47 82 34 100 34 C118 34 134 47 138 76 C132 58 116 47 100 46 C84 47 68 58 62 76 Z" fill="$hair"/>''';
      break;
    case 5:
      backHair = '''
        <path d="M55 80 C42 105 40 130 48 150 C58 145 64 128 66 108 Z" fill="$hair"/>
        <path d="M145 80 C158 105 160 130 152 150 C142 145 136 128 134 108 Z" fill="$hair"/>
        <circle cx="100" cy="28" r="15" fill="$hair"/>''';
      frontHair = '''
        <path d="M64 76 C68 50 83 38 100 38 C117 38 132 50 136 76 C130 60 116 50 100 49 C84 50 70 60 64 76 Z" fill="$hair"/>''';
      break;
    default:
      backHair = '''
        <path d="M53 78 C37 115 32 168 47 221 L68 221 C63 179 61 137 68 100 Z" fill="$hair"/>
        <path d="M147 78 C163 115 168 168 153 221 L132 221 C137 179 139 137 132 100 Z" fill="$hair"/>''';
      frontHair = '''
        <path d="M62 76 C66 47 82 34 100 34 C118 34 134 47 138 76 C132 58 116 47 100 46 C84 47 68 58 62 76 Z" fill="$hair"/>
        <path d="M68 47 C62 63 59 82 63 95 C67 76 76 62 87 50 Z" fill="$hair"/>
        <path d="M132 47 C138 63 141 82 137 95 C133 76 124 62 113 50 Z" fill="$hair"/>
        <path d="M79 47 C76 61 78 74 84 82 C85 68 89 56 96 48 Z" fill="$hair2" opacity="0.55"/>''';
  }

  return '''
<svg viewBox="0 0 200 235" xmlns="http://www.w3.org/2000/svg">
  $backHair
  <path d="M58 158 C74 147 126 147 142 158 L158 221 L42 221 Z" fill="$dress"/>
  <path d="M58 158 C74 147 126 147 142 158 L147 174 C121 163 79 163 53 174 Z" fill="#000000" opacity="0.22"/>
  <rect x="89" y="123" width="22" height="29" fill="$skin"/>
  <rect x="89" y="136" width="22" height="16" fill="#000000" opacity="0.15"/>
  <ellipse cx="100" cy="95" rx="36" ry="42" fill="$skin"/>
  <path d="M68 100 C68 126 79 142 100 145 C84 137 74 118 73 97 Z" fill="#000000" opacity="0.13"/>
  <ellipse cx="79" cy="108" rx="8" ry="5" fill="#ff8fab" opacity="0.3"/>
  <ellipse cx="121" cy="108" rx="8" ry="5" fill="#ff8fab" opacity="0.3"/>
  $frontHair
  <path d="M73 89 Q84 82 96 89 Q84 95 73 89 Z" fill="#fff"/>
  <circle cx="84" cy="89" r="6.3" fill="$eye"/>
  <circle cx="82" cy="86.5" r="1.8" fill="#fff"/>
  <path d="M104 89 Q116 82 127 89 Q116 95 104 89 Z" fill="#fff"/>
  <circle cx="116" cy="89" r="6.3" fill="$eye"/>
  <circle cx="114" cy="86.5" r="1.8" fill="#fff"/>
  <path d="M72 85 Q84 79 97 85" stroke="$hair" stroke-width="1.6" fill="none" stroke-linecap="round"/>
  <path d="M103 85 Q116 79 128 85" stroke="$hair" stroke-width="1.6" fill="none" stroke-linecap="round"/>
  <path d="M98 94 Q96 103 100 107" stroke="#000" stroke-width="1" fill="none" stroke-linecap="round" opacity="0.2"/>
  <path d="M88 117 Q100 122 112 117 Q100 126 88 117 Z" fill="#c96a5e"/>
  <path d="M133 46 Q140 49 147 46 Q140 58 133 46 Z" fill="$acc"/>
</svg>''';
}

class SvgView extends StatelessWidget {
  final String svg;
  final double size;
  const SvgView({super.key, required this.svg, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.15),
      painter: _SvgPainter(svg),
    );
  }
}

class _SvgPainter extends CustomPainter {
  final String svg;
  _SvgPainter(this.svg);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 200, size.height / 235);
    final paths = _parseSvg(svg);
    for (final op in paths) {
      final paint = Paint()
        ..color = op.color
        ..style = op.fill ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = op.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      if (op.path != null) canvas.drawPath(op.path!, paint);
      if (op.circle != null) {
        if (op.fill) {
          canvas.drawCircle(op.circle!.center, op.circle!.radius, paint);
        } else {
          canvas.drawCircle(op.circle!.center, op.circle!.radius, paint);
        }
      }
    }
    canvas.restore();
  }

  List<_SvgOp> _parseSvg(String src) {
    final ops = <_SvgOp>[];
    // path
    final pRe = RegExp(r'<path\s+([^/]*?)/>', dotAll: true);
    for (final m in pRe.allMatches(src)) {
      final attrs = _attrs(m.group(1)!);
      final d = attrs['d'];
      if (d == null) continue;
      final p = _parsePathD(d);
      if (p == null) continue;
      ops.add(_SvgOp(
        path: p,
        color: _colorFromHex(attrs['fill'] ?? attrs['stroke'] ?? '#000'),
        fill: attrs['fill'] != 'none' && (attrs['fill'] ?? '').isNotEmpty,
        strokeWidth: double.tryParse(attrs['stroke-width'] ?? '1') ?? 1,
      ));
    }
    final cRe = RegExp(r'<circle\s+([^/]*?)/>', dotAll: true);
    for (final m in cRe.allMatches(src)) {
      final attrs = _attrs(m.group(1)!);
      final cx = double.tryParse(attrs['cx'] ?? '0') ?? 0;
      final cy = double.tryParse(attrs['cy'] ?? '0') ?? 0;
      final r = double.tryParse(attrs['r'] ?? '0') ?? 0;
      ops.add(_SvgOp(
        circle: _Circle(Offset(cx, cy), r),
        color: _colorFromHex(attrs['fill'] ?? '#000'),
        fill: true,
        strokeWidth: 1,
      ));
    }
    final eRe = RegExp(r'<ellipse\s+([^/]*?)/>', dotAll: true);
    for (final m in eRe.allMatches(src)) {
      final attrs = _attrs(m.group(1)!);
      final cx = double.tryParse(attrs['cx'] ?? '0') ?? 0;
      final cy = double.tryParse(attrs['cy'] ?? '0') ?? 0;
      final rx = double.tryParse(attrs['rx'] ?? '0') ?? 0;
      final ry = double.tryParse(attrs['ry'] ?? '0') ?? 0;
      final rect = Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2);
      final p = Path()..addOval(rect);
      ops.add(_SvgOp(
        path: p,
        color: _colorFromHex(attrs['fill'] ?? '#000'),
        fill: true,
        strokeWidth: 1,
      ));
    }
    final rRe = RegExp(r'<rect\s+([^/]*?)/>', dotAll: true);
    for (final m in rRe.allMatches(src)) {
      final attrs = _attrs(m.group(1)!);
      final x = double.tryParse(attrs['x'] ?? '0') ?? 0;
      final y = double.tryParse(attrs['y'] ?? '0') ?? 0;
      final w = double.tryParse(attrs['width'] ?? '0') ?? 0;
      final h = double.tryParse(attrs['height'] ?? '0') ?? 0;
      final p = Path()..addRect(Rect.fromLTWH(x, y, w, h));
      ops.add(_SvgOp(
        path: p,
        color: _colorFromHex(attrs['fill'] ?? '#000'),
        fill: true,
        strokeWidth: 1,
      ));
    }
    return ops;
  }

  Map<String, String> _attrs(String s) {
    final re = RegExp(r'([\w-]+)\s*=\s*"([^"]*)"');
    final map = <String, String>{};
    for (final m in re.allMatches(s)) {
      map[m.group(1)!] = m.group(2)!;
    }
    return map;
  }

  Path? _parsePathD(String d) {
    final p = Path();
    final tokens = RegExp(r'([MLCSQTAZmlcsqtaz])|(-?\d*\.?\d+)').allMatches(d).toList();
    var i = 0;
    String cmd = 'M';
    double nx() => double.parse(tokens[i++].group(0)!);
    var started = false;
    while (i < tokens.length) {
      final t = tokens[i].group(0)!;
      if (RegExp(r'[A-Za-z]').hasMatch(t)) {
        cmd = t;
        i++;
        continue;
      }
      switch (cmd) {
        case 'M':
          final x = nx(); final y = nx();
          if (!started) { p.moveTo(x, y); started = true; } else { p.moveTo(x, y); }
          break;
        case 'L':
          p.lineTo(nx(), nx());
          break;
        case 'C':
          final x1 = nx(), y1 = nx(), x2 = nx(), y2 = nx(), x3 = nx(), y3 = nx();
          p.cubicTo(x1, y1, x2, y2, x3, y3);
          break;
        case 'Q':
          final x1 = nx(), y1 = nx(), x2 = nx(), y2 = nx();
          p.quadraticBezierTo(x1, y1, x2, y2);
          break;
        case 'Z':
        case 'z':
          p.close();
          break;
        default:
          // unhandled, skip one number
          i++;
      }
    }
    return started ? p : null;
  }

  Color _colorFromHex(String hex) {
    var h = hex.replaceAll('#', '').trim();
    if (h == 'none') return Colors.transparent;
    if (h.length == 3) h = h.split('').map((c) => '$c$c').join();
    if (h.length == 6) h = 'FF$h';
    try { return Color(int.parse(h, radix: 16)); } catch (_) { return Colors.black; }
  }

  @override
  bool shouldRepaint(covariant _SvgPainter old) => old.svg != svg;
}

class _SvgOp {
  final Path? path;
  final _Circle? circle;
  final Color color;
  final bool fill;
  final double strokeWidth;
  _SvgOp({this.path, this.circle, required this.color, required this.fill, required this.strokeWidth});
}
class _Circle { final Offset center; final double radius; _Circle(this.center, this.radius); }

// ═══════════════════════════════════════════════════════════════
// NRS SHAPES — 8 built-in fallback
// ═══════════════════════════════════════════════════════════════
const kNrsShapes = <String>[
  '<svg viewBox="0 0 100 100"><polygon points="50,5 61,35 95,35 68,57 79,91 50,70 21,91 32,57 5,35 39,35" fill="#FFD700"/></svg>',
  '<svg viewBox="0 0 100 100"><circle cx="50" cy="50" r="45" fill="#FF6BB0"/><circle cx="50" cy="50" r="30" fill="#B06BFF"/></svg>',
  '<svg viewBox="0 0 100 100"><polygon points="50,10 90,90 10,90" fill="#22D3EE"/></svg>',
  '<svg viewBox="0 0 100 100"><rect x="15" y="15" width="70" height="70" rx="12" fill="#22E06B"/></svg>',
  '<svg viewBox="0 0 100 100"><polygon points="50,5 95,50 50,95 5,50" fill="#FFB84D"/></svg>',
  '<svg viewBox="0 0 100 100"><polygon points="50,8 92,32 92,68 50,92 8,68 8,32" fill="#4D7CFF"/></svg>',
  '<svg viewBox="0 0 100 100"><ellipse cx="50" cy="50" rx="45" ry="30" fill="#FF4D6D"/></svg>',
  '<svg viewBox="0 0 100 100"><path d="M50 5 L95 50 L50 95 L5 50 Z" fill="#E8E8F2"/><circle cx="50" cy="50" r="15" fill="#0B0B14"/></svg>',
];

// ═══════════════════════════════════════════════════════════════
// UI — MAIN APP
// ═══════════════════════════════════════════════════════════════
class ZenithApp extends StatelessWidget {
  const ZenithApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..bootstrap(),
      child: Consumer<AppState>(
        builder: (ctx, st, _) {
          final t = st.theme;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ZENITH',
            theme: ThemeData(
              brightness: t.isDark ? Brightness.dark : Brightness.light,
              scaffoldBackgroundColor: t.bg,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: st.primaryColor,
                brightness: t.isDark ? Brightness.dark : Brightness.light,
              ),
              fontFamily: 'Cairo',
            ),
            locale: const Locale('ar'),
            builder: (ctx, child) => Directionality(
              textDirection: TextDirection.rtl, child: child!,
            ),
            home: !st.bootstrapped
                ? Scaffold(
                    backgroundColor: t.bg,
                    body: Center(child: CircularProgressIndicator(color: t.primary)),
                  )
                : st.onboarded
                    ? const ChatScreen()
                    : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}

// Provider import shim — minimal change notifier provider
class ChangeNotifierProvider<T extends ChangeNotifier> extends InheritedNotifier<T> {
  final T Function(BuildContext) _create;
  final Widget child;
  ChangeNotifierProvider({super.key, required T Function(BuildContext) create, required this.child})
      : _create = create, super(notifier: null as T);

  @override
  bool updateShouldNotify(InheritedNotifier<T> oldWidget) => true;

  static T of<T extends ChangeNotifier>(BuildContext context) {
    final p = context.dependOnInheritedWidgetOfExactType<ChangeNotifierProvider<T>>();
    if (p != null && p.notifier != null) return p.notifier!;
    throw FlutterError('Provider<$T> not found');
  }
}

// Rewrite minimal: use a StatefulWidget provider instead
class _ProviderScope extends StatefulWidget {
  final Widget child;
  const _ProviderScope({required this.child});
  @override
  State<_ProviderScope> createState() => _ProviderScopeState();
}
class _ProviderScopeState extends State<_ProviderScope> {
  late final AppState state = AppState();
  @override
  void initState() { super.initState(); state.bootstrap(); }
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<AppState>(
    create: (_) => state, child: widget.child,
  );
}

// Rebuild the app root — use this instead of provider package
class ZenithAppRoot extends StatelessWidget {
  const ZenithAppRoot({super.key});
  @override
  Widget build(BuildContext context) => _ProviderScope(child: const _AppInner());
}

class _AppInner extends StatelessWidget {
  const _AppInner();
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _GlobalState.instance,
      builder: (_, __) {
        final st = _GlobalState.instance;
        final t = st.theme;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ZENITH',
          theme: ThemeData(
            brightness: t.isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: t.bg,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: st.primaryColor,
              brightness: t.isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          locale: const Locale('ar'),
          builder: (ctx, child) => Directionality(
            textDirection: TextDirection.rtl, child: child!,
          ),
          home: !st.bootstrapped
              ? Scaffold(
                  backgroundColor: t.bg,
                  body: Center(child: CircularProgressIndicator(color: t.primary)),
                )
              : st.onboarded
                  ? const ChatScreen()
                  : const OnboardingScreen(),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// GLOBAL STATE ACCESSOR — simple singleton
// ═══════════════════════════════════════════════════════════════
class _GlobalState {
  static final AppState instance = AppState();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await _GlobalState.instance.bootstrap();
  runApp(const _AppInner());
}