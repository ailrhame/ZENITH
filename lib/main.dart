// lib/main.dart — ZENITH v4 Flutter clean single-file build
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final state = AppState();
  await state.bootstrap();
  runApp(ZenithApp(state: state));
}

// ═══════════════════════════════════════════════════════════════
// THEMES
// ═══════════════════════════════════════════════════════════════
class ZenithTheme {
  final String id, name;
  final Color bg, surface, surface2, text, textDim, textMuted;
  final Color primary, primary2, accent, botBubble, botText, modalBg, inputBg;
  final List<Color> userBubble;
  final Color userText, online, danger, success, warning, border;
  final bool isDark;

  const ZenithTheme({
    required this.id, required this.name, required this.bg,
    required this.surface, required this.surface2, required this.text,
    required this.textDim, required this.textMuted,
    required this.primary, required this.primary2, required this.accent,
    required this.userBubble, required this.userText,
    required this.botBubble, required this.botText,
    required this.modalBg, required this.inputBg,
    required this.online, required this.danger, required this.success,
    required this.warning, required this.border, required this.isDark,
  });
}

const kThemes = <String, ZenithTheme>{
  'night': ZenithTheme(
    id: 'night', name: 'ليلي',
    bg: Color(0xFF0B0B14), surface: Color(0xFF1A1A2E), surface2: Color(0xFF232338),
    text: Color(0xFFE8E8F2), textDim: Color(0xFF8A8AA0), textMuted: Color(0xFF5A5A72),
    primary: Color(0xFFB06BFF), primary2: Color(0xFFFF6BB0), accent: Color(0xFF6B9BFF),
    userBubble: [Color(0xFFFF6BB0), Color(0xFFB06BFF)], userText: Colors.white,
    botBubble: Color(0xFF232338), botText: Color(0xFFE8E8F2),
    modalBg: Color(0xFF1A1A2E), inputBg: Color(0xFF1A1A2E),
    online: Color(0xFF22E06B), danger: Color(0xFFFF4D6D),
    success: Color(0xFF22E06B), warning: Color(0xFFFFB84D),
    border: Color(0x12FFFFFF), isDark: true,
  ),
  'day': ZenithTheme(
    id: 'day', name: 'نهاري',
    bg: Color(0xFFF2F4F8), surface: Colors.white, surface2: Color(0xFFEEF1F6),
    text: Color(0xFF1A1A2E), textDim: Color(0xFF5A5A72), textMuted: Color(0xFF8A8AA0),
    primary: Color(0xFF7A3EE8), primary2: Color(0xFFE83E94), accent: Color(0xFF3E7AE8),
    userBubble: [Color(0xFFE83E94), Color(0xFF7A3EE8)], userText: Colors.white,
    botBubble: Colors.white, botText: Color(0xFF1A1A2E),
    modalBg: Colors.white, inputBg: Color(0xFFF2F4F8),
    online: Color(0xFF12B85A), danger: Color(0xFFE83E5C),
    success: Color(0xFF12B85A), warning: Color(0xFFE89B3E),
    border: Color(0x14000000), isDark: false,
  ),
  'midnight': ZenithTheme(
    id: 'midnight', name: 'منتصف الليل',
    bg: Color(0xFF05060D), surface: Color(0xFF0F1428), surface2: Color(0xFF161D36),
    text: Color(0xFFD8E0FF), textDim: Color(0xFF7A86B8), textMuted: Color(0xFF4A5478),
    primary: Color(0xFF4D7CFF), primary2: Color(0xFF6B5CFF), accent: Color(0xFF22D3EE),
    userBubble: [Color(0xFF4D7CFF), Color(0xFF22D3EE)], userText: Colors.white,
    botBubble: Color(0xFF161D36), botText: Color(0xFFD8E0FF),
    modalBg: Color(0xFF0F1428), inputBg: Color(0xFF0F1428),
    online: Color(0xFF22E0D3), danger: Color(0xFFFF4D6D),
    success: Color(0xFF22E0D3), warning: Color(0xFFFFB84D),
    border: Color(0x1F4D7CFF), isDark: true,
  ),
  'forest': ZenithTheme(
    id: 'forest', name: 'غابة',
    bg: Color(0xFF0D1410), surface: Color(0xFF16241C), surface2: Color(0xFF1E3126),
    text: Color(0xFFDCEFE0), textDim: Color(0xFF7A9A82), textMuted: Color(0xFF4A6A52),
    primary: Color(0xFF3FB87A), primary2: Color(0xFF7BC74D), accent: Color(0xFFB8D94D),
    userBubble: [Color(0xFF3FB87A), Color(0xFFB8D94D)], userText: Color(0xFF0D1410),
    botBubble: Color(0xFF1E3126), botText: Color(0xFFDCEFE0),
    modalBg: Color(0xFF16241C), inputBg: Color(0xFF16241C),
    online: Color(0xFF7BC74D), danger: Color(0xFFE85D5D),
    success: Color(0xFF7BC74D), warning: Color(0xFFE8B84D),
    border: Color(0x1F3FB87A), isDark: true,
  ),
  'sunset': ZenithTheme(
    id: 'sunset', name: 'غروب',
    bg: Color(0xFF1A0F1E), surface: Color(0xFF2C1832), surface2: Color(0xFF3A2040),
    text: Color(0xFFFFE8F0), textDim: Color(0xFFB88AA0), textMuted: Color(0xFF7A4A60),
    primary: Color(0xFFFF6B6B), primary2: Color(0xFFFFB84D), accent: Color(0xFFFF4D9B),
    userBubble: [Color(0xFFFF4D9B), Color(0xFFFFB84D)], userText: Colors.white,
    botBubble: Color(0xFF3A2040), botText: Color(0xFFFFE8F0),
    modalBg: Color(0xFF2C1832), inputBg: Color(0xFF2C1832),
    online: Color(0xFFFFB84D), danger: Color(0xFFFF4D6D),
    success: Color(0xFFFFB84D), warning: Color(0xFFFFB84D),
    border: Color(0x1FFF6B6B), isDark: true,
  ),
  'ocean': ZenithTheme(
    id: 'ocean', name: 'محيط',
    bg: Color(0xFF061620), surface: Color(0xFF0E2940), surface2: Color(0xFF153652),
    text: Color(0xFFD4F0FF), textDim: Color(0xFF6FA3C4), textMuted: Color(0xFF3D6682),
    primary: Color(0xFF22D3EE), primary2: Color(0xFF4D7CFF), accent: Color(0xFF5EEAD4),
    userBubble: [Color(0xFF22D3EE), Color(0xFF4D7CFF)], userText: Color(0xFF061620),
    botBubble: Color(0xFF153652), botText: Color(0xFFD4F0FF),
    modalBg: Color(0xFF0E2940), inputBg: Color(0xFF0E2940),
    online: Color(0xFF5EEAD4), danger: Color(0xFFFF6B6B),
    success: Color(0xFF5EEAD4), warning: Color(0xFFFBBF24),
    border: Color(0x1F22D3EE), isDark: true,
  ),
  'mono': ZenithTheme(
    id: 'mono', name: 'أحادي',
    bg: Color(0xFF0A0A0A), surface: Color(0xFF1A1A1A), surface2: Color(0xFF262626),
    text: Color(0xFFF5F5F5), textDim: Color(0xFFA3A3A3), textMuted: Color(0xFF525252),
    primary: Color(0xFFE5E5E5), primary2: Color(0xFFA3A3A3), accent: Color(0xFFD4D4D4),
    userBubble: [Color(0xFF525252), Color(0xFF262626)], userText: Color(0xFFF5F5F5),
    botBubble: Color(0xFF1A1A1A), botText: Color(0xFFE5E5E5),
    modalBg: Color(0xFF1A1A1A), inputBg: Color(0xFF1A1A1A),
    online: Color(0xFFE5E5E5), danger: Color(0xFFF87171),
    success: Color(0xFFE5E5E5), warning: Color(0xFFFBBF24),
    border: Color(0x14FFFFFF), isDark: true,
  ),
  'sakura': ZenithTheme(
    id: 'sakura', name: 'ساكورا',
    bg: Color(0xFFFFF5F8), surface: Colors.white, surface2: Color(0xFFFFE4EC),
    text: Color(0xFF4A1A2C), textDim: Color(0xFFA8758A), textMuted: Color(0xFFD4A8B8),
    primary: Color(0xFFEC4899), primary2: Color(0xFFF472B6), accent: Color(0xFFFB7185),
    userBubble: [Color(0xFFF472B6), Color(0xFFFB7185)], userText: Colors.white,
    botBubble: Colors.white, botText: Color(0xFF4A1A2C),
    modalBg: Colors.white, inputBg: Color(0xFFFFF5F8),
    online: Color(0xFFF472B6), danger: Color(0xFFEF4444),
    success: Color(0xFFEC4899), warning: Color(0xFFF59E0B),
    border: Color(0x1FEC4899), isDark: false,
  ),
  'cyberpunk': ZenithTheme(
    id: 'cyberpunk', name: 'سايبربانك',
    bg: Color(0xFF0D0221), surface: Color(0xFF1F0335), surface2: Color(0xFF2A054A),
    text: Color(0xFFFFE8FF), textDim: Color(0xFFB866D4), textMuted: Color(0xFF6D1A8A),
    primary: Color(0xFFFF00AA), primary2: Color(0xFF00FFF7), accent: Color(0xFFFAFF00),
    userBubble: [Color(0xFFFF00AA), Color(0xFF00FFF7)], userText: Color(0xFF0D0221),
    botBubble: Color(0xFF2A054A), botText: Color(0xFFFFE8FF),
    modalBg: Color(0xFF1F0335), inputBg: Color(0xFF1F0335),
    online: Color(0xFF00FFF7), danger: Color(0xFFFF004D),
    success: Color(0xFF00FFF7), warning: Color(0xFFFAFF00),
    border: Color(0x2EFF00AA), isDark: true,
  ),
  'coffee': ZenithTheme(
    id: 'coffee', name: 'قهوة',
    bg: Color(0xFF1A120B), surface: Color(0xFF2D1F15), surface2: Color(0xFF3D2A1C),
    text: Color(0xFFF5E6D3), textDim: Color(0xFFA89078), textMuted: Color(0xFF6B5844),
    primary: Color(0xFFD4A574), primary2: Color(0xFFB8763F), accent: Color(0xFFE6C090),
    userBubble: [Color(0xFFB8763F), Color(0xFFD4A574)], userText: Color(0xFF1A120B),
    botBubble: Color(0xFF3D2A1C), botText: Color(0xFFF5E6D3),
    modalBg: Color(0xFF2D1F15), inputBg: Color(0xFF2D1F15),
    online: Color(0xFFD4A574), danger: Color(0xFFE85D5D),
    success: Color(0xFFD4A574), warning: Color(0xFFE6C090),
    border: Color(0x24D4A574), isDark: true,
  ),
};

