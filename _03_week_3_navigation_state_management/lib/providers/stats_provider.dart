import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final diceProvider =
    Provider<double Function()>((ref) => Random().nextDouble);

final statsDelayProvider =
    Provider<Duration>((ref) => const Duration(seconds: 2));

class StatsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() => _fetch();

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<List<String>> _fetch() async {
    await Future.delayed(ref.watch(statsDelayProvider));
    if (ref.watch(diceProvider)() < 0.3) {
      throw Exception('Gagal mengambil statistik');
    }
    return const ['Pengguna aktif: 1.204', 'Todo selesai: 87%', 'Rating: 4.8'];
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(StatsNotifier.new,
        retry: (_, _) => null);
