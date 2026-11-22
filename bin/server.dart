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

const _fontFiles = {
  'Syne-SemiBold.ttf',
  'Syne-Bold.ttf',
  'Syne-ExtraBold.ttf',
  'DMSans-Regular.ttf',
  'DMSans-Medium.ttf',
  'DMSans-SemiBold.ttf',
  'DMSans-Bold.ttf',
};

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

String _expiredHtml(String tableNumber) =>
    '''<!doctype html>
<html lang="de">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="theme-color" content="#0a0a0a">
  <title>Link abgelaufen · Haze &amp; Chill</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <style>
    @font-face{font-family:'Syne';font-style:normal;font-weight:600;font-display:swap;src:url('/fonts/Syne-SemiBold.ttf') format('truetype')}
    @font-face{font-family:'Syne';font-style:normal;font-weight:700;font-display:swap;src:url('/fonts/Syne-Bold.ttf') format('truetype')}
    @font-face{font-family:'Syne';font-style:normal;font-weight:800;font-display:swap;src:url('/fonts/Syne-ExtraBold.ttf') format('truetype')}
    @font-face{font-family:'DM Sans';font-style:normal;font-weight:400;font-display:swap;src:url('/fonts/DMSans-Regular.ttf') format('truetype')}
    @font-face{font-family:'DM Sans';font-style:normal;font-weight:500;font-display:swap;src:url('/fonts/DMSans-Medium.ttf') format('truetype')}
    @font-face{font-family:'DM Sans';font-style:normal;font-weight:600;font-display:swap;src:url('/fonts/DMSans-SemiBold.ttf') format('truetype')}
    :root{color-scheme:dark}
    *{box-sizing:border-box;margin:0;padding:0}
    body{
      min-height:100svh;
      display:flex;
      flex-direction:column;
      align-items:center;
      justify-content:center;
      padding:28px 20px;
      font-family:'DM Sans',system-ui,sans-serif;
      color:#faf5ff;
      background:
        radial-gradient(ellipse 75% 55% at 20% 12%,rgba(139,92,246,.22),transparent 65%),
        radial-gradient(ellipse 65% 50% at 85% 88%,rgba(16,185,129,.16),transparent 65%),
        #0a0a0a;
      -webkit-font-smoothing:antialiased;
    }
    main{
      width:100%;
      max-width:440px;
      text-align:center;
      padding:36px 26px 30px;
      border-radius:24px;
      border:1px solid rgba(255,255,255,.11);
      background:rgba(255,255,255,.045);
      backdrop-filter:blur(16px);
      -webkit-backdrop-filter:blur(16px);
      box-shadow:0 20px 60px rgba(0,0,0,.55);
    }
    .logo{
      width:84px;
      height:84px;
      margin:0 auto 20px;
      background:linear-gradient(120deg,#c4b5fd,#f5d0fe 48%,#6ee7b7);
      -webkit-mask-image:url('/logo.svg');
      mask-image:url('/logo.svg');
      -webkit-mask-size:contain;
      mask-size:contain;
      -webkit-mask-repeat:no-repeat;
      mask-repeat:no-repeat;
      -webkit-mask-position:center;
      mask-position:center;
      filter:drop-shadow(0 0 18px rgba(139,92,246,.42)) drop-shadow(0 0 28px rgba(16,185,129,.18));
    }
    .badge{
      display:inline-flex;
      align-items:center;
      gap:8px;
      padding:6px 14px;
      border-radius:999px;
      border:1px solid rgba(167,139,250,.32);
      background:rgba(139,92,246,.12);
      color:#ddd6fe;
      font-family:'Syne',system-ui,sans-serif;
      font-size:12px;
      font-weight:700;
      letter-spacing:.14em;
      text-transform:uppercase;
      margin-bottom:16px;
    }
    .dot{width:7px;height:7px;border-radius:999px;background:#fb7185;box-shadow:0 0 10px rgba(251,113,133,.75)}
    h1{
      font-family:'Syne',system-ui,sans-serif;
      font-size:clamp(26px,7vw,34px);
      font-weight:700;
      letter-spacing:-.02em;
      line-height:1.12;
      margin-bottom:12px;
      color:#fff;
    }
    p{
      font-size:15px;
      line-height:1.6;
      color:rgba(237,233,254,.78);
    }
    .hint{
      margin-top:20px;
      padding:14px 16px;
      border-radius:16px;
      border:1px solid rgba(52,211,153,.24);
      background:rgba(16,185,129,.08);
      font-size:13.5px;
      line-height:1.5;
      color:#a7f3d0;
    }
    footer{
      margin-top:26px;
      font-size:12px;
      letter-spacing:.06em;
      color:rgba(196,181,253,.52);
      text-align:center;
    }
  </style>
</head>
<body>
  <main>
    <div class="logo" role="img" aria-label="Haze &amp; Chill Café Logo"></div>
    <div class="badge"><span class="dot"></span>Tisch $tableNumber</div>
    <h1>Link abgelaufen</h1>
    <p>Dieser Tischlink ist nicht mehr gültig. Bitte scanne den QR-Code auf deinem Tisch einfach erneut, um weiterzubestellen.</p>
    <div class="hint">Dein Warenkorb bleibt auf diesem Gerät für Tisch $tableNumber gespeichert.</div>
  </main>
  <footer>Haze &amp; Chill · Café &amp; Gaming Lounge · Kassel</footer>
</body>
</html>''';

void reply(HttpRequest req, int status, Object data, {bool html = false}) {
  req.response.statusCode = status;
  req.response.headers.contentType = html ? ContentType.html : ContentType.json;
  req.response.write(html ? data : jsonEncode(data));
}

Future<void> main(List<String> args) async {
  final fast = args.contains('--demo-fast');
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
  final qrcodeJs = File('assets/qrcode.js').readAsBytesSync();
  final logoSvg = File('assets/haze-chill-logo.svg').readAsBytesSync();
  final logoPng = File('assets/haze-chill-logo.png').readAsBytesSync();
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8787);
  save();
  int slot() =>
      1 +
      ((DateTime.now().millisecondsSinceEpoch - (state['start'] as int)) ~/
          duration);
  final hosts = {'localhost', '127.0.0.1'};
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
        req.response.headers.set('cache-control', 'public, max-age=86400');
        req.response.headers.contentType = ContentType(
          'application',
          'javascript',
          charset: 'utf-8',
        );
        req.response.add(qrcodeJs);
        return;
      }
      if (req.method == 'GET' &&
          (path == '/logo.svg' || path == '/favicon.svg')) {
        req.response.headers.set('cache-control', 'public, max-age=86400');
        req.response.headers.contentType = ContentType('image', 'svg+xml');
        req.response.add(logoSvg);
        return;
      }
      if (req.method == 'GET' && path == '/logo.png') {
        req.response.headers.set('cache-control', 'public, max-age=86400');
        req.response.headers.contentType = ContentType('image', 'png');
        req.response.add(logoPng);
        return;
      }
      if (req.method == 'GET' && path.startsWith('/fonts/')) {
        final name = path.substring('/fonts/'.length);
        if (_fontFiles.contains(name)) {
          final fontFile = File('assets/fonts/$name');
          if (fontFile.existsSync()) {
            req.response.headers.set('cache-control', 'public, max-age=86400');
            req.response.headers.contentType = ContentType('font', 'ttf');
            req.response.add(fontFile.readAsBytesSync());
            return;
          }
        }
        reply(req, 404, 'Schriftart nicht gefunden');
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
          reply(req, 410, _expiredHtml(table[1]!), html: true);
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