// ═══════════════════════════════════════════════════════════════
// CHARACTERS — 50 deterministic colors
// ═══════════════════════════════════════════════════════════════
class CharacterColors {
  final int id, style;
  final Color skin, hair, hair2, eye, dress, accessory;
  const CharacterColors(this.id, this.skin, this.hair, this.hair2, this.eye,
      this.dress, this.accessory, this.style);
}

const _skinPool = [Color(0xFFFFE4EC), Color(0xFFFCD5CE), Color(0xFFF3C4B3),
  Color(0xFFE6B999), Color(0xFFD4A373), Color(0xFFFFD1DC), Color(0xFFFFB3B3)];
const _hairPool = [Color(0xFF8B3A5F), Color(0xFF333333), Color(0xFF6B4423),
  Color(0xFFE6B800), Color(0xFFFF4D4D), Color(0xFF4D79FF), Color(0xFFD96B8C),
  Color(0xFFCC99FF), Color(0xFF99CCFF), Color(0xFFFFB3B3), Color(0xFF1A1A1A),
  Color(0xFFB76E92)];
const _eyePool = [Color(0xFF4FACFE), Color(0xFF00F2FE), Color(0xFF8B5A2B),
  Color(0xFF2ECC71), Color(0xFFFFA751), Color(0xFF9B59B6), Color(0xFFFF6B6B),
  Color(0xFF3498DB)];
const _dressPool = [Color(0xFFFF8FAB), Color(0xFFF7CAE0), Color(0xFFFFC3A0),
  Color(0xFF9B59B6), Color(0xFF3498DB), Color(0xFFE74C3C), Color(0xFF2ECC71),
  Color(0xFFF1C40F), Color(0xFF95A5A6), Color(0xFFFFA502), Color(0xFFA29BFE),
  Color(0xFF55EFC4)];
const _accPool = [Color(0xFFFF8FAB), Color(0xFFFF6B6B), Color(0xFF4FACFE),
  Color(0xFFF1C40F), Color(0xFFFD79A8), Color(0xFF00CEC9), Color(0xFF6C5CE7),
  Color(0xFFFDCB6E)];

List<CharacterColors> buildCharacters() {
  final list = <CharacterColors>[
    const CharacterColors(0, Color(0xFFFFE4EC), Color(0xFF8B3A5F),
        Color(0xFFD96B8C), Color(0xFF4FACFE), Color(0xFFA29BFE),
        Color(0xFFFF8FAB), 0),
  ];
  for (var i = 1; i < 50; i++) {
    var s = (i * 7919 + 13) & 0xFFFFFFFF;
    int next() {
      s = (s * 1664525 + 1013904223) & 0xFFFFFFFF;
      return s;
    }
    T pick<T>(List<T> arr) => arr[next() % arr.length];
    list.add(CharacterColors(i, pick(_skinPool), pick(_hairPool),
        pick(_hairPool), pick(_eyePool), pick(_dressPool), pick(_accPool), i % 6));
  }
  return list;
}

final kCharacters = buildCharacters();

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
  final List<QAItem> items = [];
  int get length => items.length;
  QAItem random() => items[Random().nextInt(items.length)];

  void seedDefaults(String name) {
    items.addAll([
      QAItem('من أنت', 'أنا $name، أتحدث معك وأتعلم من ملفاتك.'),
      QAItem('كم عمرك', 'عمري ليس مهماً، المهم أنني هنا لمساعدتك.'),
      QAItem('كيف الحال', 'بخير، شكراً لسؤالك! كيف حالك أنت اليوم؟'),
    ]);
  }

  void loadFromJson(List list) {
    items.clear();
    for (final e in list) {
      final m = Map<String, dynamic>.from(e as Map);
      items.add(QAItem(m['question'] ?? '', m['answer'] ?? ''));
    }
  }

  List<Map<String, dynamic>> toJson() => items.map((i) => i.toJson()).toList();

  void addQA(String q, String a) {
    final i = items.indexWhere((x) => x.question == q);
    if (i >= 0) { items[i].answer = a; } else { items.add(QAItem(q, a)); }
  }

  void clear() => items.clear();

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
    if (items.isEmpty) return {'text': 'عذراً، لا توجد بيانات في الذاكرة.'};
    final uk = _extract(question);
    if (uk.isEmpty) return {'text': 'اسأل سؤالاً واضحاً 😊'};

    final scored = <MapEntry<QAItem, double>>[];
    for (final item in items) {
      final sk = item.keywords;
      var hit = 0;
      for (final u in uk) if (sk.any((s) => _sim(u, s))) hit++;
      scored.add(MapEntry(item, hit / uk.length));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    final best = scored.first;

    if (best.value >= 0.6) {
      final related = items
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
    alternates: (j['alternates'] as List?)
        ?.map((e) => Map<String, String>.from(e)).toList(),
    needsTeaching: j['needsTeaching'] ?? false,
  );
}

