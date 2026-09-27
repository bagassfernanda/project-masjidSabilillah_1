import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:masjid_sabilillah/data/models/prayer_time_model.dart';
import 'package:masjid_sabilillah/presentation/screens/donasi_screen.dart';

void main() {
  test('PrayerTime menyusun lima waktu sholat secara berurutan', () {
    final prayer = PrayerTime(
      tanggal: '27-09-2026',
      subuh: '04:05',
      dzuhur: '11:25',
      ashar: '14:35',
      maghrib: '17:30',
      isya: '18:40',
    );

    final names = prayer.prayerList.map((e) => e['name']).toList();
    expect(names, ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya']);
    expect(prayer.prayerList.first['time'], '04:05');
    expect(prayer.prayerList.last['time'], '18:40');
  });

  testWidgets('Halaman Donasi tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: DonasiScreen()));

    expect(find.text('Donasi'), findsOneWidget);
    expect(find.text('Fitur Donasi Segera Hadir'), findsOneWidget);
  });
}
