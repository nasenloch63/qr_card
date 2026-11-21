import 'dart:convert';
import 'dart:io';

typedef Json = Map<String, dynamic>;

const categories = [
  'Alkoholfrei',
  'Alkoholisch',
  'Heißgetränke',
  'Essen',
  'Snacks',
  'Specials',
];
Json fresh() {
  final names = [
    'Haus-Eistee Pfirsich',
    'Pils',
    'Cappuccino',
    'Käsetoast',
    'Tortilla-Chips',
    'Frischer Obstbecher',
  ];
  final prices = [450, 390, 320, 490, 250, 550];
  return {
    'start': DateTime.now().millisecondsSinceEpoch,
    'items': [
      for (var i = 0; i < names.length; i++)
        {
          'id': i + 1,
          'name': names[i],
          'category': categories[i],
          'price': prices[i],
          'available': true,
        },
    ],
    'orders': [],
  };
}

void reply(HttpRequest req, int status, Object data, {bool html = false}) {
  req.response.statusCode = status;
  req.response.headers.contentType = html ? ContentType.html : ContentType.json;
  req.response.write(html ? data : jsonEncode(data));
}

Future<void> main(List<String> args) async {
  final fast = args.contains('--demo-fast');
  final lan = args.contains('--lan');
  final duration =
      (fast ? const Duration(seconds: 20) : const Duration(hours: 2))
          .inMilliseconds;
  final file = File('.demo/${fast ? 'fast' : 'cafe'}.json');
  file.parent.createSync(recursive: true);
  final Json state = file.existsSync()
      ? jsonDecode(file.readAsStringSync())
      : fresh();
  void save() {
    final tmp = File('${file.path}.tmp');
    tmp.writeAsStringSync(jsonEncode(state), flush: true);
    tmp.renameSync(file.path);
  }

  final guest = File('assets/menu.html').readAsStringSync();
  final server = await HttpServer.bind(
    lan ? InternetAddress.anyIPv4 : InternetAddress.loopbackIPv4,
    8787,
  );
  save();
  int slot() =>
      1 +
      ((DateTime.now().millisecondsSinceEpoch - (state['start'] as int)) ~/
          duration);
  final hosts = {'localhost', '127.0.0.1'};
  if (lan) {
    for (final net in await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    )) {
      for (final ip in net.addresses) {
        hosts.add(ip.address);
        print('Tisch 1: http://${ip.address}:8787/tisch/1');
      }
    }
  }
  print('Bestellserver: http://127.0.0.1:8787/tisch/1');
  final tablePath = RegExp(r'^/tisch/([1-9]|[12][0-9]|30)(?:/([1-9][0-9]*))?$');
  server.listen((req) async {
    try {
      final uri = req.requestedUri;
      final origin = req.headers.value('origin');
      final source = origin == null ? null : Uri.tryParse(origin);
      final local = req.connectionInfo!.remoteAddress.isLoopback;
      final teamOrigin =
          source != null &&
          source.scheme == 'http' &&
          {'localhost', '127.0.0.1'}.contains(source.host);
      if (!hosts.contains(uri.host) ||
          (origin != null && origin != uri.origin && !(local && teamOrigin))) {
        reply(req, 403, 'Zugriff verweigert');
        return;
      }
      req.response.headers.set('cache-control', 'no-store');
      if (local && teamOrigin) {
        req.response.headers.set('access-control-allow-origin', origin!);
        req.response.headers.set(
          'access-control-allow-headers',
          'content-type, x-team',
        );
        req.response.headers.set(
          'access-control-allow-methods',
          'GET, POST, OPTIONS',
        );
      }
      if (req.method == 'OPTIONS') {
        req.response.statusCode = 204;
        return;
      }
      final path = uri.path;
      if (req.method == 'GET' && path == '/qrcode.js') {
        req.response.headers.contentType = ContentType(
          'application',
          'javascript',
        );
        req.response.write(File('assets/qrcode.js').readAsStringSync());
        return;
      }
      if (req.method == 'GET' && path == '/qr') {
        reply(
          req,
          200,
          File('assets/tables.html').readAsStringSync(),
          html: true,
        );
        return;
      }
      final table = tablePath.firstMatch(path);
      final items = state['items'] as List;
      final orders = state['orders'] as List;
      if (table != null && req.method == 'GET') {
        final current = slot();
        if (table[2] == null) {
          req.response.statusCode = 302;
          req.response.headers.set('location', '${uri.path}/$current');
          return;
        }
        if (table[2] != '$current') {
          reply(
            req,
            410,
            '<meta charset=utf-8><meta name=viewport content="width=device-width"><h2>Link abgelaufen</h2>Bitte scanne den QR-Code am Tisch erneut.',
            html: true,
          );
          return;
        }
        reply(req, 200, guest, html: true);
        return;
      }
      if (path == '/api/menu' && req.method == 'GET') {
        reply(req, 200, {'items': items, 'categories': categories});
        return;
      }
      final team = path.startsWith('/api/team');
      if (team && (!local || req.headers.value('x-team') != 'prototype')) {
        reply(req, 403, 'Nur am Team-PC verfügbar');
        return;
      }
      if (path == '/api/team' && req.method == 'GET') {
        reply(req, 200, {'orders': orders, 'items': items});
        return;
      }
      if (req.method != 'POST' ||
          req.headers.contentType?.mimeType != 'application/json') {
        reply(req, 404, 'Unbekannte Anfrage');
        return;
      }
      final bytes = <int>[];
      await for (final chunk in req) {
        bytes.addAll(chunk);
        if (bytes.length > 16384) {
          reply(req, 413, 'Anfrage zu groß');
          return;
        }
      }
      final body = jsonDecode(utf8.decode(bytes));
      if (body is! Json) {
        throw const FormatException();
      }
      if (path == '/api/orders') {
        final t = body['table'],
            s = body['slot'],
            key = body['key'],
            cart = body['cart'];
        if (t is! int ||
            t < 1 ||
            t > 30 ||
            s is! int ||
            key is! String ||
            !RegExp(r'^[0-9a-f]{32}$').hasMatch(key) ||
            cart is! Map ||
            cart.isEmpty) {
          throw const FormatException();
        }
        if (s != slot()) {
          reply(req, 410, 'Link abgelaufen. Bitte scanne den QR-Code erneut.');
          return;
        }
        final existing = orders
            .where((o) => o['key'] == key && o['table'] == t && o['slot'] == s)
            .firstOrNull;
        if (existing != null) {
          reply(req, 200, {'number': existing['number']});
          return;
        }
        final lines = <Json>[];
        var total = 0;
        for (final e in cart.entries) {
          final item = items.where((i) => '${i['id']}' == e.key).firstOrNull;
          final n = e.value;
          if (item == null || n is! int || n < 1 || n > 30) {
            throw const FormatException();
          }
          if (item['available'] != true ||
              body['prices'] is! Map ||
              body['prices'][e.key] != item['price']) {
            reply(
              req,
              409,
              'Speisekarte geändert. Bitte lade die Seite neu und prüfe den Warenkorb.',
            );
            return;
          }
          lines.add({'name': item['name'], 'qty': n, 'price': item['price']});
          total += n * (item['price'] as int);
        }
        final number = orders.length + 1;
        orders.add({
          'number': number,
          'time': DateTime.now().toIso8601String(),
          'table': t,
          'key': key,
          'slot': s,
          'lines': lines,
          'total': total,
          'status': 0,
        });
        save();
        reply(req, 201, {'number': number});
        return;
      }
      if (path == '/api/team/status') {
        final order = orders
            .where((o) => o['number'] == body['number'])
            .firstOrNull;
        if (order == null ||
            body['status'] != order['status'] + 1 ||
            body['status'] > 3) {
          reply(req, 409, 'Status hat sich geändert');
          return;
        }
        order['status'] = body['status'];
      } else if (path == '/api/team/item') {
        final item = items.where((i) => i['id'] == body['id']).firstOrNull;
        final name = body['name'], price = body['price'];
        if (item == null ||
            name is! String ||
            name.trim().isEmpty ||
            name.length > 80 ||
            price is! int ||
            price < 1 ||
            price > 100000 ||
            body['available'] is! bool) {
          throw const FormatException();
        }
        item.addAll({
          'name': name.trim(),
          'price': price,
          'available': body['available'],
        });
      } else {
        reply(req, 404, 'Unbekannte Anfrage');
        return;
      }
      save();
      reply(req, 200, {'ok': true});
    } on FormatException {
      reply(req, 400, 'Ungültige Eingabe');
    } catch (e) {
      stderr.writeln(e);
      reply(req, 500, 'Serverfehler');
    } finally {
      await req.response.close();
    }
  });
}