class PinnedMessage {
  final String id, sender, text;
  PinnedMessage({required this.id, required this.sender, required this.text});
}

// ═══════════════════════════════════════════════════════════════
// APP STATE — single source of truth
// ═══════════════════════════════════════════════════════════════
class AppState extends ChangeNotifier {
  bool bootstrapped = false;
  bool onboarded = false;

  String themeId = 'night';
  String weather = '';
  int charId = 0;
  String charName = 'زوجه علاوي';
  int botAge = 18;
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
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool recording = false;

  ZenithTheme get theme => kThemes[themeId] ?? kThemes['night']!;
  CharacterColors get character => kCharacters[charId];

  Future<void> bootstrap() async {
    final p = await SharedPreferences.getInstance();
    onboarded = p.getBool('zenith_onboarded') ?? false;
    themeId = p.getString('zenith_theme') ?? 'night';
    weather = p.getString('zenith_weather') ?? '';
    charId = p.getInt('selectedCharacterId') ?? 0;
    charName = p.getString('robotName') ?? 'زوجه علاوي';
    botAge = p.getInt('robotAge') ?? 18;
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
    if (ua != null) {
      unanswered.addAll((jsonDecode(ua) as List).cast<Map<String, dynamic>>());
    }
    final um = p.getString('zenith_user_memory');
    if (um != null) {
      userMemory.addAll(Map<String, String>.from(jsonDecode(um)));
    }

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
    await p.setString('zenith_weather', weather);
    await p.setInt('selectedCharacterId', charId);
    await p.setString('robotName', charName);
    await p.setInt('robotAge', botAge);
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
      _pushMessage(ChatMessage(
        id: UniqueKey().toString(), sender: 'bot',
        text: '🎉 مبروك! وصلت إلى المستوى $userLevel!',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    notifyListeners(); saveAll();
  }

  void _pushMessage(ChatMessage m) {
    messages.add(m);
    notifyListeners();
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
    final idx = pinned.indexWhere(
        (p) => p.text == m.text && p.sender == m.sender);
    if (idx >= 0) {
      pinned.removeAt(idx);
    } else {
      pinned.add(PinnedMessage(id: m.id, sender: m.sender, text: m.text));
    }
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

  Future<void> toggleMic(void Function(String) onText) async {
    if (recording) {
      await _speech.stop();
      recording = false;
      notifyListeners();
      return;
    }
    final ok = await _speech.initialize();
    if (!ok) return;
    recording = true;
    notifyListeners();
    await _speech.listen(
      localeId: 'ar-SA',
      onResult: (r) { if (r.recognizedWords.isNotEmpty) onText(r.recognizedWords); },
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
      'theme': themeId, 'weather': weather,
      'questionFreq': questionFreq, 'unanswered': unanswered,
      'userMemory': userMemory,
      'messages': messages.map((m) => m.toJson()).toList(),
      'pinned': pinned.map((p) => {'sender': p.sender, 'text': p.text}).toList(),
    };
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/zenith_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    await Share.shareXFiles([XFile(file.path)], subject: 'ZENITH v4 backup');
  }

  Future<void> importBackup() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (res == null) return;
    final f = res.files.single;
    if (f.path == null) return;
    final raw = await File(f.path!).readAsString();
    final data = jsonDecode(raw) as Map<String, dynamic>;
    engine.loadFromJson(data['knowledgeBase'] as List? ?? []);
    coins = data['coins'] ?? 0;
    userXP = data['xp'] ?? 0;
    userLevel = data['level'] ?? 1;
    charId = data['charId'] ?? 0;
    charName = data['charName'] ?? charName;
    botAge = data['botAge'] ?? botAge;
    themeId = data['theme'] ?? themeId;
    weather = data['weather'] ?? '';
    questionFreq = Map<String, int>.from(data['questionFreq'] ?? {});
    unanswered = List<Map<String, dynamic>>.from(data['unanswered'] ?? []);
    userMemory
      ..clear()
      ..addAll(Map<String, String>.from(data['userMemory'] ?? {}));
    messages.clear();
    for (final m in (data['messages'] as List? ?? [])) {
      messages.add(ChatMessage.fromJson(m));
    }
    pinned.clear();
    for (final pi in (data['pinned'] as List? ?? [])) {
      pinned.add(PinnedMessage(id: UniqueKey().toString(), sender: pi['sender'], text: pi['text']));
    }
    await saveAll();
    notifyListeners();
  }

  Future<void> resetAll() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
    messages.clear();
    pinned.clear();
    engine.clear();
    engine.seedDefaults(charName);
    coins = 0; userXP = 0; userLevel = 1;
    statLikes = 0; statDislikes = 0; statQuestions = 0;
    questionFreq.clear();
    unanswered.clear();
    userMemory.clear();
    notifyListeners();
    await saveAll();
  }
}

// ═══════════════════════════════════════════════════════════════
// ROOT APP
// ═══════════════════════════════════════════════════════════════
class ZenithApp extends StatelessWidget {
  final AppState state;
  const ZenithApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (_, __) {
        final t = state.theme;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ZENITH',
          theme: ThemeData(
            brightness: t.isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: t.bg,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: t.primary,
              brightness: t.isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          locale: const Locale('ar'),
          builder: (ctx, child) => Directionality(
            textDirection: TextDirection.rtl, child: child!,
          ),
          home: state.onboarded
              ? ChatScreen(state: state)
              : OnboardingScreen(state: state),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ONBOARDING
// ═══════════════════════════════════════════════════════════════
class OnboardingScreen extends StatelessWidget {
  final AppState state;
  const OnboardingScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final t = state.theme;
    final feats = [
      ['🎨', '10 ثيمات + خطوط', 'ليلي، نهاري، غروب، ساكورا، سايبربانك، قهوة...'],
      ['💬', 'محرك أسئلة وأجوبة', 'يتعلم من TXT ويطابق حتى مع الأخطاء الإملائية.'],
      ['👩‍🚀', '50 شخصية + NRS', 'اختر شخصيتك واسحب الأشكال العائمة.'],
      ['🌧️', 'أربع أجواء متحركة', 'مطر، ثلج، نجوم، أوراق خريفية.'],
      ['⚡', 'أدوات متقدمة', 'ردود سريعة، نسخ احتياطي كامل، إحصائيات، ألعاب.'],
    ];
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: LinearGradient(colors: [t.primary2, t.primary]),
                  boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.4), blurRadius: 40)],
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 20),
              Text('ZENITH v4',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: t.text, letterSpacing: 1)),
              const SizedBox(height: 8),
              Text('رفيقك الذكي في المحادثة — 10 ثيمات، 50 شخصية، وميزات تكبر معك.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: t.textDim, height: 1.5)),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: feats.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final f = feats[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: t.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: t.border),
                      ),
                      child: Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(colors: [t.primary, t.primary2]),
                          ),
                          alignment: Alignment.center,
                          child: Text(f[0], style: const TextStyle(fontSize: 22)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(f[1], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: t.text)),
                              const SizedBox(height: 3),
                              Text(f[2], style: TextStyle(fontSize: 12, color: t.textDim, height: 1.4)),
                            ],
                          ),
                        ),
                      ]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => state.completeOnboarding(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: t.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: const Text('ابدأ الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CHAT SCREEN
// ═══════════════════════════════════════════════════════════════
class ChatScreen extends StatefulWidget {
  final AppState state;
  const ChatScreen({super.key, required this.state});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _focus = FocusNode();
  final Set<String> _selected = {};
  bool _selectMode = false;
  bool _fabOpen = false;
  String _search = '';
  bool _searchOpen = false;

  AppState get s => widget.state;

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;

    if (text == 'N5CR4') {
      s.setUnlimited();
      _input.clear();
      _showToast('🔓 تم تفعيل العملات اللانهائية');
      return;
    }
    if (text.toUpperCase() == 'NRS') {
      s.toggleNrs();
      _input.clear();
      return;
    }

    if (s.pendingCorrection != null) {
      if (text == 'تجاهل') {
        s.skipTeach();
        _input.clear();
        _showToast('تمام، تجاوزتها');
        return;
      }
      s.teach(text);
      _input.clear();
      _showToast('✅ تم الحفظ');
      return;
    }

    if (s.gameState != null) {
      final ans = s.gameState!['answer'] as String;
      if (text.contains(ans)) {
        s.addCoins(10); s.addXP(20);
        s.addMessage(ChatMessage(
          id: UniqueKey().toString(), sender: 'bot',
          text: '🎉 إجابة صحيحة! (الجواب: $ans)',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ));
        s.gameState = null;
      } else {
        s.addMessage(ChatMessage(
          id: UniqueKey().toString(), sender: 'bot',
          text: '❌ إجابة خاطئة، حاول مرة أخرى!',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ));
      }
      _input.clear();
      return;
    }

    s.addMessage(ChatMessage(
      id: UniqueKey().toString(), sender: 'user', text: text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));
    _input.clear();
    _scrollBottom();

    await Future.delayed(const Duration(milliseconds: 350));
    final reply = s.replyTo(text);
    if (reply != null) {
      s.addMessage(reply);
      _scrollBottom();
      if (reply.sender == 'bot') {
        await Future.delayed(Duration(milliseconds: min(1400, max(300, reply.text.length * 10))));
      }
    }
    await s.saveAll();
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      duration: const Duration(milliseconds: 1800),
      behavior: SnackBarBehavior.floating,
      backgroundColor: s.theme.surface2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = s.theme;
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(t),
            _buildStatsRow(t),
            if (_searchOpen) _buildSearchBar(t),
            if (s.pinned.isNotEmpty) _buildPinnedBar(t),
            Expanded(
              child: Stack(
                children: [
                  _buildWeather(t),
                  _buildChat(t),
                  _buildCharacter(t),
                  _buildNrs(t),
                  if (_selectMode) _buildSelectionBar(t),
                  if (!_selectMode) _buildFab(t),
                ],
              ),
            ),
            if (!_selectMode) _buildComposer(t),
          ],
        ),
      ),
    );
  }

  // ═══ TOP BAR ═══
  Widget _buildTopBar(ZenithTheme t) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(colors: [t.primary2, t.primary]),
          ),
          child: const Icon(Icons.star, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ZENITH',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                      color: t.text, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Row(children: [
                Container(width: 7, height: 7,
                    decoration: BoxDecoration(color: t.online, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text('متصل الآن', style: TextStyle(fontSize: 11, color: t.textDim)),
              ]),
            ],
          ),
        ),
        _iconBtn(t, Icons.search, () => setState(() => _searchOpen = !_searchOpen)),
        _iconBtn(t, Icons.more_vert, () => _openSettings()),
      ]),
    );
  }

  Widget _iconBtn(ZenithTheme t, IconData i, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: t.surface2.withValues(alpha: 0.5), shape: BoxShape.circle),
          child: Icon(i, color: t.text, size: 18),
        ),
      ),
    );
  }

  // ═══ STATS ROW ═══
  Widget _buildStatsRow(ZenithTheme t) {
    Widget chip(IconData i, Color c, String text) => Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: t.surface2.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Row(children: [
        Icon(i, size: 13, color: c),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: t.text)),
      ]),
    );

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          chip(Icons.star, t.accent, '${s.userXP} XP'),
          chip(Icons.monetization_on, t.warning, s.unlimited ? '∞' : '${s.coins}'),
          chip(Icons.workspace_premium, t.primary2, 'LEVEL ${s.userLevel}'),
        ]),
      ),
    );
  }

  // ═══ SEARCH ═══
  Widget _buildSearchBar(ZenithTheme t) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: t.surface,
      child: Row(children: [
        Expanded(
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            style: TextStyle(color: t.text, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'ابحث في المحادثة...',
              hintStyle: TextStyle(color: t.textMuted),
              filled: true,
              fillColor: t.inputBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ),
        IconButton(
          onPressed: () => setState(() { _searchOpen = false; _search = ''; }),
          icon: Icon(Icons.close, color: t.textDim),
        ),
      ]),
    );
  }

  // ═══ PINNED ═══
  Widget _buildPinnedBar(ZenithTheme t) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: s.pinned.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final p = s.pinned[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: t.surface2.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: t.primary),
            ),
            alignment: Alignment.center,
            child: Text(
              '${p.sender == 'user' ? '🧑' : '🤖'} ${p.text.length > 30 ? '${p.text.substring(0, 30)}…' : p.text}',
              style: TextStyle(fontSize: 11, color: t.text),
            ),
          );
        },
      ),
    );
  }

  // ═══ WEATHER ═══
  Widget _buildWeather(ZenithTheme t) {
    if (s.weather.isEmpty) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: 0.35,
          duration: const Duration(milliseconds: 600),
          child: CustomPaint(painter: _WeatherPainter(s.weather)),
        ),
      ),
    );
  }

  // ═══ CHAT LIST ═══
  Widget _buildChat(ZenithTheme t) {
    final msgs = s.messages.where((m) {
      if (_search.isEmpty) return true;
      return m.text.contains(_search);
    }).toList();

    if (msgs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('💬', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'ابدأ المحادثة\nجرّب: "السلام عليكم" أو "من أنت"',
                textAlign: TextAlign.center,
                style: TextStyle(color: t.textDim, fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      itemCount: msgs.length,
      itemBuilder: (_, i) => _buildBubble(msgs[i], t),
    );
  }

  Widget _buildBubble(ChatMessage m, ZenithTheme t) {
    final isUser = m.sender == 'user';
    final isSelected = _selected.contains(m.id);

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _selectMode = true;
          _selected.add(m.id);
        });
      },
      onTap: _selectMode
          ? () => setState(() {
                if (_selected.contains(m.id)) {
                  _selected.remove(m.id);
                } else {
                  _selected.add(m.id);
                }
                if (_selected.isEmpty) _selectMode = false;
              })
          : null,
      child: Align(
        alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          decoration: BoxDecoration(
            gradient: isUser
                ? LinearGradient(colors: t.userBubble)
                : null,
            color: isUser ? null : t.botBubble,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isUser ? 6 : 20),
              bottomRight: Radius.circular(isUser ? 20 : 6),
            ),
            border: isSelected ? Border.all(color: t.danger, width: 2) : null,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                m.text,
                style: TextStyle(
                  color: isUser ? t.userText : t.botText,
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(m.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: isUser ? Colors.white70 : t.textMuted,
                ),
              ),
              if (!isUser) _buildBotActions(m, t),
              if (m.suggestions != null && m.suggestions!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 6, runSpacing: 6,
                    children: m.suggestions!.map((sug) => GestureDetector(
                      onTap: () {
                        _input.text = sug;
                        _send();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: t.surface2.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: t.border),
                        ),
                        child: Text(sug, style: TextStyle(fontSize: 12, color: t.text)),
                      ),
                    )).toList(),
                  ),
                ),
              if (m.needsTeaching)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: GestureDetector(
                    onTap: () => _showToast('اكتب الجواب الصحيح الآن'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: t.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: t.primary),
                      ),
                      child: Text('➕ علّمني الجواب',
                          style: TextStyle(fontSize: 12, color: t.primary, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotActions(ChatMessage m, ZenithTheme t) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(children: [
        _fbBtn(Icons.thumb_up_alt_outlined, t, () {
          s.statLikes++;
          s.addCoins(2);
          s.addXP(5);
          s.saveAll();
          _showToast('👍 شكراً!');
        }),
        const SizedBox(width: 6),
        _fbBtn(Icons.thumb_down_alt_outlined, t, () {
          s.statDislikes++;
          s.pendingCorrection = {'question': m.question ?? m.text};
          s.saveAll();
          _showToast('📝 علّمني الجواب الصحيح');
        }),
        const SizedBox(width: 6),
        _fbBtn(Icons.volume_up_outlined, t, () => s.speak(m.text)),
        const SizedBox(width: 6),
        _fbBtn(Icons.push_pin_outlined, t, () => s.togglePin(m)),
      ]),
    );
  }

  Widget _fbBtn(IconData i, ZenithTheme t, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: t.surface2.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: Border.all(color: t.border),
        ),
        child: Icon(i, size: 14, color: t.textDim),
      ),
    );
  }

  // ═══ CHARACTER ═══
  Widget _buildCharacter(ZenithTheme t) {
    return Positioned(
      top: 12, left: 12,
      child: GestureDetector(
        onTap: () {
          s.addMessage(ChatMessage(
            id: UniqueKey().toString(), sender: 'bot',
            text: 'أنا فتاة متزوجة لا تلمسني!',
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ));
          _showToast('💢 لا تلمسني!');
        },
        child: SizedBox(
          width: 70, height: 82,
          child: SvgRender(svg: buildCharacterSvg(s.character)),
        ),
      ),
    );
  }

  // ═══ NRS ═══
  Widget _buildNrs(ZenithTheme t) {
    if (!s.nrsActive) return const SizedBox.shrink();
    final shape = kNrsShapes[s.nrsShapeIndex % kNrsShapes.length];
    return Positioned(
      top: 12, right: 12,
      child: GestureDetector(
        onTap: () {
          s.setNrsShape((s.nrsShapeIndex + 1) % kNrsShapes.length);
          _showToast('💎 الشكل ${s.nrsShapeIndex + 1}');
        },
        child: SizedBox(
          width: 60, height: 60,
          child: SvgRender(svg: shape),
        ),
      ),
    );
  }

  // ═══ SELECTION BAR ═══
  Widget _buildSelectionBar(ZenithTheme t) {
    return Positioned(
      bottom: 12, left: 20, right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20)],
          border: Border.all(color: t.border),
        ),
        child: Row(children: [
          Text('${_selected.length} محددة',
              style: TextStyle(color: t.text, fontSize: 13, fontWeight: FontWeight.w700)),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              s.deleteMessages(_selected);
              setState(() { _selected.clear(); _selectMode = false; });
              _showToast('🗑️ تم الحذف');
            },
            icon: const Icon(Icons.delete, color: Colors.white, size: 16),
            label: const Text('مسح', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            style: TextButton.styleFrom(backgroundColor: t.danger),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => setState(() { _selected.clear(); _selectMode = false; }),
            icon: Icon(Icons.close, color: t.textDim),
          ),
        ]),
      ),
    );
  }

  // ═══ FAB ═══
  Widget _buildFab(ZenithTheme t) {
    return Positioned(
      bottom: 16, left: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_fabOpen) ...[
            _fabItem(t, Icons.broom, 'مسح المحادثة', () {
              s.clearChat();
              setState(() => _fabOpen = false);
            }),
            _fabItem(t, Icons.shuffle, 'ثيم عشوائي', () {
              final ids = kThemes.keys.toList()..remove(s.themeId);
              s.setTheme(ids[Random().nextInt(ids.length)]);
              setState(() => _fabOpen = false);
            }),
            _fabItem(t, Icons.save, 'حفظ المحادثة', () {
              _showToast('💾 محفوظ تلقائياً');
              setState(() => _fabOpen = false);
            }),
            _fabItem(t, Icons.bar_chart, 'الإحصائيات', () {
              _openStats();
              setState(() => _fabOpen = false);
            }),
            const SizedBox(height: 8),
          ],
          FloatingActionButton(
            onPressed: () => setState(() => _fabOpen = !_fabOpen),
            backgroundColor: t.primary,
            child: AnimatedRotation(
              turns: _fabOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fabItem(ZenithTheme t, IconData i, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        FloatingActionButton.small(
          heroTag: label,
          onPressed: onTap,
          backgroundColor: t.surface,
          child: Icon(i, color: t.text, size: 18),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.border),
          ),
          child: Text(label, style: TextStyle(color: t.text, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  // ═══ COMPOSER ═══
  Widget _buildComposer(ZenithTheme t) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: Row(children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: t.inputBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _focus.hasFocus ? t.primary : t.border),
            ),
            child: Row(children: [
              IconButton(
                onPressed: () => _openEmoji(),
                icon: Icon(Icons.emoji_emotions_outlined, color: t.textDim, size: 20),
              ),
              Expanded(
                child: TextField(
                  controller: _input,
                  focusNode: _focus,
                  maxLines: 4, minLines: 1,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(color: t.text, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك...',
                    hintStyle: TextStyle(color: t.textMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => s.toggleMic((txt) {
                  _input.text = txt;
                  setState(() {});
                }),
                icon: Icon(s.recording ? Icons.mic : Icons.mic_none,
                    color: s.recording ? t.danger : t.textDim, size: 20),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: _send,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [t.primary2, t.primary]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.35), blurRadius: 14)],
            ),
            child: const Icon(Icons.send, color: Colors.white, size: 18),
          ),
        ),
      ]),
    );
  }

  // ═══ SETTINGS BOTTOM SHEET ═══
  void _openSettings() {
    final t = s.theme;
    showModalBottomSheet(
      context: context,
      backgroundColor: t.modalBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(builder: (ctx, setSheet) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: DraggableScrollableSheet(
            expand: false, initialChildSize: 0.85, maxChildSize: 0.95,
            builder: (_, ctrl) => ListView(
              controller: ctrl,
              padding: const EdgeInsets.all(18),
              children: [
                Center(child: Container(
                  width: 42, height: 4,
                  decoration: BoxDecoration(color: t.textMuted, borderRadius: BorderRadius.circular(2)),
                )),
                const SizedBox(height: 16),
                Text('الإعدادات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: t.text)),
                const SizedBox(height: 16),

                _sectionTitle('الثيمات', t),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: kThemes.entries.map((e) => GestureDetector(
                    onTap: () { s.setTheme(e.key); setSheet(() {}); setState(() {}); },
                    child: Container(
                      width: 90, height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [e.value.primary, e.value.primary2]),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: s.themeId == e.key ? t.text : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.all(6),
                      child: Text(e.value.name,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  )).toList(),
                ),

                const SizedBox(height: 20),
                _sectionTitle('الأجواء', t),
                Wrap(
                  spacing: 8,
                  children: [
                    _chip(t, 'مطر 🌧️', s.weather == 'rain', () { s.setWeather(s.weather == 'rain' ? '' : 'rain'); setSheet(() {}); setState(() {}); }),
                    _chip(t, 'ثلج ❄️', s.weather == 'snow', () { s.setWeather(s.weather == 'snow' ? '' : 'snow'); setSheet(() {}); setState(() {}); }),
                    _chip(t, 'نجوم ✨', s.weather == 'stars', () { s.setWeather(s.weather == 'stars' ? '' : 'stars'); setSheet(() {}); setState(() {}); }),
                    _chip(t, 'أوراق 🍂', s.weather == 'leaves', () { s.setWeather(s.weather == 'leaves' ? '' : 'leaves'); setSheet(() {}); setState(() {}); }),
                  ],
                ),

                const SizedBox(height: 20),
                _sectionTitle('الشخصية', t),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: kCharacters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () { s.setCharId(i); setSheet(() {}); setState(() {}); },
                      child: Container(
                        width: 60,
                        decoration: BoxDecoration(
                          color: t.surface2.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: s.charId == i ? t.primary : t.border,
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: SvgRender(svg: buildCharacterSvg(kCharacters[i])),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                _sectionTitle('NRS', t),
                Row(children: [
                  _chip(t, s.nrsActive ? 'مفعّل ✅' : 'معطّل ❌', s.nrsActive, () {
                    s.toggleNrs(); setSheet(() {}); setState(() {});
                  }),
                  const SizedBox(width: 8),
                  _chip(t, 'الشكل التالي', false, () {
                    s.setNrsShape((s.nrsShapeIndex + 1) % kNrsShapes.length);
                    setSheet(() {}); setState(() {});
                  }),
                ]),

                const SizedBox(height: 20),
                _sectionTitle('الذاكرة', t),
                _actionBtn(t, Icons.upload_file, 'رفع ملف TXT', _pickAndLoadFile),
                _actionBtn(t, Icons.download, 'تصدير نسخة احتياطية', () async {
                  await s.exportBackup();
                  if (mounted) _showToast('💾 تم التصدير');
                }),
                _actionBtn(t, Icons.file_upload, 'استيراد نسخة', () async {
                  await s.importBackup();
                  if (mounted) { setState(() {}); _showToast('✅ تم الاستيراد'); }
                }),
                _actionBtn(t, Icons.bar_chart, 'عرض الإحصائيات', _openStats),

                const SizedBox(height: 20),
                _sectionTitle('ألعاب', t),
                _actionBtn(t, Icons.quiz, 'لعبة الأسئلة', () { s.startQuiz(); Navigator.pop(context); setState(() {}); }),
                _actionBtn(t, Icons.bolt, 'تحدي السرعة', () { s.startSpeed(); Navigator.pop(context); setState(() {}); }),

                const SizedBox(height: 20),
                _actionBtn(t, Icons.delete_forever, 'إعادة ضبط كامل', () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: t.modalBg,
                      title: Text('متأكد؟', style: TextStyle(color: t.text)),
                      content: Text('سيتم حذف كل شيء.', style: TextStyle(color: t.textDim)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false),
                            child: Text('إلغاء', style: TextStyle(color: t.textDim))),
                        TextButton(onPressed: () => Navigator.pop(context, true),
                            child: Text('حذف', style: TextStyle(color: t.danger))),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await s.resetAll();
                    if (mounted) { Navigator.pop(context); setState(() {}); }
                  }
                }, danger: true),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _sectionTitle(String s, ZenithTheme t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(s, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: t.textDim)),
  );

  Widget _chip(ZenithTheme t, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? t.primary : t.surface2.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? t.primary : t.border),
        ),
        child: Text(label,
            style: TextStyle(
              color: active ? Colors.white : t.text,
              fontSize: 12, fontWeight: FontWeight.w600,
            )),
      ),
    );
  }

  Widget _actionBtn(ZenithTheme t, IconData i, String label, VoidCallback onTap, {bool danger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: t.surface2.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: t.border),
          ),
          child: Row(children: [
            Icon(i, color: danger ? t.danger : t.primary, size: 18),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                  color: danger ? t.danger : t.text,
                  fontSize: 13, fontWeight: FontWeight.w700,
                )),
          ]),
        ),
      ),
    );
  }

  Future<void> _pickAndLoadFile() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt']);
    if (res == null || res.files.single.path == null) return;
    final content = await File(res.files.single.path!).readAsString();
    s.engine.parseAndAdd(content);
    await s.saveAll();
    if (mounted) {
      setState(() {});
      _showToast('✅ تم التحميل: ${s.engine.length} سؤال');
    }
  }

  void _openStats() {
    final t = s.theme;
    showModalBottomSheet(
      context: context,
      backgroundColor: t.modalBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الإحصائيات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: t.text)),
              const SizedBox(height: 16),
              Row(children: [
                _statCard(t, '👍', '${s.statLikes}', 'إعجاب'),
                _statCard(t, '👎', '${s.statDislikes}', 'عدم إعجاب'),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                _statCard(t, '❓', '${s.statQuestions}', 'أسئلة'),
                _statCard(t, '📚', '${s.engine.length}', 'في الذاكرة'),
              ]),
              const SizedBox(height: 20),
              Text('الأسئلة الأكثر تكراراً',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: t.textDim)),
              const SizedBox(height: 8),
              ...(s.questionFreq.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value)))
                  .take(5)
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(children: [
                          Expanded(child: Text(e.key,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: t.text))),
                          Text('${e.value}×',
                              style: TextStyle(fontSize: 12, color: t.primary, fontWeight: FontWeight.w700)),
                        ]),
                      )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(ZenithTheme t, String icon, String v, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: t.surface2.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.border),
        ),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(v, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: t.primary)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: t.textDim)),
        ]),
      ),
    );
  }

  void _openEmoji() {
    final t = s.theme;
    const emojis = ['😀','😃','😄','😁','😆','😅','🤣','😂','🙂','🙃','😉','😊',
      '😇','🥰','😍','🤩','😘','😗','😚','😙','😋','😛','😜','🤪','😝','🤗',
      '👍','👎','👌','✌️','🤞','🤟','🤘','🤙','👈','👉','👆','👇','☝️','✋',
      '❤️','🧡','💛','💚','💙','💜','🖤','🤍','💔','💕','💖','💘','💝',
      '🌸','🌹','🌺','🌻','🌷','🍀','🌿','🌱','🌳','🌵','🍁','🍂','🍃',
      '✨','⭐','🌟','💫','⚡','🔥','🌈','☀️','🌙','☁️','🌧️','❄️',
      '🍎','🍊','🍋','🍌','🍉','🍓','🍇','🍒','🍑','🥝','🍕','🍔','🍟','🍩','🍪','🎂','☕','🍵'];

    showModalBottomSheet(
      context: context,
      backgroundColor: t.modalBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: GridView.count(
            crossAxisCount: 8,
            children: emojis.map((e) => GestureDetector(
              onTap: () {
                _input.text += e;
                setState(() {});
              },
              child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
            )).toList(),
          ),
        ),
      ),
    );
  }

  String _formatTime(int ts) {
    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

// ═══════════════════════════════════════════════════════════════
// SVG RENDER — minimal path parser
// ═══════════════════════════════════════════════════════════════
class SvgRender extends StatelessWidget {
  final String svg;
  const SvgRender({super.key, required this.svg});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SvgP(svg),
      size: Size.infinite,
    );
  }
}

