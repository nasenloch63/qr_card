# Haze & Chill · QR-Karte

Lokaler Flutter-Prototyp für Theke, Service und Speisekartenpflege. Die mobile Gästekarte und die Bestell-API laufen auf einem kleinen Dart-Server. Flutter SDK mit Dart 3.13 oder neuer und die Flutter-Erweiterung für VS Code werden benötigt.

## In VS Code testen

1. Diesen Projektordner öffnen und im Terminal `flutter pub get` ausführen.
2. Unter **Ausführen und Debuggen** die Konfiguration **Café testen** wählen und F5 drücken. VS Code startet den lokalen Server und die Flutter-App in Edge.
3. In einem zweiten Tab <http://127.0.0.1:8787/tisch/1> öffnen. Artikel auswählen und bestellen. Im Dashboard unter Theke die Zubereitung starten und die Bestellung zur Abholung freigeben. Im Service das Servieren bestätigen.
4. Im Admin Preis, Namen oder Verfügbarkeit anpassen. Beim nächsten Öffnen zeigt die Gästekarte die Änderung.

Alternativ in zwei Terminals `dart run bin/server.dart` und `flutter run -d edge` starten. Der Server speichert Menü, Bestellungen und Zeitfenster lokal unter `.demo/`. Die App aktualisiert die Liste alle zwei Sekunden.

## QR und Ablauf testen

Der gedruckte QR enthält die feste Adresse `/tisch/1` (Tische 1 bis 30). Sie leitet auf `/tisch/1/1`, später auf `/tisch/1/2` usw. weiter. Die zweistündigen Fenster beginnen mit der ersten Inbetriebnahme des Servers. Abgelaufene Links und Bestellversuche erhalten HTTP 410. Ein erneuter Aufruf des festen Links erhält den Warenkorb auf demselben Gerät und Tisch.

Für einen schnellen separaten Test den normalen Server beenden und `dart run bin/server.dart --demo-fast` starten. Die Fenster dauern dann 20 Sekunden und nutzen einen eigenen Datenbestand. Den alten Link nach dem Wechsel neu laden und anschließend den festen Link öffnen.

## Tischkarten drucken

Unter <http://127.0.0.1:8787/qr> einen Tisch auswählen und seine Karte drucken. Die lokale Vorschau verwendet die Adresse des Testservers. Für den späteren Betrieb auf haze-chill.com werden die Karten mit der öffentlichen Domain erstellt.

Die Gültigkeit richtet sich nach Tisch und aktuellem Zeitfenster. Wer die feste Tischadresse gespeichert hat, kann darüber auch von unterwegs den aktuellen Link öffnen. Die Rotation allein bestätigt keine Anwesenheit am Tisch.
