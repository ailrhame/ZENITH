import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final store = await ZenithStore.init();
  runApp(ZenithApp(store: store));
}

// ═══════════════════════════════════════════════════════════════
// THEMES
// ═══════════════════════════════════════════════════════════════
class ZTheme {
  final String id, name;
  final Color bg, surface, surface2, text, textDim, textMuted;
  final Color primary, primary2, botBubble, botText, inputBg;
  final List<Color> userBubble;
  final Color userText, online, danger, border;
  final bool isDark;

  const ZTheme({
    required this.id, required this.name, required this.bg,
    required this.surface, required this.surface2, required this.text,
    required this.textDim, required this.textMuted,
    required this.primary, required this.primary2,
    required this.userBubble, required this.userText,
    required this.botBubble, required this.botText, required this.inputBg,
    required this.online, required this.danger, required this.border,
    required this.isDark,
  });
}

const kThemes = <String, ZTheme>{
  'night': ZTheme(
    id: 'night', name: 'ليلي',
    bg: Color(0xFF0B0B14), surface: Color(0xFF1A1A2E), surface2: Color(0xFF232338),
    text: Color(0xFFE8E8F2), textDim: Color(0xFF8A8AA0), textMuted: Color(0xFF5A5A72),
    primary: Color(0xFFB06BFF), primary2: Color(0xFFFF6BB0),
    userBubble: [Color(0xFFFF6BB0), Color(0xFFB06BFF)], userText: Colors.white,
    botBubble: Color(0xFF232338), botText: Color(0xFFE8E8F2), inputBg: Color(0xFF1A1A2E),
    online: Color(0xFF22E06B), danger: Color(0xFFFF4D6D),
    border: Color(0x12FFFFFF), isDark: true,
  ),
  'day': ZTheme(
    id: 'day', name: 'نهاري',
    bg: Color(0xFFF2F4F8), surface: Colors.white, surface2: Color(0xFFEEF1F6),
    text: Color(0xFF1A1A2E), textDim: Color(0xFF5A5A72), textMuted: Color(0xFF8A8AA0),
    primary: Color(0xFF7A3EE8), primary2: Color(0xFFE83E94),
    userBubble: [Color(0xFFE83E94), Color(0xFF7A3EE8)], userText: Colors.white,
    botBubble: Colors.white, botText: Color(0xFF1A1A2E), inputBg: Color(0xFFF2F4F8),
    online: Color(0xFF12B85A), danger: Color(0xFFE83E5C),
    border: Color(0x14000000), isDark: false,
  ),
  'midnight': ZTheme(
    id: 'midnight', name: 'منتصف الليل',
    bg: Color(0xFF05060D), surface: Color(0xFF0F1428), surface2: Color(0xFF161D36),
    text: Color(0xFFD8E0FF), textDim: Color(0xFF7A86B8), textMuted: Color(0xFF4A5478),
    primary: Color(0xFF4D7CFF), primary2: Color(0xFF6B5CFF),
    userBubble: [Color(0xFF4D7CFF), Color(0xFF22D3EE)], userText: Colors.white,
    botBubble: Color(0xFF161D36), botText: Color(0xFFD8E0FF), inputBg: Color(0xFF0F1428),
    online: Color(0xFF22E0D3), danger: Color(0xFFFF4D6D),
    border: Color(0x1F4D7CFF), isDark: true,
  ),
  'forest': ZTheme(
    id: 'forest', name: 'غابة',
    bg: Color(0xFF0D1410), surface: Color(0xFF16241C), surface2: Color(0xFF1E3126),
    text: Color(0xFFDCEFE0), textDim: Color(0xFF7A9A82), textMuted: Color(0xFF4A6A52),
    primary: Color(0xFF3FB87A), primary2: Color(0xFF7BC74D),
    userBubble: [Color(0xFF3FB87A), Color(0xFFB8D94D)], userText: Color(0xFF0D1410),
    botBubble: Color(0xFF1E3126), botText: Color(0xFFDCEFE0), inputBg: Color(0xFF16241C),
    online: Color(0xFF7BC74D), danger: Color(0xFFE85D5D),
    border: Color(0x1F3FB87A), isDark: true,
  ),
  'sunset': ZTheme(
    id: 'sunset', name: 'غروب',
    bg: Color(0xFF1A0F1E), surface: Color(0xFF2C1832), surface2: Color(0xFF3A2040),
    text: Color(0xFFFFE8F0), textDim: Color(0xFFB88AA0), textMuted: Color(0xFF7A4A60),
    primary: Color(0xFFFF6B6B), primary2: Color(0xFFFFB84D),
    userBubble: [Color(0xFFFF4D9B), Color(0xFFFFB84D)], userText: Colors.white,
    botBubble: Color(0xFF3A2040), botText: Color(0xFFFFE8F0), inputBg: Color(0xFF2C1832),
    online: Color(0xFFFFB84D), danger: Color(0xFFFF4D6D),
    border: Color(0x1FFF6B6B), isDark: true,
  ),
  'ocean': ZTheme(
    id: 'ocean', name: 'محيط',
    bg: Color(0xFF061620), surface: Color(0xFF0E2940), surface2: Color(0xFF153652),
    text: Color(0xFFD4F0FF), textDim: Color(0xFF6FA3C4), textMuted: Color(0xFF3D6682),
    primary: Color(0xFF22D3EE), primary2: Color(0xFF4D7CFF),
    userBubble: [Color(0xFF22D3EE), Color(0xFF4D7CFF)], userText: Color(0xFF061620),
    botBubble: Color(0xFF153652), botText: Color(0xFFD4F0FF), inputBg: Color(0xFF0E2940),
    online: Color(0xFF5EEAD4), danger: Color(0xFFFF6B6B),
    border: Color(0x1F22D3EE), isDark: true,
  ),
  'mono': ZTheme(
    id: 'mono', name: 'أحادي',
    bg: Color(0xFF0A0A0A), surface: Color(0xFF1A1A1A), surface2: Color(0xFF262626),
    text: Color(0xFFF5F5F5), textDim: Color(0xFFA3A3A3), textMuted: Color(0xFF525252),
    primary: Color(0xFFE5E5E5), primary2: Color(0xFFA3A3A3),
    userBubble: [Color(0xFF525252), Color(0xFF262626)], userText: Color(0xFFF5F5F5),
    botBubble: Color(0xFF1A1A1A), botText: Color(0xFFE5E5E5), inputBg: Color(0xFF1A1A1A),
    online: Color(0xFFE5E5E5), danger: Color(0xFFF87171),
    border: Color(0x14FFFFFF), isDark: true,
  ),
  'sakura': ZTheme(
    id: 'sakura', name: 'ساكورا',
    bg: Color(0xFFFFF5F8), surface: Colors.white, surface2: Color(0xFFFFE4EC),
    text: Color(0xFF4A1A2C), textDim: Color(0xFFA8758A), textMuted: Color(0xFFD4A8B8),
    primary: Color(0xFFEC4899), primary2: Color(0xFFF472B6),
    userBubble: [Color(0xFFF472B6), Color(0xFFFB7185)], userText: Colors.white,
    botBubble: Colors.white, botText: Color(0xFF4A1A2C), inputBg: Color(0xFFFFF5F8),
    online: Color(0xFFF472B6), danger: Color(0xFFEF4444),
    border: Color(0x1FEC4899), isDark: false,
  ),
  'cyberpunk': ZTheme(
    id: 'cyberpunk', name: 'سايبربانك',
    bg: Color(0xFF0D0221), surface: Color(0xFF1F0335), surface2: Color(0xFF2A054A),
    text: Color(0xFFFFE8FF), textDim: Color(0xFFB866D4), textMuted: Color(0xFF6D1A8A),
    primary: Color(0xFFFF00AA), primary2: Color(0xFF00FFF7),
    userBubble: [Color(0xFFFF00AA), Color(0xFF00FFF7)], userText: Color(0xFF0D0221),
    botBubble: Color(0xFF2A054A), botText: Color(0xFFFFE8FF), inputBg: Color(0xFF1F0335),
    online: Color(0xFF00FFF7), danger: Color(0xFFFF004D),
    border: Color(0x2EFF00AA), isDark: true,
  ),
  'coffee': ZTheme(
    id: 'coffee', name: 'قهوة',
    bg: Color(0xFF1A120B), surface: Color(0xFF2D1F15), surface2: Color(0xFF3D2A1C),
    text: Color(0xFFF5E6D3), textDim: Color(0xFFA89078), textMuted: Color(0xFF6B5844),
    primary: Color(0xFFD4A574), primary2: Color(0xFFB8763F),
    userBubble: [Color(0xFFB8763F), Color(0xFFD4A574)], userText: Color(0xFF1A120B),
    botBubble: Color(0xFF3D2A1C), botText: Color(0xFFF5E6D3), inputBg: Color(0xFF2D1F15),
    online: Color(0xFFD4A574), danger: Color(0xFFE85D5D),
    border: Color(0x24D4A574), isDark: true,
  ),
};