class _SvgP extends CustomPainter {
  final String svg;
  _SvgP(this.svg);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 200, size.height / 235);
    _drawPath(canvas, svg);
    _drawCircle(canvas, svg);
    _drawEllipse(canvas, svg);
    _drawRect(canvas, svg);
    _drawPolygon(canvas, svg);
    canvas.restore();
  }

  Map<String, String> _attrs(String s) {
    final re = RegExp(r'([\w-]+)\s*=\s*"([^"]*)"');
    final m = <String, String>{};
    for (final x in re.allMatches(s)) m[x.group(1)!] = x.group(2)!;
    return m;
  }

  Color _color(String? hex) {
    if (hex == null || hex == 'none') return Colors.transparent;
    var h = hex.replaceAll('#', '').trim();
    if (h.length == 3) h = h.split('').map((c) => '$c$c').join();
    if (h.length == 6) h = 'FF$h';
    try { return Color(int.parse(h, radix: 16)); } catch (_) { return Colors.black; }
  }

  void _drawPath(Canvas c, String s) {
    final re = RegExp(r'<path\s+([^/]*?)/>', dotAll: true);
    for (final m in re.allMatches(s)) {
      final a = _attrs(m.group(1)!);
      final d = a['d'];
      if (d == null) continue;
      final p = _parsePath(d);
      if (p == null) continue;
      final fill = a['fill'];
      final stroke = a['stroke'];
      final paint = Paint()..style = fill != null && fill != 'none' ? PaintingStyle.fill : PaintingStyle.stroke;
      paint.color = _color(fill != null && fill != 'none' ? fill : stroke);
      if (stroke != null && fill != null && fill != 'none') {
        // both — draw fill then stroke
      }
      paint.strokeWidth = double.tryParse(a['stroke-width'] ?? '1') ?? 1;
      paint.strokeCap = StrokeCap.round;
      paint.strokeJoin = StrokeJoin.round;
      if (a['opacity'] != null) {
        final o = double.tryParse(a['opacity']!) ?? 1;
        paint.color = paint.color.withValues(alpha: paint.color.a * o);
      }
      c.drawPath(p, paint);
    }
  }

  Path? _parsePath(String d) {
    final p = Path();
    final tokens = RegExp(r'([MLCSQmlcsq])\s*(-?\d*\.?\d+)|(-?\d*\.?\d+)')
        .allMatches(d).map((m) => m.group(0)!.trim()).toList();
    if (tokens.isEmpty) return null;
    var i = 0;
    String cmd = 'M';
    double nx() => double.parse(tokens[i++]);
    bool isCmd(String t) => RegExp(r'^[A-Za-z]$').hasMatch(t);
    p.moveTo(0, 0);
    var started = false;
    while (i < tokens.length) {
      final t = tokens[i];
      if (isCmd(t)) { cmd = t; i++; continue; }
      switch (cmd) {
        case 'M':
          final x = nx(); final y = nx();
          if (!started) { p.moveTo(x, y); started = true; } else { p.lineTo(x, y); }
          break;
        case 'm':
          final x = nx(); final y = nx();
          p.moveTo(x, y); started = true;
          break;
        case 'L':
          p.lineTo(nx(), nx());
          break;
        case 'l':
          p.relativeLineTo(nx(), nx());
          break;
        case 'C':
          p.cubicTo(nx(), nx(), nx(), nx(), nx(), nx());
          break;
        case 'c':
          p.relativeCubicTo(nx(), nx(), nx(), nx(), nx(), nx());
          break;
        case 'Q':
          p.quadraticBezierTo(nx(), nx(), nx(), nx());
          break;
        case 'q':
          p.relativeQuadraticBezierTo(nx(), nx(), nx(), nx());
          break;
        case 'Z':
        case 'z':
          p.close();
          break;
        default:
          i++;
      }
    }
    return started ? p : null;
  }

  void _drawCircle(Canvas c, String s) {
    final re = RegExp(r'<circle\s+([^/]*?)/>', dotAll: true);
    for (final m in re.allMatches(s)) {
      final a = _attrs(m.group(1)!);
      final cx = double.tryParse(a['cx'] ?? '0') ?? 0;
      final cy = double.tryParse(a['cy'] ?? '0') ?? 0;
      final r = double.tryParse(a['r'] ?? '0') ?? 0;
      final paint = Paint()..color = _color(a['fill']);
      c.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  void _drawEllipse(Canvas c, String s) {
    final re = RegExp(r'<ellipse\s+([^/]*?)/>', dotAll: true);
    for (final m in re.allMatches(s)) {
      final a = _attrs(m.group(1)!);
      final cx = double.tryParse(a['cx'] ?? '0') ?? 0;
      final cy = double.tryParse(a['cy'] ?? '0') ?? 0;
      final rx = double.tryParse(a['rx'] ?? '0') ?? 0;
      final ry = double.tryParse(a['ry'] ?? '0') ?? 0;
      final paint = Paint()..color = _color(a['fill']);
      c.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2), paint);
    }
  }

  void _drawRect(Canvas c, String s) {
    final re = RegExp(r'<rect\s+([^/]*?)/>', dotAll: true);
    for (final m in re.allMatches(s)) {
      final a = _attrs(m.group(1)!);
      final x = double.tryParse(a['x'] ?? '0') ?? 0;
      final y = double.tryParse(a['y'] ?? '0') ?? 0;
      final w = double.tryParse(a['width'] ?? '0') ?? 0;
      final h = double.tryParse(a['height'] ?? '0') ?? 0;
      final paint = Paint()..color = _color(a['fill']);
      if (a['opacity'] != null) {
        final o = double.tryParse(a['opacity']!) ?? 1;
        paint.color = paint.color.withValues(alpha: paint.color.a * o);
      }
      c.drawRect(Rect.fromLTWH(x, y, w, h), paint);
    }
  }

  void _drawPolygon(Canvas c, String s) {
    final re = RegExp(r'<polygon\s+([^/]*?)/>', dotAll: true);
    for (final m in re.allMatches(s)) {
      final a = _attrs(m.group(1)!);
      final points = a['points'] ?? '';
      final nums = RegExp(r'-?\d*\.?\d+').allMatches(points)
          .map((x) => double.parse(x.group(0)!)).toList();
      if (nums.length < 4) continue;
      final path = Path()..moveTo(nums[0], nums[1]);
      for (var i = 2; i < nums.length - 1; i += 2) {
        path.lineTo(nums[i], nums[i + 1]);
      }
      path.close();
      final paint = Paint()..color = _color(a['fill']);
      c.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SvgP old) => old.svg != svg;
}

