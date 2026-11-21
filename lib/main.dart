import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

typedef Json = Map<String, dynamic>;
const base = 'http://127.0.0.1:8787';
const headers = {'x-team': 'prototype'};
const states = ['Neu', 'In Arbeit', 'Abholbereit', 'Serviert'];
const accent = Color(0xffb4f1cf);

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
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Haze & Chill · Team',
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xff101820),
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
      ).copyWith(primary: accent),
      cardTheme: const CardThemeData(color: Color(0xff1d2a32), elevation: 0),
    ),
    home: const Board(),
  );
}

class Board extends ConsumerStatefulWidget {
  const Board({super.key});
  @override
  ConsumerState<Board> createState() => _BoardState();
}

class _BoardState extends ConsumerState<Board> {
  int tab = 0;
  bool saving = false;
  final labels = ['Theke', 'Service', 'Admin'];
  final icons = [
    Icons.local_cafe_outlined,
    Icons.room_service_outlined,
    Icons.tune,
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
      if (r.statusCode != 200)
        throw Exception(jsonDecode(utf8.decode(r.bodyBytes)));
      if (mounted) ref.invalidate(boardProvider);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Speichern fehlgeschlagen. $e')));
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

  Widget orders(List entries) {
    final visible = entries
        .cast<Json>()
        .where((o) => tab == 0 ? o['status'] < 2 : o['status'] >= 2)
        .toList();
    if (tab == 1) {
      visible.sort((a, b) {
        final byStatus = (a['status'] as int).compareTo(b['status']);
        return byStatus != 0
            ? byStatus
            : (b['number'] as int).compareTo(a['number']);
      });
    }
    if (visible.isEmpty)
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          tab == 0
              ? 'Neue Bestellungen erscheinen hier.'
              : 'Aktuell wartet keine Bestellung auf den Service.',
        ),
      );
    return Column(
      children: [
        for (final o in visible)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Tisch ${o['table']}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '#${o['number']}  ·  ${(o['time'] as String).substring(11, 16)}',
                      ),
                      Text(
                        states[o['status']],
                        style: const TextStyle(color: accent),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  for (final line in o['lines'])
                    Text("${line['qty']} × ${line['name']}"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 24,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        money(o['total']),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (o['status'] < 3)
                        FilledButton(
                          onPressed: saving
                              ? null
                              : () => post('status', {
                                  'number': o['number'],
                                  'status': o['status'] + 1,
                                }),
                          child: Text(
                            [
                              'Zubereitung starten',
                              'Abholbereit melden',
                              'Als serviert markieren',
                            ][o['status']],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget menu(List items) => Column(
    children: [
      for (final i in items)
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            title: Text(i['name']),
            subtitle: Text(
              "${i['category']} · ${money(i['price'])} · ${i['available'] ? 'Verfügbar' : 'Ausverkauft'}",
            ),
            trailing: const Icon(Icons.edit_outlined),
            onTap: saving ? null : () => edit(i),
          ),
        ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(boardProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Haze & Chill'),
        actions: [
          IconButton(
            tooltip: 'Testlink für Tisch 1 kopieren',
            icon: const Icon(Icons.link),
            onPressed: () async {
              await Clipboard.setData(
                const ClipboardData(text: '$base/tisch/1'),
              );
              if (context.mounted)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Testlink für Tisch 1 kopiert')),
                );
            },
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff1a3234), Color(0xff101820)],
            begin: Alignment.topRight,
            end: Alignment.centerLeft,
          ),
        ),
        child: SizedBox.expand(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    labels[tab],
                    style: Theme.of(context).textTheme.displaySmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      'Bestelleingang und Zubereitung',
                      'Abholung und servierte Bestellungen',
                      'Speisekarte bearbeiten',
                    ][tab],
                  ),
                  const SizedBox(height: 20),
                  data.when(
                    data: (d) =>
                        tab == 2 ? menu(d['items']) : orders(d['orders']),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Keine Verbindung zum Bestellserver.'),
                        TextButton(
                          onPressed: () => ref.invalidate(boardProvider),
                          child: const Text('Erneut verbinden'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: [
          for (var i = 0; i < 3; i++)
            NavigationDestination(icon: Icon(icons[i]), label: labels[i]),
        ],
      ),
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
  late String name = widget.item['name'];
  late String price = (widget.item['price'] / 100)
      .toStringAsFixed(2)
      .replaceAll('.', ',');
  late bool available = widget.item['available'];
  @override
  Widget build(BuildContext context) {
    final valid = RegExp(r'^\d{1,4}([.,]\d{1,2})?$').hasMatch(price);
    final cents = valid
        ? (double.parse(price.replaceAll(',', '.')) * 100).round()
        : 0;
    return AlertDialog(
      title: const Text('Artikel bearbeiten'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: name,
              maxLength: 80,
              decoration: const InputDecoration(labelText: 'Artikelname'),
              onChanged: (v) => setState(() => name = v),
            ),
            TextFormField(
              initialValue: price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Preis in Euro'),
              onChanged: (v) => setState(() => price = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Verfügbar'),
              value: available,
              onChanged: (v) => setState(() => available = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: name.trim().isEmpty || cents < 1 || cents > 100000
              ? null
              : () => Navigator.pop(context, {
                  'id': widget.item['id'],
                  'name': name.trim(),
                  'price': cents,
                  'available': available,
                }),
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