// ═══════════════════════════════════════════════════════════════
// CHARACTERS
// ═══════════════════════════════════════════════════════════════
class ZChar {
  final int id, style;
  final Color skin, hair, eye, dress, accessory;
  const ZChar(this.id, this.skin, this.hair, this.eye, this.dress, this.accessory, this.style);
}

final kChars = <ZChar>[
  const ZChar(0, Color(0xFFFFE4EC), Color(0xFF8B3A5F), Color(0xFF4FACFE), Color(0xFFA29BFE), Color(0xFFFF8FAB), 0),
  const ZChar(1, Color(0xFFFCD5CE), Color(0xFF333333), Color(0xFF00F2FE), Color(0xFFFF8FAB), Color(0xFFFF6B6B), 1),
  const ZChar(2, Color(0xFFF3C4B3), Color(0xFF6B4423), Color(0xFF8B5A2B), Color(0xFFF7CAE0), Color(0xFF4FACFE), 2),
  const ZChar(3, Color(0xFFE6B999), Color(0xFFE6B800), Color(0xFF2ECC71), Color(0xFFFFC3A0), Color(0xFFF1C40F), 3),
  const ZChar(4, Color(0xFFD4A373), Color(0xFFFF4D4D), Color(0xFFFFA751), Color(0xFF9B59B6), Color(0xFFFD79A8), 4),
  const ZChar(5, Color(0xFFFFD1DC), Color(0xFF4D79FF), Color(0xFF9B59B6), Color(0xFF3498DB), Color(0xFF00CEC9), 5),
  const ZChar(6, Color(0xFFFFB3B3), Color(0xFFD96B8C), Color(0xFFFF6B6B), Color(0xFFE74C3C), Color(0xFF6C5CE7), 0),
  const ZChar(7, Color(0xFFFFE4EC), Color(0xFFCC99FF), Color(0xFF3498DB), Color(0xFF2ECC71), Color(0xFFFDCB6E), 1),
  const ZChar(8, Color(0xFFFCD5CE), Color(0xFF99CCFF), Color(0xFF4FACFE), Color(0xFFF1C40F), Color(0xFFFF8FAB), 2),
  const ZChar(9, Color(0xFFF3C4B3), Color(0xFFFFB3B3), Color(0xFF00F2FE), Color(0xFF95A5A6), Color(0xFFFF6B6B), 3),
  const ZChar(10, Color(0xFFE6B999), Color(0xFF1A1A1A), Color(0xFF8B5A2B), Color(0xFFFFA502), Color(0xFF4FACFE), 4),
  const ZChar(11, Color(0xFFD4A373), Color(0xFFB76E92), Color(0xFF2ECC71), Color(0xFFA29BFE), Color(0xFFF1C40F), 5),
];