String buildCharacterSvg(CharacterColors c) {
  String hex(Color col) {
    final v = col.value;
    final r = (v >> 16) & 0xFF;
    final g = (v >> 8) & 0xFF;
    final b = v & 0xFF;
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }

  final skin = hex(c.skin);
  final hair = hex(c.hair);
  final hair2 = hex(c.hair2);
  final eye = hex(c.eye);
  final dress = hex(c.dress);
  final acc = hex(c.accessory);

  String back, front;
  switch (c.style) {
    case 1:
      back = '<path d="M55 80 C42 105 40 130 48 150 C58 145 64 128 66 108 Z" fill="$hair"/>'
             '<path d="M145 80 C158 105 160 130 152 150 C142 145 136 128 134 108 Z" fill="$hair"/>';
      front = '<path d="M60 78 C64 46 82 32 100 32 C118 32 136 46 140 78 C133 60 118 48 100 47 C82 48 67 60 60 78 Z" fill="$hair"/>'
              '<path d="M63 68 L137 68 L134 79 L66 79 Z" fill="$hair"/>';
      break;
    case 2:
      back = '<path d="M58 82 C50 100 50 118 56 132 C64 126 68 108 68 92 Z" fill="$hair"/>'
             '<path d="M142 82 C150 100 150 118 144 132 C136 126 132 108 132 92 Z" fill="$hair"/>'
             '<path d="M136 58 C160 70 170 112 154 162 C147 150 141 118 139 88 Z" fill="$hair"/>'
             '<ellipse cx="137" cy="60" rx="6" ry="4" fill="$acc"/>';
      front = '<path d="M62 76 C66 47 82 34 100 34 C118 34 132 47 137 74 C130 58 116 47 100 46 C85 47 69 58 62 76 Z" fill="$hair"/>';
      break;
    case 3:
      back = '<path d="M56 82 C44 104 42 126 50 144 C60 138 65 120 66 104 Z" fill="$hair"/>'
             '<path d="M144 82 C156 104 158 126 150 144 C140 138 135 120 134 104 Z" fill="$hair"/>'
             '<path d="M55 88 C28 92 18 116 28 142 C40 132 49 112 58 96 Z" fill="$hair"/>'
             '<path d="M145 88 C172 92 182 116 172 142 C160 132 151 112 142 96 Z" fill="$hair"/>';
      front = '<path d="M62 76 C66 47 82 34 100 34 C118 34 134 47 138 76 C132 58 116 47 100 46 C84 47 68 58 62 76 Z" fill="$hair"/>';
      break;
    case 4:
      back = '<path d="M53 78 C44 100 50 118 40 140 C50 150 44 170 50 190 C58 175 64 160 58 145 C68 135 60 118 68 100 Z" fill="$hair"/>'
             '<path d="M147 78 C156 100 150 118 160 140 C150 150 156 170 150 190 C142 175 136 160 142 145 C132 135 140 118 132 100 Z" fill="$hair"/>';
      front = '<path d="M62 76 C66 47 82 34 100 34 C118 34 134 47 138 76 C132 58 116 47 100 46 C84 47 68 58 62 76 Z" fill="$hair"/>';
      break;
    case 5:
      back = '<path d="M55 80 C42 105 40 130 48 150 C58 145 64 128 66 108 Z" fill="$hair"/>'
             '<path d="M145 80 C158 105 160 130 152 150 C142 145 136 128 134 108 Z" fill="$hair"/>'
             '<circle cx="100" cy="28" r="15" fill="$hair"/>';
      front = '<path d="M64 76 C68 50 83 38 100 38 C117 38 132 50 136 76 C130 60 116 50 100 49 C84 50 70 60 64 76 Z" fill="$hair"/>';
      break;
    default:
      back = '<path d="M53 78 C37 115 32 168 47 221 L68 221 C63 179 61 137 68 100 Z" fill="$hair"/>'
             '<path d="M147 78 C163 115 168 168 153 221 L132 221 C137 179 139 137 132 100 Z" fill="$hair"/>';
      front = '<path d="M62 76 C66 47 82 34 100 34 C118 34 134 47 138 76 C132 58 116 47 100 46 C84 47 68 58 62 76 Z" fill="$hair"/>'
              '<path d="M68 47 C62 63 59 82 63 95 C67 76 76 62 87 50 Z" fill="$hair"/>'
              '<path d="M132 47 C138 63 141 82 137 95 C133 76 124 62 113 50 Z" fill="$hair"/>';
  }

  return '''
<svg viewBox="0 0 200 235">
  $back
  <path d="M58 158 C74 147 126 147 142 158 L158 221 L42 221 Z" fill="$dress"/>
  <path d="M58 158 C74 147 126 147 142 158 L147 174 C121 163 79 163 53 174 Z" fill="#000000" opacity="0.22"/>
  <rect x="89" y="123" width="22" height="29" fill="$skin"/>
  <rect x="89" y="136" width="22" height="16" fill="#000000" opacity="0.15"/>
  <ellipse cx="100" cy="95" rx="36" ry="42" fill="$skin"/>
  <ellipse cx="79" cy="108" rx="8" ry="5" fill="#ff8fab" opacity="0.3"/>
  <ellipse cx="121" cy="108" rx="8" ry="5" fill="#ff8fab" opacity="0.3"/>
  $front
  <path d="M73 89 Q84 82 96 89 Q84 95 73 89 Z" fill="#fff"/>
  <circle cx="84" cy="89" r="6.3" fill="$eye"/>
  <circle cx="82" cy="86.5" r="1.8" fill="#fff"/>
  <path d="M104 89 Q116 82 127 89 Q116 95 104 89 Z" fill="#fff"/>
  <circle cx="116" cy="89" r="6.3" fill="$eye"/>
  <circle cx="114" cy="86.5" r="1.8" fill="#fff"/>
  <path d="M72 85 Q84 79 97 85" stroke="$hair" stroke-width="1.6" fill="none"/>
  <path d="M103 85 Q116 79 128 85" stroke="$hair" stroke-width="1.6" fill="none"/>
  <path d="M88 117 Q100 122 112 117 Q100 126 88 117 Z" fill="#c96a5e"/>
  <path d="M133 46 Q140 49 147 46 Q140 58 133 46 Z" fill="$acc"/>
</svg>''';
}

