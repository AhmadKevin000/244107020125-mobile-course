import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:_03_week_3_navigation_state_management/providers/stats_provider.dart';

void main() {
  late double diceResult;
  late ProviderContainer container;

  setUp(() {
    diceResult = 0.9;
    container = ProviderContainer(overrides: [
      diceProvider.overrideWithValue(() => diceResult),
      statsDelayProvider.overrideWithValue(Duration.zero),
    ]);
    addTearDown(container.dispose);
  });

  Future<AsyncValue<List<String>>> settle() async {
    final states = <AsyncValue<List<String>>>[];
    final sub = container.listen(
      statsProvider,
      (_, s) => states.add(s),
      fireImmediately: true,
    );
    addTearDown(sub.close);
    for (var i = 0; i < 100; i++) {
      final last = states.isEmpty ? null : states.last;
      if (last is AsyncData<List<String>> || last is AsyncError<List<String>>) {
        return last!;
      }
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    fail('Fetch tidak selesai (timeout)');
  }

  test('state awal adalah loading sebelum fetch selesai', () {
    expect(container.read(statsProvider), isA<AsyncLoading>());
  });

  test('fetch berhasil menghasilkan AsyncData berisi 3 item', () async {
    diceResult = 0.9;
    final state = await settle();
    expect(state, isA<AsyncData<List<String>>>());
    expect(state.value, hasLength(3));
  });

  test('fetch gagal menghasilkan AsyncError', () async {
    diceResult = 0.1;
    final state = await settle();
    expect(state, isA<AsyncError<List<String>>>());
  });

  test('retry() pulihkan state dari error ke success', () async {
    diceResult = 0.1;
    expect(await settle(), isA<AsyncError<List<String>>>());

    diceResult = 0.9;
    await container.read(statsProvider.notifier).retry();

    final state = container.read(statsProvider);
    expect(state, isA<AsyncData<List<String>>>());
    expect(state.value, hasLength(3));
  });
}
