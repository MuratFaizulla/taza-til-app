import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('ТТ',
                    style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
              ),
              title: const Text('Таза Тіл',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Нұсқа 2.0.0'),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: Icon(Icons.translate, color: primary),
              title: const Text('Мақсат'),
              subtitle: const Text(
                'Қазақ тіліндегі орыс калькаларын анықтап, '
                'таза қазақша баламаларын ұсыну.',
                style: TextStyle(fontSize: 12),
              ),
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
}