// ═══════════════════════════════════════════════════════════════
// NRS SHAPES
// ═══════════════════════════════════════════════════════════════
const kNrsShapes = <String>[
  '<svg viewBox="0 0 100 100"><polygon points="50,5 61,35 95,35 68,57 79,91 50,70 21,91 32,57 5,35 39,35" fill="#FFD700"/></svg>',
  '<svg viewBox="0 0 100 100"><circle cx="50" cy="50" r="45" fill="#FF6BB0"/><circle cx="50" cy="50" r="30" fill="#B06BFF"/></svg>',
  '<svg viewBox="0 0 100 100"><polygon points="50,10 90,90 10,90" fill="#22D3EE"/></svg>',
  '<svg viewBox="0 0 100 100"><rect x="15" y="15" width="70" height="70" fill="#22E06B"/></svg>',
  '<svg viewBox="0 0 100 100"><polygon points="50,5 95,50 50,95 5,50" fill="#FFB84D"/></svg>',
  '<svg viewBox="0 0 100 100"><polygon points="50,8 92,32 92,68 50,92 8,68 8,32" fill="#4D7CFF"/></svg>',
  '<svg viewBox="0 0 100 100"><ellipse cx="50" cy="50" rx="45" ry="30" fill="#FF4D6D"/></svg>',
  '<svg viewBox="0 0 100 100"><polygon points="50,5 95,50 50,95 5,50" fill="#E8E8F2"/><circle cx="50" cy="50" r="15" fill="#0B0B14"/></svg>',
];

