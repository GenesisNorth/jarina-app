import 'package:jarina_core/jarina_core.dart';
import 'package:test/test.dart';

// Times are given in UTC; WAT = UTC+1.
DateTime utc(int d, int h, int m) => DateTime.utc(2026, 10, d, h, m); // 2026-10-19 is a Monday

void main() {
  test('open 10:00–14:30 WAT on weekdays', () {
    expect(NgxSchedule.isOpen(utc(19, 8, 59)), isFalse); // 09:59 WAT
    expect(NgxSchedule.isOpen(utc(19, 9, 0)), isTrue); // 10:00 WAT
    expect(NgxSchedule.isOpen(utc(19, 13, 29)), isTrue); // 14:29 WAT
    expect(NgxSchedule.isOpen(utc(19, 13, 30)), isFalse); // 14:30 WAT
    expect(NgxSchedule.isOpen(utc(24, 10, 0)), isFalse); // Saturday
  });

  test('next open', () {
    expect(NgxSchedule.nextOpen(utc(19, 7, 0)), utc(19, 9, 0)); // Mon early → same day
    expect(NgxSchedule.nextOpen(utc(19, 14, 0)), utc(20, 9, 0)); // Mon after close → Tue
    expect(NgxSchedule.nextOpen(utc(23, 15, 0)), utc(26, 9, 0)); // Fri after close → Mon
    expect(NgxSchedule.nextOpen(utc(24, 10, 0)), utc(26, 9, 0)); // Sat → Mon
    expect(NgxSchedule.nextOpen(DateTime.utc(2026, 10, 25, 23, 30)), utc(26, 9, 0)); // Sun 23:30 UTC = Mon 00:30 WAT
  });
}
