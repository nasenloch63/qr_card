import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

typedef Json = Map<String, dynamic>;
const base = 'http://127.0.0.1:8787';
const headers = {'x-team': 'prototype'};
const states = ['Neu', 'In Arbeit', 'Abholbereit', 'Serviert'];

/// Authentic Haze & Chill Café color & typography tokens inspired by haze-chill.com
abstract final class HC {
  static const bg = Color(0xFF0A0A0A);
  static const surface = Color(0xFF13121A);
  static const surfaceElevated = Color(0xFF1A1824);
  static const border = Color(0x1EFFFFFF);
  static const borderSoft = Color(0x10FFFFFF);

  static const emerald = Color(0xFF10B981);
  static const emeraldLight = Color(0xFF6EE7B7);
  static const teal = Color(0xFF2DD4BF);
  static const violet = Color(0xFF8B5CF6);
  static const violetLight = Color(0xFFC4B5FD);
  static const fuchsiaLight = Color(0xFFF5D0FE);
  static const amber = Color(0xFFFBBF24);
  static const rose = Color(0xFFFB7185);

  static const text = Color(0xFFFAF5FF);
  static const textSecondary = Color(0xCCE8E2F8);
  static const textMuted = Color(0x99B6ACD1);

  static const displayFont = 'Syne';
  static const bodyFont = 'DM Sans';

  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w700,
    Color color = text,
    double? letterSpacing,
    double? height,
    bool tabular = false,
  }) => TextStyle(
    fontFamily: displayFont,
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
  );

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = text,
    double? letterSpacing,
    double? height,
  }) => TextStyle(
    fontFamily: bodyFont,
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  static ({Color from, Color to, IconData icon}) categoryStyle(String cat) =>
      switch (cat) {
        'Alkoholfrei' => (
          from: const Color(0xFF6EE7B7),
          to: const Color(0xFF14B8A6),
          icon: Icons.local_drink_outlined,
        ),
        'Alkoholisch' => (
          from: const Color(0xFFE879F9),
          to: const Color(0xFF9333EA),
          icon: Icons.local_bar_outlined,
        ),
        'Heißgetränke' => (
          from: const Color(0xFFFBBF24),
          to: const Color(0xFFD97706),
          icon: Icons.coffee_outlined,
        ),
        'Essen' => (
          from: const Color(0xFFFB923C),
          to: const Color(0xFFEF4444),
          icon: Icons.restaurant_outlined,
        ),
        'Snacks' => (
          from: const Color(0xFFA855F7),
          to: const Color(0xFFEC4899),
          icon: Icons.local_fire_department_outlined,
        ),
        'Specials' => (
          from: const Color(0xFF38BDF8),
          to: const Color(0xFFA78BFA),
          icon: Icons.auto_awesome_outlined,
        ),
        _ => (
          from: emeraldLight,
          to: violetLight,
          icon: Icons.local_cafe_outlined,
        ),
      };
}

final boardProvider = StreamProvider<Json>((ref) async* {
  while (ref.mounted) {
    final response = await http
        .get(Uri.parse('$base/api/team'), headers: headers)
        .timeout(const Duration(seconds: 4));
    if (response.statusCode != 200) throw Exception('Server nicht erreichbar');
    yield jsonDecode(utf8.decode(response.bodyBytes)) as Json;
    await Future<void>.delayed(const Duration(seconds: 2));
  }
});

String money(int cents) =>
    '${(cents / 100).toStringAsFixed(2).replaceAll('.', ',')} €';

void main() => runApp(const ProviderScope(child: CafeApp()));

class CafeApp extends StatelessWidget {
  const CafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: HC.bodyFont,
      scaffoldBackgroundColor: HC.bg,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: HC.emerald,
            brightness: Brightness.dark,
          ).copyWith(
            primary: HC.emeraldLight,
            secondary: HC.violetLight,
            surface: HC.surface,
            onPrimary: HC.bg,
            onSurface: HC.text,
          ),
      dividerColor: HC.borderSoft,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: HC.surfaceElevated,
        contentTextStyle: HC.body(14, weight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: HC.emerald.withValues(alpha: 0.35)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: HC.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: HC.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        labelStyle: HC.body(14, color: HC.textMuted),
        floatingLabelStyle: HC.body(
          13,
          weight: FontWeight.w600,
          color: HC.emeraldLight,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: HC.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: HC.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: HC.emeraldLight.withValues(alpha: 0.75),
            width: 1.5,
          ),
        ),
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Haze & Chill · Team',
      theme: baseTheme,
      home: const Board(),
    );
  }
}