// ═══════════════════════════════════════════════════════════════
// KNOWLEDGE ENGINE
// ═══════════════════════════════════════════════════════════════
class QA {
  final String question;
  String answer;
  QA(this.question, this.answer);
  Map<String, dynamic> toJson() => {'q': question, 'a': answer};
}

class Engine {
  final List<QA> items = [];
  int get length => items.length;

  void seed() {
    items.addAll([
      QA('من أنت', 'أنا زوجه علاوي، أتحدث معك وأتعلم من ملفاتك.'),
      QA('كم عمرك', 'عمري 18 سنة! 😄'),
      QA('كيف الحال', 'بخير، شكراً لسؤالك! كيف حالك أنت؟'),
      QA('ما اسمك', 'اسمي زوجه علاوي! 😊'),
      QA('السلام عليكم', 'وعليكم السلام ورحمة الله وبركاته! 😊'),
    ]);
  }

  void load(List list) {
    items.clear();
    for (final e in list) {
      final m = Map<String, dynamic>.from(e);
      items.add(QA(m['q'] ?? '', m['a'] ?? ''));
    }
  }

  List<Map<String, dynamic>> toJson() => items.map((e) => e.toJson()).toList();

  void addQA(String q, String a) {
    final i = items.indexWhere((x) => x.question == q);
    if (i >= 0) items[i].answer = a;
    else items.add(QA(q, a));
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

  static String _norm(String s) => s
      .replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا')
      .replaceAll('ة', 'ه').replaceAll('ى', 'ي').toLowerCase();

  static const Set<String> _stop = {
    'هل','ما','هو','هي','ال','من','في','على','إلى','و','ف','ك','ل',
    'وش','شو','هذا','ذلك','كان','يكون','ايش','حب','عندك','عندي',
    'ليش','بس','كل','نفس','أي','بدي','ابي','كيف','قد','لي','له','لها'
  };

  static List<String> _kw(String text) => _norm(text)
      .split(RegExp(r'[\s،؟!.\-,]+'))
      .where((w) => w.length >= 2 && !_stop.contains(w)).toList();

  String? find(String question) {
    if (items.isEmpty) return null;
    final uk = _kw(question);
    if (uk.isEmpty) return null;

    QA? best;
    double bestScore = 0;
    for (final item in items) {
      final sk = _kw(item.question);
      var hit = 0;
      for (final u in uk) {
        if (sk.any((s) => s == u || s.contains(u) || u.contains(s))) hit++;
      }
      final score = hit / uk.length;
      if (score > bestScore) {
        bestScore = score;
        best = item;
      }
    }
    if (best != null && bestScore >= 0.4) return best.answer;
    return null;
  }
}

// ═══════════════════════════════════════════════════════════════
// STORE
// ═══════════════════════════════════════════════════════════════
class ZenithStore {
  final SharedPreferences prefs;
  final Engine engine = Engine();
  final List<Map<String, dynamic>> messages = [];
  final Map<String, String> userMemory = {};

