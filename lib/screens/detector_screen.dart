import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/word_controller.dart';
import '../widgets/word_card.dart';

class DetectorScreen extends StatefulWidget {
  const DetectorScreen({super.key});

  @override
  State<DetectorScreen> createState() => _DetectorScreenState();
}

class _DetectorScreenState extends State<DetectorScreen> {
  final WordController controller = Get.find<WordController>();
  final TextEditingController _textController = TextEditingController();
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _textController.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInput(),
              const SizedBox(height: 16),
              Obx(() {
                final text = controller.detectorText.value;
                if (text.trim().isEmpty) return _buildHint();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHighlightPreview(text),
                    const SizedBox(height: 16),
                    _buildDetectedSection(text),
                    const SizedBox(height: 16),
                    _buildAISection(text),
                    const SizedBox(height: 16),
                    _buildHistorySection(),
                    const SizedBox(height: 40),
                  ],
                );
              }),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 20,
            colors: const [
              Color(0xFF2E7D32), Colors.white, Colors.lightGreen
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInput() {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Мәтін енгізіңіз',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: primary)),
        const SizedBox(height: 4),
        Text('Калька сөздер автоматты белгіленеді',
            style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        const SizedBox(height: 10),
        Card(
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              TextField(
                controller: _textController,
                maxLines: 5,
                minLines: 4,
                onChanged: controller.updateDetectorText,
                style: const TextStyle(fontSize: 15, height: 1.5),
                decoration: InputDecoration(
                  hintText:
                      'Мысалы: Бұл проблема өте интересно, конечно шешу керек...',
                  hintStyle: TextStyle(
                      color: Colors.grey[400], fontSize: 13, height: 1.5),
                  contentPadding: const EdgeInsets.all(14),
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
              Obx(() => controller.detectorText.value.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.history, size: 18),
                            color: Colors.grey[500],
                            tooltip: 'Тарихқа сақтау',
                            onPressed: () {
                              final text = controller.detectorText.value;
                              final detected =
                                  controller.detectKalkaInText(text);
                              controller.saveToHistory(
                                  text, detected.length);
                              Get.snackbar(
                                'Сақталды',
                                'Тексеру тарихқа қосылды',
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 2),
                              );
                            },
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              _textController.clear();
                              controller.updateDetectorText('');
                            },
                            icon: const Icon(Icons.clear, size: 15),
                            label: const Text('Тазарту'),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.grey[600],
                                textStyle:
                                    const TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightPreview(String text) {
    final spans = _buildSpans(text);
    if (spans.isEmpty) return const SizedBox.shrink();
    return _Section(
      icon: Icons.preview,
      title: 'Белгіленген мәтін',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.6,
            ),
            children: spans,
          ),
        ),
      ),
    );
  }

  Widget _buildDetectedSection(String text) {
    final detected = controller.detectKalkaInText(text);

    if (detected.isEmpty) {
      // Post-frame callback avoids side-effects during build
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _confetti.play());
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA5D6A7)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Таза мәтін!',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B5E20),
                          fontSize: 15)),
                  Text('Калька сөздер табылмады.',
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share, size: 18),
              onPressed: () => Share.share(
                  '✅ Таза мәтін — калька сөздер жоқ!\n\n$text'),
            ),
          ],
        ),
      );
    }

    return _Section(
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFD32F2F),
      title: 'Табылған калькалар (${detected.length})',
      titleColor: const Color(0xFFD32F2F),
      trailing: IconButton(
        icon: const Icon(Icons.share, size: 18),
        onPressed: () {
          final suggestions = detected
              .map((w) => '• ${w.kalka} → ${w.kazakh}')
              .join('\n');
          Share.share(
              'Мәтінде ${detected.length} калька табылды:\n\n$suggestions\n\n#ТазаТіл');
        },
      ),
      child: Column(
        children: detected
            .map((w) => WordCardHighlight(word: w))
            .toList(),
      ),
    );
  }

  Widget _buildAISection(String text) {
    final primary = Theme.of(context).colorScheme.primary;
    return _Section(
      icon: Icons.psychology,
      title: 'ЖИ-мен аудару',
      child: Obx(() {
        final loading = controller.isLoadingAI.value;
        final result = controller.aiRewrittenText.value;
        final provider = controller.selectedAIProvider.value;
        final providerLabel = provider == 'claude' ? '🤖 Claude' : '⚡ Groq';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(
                '$providerLabel арқылы таза қазақшаға аудару',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const Spacer(),
              // Quick provider toggle
              GestureDetector(
                onTap: () => controller.setAIProvider(
                    provider == 'claude' ? 'grok' : 'claude'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: primary.withValues(alpha: 0.3)),
                  ),
                  child: Text('Ауыстыру',
                      style: TextStyle(
                          fontSize: 11,
                          color: primary,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    loading ? null : () => controller.rewriteWithAI(text),
                icon: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_fix_high, size: 18),
                label: Text(loading
                    ? 'Аударылуда...'
                    : '$providerLabel аудару'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            if (result.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFFA5D6A7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology,
                            size: 14, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 6),
                        const Text('ЖИ талдауы',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B5E20),
                                fontSize: 13)),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: result));
                            Get.snackbar('Көшірілді', '',
                                snackPosition: SnackPosition.BOTTOM,
                                duration:
                                    const Duration(seconds: 1));
                          },
                          child: const Icon(Icons.copy,
                              size: 16, color: Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    _buildFormattedResult(result),
                  ],
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildHistorySection() {
    return Obx(() {
      if (controller.detectorHistory.isEmpty) return const SizedBox.shrink();
      return _Section(
        icon: Icons.history,
        title: 'Соңғы тексерулер',
        trailing: TextButton(
          onPressed: controller.clearHistory,
          child: Text('Тазарту',
              style: TextStyle(
                  color: Colors.red[400], fontSize: 12)),
        ),
        child: Column(
          children: controller.detectorHistory
              .take(5)
              .map((h) => _HistoryTile(entry: h))
              .toList(),
        ),
      );
    });
  }

  Widget _buildHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.tips_and_updates_outlined,
              size: 40, color: Colors.amber[700]),
          const SizedBox(height: 12),
          const Text('Мәтін жазыңыз',
              style:
                  TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 6),
          Text(
            'Жоғарыдағы өріске мәтін жазсаңыз, калька сөздер '
            'автоматты түрде анықталады.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedResult(String result) {
    final lines = result.split('\n');
    final widgets = <Widget>[];

    for (final raw in lines) {
      if (raw.trim() == '---') {
        widgets.add(const Divider(height: 20, color: Color(0xFFA5D6A7)));
        continue;
      }
      if (raw.trim().isEmpty) {
        widgets.add(const SizedBox(height: 4));
        continue;
      }
      widgets.add(_buildResultLine(raw));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildResultLine(String line) {
    // Bold headers like **Табылған калька:**
    final boldPattern = RegExp(r'\*\*(.+?)\*\*');
    if (boldPattern.hasMatch(line)) {
      final spans = <InlineSpan>[];
      int last = 0;
      for (final m in boldPattern.allMatches(line)) {
        if (m.start > last) {
          spans.add(TextSpan(
            text: line.substring(last, m.start),
            style: const TextStyle(fontSize: 14, height: 1.6),
          ));
        }
        spans.add(TextSpan(
          text: m.group(1),
          style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B5E20)),
        ));
        last = m.end;
      }
      if (last < line.length) {
        spans.add(TextSpan(
          text: line.substring(last),
          style: const TextStyle(fontSize: 14, height: 1.6),
        ));
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface),
            children: spans,
          ),
        ),
      );
    }

    // ❌ lines — red tint
    if (line.trimLeft().startsWith('❌')) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(line,
            style: const TextStyle(
                fontSize: 14, height: 1.6, color: Color(0xFFB71C1C))),
      );
    }

    // ✅ lines — green tint
    if (line.trimLeft().startsWith('✅')) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(line,
            style: const TextStyle(
                fontSize: 14, height: 1.6, color: Color(0xFF2E7D32))),
      );
    }

    // bullet • lines — slight indent
    if (line.trimLeft().startsWith('•')) {
      return Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 2),
        child: Text(line,
            style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurface)),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(line,
          style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurface)),
    );
  }

  List<InlineSpan> _buildSpans(String text) {
    final kalkaSet = controller.kalkaWordSet;
    final spans = <InlineSpan>[];
    final tokenPattern =
        RegExp(r'[\p{L}\p{N}]+|[^\p{L}\p{N}]+', unicode: true);

    for (final m in tokenPattern.allMatches(text)) {
      final token = m.group(0)!;
      final isKalka = kalkaSet.contains(token.toLowerCase());
      if (isKalka) {
        final alt = controller.kalkaAlternative(token.toLowerCase());
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Tooltip(
            message: alt != null ? '→ ${alt.kazakh}' : '',
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFEF9A9A)),
              ),
              child: Text(token,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.w600,
                      height: 1.6)),
            ),
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: token,
          style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.6),
        ));
      }
    }
    return spans;
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final Color? titleColor;
  final Widget? trailing;
  final Widget child;

  const _Section({
    required this.icon,
    this.iconColor,
    required this.title,
    this.titleColor,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor ?? primary),
            const SizedBox(width: 6),
            Text(title,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: titleColor ??
                        Theme.of(context).colorScheme.onSurface)),
            const Spacer(),
            ?trailing,
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Map<String, dynamic> entry;
  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.tryParse(entry['timestamp'] as String? ?? '');
    final timeStr = dt != null
        ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
        : '';
    final count = entry['kalkaCount'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              entry['text'] as String? ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(timeStr,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: count > 0
                      ? const Color(0xFFFFEBEE)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count > 0 ? '$count калька' : 'Таза',
                  style: TextStyle(
                    fontSize: 11,
                    color: count > 0
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
