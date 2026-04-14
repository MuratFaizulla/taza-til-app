import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/word_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final WordController controller = Get.find<WordController>();
  late final TextEditingController _claudeKeyCtrl;
  late final TextEditingController _grokKeyCtrl;
  bool _obscureClaude = true;
  bool _obscureGrok = true;

  @override
  void initState() {
    super.initState();
    _claudeKeyCtrl = TextEditingController(text: controller.claudeApiKey.value);
    _grokKeyCtrl = TextEditingController(text: controller.grokApiKey.value);
  }

  @override
  void dispose() {
    _claudeKeyCtrl.dispose();
    _grokKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Баптаулар'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Appearance ────────────────────────────────────────────────────
          _sectionHeader('Көрініс', Icons.palette_outlined, primary),
          const SizedBox(height: 8),
          _buildCard([
            Obx(() => SwitchListTile(
                  title: const Text('Қараңғы тақырып',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text('Қараңғы режимге ауысу'),
                  secondary: Icon(
                    controller.isDarkMode.value
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: primary,
                  ),
                  value: controller.isDarkMode.value,
                  activeTrackColor: primary,
                  onChanged: (_) => controller.toggleDarkMode(),
                )),
          ]),

          const SizedBox(height: 20),

          // ── AI Provider ───────────────────────────────────────────────────
          _sectionHeader(
              'Жасанды интеллект', Icons.psychology_outlined, primary),
          const SizedBox(height: 8),
          _buildCard([
            // Provider selector
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI Провайдері',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 10),
                  Obx(() => Row(
                        children: [
                          _providerChip(
                            label: 'Claude',
                            logo: '🤖',
                            subtitle: 'Anthropic',
                            value: 'claude',
                            primary: primary,
                          ),
                          const SizedBox(width: 10),
                          _providerChip(
                            label: 'Grok',
                            logo: '⚡',
                            subtitle: 'xAI',
                            value: 'grok',
                            primary: primary,
                          ),
                        ],
                      )),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),

            // Claude key
            _keySection(
              context: context,
              title: 'Claude API кілті',
              hint: 'sk-ant-api03-...',
              logo: '🤖',
              docsNote: 'console.anthropic.com',
              ctrl: _claudeKeyCtrl,
              obscure: _obscureClaude,
              onToggleObscure: () =>
                  setState(() => _obscureClaude = !_obscureClaude),
              hasKey: controller.claudeApiKey.value.isNotEmpty,
              onSave: () {
                controller.saveClaudeApiKey(_claudeKeyCtrl.text);
                _showSaved(primary);
              },
              primary: primary,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),

            // Grok key
            _keySection(
              context: context,
              title: 'Grok API кілті',
              hint: 'xai-...',
              logo: '⚡',
              docsNote: 'console.x.ai',
              ctrl: _grokKeyCtrl,
              obscure: _obscureGrok,
              onToggleObscure: () =>
                  setState(() => _obscureGrok = !_obscureGrok),
              hasKey: controller.grokApiKey.value.isNotEmpty,
              onSave: () {
                controller.saveGrokApiKey(_grokKeyCtrl.text);
                _showSaved(primary);
              },
              primary: primary,
            ),
          ]),

          const SizedBox(height: 20),

          // ── Font Size ─────────────────────────────────────────────────────
          _sectionHeader('🔤 Қаріп өлшемі', Icons.text_fields_outlined,
              Colors.teal),
          const SizedBox(height: 8),
          _buildCard([
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _fontSizeBtn(
                              context, 'Аа', 'Кіші', 0.85, Colors.teal)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _fontSizeBtn(
                              context, 'Аа', 'Орташа', 1.0, Colors.teal)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _fontSizeBtn(
                              context, 'Аа', 'Үлкен', 1.15, Colors.teal)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Live preview
                  Obx(() => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.teal.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'Мысал: Таза тіл — ұлт тілі 🇰🇿',
                          style: TextStyle(
                            fontSize: 15 * controller.fontScale.value,
                            color: Colors.teal[700],
                            fontWeight: FontWeight.w500,
                          ),
                          textScaler: TextScaler.noScaling,
                        ),
                      )),
                ],
              ),
            ),
          ]),

          const SizedBox(height: 20),

          // ── Statistics ────────────────────────────────────────────────────
          _sectionHeader('Статистика', Icons.bar_chart_outlined, primary),
          const SizedBox(height: 8),
          _buildCard([
            Obx(() => _statTile(
                  Icons.favorite,
                  'Таңдаулы сөздер',
                  '${controller.favoritesCount}',
                  Colors.red,
                )),
            const Divider(height: 1, indent: 16, endIndent: 16),
            Obx(() => _statTile(
                  Icons.emoji_events,
                  'Ең жоғары нәтиже',
                  '${controller.bestScore.value}/10',
                  Colors.amber,
                )),
            const Divider(height: 1, indent: 16, endIndent: 16),
            // ✅ Fixed: use Get.find() instead of WordController()
            _statTile(
              Icons.menu_book,
              'Жалпы сөздер',
              '${controller.allWords.length}',
              primary,
            ),
          ]),

          const SizedBox(height: 20),

          // ── History ───────────────────────────────────────────────────────
          _sectionHeader('Тарих', Icons.history_outlined, primary),
          const SizedBox(height: 8),
          _buildCard([
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red[400]),
              title: const Text('Тексеру тарихын тазарту'),
              onTap: () => Get.dialog(AlertDialog(
                title: const Text('Тарихты жою'),
                content: const Text(
                    'Барлық тексеру тарихы жойылады. Растайсыз ба?'),
                actions: [
                  TextButton(
                      onPressed: Get.back,
                      child: const Text('Болдырмау')),
                  TextButton(
                    onPressed: () {
                      controller.clearHistory();
                      Get.back();
                    },
                    child: Text('Жою',
                        style: TextStyle(color: Colors.red[400])),
                  ),
                ],
              )),
            ),
          ]),

          const SizedBox(height: 20),

          // ── About ─────────────────────────────────────────────────────────
          _sectionHeader('Қосымша туралы', Icons.info_outline, primary),
          const SizedBox(height: 8),
          _buildCard([
            // ── App header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
                  // Logo + title row
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primary, const Color(0xFF1B5E20)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('ТТ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Таза Тіл',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('v3.0.0',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: primary,
                                          fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Stable',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 6),
                                Text('2025',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[400])),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: primary.withValues(alpha: 0.15)),
                    ),
                    child: const Text(
                      'Таза Тіл — қазақ тіліндегі орыс калькаларын '
                      'анықтауға арналған қосымша. Сөздікте 1 700-ден '
                      'астам қате қолданыс пен оның дұрыс баламасы бар. '
                      'Claude және Grok жасанды интеллекті арқылы '
                      'кез келген мәтінді талдап, калькаларды автоматты '
                      'түрде анықтайды.',
                      style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Colors.black87),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Stats row
                  Row(
                    children: [
                      _aboutStat('1 748', 'сөз базасы', primary),
                      _vDivider(),
                      _aboutStat('2', 'AI модель', Colors.deepPurple),
                      _vDivider(),
                      _aboutStat('5', 'санат', Colors.teal),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),

            // AI providers
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('🤖', style: TextStyle(fontSize: 18)),
              ),
              title: const Text('Жасанды интеллект',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text(
                'Claude (Anthropic) · Grok (xAI)\n'
                'Мәтін талдауы және калька анықтауы',
                style: TextStyle(fontSize: 12, height: 1.5),
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),

            // Mission
            ListTile(
              leading: Icon(Icons.translate, color: primary),
              title: const Text('Мақсат',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text(
                'Қазақ тілін орыс калькаларынан тазартып, '
                'ана тілімізді байыту және дамыту.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),

            // Share app
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.share, color: Colors.blue, size: 20),
              ),
              title: const Text('Қосымшаны бөлісу',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('Достарыңмен бөліс',
                  style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.blue),
              onTap: () {
                Share.share(
                  '📱 Таза Тіл — қазақ тілін тазартатын қосымша!\n\n'
                  'Қазақ мәтіндеріндегі орыс калькаларын анықтайды '
                  'және AI арқылы талдайды.\n\n'
                  '🔗 #ТазаТіл #ҚазақТілі',
                );
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),

            // GitHub
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.code, color: Colors.black87, size: 20),
              ),
              title: const Text('GitHub',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('Бастапқы код',
                  style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.copy, size: 16, color: Colors.grey),
              onTap: () {
                // Copy GitHub URL to clipboard
                _copyToClipboard(
                    context, 'https://github.com/yourusername/taza-til');
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),

            // Changelog
            ExpansionTile(
              leading: Icon(Icons.history, color: primary),
              title: const Text('Жаңартулар тарихы',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              children: [
                _changelogItem(context, 'v3.0.0', '2025',
                    ['📚 1 748 жаңа калька сөз базасы',
                     '⚡ Grok AI (xAI) қолдауы қосылды',
                     '🤖 Claude + Grok провайдер таңдауы',
                     '❌✅ Карточкаларда emoji белгілері',
                     '🧹 Сөз базасы толық жаңартылды']),
                _changelogItem(context, 'v2.0.0', '2025',
                    ['🔥 Live fire streak анимациясы',
                     '🤖 Claude AI талдауы',
                     '🔤 Қаріп өлшемін реттеу',
                     '💾 ЖИ тарихын сақтау']),
                _changelogItem(context, 'v1.0.0', '2024',
                    ['🌱 Бастапқы нұсқа',
                     '📚 76 калька сөз базасы',
                     '🎮 Күнделікті квиз',
                     '🔍 Анықтаушы беті']),
              ],
            ),
          ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _providerChip({
    required String label,
    required String logo,
    required String subtitle,
    required String value,
    required Color primary,
  }) {
    final selected =
        controller.selectedAIProvider.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setAIProvider(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? primary.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? primary : Colors.grey.withValues(alpha: 0.3),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(logo, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: selected ? primary : null)),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _keySection({
    required BuildContext context,
    required String title,
    required String hint,
    required String logo,
    required String docsNote,
    required TextEditingController ctrl,
    required bool obscure,
    required VoidCallback onToggleObscure,
    required bool hasKey,
    required VoidCallback onSave,
    required Color primary,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(logo, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            if (hasKey) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Бар',
                    style: TextStyle(
                        fontSize: 10,
                        color: primary,
                        fontWeight: FontWeight.w600)),
              ),
            ],
            const Spacer(),
            Text(docsNote,
                style: TextStyle(fontSize: 10, color: Colors.grey[400])),
          ]),
          const SizedBox(height: 10),
          TextField(
            controller: ctrl,
            obscureText: obscure,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              suffixIcon: IconButton(
                icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    size: 18),
                onPressed: onToggleObscure,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save, size: 16),
              label: const Text('Сақтау'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSaved(Color primary) {
    Get.snackbar(
      'Сақталды ✓',
      'API кілті сәтті сақталды',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: primary,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      duration: const Duration(seconds: 2),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 6),
      Text(title.toUpperCase(),
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.8)),
    ]);
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      margin: EdgeInsets.zero,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _statTile(
      IconData icon, String label, String value, Color color) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 14)),
      ),
    );
  }

  // ── Font size button ─────────────────────────────────────────────────────
  Widget _fontSizeBtn(BuildContext context, String sample, String label,
      double scale, Color color) {
    return Obx(() {
      final selected = (controller.fontScale.value - scale).abs() < 0.01;
      return GestureDetector(
        onTap: () => controller.setFontScale(scale),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? color : Colors.grey.withValues(alpha: 0.3),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(sample,
                  style: TextStyle(
                      fontSize: 10 + (scale - 0.85) * 30,
                      fontWeight: FontWeight.w700,
                      color: selected ? color : Colors.grey[500]),
                  textScaler: TextScaler.noScaling),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: selected ? color : Colors.grey[400],
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w400),
                  textScaler: TextScaler.noScaling),
            ],
          ),
        ),
      );
    });
  }

  // ── Clipboard helper ─────────────────────────────────────────────────────
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      '📋 Көшірілді',
      text,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
    );
  }

  // ── About stat cell ──────────────────────────────────────────────────────
  Widget _aboutStat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1, height: 36,
        color: Colors.grey.withValues(alpha: 0.2),
      );

  // ── Changelog tile ───────────────────────────────────────────────────────
  Widget _changelogItem(BuildContext context, String version, String date,
      List<String> items) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(version,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary)),
              ),
              const SizedBox(width: 8),
              Text(date,
                  style: TextStyle(fontSize: 11, color: Colors.grey[400])),
            ],
          ),
          const SizedBox(height: 6),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(item,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              )),
        ],
      ),
    );
  }

}
