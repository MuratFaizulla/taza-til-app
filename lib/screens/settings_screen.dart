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

          // ── Streak тесті ──────────────────────────────────────────────────
          _sectionHeader('🔧 Streak тесті', Icons.science_outlined, Colors.orange),
          const SizedBox(height: 8),
          _buildCard([
            Obx(() => SwitchListTile(
              title: const Text('Тест режимі',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                controller.testModeEnabled.value
                    ? 'Қосулы — streak қолмен орнатылады'
                    : 'Өшірулі — нақты streak қолданылады',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              secondary: Icon(
                controller.testModeEnabled.value
                    ? Icons.bug_report
                    : Icons.bug_report_outlined,
                color: Colors.orange,
              ),
              value: controller.testModeEnabled.value,
              activeTrackColor: Colors.orange,
              onChanged: controller.toggleTestMode,
            )),
            Obx(() {
              if (!controller.testModeEnabled.value) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 6),
                      Text('Нақты streak: ${controller.streak.value} күн',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      const Spacer(),
                      GestureDetector(
                        onTap: controller.debugResetStreak,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: const Text('Reset',
                              style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          '${controller.testStreakDays.value} күн',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.orange),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: controller.debugResetStreak,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                            ),
                            child: const Text('Reset',
                                style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: controller.testStreakDays.value.toDouble(),
                      min: 1,
                      max: 365,
                      divisions: 364,
                      activeColor: Colors.orange,
                      label: '${controller.testStreakDays.value} күн',
                      onChanged: (v) => controller.setTestStreakDays(v.round()),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ['1', '7', '30', '100', '365'].map((d) =>
                        GestureDetector(
                          onTap: () => controller.setTestStreakDays(int.parse(d)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                            ),
                            child: Text('$d күн',
                                style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ).toList(),
                    ),
                  ],
                ),
              );
            }),
          ]),
          const SizedBox(height: 20),

          // ── TTS Settings ──────────────────────────────────────────────────
          _sectionHeader('🔊 Дыбыс баптаулары', Icons.volume_up_outlined,
              Colors.blue),
          const SizedBox(height: 8),
          _buildCard([
            // ── Speed ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.speed, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text('Сөйлеу жылдамдығы',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const Spacer(),
                      Obx(() => Text(
                            '${(controller.ttsSpeed.value * 2).toStringAsFixed(1)}x',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.blue,
                                fontSize: 14),
                          )),
                    ],
                  ),
                  Obx(() => Slider(
                        value: controller.ttsSpeed.value,
                        min: 0.1,
                        max: 1.0,
                        divisions: 18,
                        activeColor: Colors.blue,
                        onChanged: (v) => controller.setTtsSpeed(v),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ttsPresetBtn('🐢 Баяу', 0.25, Colors.blue,
                          () => controller.setTtsSpeed(0.25)),
                      _ttsPresetBtn('🚶 Қалыпты', 0.5, Colors.blue,
                          () => controller.setTtsSpeed(0.5)),
                      _ttsPresetBtn('🚀 Жылдам', 0.9, Colors.blue,
                          () => controller.setTtsSpeed(0.9)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),

            // ── Pitch ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.graphic_eq,
                          size: 16, color: Colors.purple),
                      const SizedBox(width: 8),
                      const Text('Дауыс биіктігі (Pitch)',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const Spacer(),
                      Obx(() => Text(
                            '${controller.ttsPitch.value.toStringAsFixed(1)}x',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.purple,
                                fontSize: 14),
                          )),
                    ],
                  ),
                  Obx(() => Slider(
                        value: controller.ttsPitch.value,
                        min: 0.5,
                        max: 2.0,
                        divisions: 15,
                        activeColor: Colors.purple,
                        onChanged: (v) => controller.setTtsPitch(v),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ttsPresetBtn('🎵 Төмен', 0.75, Colors.purple,
                          () => controller.setTtsPitch(0.75)),
                      _ttsPresetBtn('🎤 Қалыпты', 1.0, Colors.purple,
                          () => controller.setTtsPitch(1.0)),
                      _ttsPresetBtn('🎶 Жоғары', 1.5, Colors.purple,
                          () => controller.setTtsPitch(1.5)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),

            // ── Voice picker ─────────────────────────────────────────────────
            Obx(() {
              final hasVoices = controller.availableVoices.isNotEmpty;
              final locale = controller.ttsLanguage.value;
              final voiceName = controller.ttsVoiceName.value;
              final label = voiceName.isNotEmpty ? voiceName : locale;
              final localeFlag = locale.startsWith('kk')
                  ? '🇰🇿'
                  : locale.startsWith('tr')
                      ? '🇹🇷'
                      : locale.startsWith('ru')
                          ? '🇷🇺'
                          : locale.startsWith('en')
                              ? '🇺🇸'
                              : '🔊';

              if (!hasVoices) {
                // Web / platform has no voice list — show informational tile
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('🔊',
                        style: TextStyle(fontSize: 18)),
                  ),
                  title: const Text('Дауыс таңдау',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey)),
                  subtitle: const Text(
                    '📱 Мобильді қосымшада қолжетімді',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    child: const Text('Браузер',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600)),
                  ),
                  enabled: false,
                );
              }

              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(localeFlag,
                      style: const TextStyle(fontSize: 18)),
                ),
                title: const Text('Дауыс таңдау',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  label.isNotEmpty ? label : 'Жүктелуде...',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${controller.availableVoices.length}',
                        style: const TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: Colors.blue),
                  ],
                ),
                onTap: () => _showVoicePicker(context),
              );
            }),
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
            // App logo + version
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, const Color(0xFF1B5E20)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('ТТ',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
              ),
              title: const Text('Таза Тіл',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              subtitle: const Text('Нұсқа 2.0.0  •  2025'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Stable',
                    style: TextStyle(
                        fontSize: 10,
                        color: primary,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),

            // Mission
            ListTile(
              leading: Icon(Icons.translate, color: primary),
              title: const Text('Мақсат',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text(
                'Қазақ тіліндегі орыс калькаларын анықтап, '
                'таза қазақша баламаларын ұсыну.',
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
                _changelogItem(context, 'v2.0.0', '2025',
                    ['🔥 Live fire streak анимациясы',
                     '🤖 Groq AI талдауы (Llama 3.3)',
                     '📊 Дыбыс жылдамдығы баптаулары',
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

  // ── TTS preset button ────────────────────────────────────────────────────
  Widget _ttsPresetBtn(
      String label, double value, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
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

  // ── Voice picker bottom sheet ─────────────────────────────────────────────
  void _showVoicePicker(BuildContext context) {
    final voices = controller.availableVoices;
    if (voices.isEmpty) return; // tile is disabled when empty — guard only
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          maxChildSize: 0.85,
          builder: (_, scrollCtrl) {
            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      const Text('🔊',
                          style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Дауыс таңдау',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16)),
                            Text('Барлық қолжетімді дауыстар',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      IconButton(
                          onPressed: Get.back,
                          icon: const Icon(Icons.close)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    itemCount: voices.length,
                    itemBuilder: (_, i) {
                      final v = voices[i];
                      final name = v['name']?.toString() ?? '';
                      final locale = v['locale']?.toString() ?? '';
                      final flag = locale.startsWith('kk')
                          ? '🇰🇿'
                          : locale.startsWith('tr')
                              ? '🇹🇷'
                              : locale.startsWith('ru')
                                  ? '🇷🇺'
                                  : locale.startsWith('en')
                                      ? '🇺🇸'
                                      : locale.startsWith('de')
                                          ? '🇩🇪'
                                          : locale.startsWith('fr')
                                              ? '🇫🇷'
                                              : '🌐';
                      final isSelected =
                          controller.ttsVoiceName.value == name;
                      return ListTile(
                        leading: Text(flag,
                            style: const TextStyle(fontSize: 24)),
                        title: Text(name,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        subtitle: Text(locale,
                            style: const TextStyle(fontSize: 11)),
                        trailing: isSelected
                            ? Icon(Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary)
                            : null,
                        tileColor: isSelected
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.06)
                            : null,
                        onTap: () {
                          controller.setTtsVoice(v);
                          Get.back();
                          Get.snackbar('✓ Дауыс таңдалды', name,
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2));
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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

  // ignore: unused_element
  Widget _streakTestBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