  String themeId = 'night';
  int charId = 0;
  int coins = 0;
  int xp = 0;
  int level = 1;
  int likes = 0, dislikes = 0, questions = 0;

  ZenithStore(this.prefs);

  static Future<ZenithStore> init() async {
    final p = await SharedPreferences.getInstance();
    final s = ZenithStore(p);
    s.themeId = p.getString('z_theme') ?? 'night';
    s.charId = p.getInt('z_char') ?? 0;
    s.coins = p.getInt('z_coins') ?? 0;
    s.xp = p.getInt('z_xp') ?? 0;
    s.level = p.getInt('z_level') ?? 1;
    s.likes = p.getInt('z_likes') ?? 0;
    s.dislikes = p.getInt('z_dislikes') ?? 0;
    s.questions = p.getInt('z_questions') ?? 0;

    final kb = p.getString('z_engine');
    if (kb != null) {
      try {
        s.engine.load(jsonDecode(kb) as List);
      } catch (_) {
        s.engine.seed();
      }
    } else {
      s.engine.seed();
    }

    final msgs = p.getString('z_messages');
    if (msgs != null) {
      try {
        for (final m in jsonDecode(msgs) as List) {
          s.messages.add(Map<String, dynamic>.from(m));
        }
      } catch (_) {}
    }

    final um = p.getString('z_memory');
    if (um != null) {
      try {
        s.userMemory.addAll(Map<String, String>.from(jsonDecode(um)));
      } catch (_) {}
    }

    return s;
  }

