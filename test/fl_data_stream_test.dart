import 'package:fl_channel/fl_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlDataStream', () {
    test('dispatches data to all listeners', () {
      final stream = FlDataStream<int>();
      final List<int> first = <int>[];
      final List<int> second = <int>[];

      stream.listen(first.add);
      stream.listen(second.add);
      stream.send(1);
      stream.send(2);

      expect(first, <int>[1, 2]);
      expect(second, <int>[1, 2]);
    });

    test('stops delivery after cancel', () {
      final stream = FlDataStream<String>();
      final List<String> received = <String>[];

      final cancel = stream.listen(received.add);
      stream.send('a');
      cancel();
      stream.send('b');

      expect(received, <String>['a']);
    });

    test('allows a listener to cancel itself while sending', () {
      final stream = FlDataStream<int>();
      final List<int> first = <int>[];
      final List<int> second = <int>[];
      late final void Function() cancelFirst;

      cancelFirst = stream.listen((int data) {
        first.add(data);
        cancelFirst();
      });
      stream.listen(second.add);

      stream.send(1);
      stream.send(2);

      expect(first, <int>[1]);
      expect(second, <int>[1, 2]);
    });
  });
}