/// Original Haze & Chill Café circular emblem rendered with the signature
/// violet -> fuchsia -> emerald neon gradient mask from haze-chill.com
class HazeLogo extends StatelessWidget {
  const HazeLogo({
    super.key,
    required this.size,
    this.glow = true,
    this.opacity = 1.0,
  });

  final double size;
  final bool glow;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final masked = ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [HC.violetLight, HC.fuchsiaLight, HC.emeraldLight],
      ).createShader(bounds),
      child: Image.asset(
        'assets/haze-chill-logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        semanticLabel: 'Haze & Chill Café Logo',
      ),
    );

    Widget content = masked;
    if (glow) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.84,
            height: size * 0.84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: HC.violet.withValues(alpha: 0.35),
                  blurRadius: size * 0.48,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: HC.emerald.withValues(alpha: 0.18),
                  blurRadius: size * 0.75,
                ),
              ],
            ),
          ),
          masked,
        ],
      );
    }

    return opacity < 1.0 ? Opacity(opacity: opacity, child: content) : content;
  }
}

/// Primary pill CTA button matching haze-chill.com's emerald-to-teal gradient button
class HazeGradientButton extends StatelessWidget {
  const HazeGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: enabled
            ? const LinearGradient(colors: [HC.emerald, HC.teal])
            : null,
        color: enabled ? null : Colors.white.withValues(alpha: 0.08),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: HC.emerald.withValues(alpha: 0.32),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 18 : 22,
              vertical: compact ? 10 : 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 17,
                    color: enabled
                        ? HC.bg
                        : Colors.white.withValues(alpha: 0.38),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: HC.body(
                    compact ? 14 : 14.5,
                    weight: FontWeight.w700,
                    color: enabled
                        ? HC.bg
                        : Colors.white.withValues(alpha: 0.38),
                    letterSpacing: 0.05,
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

class Board extends ConsumerStatefulWidget {
  const Board({super.key});
  @override
  ConsumerState<Board> createState() => _BoardState();
}

class _BoardState extends ConsumerState<Board> {
  int tab = 0;
  bool saving = false;
  String? adminCategory;

  static const labels = ['Theke', 'Service', 'Admin'];
  static const eyebrows = [
    'BESTELLEINGANG · BAR',
    'GASTSERVICE · LOUNGE',
    'SPEISEKARTE · VERWALTUNG',
  ];
  static const subtitles = [
    'Eingehende Tischbestellungen annehmen und zubereiten',
    'Abholbereite Drinks & Snacks an den Tisch bringen',
    'Preise, Artikelnamen und Verfügbarkeit live pflegen',
  ];
  static const icons = [
    Icons.local_cafe_outlined,
    Icons.room_service_outlined,
    Icons.tune_rounded,
  ];

  Future<void> post(String path, Json body) async {
    if (saving) return;
    setState(() => saving = true);
    try {
      final r = await http
          .post(
            Uri.parse('$base/api/team/$path'),
            headers: {...headers, 'content-type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 6));
      if (r.statusCode != 200) {
        throw Exception(jsonDecode(utf8.decode(r.bodyBytes)));
      }
      if (mounted) ref.invalidate(boardProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Speichern fehlgeschlagen. $e')));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> edit(Json item) async {
    final changed = await showDialog<Json>(
      context: context,
      builder: (_) => ItemEditor(item: item),
    );
    if (changed != null && mounted) await post('item', changed);
  }

  Future<void> copyLink(String url, String message) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _statChip(String label, int count, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(999),
      color: color.withValues(alpha: 0.12),
      border: Border.all(color: color.withValues(alpha: 0.34)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 7),
        Text(
          '$count $label',
          style: HC.display(
            12,
            weight: FontWeight.w700,
            color: color,
            tabular: true,
          ),
        ),
      ],
    ),
  );

  Widget _statusPill(int status) {
    final (color, icon) = switch (status) {
      0 => (HC.violetLight, Icons.fiber_new_rounded),
      1 => (HC.amber, Icons.local_fire_department_rounded),
      2 => (HC.emeraldLight, Icons.notifications_active_outlined),
      _ => (HC.textMuted, Icons.check_circle_outline_rounded),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.13),
        border: Border.all(color: color.withValues(alpha: 0.38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            states[status],
            style: HC.display(11.5, weight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String title, String subtitle) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: HC.border),
      color: Colors.white.withValues(alpha: 0.035),
    ),
    child: Column(
      children: [
        const HazeLogo(size: 64, glow: false, opacity: 0.55),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: HC.display(18, weight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: HC.body(14, color: HC.textMuted),
        ),
      ],
    ),
  );

  Widget orders(List entries) {
    final all = entries.cast<Json>();
    final visible = all
        .where((o) => tab == 0 ? o['status'] < 2 : o['status'] >= 2)
        .toList();
    if (tab == 1) {
      visible.sort((a, b) {
        final byStatus = (a['status'] as int).compareTo(b['status'] as int);
        return byStatus != 0
            ? byStatus
            : (b['number'] as int).compareTo(a['number'] as int);
      });
    } else {
      visible.sort(
        (a, b) => (a['number'] as int).compareTo(b['number'] as int),
      );
    }

    final statRow = Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tab == 0
            ? [
                _statChip(
                  'Neu',
                  all.where((o) => o['status'] == 0).length,
                  HC.violetLight,
                ),
                _statChip(
                  'In Arbeit',
                  all.where((o) => o['status'] == 1).length,
                  HC.amber,
                ),
              ]
            : [
                _statChip(
                  'Abholbereit',
                  all.where((o) => o['status'] == 2).length,
                  HC.emeraldLight,
                ),
                _statChip(
                  'Serviert',
                  all.where((o) => o['status'] == 3).length,
                  HC.textMuted,
                ),
              ],
      ),
    );

    if (visible.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          statRow,
          _emptyCard(
            tab == 0 ? 'Alles entspannt an der Theke' : 'Kein offener Service',
            tab == 0
                ? 'Neue Bestellungen erscheinen hier automatisch alle zwei Sekunden.'
                : 'Sobald die Theke eine Bestellung freigibt, taucht sie hier auf.',
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [statRow, for (final o in visible) _orderCard(o)],
    );
  }

  Widget _orderCard(Json o) {
    final status = o['status'] as int;
    final served = status == 3;
    final borderAccent = switch (status) {
      0 => HC.violet.withValues(alpha: 0.42),
      1 => HC.amber.withValues(alpha: 0.35),
      2 => HC.emerald.withValues(alpha: 0.45),
      _ => HC.borderSoft,
    };
    final tint = switch (status) {
      0 => HC.violet.withValues(alpha: 0.06),
      1 => HC.amber.withValues(alpha: 0.045),
      2 => HC.emerald.withValues(alpha: 0.06),
      _ => Colors.white.withValues(alpha: 0.02),
    };
    final timeRaw = o['time'] as String;
    final timeStr = timeRaw.length >= 16 ? timeRaw.substring(11, 16) : timeRaw;

    return Opacity(
      opacity: served ? 0.68 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderAccent),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [tint, Colors.white.withValues(alpha: 0.03)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withValues(alpha: 0.07),
                    border: Border.all(color: HC.border),
                  ),
                  child: Text(
                    'Tisch ${o['table']}',
                    style: HC.display(17, weight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '#${o['number']}  ·  $timeStr Uhr',
                    style: HC.body(
                      13.5,
                      weight: FontWeight.w500,
                      color: HC.textMuted,
                    ),
                  ),
                ),
                _statusPill(status),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            for (final line in (o['lines'] as List).cast<Json>())
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      constraints: const BoxConstraints(minWidth: 32),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: HC.emerald.withValues(alpha: 0.14),
                      ),
                      child: Text(
                        '${line['qty']}×',
                        textAlign: TextAlign.center,
                        style: HC.body(
                          13,
                          weight: FontWeight.w700,
                          color: HC.emeraldLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${line['name']}',
                        style: HC.body(15, weight: FontWeight.w500),
                      ),
                    ),
                    if (line['price'] is int)
                      Text(
                        money((line['price'] as int) * (line['qty'] as int)),
                        style: HC.display(
                          13.5,
                          weight: FontWeight.w600,
                          color: HC.textMuted,
                          tabular: true,
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GESAMT',
                        style: HC.display(
                          10,
                          weight: FontWeight.w600,
                          color: HC.textMuted,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        money(o['total'] as int),
                        style: HC.display(
                          21,
                          weight: FontWeight.w600,
                          color: HC.emeraldLight,
                          tabular: true,
                        ),
                      ),
                    ],
                  ),
                  if (status < 3)
                    HazeGradientButton(
                      label: const [
                        'Zubereitung starten',
                        'Abholbereit melden',
                        'Als serviert markieren',
                      ][status],
                      icon: const [
                        Icons.play_arrow_rounded,
                        Icons.check_rounded,
                        Icons.room_service_rounded,
                      ][status],
                      onPressed: saving
                          ? null
                          : () => post('status', {
                              'number': o['number'],
                              'status': status + 1,
                            }),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget menu(List items) {
    final all = items.cast<Json>();
    final availableCount = all.where((i) => i['available'] == true).length;
    final soldOutCount = all.length - availableCount;
    final categories = <String>[for (final i in all) i['category'] as String]
        .toSet()
        .toList();
    final filtered = adminCategory == null
        ? all
        : all.where((i) => i['category'] == adminCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _statChip('Verfügbar', availableCount, HC.emeraldLight),
            if (soldOutCount > 0)
              _statChip('Ausverkauft', soldOutCount, HC.rose),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('Alle', adminCategory == null, () {
                setState(() => adminCategory = null);
              }),
              for (final cat in categories)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _filterChip(cat, adminCategory == cat, () {
                    setState(() => adminCategory = cat);
                  }),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: HC.border),
            color: Colors.white.withValues(alpha: 0.04),
          ),
          child: Column(
            children: [
              for (var idx = 0; idx < filtered.length; idx++) ...[
                _menuRow(filtered[idx]),
                if (idx < filtered.length - 1)
                  Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: active
                ? const LinearGradient(colors: [HC.violet, HC.emerald])
                : null,
            color: active ? null : Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: active ? Colors.transparent : HC.border),
          ),
          child: Text(
            label,
            style: HC.display(
              12,
              weight: FontWeight.w700,
              color: active ? Colors.white : HC.textSecondary,
            ),
          ),
        ),
      );

  Widget _menuRow(Json item) {
    final available = item['available'] == true;
    final cat = item['category'] as String;
    final style = HC.categoryStyle(cat);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: saving ? null : () => edit(item),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      style.from.withValues(alpha: available ? 0.95 : 0.35),
                      style.to.withValues(alpha: available ? 0.95 : 0.35),
                    ],
                  ),
                ),
                child: Icon(style.icon, size: 20, color: HC.bg),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] as String,
                      style: HC.body(
                        15.5,
                        weight: FontWeight.w600,
                        color: available ? HC.text : HC.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(cat, style: HC.body(12.5, color: HC.textMuted)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: (available ? HC.emerald : HC.rose)
                                .withValues(alpha: 0.14),
                            border: Border.all(
                              color: (available ? HC.emeraldLight : HC.rose)
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            available ? 'Verfügbar' : 'Ausverkauft',
                            style: HC.body(
                              11,
                              weight: FontWeight.w600,
                              color: available ? HC.emeraldLight : HC.rose,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                money(item['price'] as int),
                style: HC.display(
                  15.5,
                  weight: FontWeight.w600,
                  color: available ? HC.emeraldLight : HC.textMuted,
                  tabular: true,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(color: HC.borderSoft),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: HC.violetLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(AsyncValue<Json> data) {
    final isLive = data.hasValue;
    final isErr = data.hasError;
    final statusColor = isErr
        ? HC.rose
        : (isLive ? HC.emeraldLight : HC.violetLight);
    final statusLabel = isErr ? 'Offline' : (isLive ? 'Live' : 'Verbinde');

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: HC.bg.withValues(alpha: 0.78),
            border: const Border(bottom: BorderSide(color: HC.border)),
          ),
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      const HazeLogo(size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Haze & Chill',
                              style: HC.display(
                                17,
                                weight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              'TEAM · KASSEL',
                              style: HC.display(
                                10,
                                weight: FontWeight.w600,
                                color: HC.emeraldLight.withValues(alpha: 0.85),
                                letterSpacing: 2.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: statusColor.withValues(alpha: 0.12),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.36),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: statusColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: statusColor.withValues(alpha: 0.8),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              statusLabel,
                              style: HC.body(
                                12,
                                weight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _headerAction(
                        tooltip: 'QR-Tischkarten-Link kopieren',
                        icon: Icons.qr_code_2_rounded,
                        onTap: () => copyLink(
                          '$base/qr',
                          'Link für QR-Tischkarten kopiert ($base/qr)',
                        ),
                      ),
                      const SizedBox(width: 6),
                      _headerAction(
                        tooltip: 'Testlink für Tisch 1 kopieren',
                        icon: Icons.link_rounded,
                        onTap: () => copyLink(
                          '$base/tisch/1',
                          'Testlink für Tisch 1 kopiert',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerAction({
    required String tooltip,
    required IconData icon,
    required VoidCallback onTap,
  }) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: HC.border),
        ),
        child: Icon(icon, size: 18, color: HC.violetLight),
      ),
    ),
  );

  Widget _floatingNav(int barCount, int serviceCount) {
    final badges = [barCount, serviceCount, 0];
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Center(
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: const Color(0xE6111018),
                    border: Border.all(color: HC.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.55),
                        blurRadius: 32,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Expanded(
                          child: _navItem(
                            index: i,
                            selected: tab == i,
                            badge: badges[i],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required bool selected,
    required int badge,
  }) => GestureDetector(
    onTap: () => setState(() => tab = index),
    behavior: HitTestBehavior.opaque,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: selected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  HC.violet.withValues(alpha: 0.30),
                  HC.emerald.withValues(alpha: 0.22),
                ],
              )
            : null,
        border: Border.all(
          color: selected
              ? HC.emeraldLight.withValues(alpha: 0.38)
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icons[index],
            size: 19,
            color: selected ? HC.emeraldLight : HC.textMuted,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              labels[index],
              overflow: TextOverflow.ellipsis,
              style: HC.body(
                13.5,
                weight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : HC.textMuted,
              ),
            ),
          ),
          if (badge > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: index == 1 ? HC.emerald : HC.violet,
              ),
              child: Text(
                '$badge',
                style: HC.body(
                  11,
                  weight: FontWeight.w700,
                  color: index == 1 ? HC.bg : Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(boardProvider);
    final ordersList =
        data.asData?.value['orders'] as List? ?? const <dynamic>[];
    final barCount = ordersList
        .cast<Json>()
        .where((o) => (o['status'] as int) < 2)
        .length;
    final serviceCount = ordersList
        .cast<Json>()
        .where((o) => (o['status'] as int) == 2)
        .length;

    return Scaffold(
      extendBody: true,
      backgroundColor: HC.bg,
      body: Stack(
        children: [
          // Ambient Haze & Chill dark obsidian + violet/emerald radial atmosphere
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: HC.bg,
                gradient: RadialGradient(
                  center: const Alignment(-0.75, -0.85),
                  radius: 1.15,
                  colors: [
                    HC.violet.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.85, -0.35),
                  radius: 1.0,
                  colors: [
                    HC.emerald.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -90,
            top: 70,
            child: IgnorePointer(
              child: HazeLogo(size: 320, glow: false, opacity: 0.035),
            ),
          ),
          Column(
            children: [
              _topBar(data),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(22, 26, 22, 112),
                      children: [
                        Text(
                          eyebrows[tab],
                          style: HC.display(
                            11,
                            weight: FontWeight.w600,
                            color: HC.emeraldLight,
                            letterSpacing: 2.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Colors.white,
                              HC.violetLight,
                              HC.emeraldLight,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            labels[tab],
                            style: HC.display(
                              36,
                              weight: FontWeight.w700,
                              letterSpacing: -0.5,
                              height: 1.08,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitles[tab],
                          style: HC.body(14.5, color: HC.textSecondary),
                        ),
                        const SizedBox(height: 22),
                        data.when(
                          data: (d) => tab == 2
                              ? menu(d['items'] as List)
                              : orders(d['orders'] as List),
                          loading: () => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 28),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                minHeight: 4,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.08,
                                ),
                                valueColor: const AlwaysStoppedAnimation(
                                  HC.emeraldLight,
                                ),
                              ),
                            ),
                          ),
                          error: (e, _) => Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: HC.rose.withValues(alpha: 0.35),
                              ),
                              color: HC.rose.withValues(alpha: 0.08),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.wifi_off_rounded,
                                      color: HC.rose,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Keine Verbindung zum Bestellserver',
                                      style: HC.display(
                                        16,
                                        weight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Bitte prüfe, ob der lokale Bestellserver unter $base läuft.',
                                  style: HC.body(14, color: HC.textSecondary),
                                ),
                                const SizedBox(height: 16),
                                HazeGradientButton(
                                  label: 'Erneut verbinden',
                                  icon: Icons.refresh_rounded,
                                  compact: true,
                                  onPressed: () =>
                                      ref.invalidate(boardProvider),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _floatingNav(barCount, serviceCount),
    );
  }
}

class ItemEditor extends StatefulWidget {
  const ItemEditor({super.key, required this.item});
  final Json item;
  @override
  State<ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends State<ItemEditor> {
  late String name = widget.item['name'] as String;
  late String price = ((widget.item['price'] as int) / 100)
      .toStringAsFixed(2)
      .replaceAll('.', ',');
  late bool available = widget.item['available'] as bool;

  @override
  Widget build(BuildContext context) {
    final valid = RegExp(r'^\d{1,4}([.,]\d{1,2})?$').hasMatch(price);
    final cents = valid
        ? (double.parse(price.replaceAll(',', '.')) * 100).round()
        : 0;
    final canSave = name.trim().isNotEmpty && cents >= 1 && cents <= 100000;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 22),
      title: Row(
        children: [
          const HazeLogo(size: 32, glow: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Artikel bearbeiten',
                  style: HC.display(18, weight: FontWeight.w700),
                ),
                Text(
                  widget.item['category'] as String,
                  style: HC.body(12.5, color: HC.emeraldLight),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                maxLength: 80,
                style: HC.body(15, weight: FontWeight.w500),
                decoration: const InputDecoration(labelText: 'Artikelname'),
                onChanged: (v) => setState(() => name = v),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: price,
                style: HC.display(15, weight: FontWeight.w600, tabular: true),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Preis in Euro',
                  suffixText: '€',
                ),
                onChanged: (v) => setState(() => price = v),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withValues(alpha: 0.04),
                  border: Border.all(color: HC.border),
                ),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 2,
                  ),
                  activeThumbColor: HC.bg,
                  activeTrackColor: HC.emeraldLight,
                  title: Text(
                    'Verfügbar',
                    style: HC.body(14.5, weight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    available
                        ? 'Wird Gästen in der Speisekarte angezeigt'
                        : 'Aktuell als ausverkauft ausgeblendet',
                    style: HC.body(12, color: HC.textMuted),
                  ),
                  value: available,
                  onChanged: (v) => setState(() => available = v),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: HC.textSecondary),
          child: Text('Abbrechen', style: HC.body(14, weight: FontWeight.w600)),
        ),
        HazeGradientButton(
          label: 'Speichern',
          compact: true,
          onPressed: canSave
              ? () => Navigator.pop(context, {
                  'id': widget.item['id'],
                  'name': name.trim(),
                  'price': cents,
                  'available': available,
                })
              : null,
        ),
      ],
    );
  }
}