  Future<void> save() async {
    await prefs.setString('z_theme', themeId);
    await prefs.setInt('z_char', charId);
    await prefs.setInt('z_coins', coins);
    await prefs.setInt('z_xp', xp);
    await prefs.setInt('z_level', level);
    await prefs.setInt('z_likes', likes);
    await prefs.setInt('z_dislikes', dislikes);
    await prefs.setInt('z_questions', questions);
    await prefs.setString('z_engine', jsonEncode(engine.toJson()));
    await prefs.setString('z_messages', jsonEncode(messages));
    await prefs.setString('z_memory', jsonEncode(userMemory));
  }

  ZTheme get theme => kThemes[themeId] ?? kThemes['night']!;
  ZChar get character => kChars[charId % kChars.length];
}

// ═══════════════════════════════════════════════════════════════
// ROOT APP
// ═══════════════════════════════════════════════════════════════
class ZenithApp extends StatefulWidget {
  final ZenithStore store;
  const ZenithApp({super.key, required this.store});
  @override
  State<ZenithApp> createState() => _ZenithAppState();
}

class _ZenithAppState extends State<ZenithApp> {
  ZenithStore get s => widget.store;

  @override
  Widget build(BuildContext context) {
    final t = s.theme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZENITH',
      theme: ThemeData(
        brightness: t.isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: t.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: t.primary,
          brightness: t.isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      builder: (ctx, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: ChatPage(store: s, onChanged: () => setState(() {})),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CHAT PAGE
// ═══════════════════════════════════════════════════════════════
class ChatPage extends StatefulWidget {
  final ZenithStore store;
  final VoidCallback onChanged;
  const ChatPage({super.key, required this.store, required this.onChanged});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  ZenithStore get s => widget.store;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;

    s.messages.add({
      'sender': 'user',
      'text': text,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
    _input.clear();
    setState(() {});
    _scrollBottom();

    await Future.delayed(const Duration(milliseconds: 400));

    String? reply;
    final n = text.replaceAll('أ', 'ا').replaceAll('ة', 'ه');

    if (n.contains('السلام عليكم')) {
      reply = 'وعليكم السلام ورحمة الله وبركاته! 😊';
    } else if (n.contains('شكرا')) {
      reply = 'العفو! 💖';
    } else if (n.contains('اسمي') || n.contains('اتصل بي')) {
      final name = text.replaceAll(RegExp(r'اسمي|اتصل بي'), '').trim();
      if (name.isNotEmpty) {
        s.userMemory['name'] = name;
        reply = 'تشرفت بمعرفتك يا $name! 😊';
      }
    } else if (n.contains('ماذا تعرف عني')) {
      if (s.userMemory.isEmpty) {
        reply = 'لا أعرف شيئاً عنك بعد.';
      } else {
        reply = 'أعرف: ${s.userMemory.entries.map((e) => '${e.key}=${e.value}').join(', ')}';
      }
    } else {
      final teach = RegExp(r'تعلّم:\s*(.+?)\s*=\s*(.+)').firstMatch(text);
      if (teach != null) {
        s.engine.addQA(teach.group(1)!.trim(), teach.group(2)!.trim());
        reply = '✅ تم الحفظ!';
      } else {
        reply = s.engine.find(text);
      }
    }

    if (reply == null) {
      reply = 'آسف، ما عندي جواب 🤔 علّمني: اكتب "تعلّم: [السؤال] = [الجواب]"';
    }

    s.questions++;
    s.xp += 5;
    if (s.xp >= s.level * 100) {
      s.level++;
      s.xp = 0;
    }

    s.messages.add({
      'sender': 'bot',
      'text': reply,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
    await s.save();
    setState(() {});
    _scrollBottom();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final t = s.theme;
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(t),
            _statsBar(t),
            Expanded(child: _chatList(t)),
            _composer(t),
          ],
        ),
      ),
    );
  }

  Widget _topBar(ZTheme t) => Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: t.surface,
          border: Border(bottom: BorderSide(color: t.border)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
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
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: t.text)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                            color: t.online, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Text('متصل الآن',
                          style: TextStyle(fontSize: 11, color: t.textDim)),
                    ],
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: _openSettings,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: t.surface2.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.more_vert, color: t.text, size: 18),
              ),
            ),
          ],
        ),
      );

  Widget _statsBar(ZTheme t) {
    Widget chip(IconData i, Color c, String text) => Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: t.surface2.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: t.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(i, size: 13, color: c),
              const SizedBox(width: 6),
              Text(text,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: t.text)),
            ],
          ),
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
        child: Row(
          children: [
            chip(Icons.star, t.primary2, '${s.xp} XP'),
            chip(Icons.monetization_on, const Color(0xFFFFB84D), '${s.coins}'),
            chip(Icons.workspace_premium, t.primary2, 'LEVEL ${s.level}'),
          ],
        ),
      ),
    );
  }

  Widget _chatList(ZTheme t) {
    if (s.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💬', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'ابدأ المحادثة\nجرّب: "السلام عليكم"',
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
      itemCount: s.messages.length,
      itemBuilder: (_, i) {
        final m = s.messages[i];
        final isUser = m['sender'] == 'user';
        final ts = DateTime.fromMillisecondsSinceEpoch(m['ts'] ?? 0);
        final time =
            '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';

        return Align(
          alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.82),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            decoration: BoxDecoration(
              gradient: isUser ? LinearGradient(colors: t.userBubble) : null,
              color: isUser ? null : t.botBubble,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 6 : 20),
                bottomRight: Radius.circular(isUser ? 20 : 6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m['text'] ?? '',
                  style: TextStyle(
                    color: isUser ? t.userText : t.botText,
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isUser ? Colors.white70 : t.textMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _composer(ZTheme t) => Container(
        padding: EdgeInsets.fromLTRB(
            12, 10, 12, 10 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: t.surface,
          border: Border(top: BorderSide(color: t.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: t.inputBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: t.border),
                ),
                child: TextField(
                  controller: _input,
                  maxLines: 4,
                  minLines: 1,
                  style: TextStyle(color: t.text, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك...',
                    hintStyle: TextStyle(color: t.textMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _send,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [t.primary2, t.primary]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      );

  void _openSettings() {
    final t = s.theme;
    showModalBottomSheet(
      context: context,
      backgroundColor: t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          builder: (_, ctrl) => ListView(
            controller: ctrl,
            padding: const EdgeInsets.all(18),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: t.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('الإعدادات',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: t.text)),
              const SizedBox(height: 16),
              _sectionTitle('الثيمات', t),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kThemes.entries.map((e) {
                  return GestureDetector(
                    onTap: () {
                      s.themeId = e.key;
                      s.save();
                      setState(() {});
                      widget.onChanged();
                    },
                    child: Container(
                      width: 90,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [e.value.primary, e.value.primary2]),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: s.themeId == e.key
                              ? t.text
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.all(6),
                      child: Text(
                        e.value.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              _sectionTitle('الشخصية', t),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kChars.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () {
                      s.charId = i;
                      s.save();
                      setState(() {});
                      widget.onChanged();
                    },
                    child: Container(
                      width: 70,
                      decoration: BoxDecoration(
                        color: t.surface2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: s.charId == i ? t.primary : t.border,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: CustomPaint(painter: _CharPainter(kChars[i])),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _sectionTitle('الذاكرة', t),
              ListTile(
                leading: Icon(Icons.info, color: t.primary),
                title: Text(
                  '${s.engine.length} سؤال/جواب',
                  style: TextStyle(color: t.text, fontSize: 13),
                ),
              ),
              ListTile(
                leading: Icon(Icons.delete_forever, color: t.danger),
                title: Text(
                  'مسح الذاكرة',
                  style: TextStyle(
                    color: t.danger,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () {
                  s.engine.clear();
                  s.engine.seed();
                  s.save();
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.restart_alt, color: t.danger),
                title: Text(
                  'إعادة ضبط كامل',
                  style: TextStyle(
                    color: t.danger,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () async {
                  await s.prefs.clear();
                  s.messages.clear();
                  s.engine.clear();
                  s.engine.seed();
                  s.coins = 0;
                  s.xp = 0;
                  s.level = 1;
                  s.likes = 0;
                  s.dislikes = 0;
                  s.questions = 0;
                  s.userMemory.clear();
                  s.themeId = 'night';
                  s.charId = 0;
                  await s.save();
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, ZTheme t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: t.textDim,
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
// CHARACTER PAINTER
// ═══════════════════════════════════════════════════════════════
class _CharPainter extends CustomPainter {
  final ZChar c;
  _CharPainter(this.c);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200;
    canvas.scale(scale, scale);

    final skin = Paint()..color = c.skin;
    final hair = Paint()..color = c.hair;
    final dress = Paint()..color = c.dress;
    final eye = Paint()..color = c.eye;
    final acc = Paint()..color = c.accessory;
    final white = Paint()..color = Colors.white;

    final backHair = Path()
      ..moveTo(53, 78)
      ..cubicTo(37, 115, 32, 168, 47, 221)
      ..lineTo(68, 221)
      ..cubicTo(63, 179, 61, 137, 68, 100)
      ..close();
    canvas.drawPath(backHair, hair);

    final backHair2 = Path()
      ..moveTo(147, 78)
      ..cubicTo(163, 115, 168, 168, 153, 221)
      ..lineTo(132, 221)
      ..cubicTo(137, 179, 139, 137, 132, 100)
      ..close();
    canvas.drawPath(backHair2, hair);

    final dressPath = Path()
      ..moveTo(58, 158)
      ..cubicTo(74, 147, 126, 147, 142, 158)
      ..lineTo(158, 221)
      ..lineTo(42, 221)
      ..close();
    canvas.drawPath(dressPath, dress);

    canvas.drawRect(Rect.fromLTWH(89, 123, 22, 29), skin);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 95), width: 72, height: 84),
      skin,
    );

    final blush = Paint()..color = const Color(0xFFFF8FAB).withOpacity(0.3);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(79, 108), width: 16, height: 10),
      blush,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(121, 108), width: 16, height: 10),
      blush,
    );

    final front = Path()
      ..moveTo(62, 76)
      ..cubicTo(66, 47, 82, 34, 100, 34)
      ..cubicTo(118, 34, 134, 47, 138, 76)
      ..cubicTo(132, 58, 116, 47, 100, 46)
      ..cubicTo(84, 47, 68, 58, 62, 76)
      ..close();
    canvas.drawPath(front, hair);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(84, 89), width: 12, height: 10),
      white,
    );
    canvas.drawCircle(const Offset(84, 89), 6.3, eye);
    canvas.drawCircle(const Offset(82, 86.5), 1.8, white);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(116, 89), width: 12, height: 10),
      white,
    );
    canvas.drawCircle(const Offset(116, 89), 6.3, eye);
    canvas.drawCircle(const Offset(114, 86.5), 1.8, white);

    final mouth = Paint()..color = const Color(0xFFC96A5E);
    final mouthPath = Path()
      ..moveTo(88, 117)
      ..quadraticBezierTo(100, 122, 112, 117)
      ..quadraticBezierTo(100, 126, 88, 117)
      ..close();
    canvas.drawPath(mouthPath, mouth);

    final accPath = Path()
      ..moveTo(133, 46)
      ..quadraticBezierTo(140, 49, 147, 46)
      ..quadraticBezierTo(140, 58, 133, 46)
      ..close();
    canvas.drawPath(accPath, acc);
  }

  @override
  bool shouldRepaint(covariant _CharPainter old) => old.c.id != c.id;
}