// ═══════════════════════════════════════════════════════════════
// WEATHER PAINTER
// ═══════════════════════════════════════════════════════════════
class _WeatherPainter extends CustomPainter {
  final String type;
  _WeatherPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(42);
    final paint = Paint();
    switch (type) {
      case 'rain':
        paint.color = const Color(0xFFAAC8FF).withValues(alpha: 0.5);
        for (var i = 0; i < 80; i++) {
          final x = rnd.nextDouble() * size.width;
          final y = rnd.nextDouble() * size.height;
          canvas.drawLine(Offset(x, y), Offset(x - 2, y + 14), paint..strokeWidth = 1.4);
        }
        break;
      case 'snow':
        paint.color = Colors.white;
        for (var i = 0; i < 60; i++) {
          final x = rnd.nextDouble() * size.width;
          final y = rnd.nextDouble() * size.height;
          canvas.drawCircle(Offset(x, y), 1.5 + rnd.nextDouble() * 1.5, paint);
        }
        break;
      case 'stars':
        paint.color = Colors.white;
        for (var i = 0; i < 50; i++) {
          final x = rnd.nextDouble() * size.width;
          final y = rnd.nextDouble() * size.height;
          canvas.drawCircle(Offset(x, y), 0.8 + rnd.nextDouble() * 1.2, paint);
        }
        break;
      case 'leaves':
        for (var i = 0; i < 30; i++) {
          final c = [const Color(0xFFD97706), const Color(0xFFDC2626), const Color(0xFFEA580C)][i % 3];
          paint.color = c.withValues(alpha: 0.7);
          final x = rnd.nextDouble() * size.width;
          final y = rnd.nextDouble() * size.height;
          canvas.drawCircle(Offset(x, y), 2.5, paint);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherPainter old) => old.type != type;
}