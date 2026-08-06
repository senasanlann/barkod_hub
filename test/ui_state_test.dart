import 'package:barkod_hub/shared/state/ui_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UiState.idle creates idle state', () {
    final state = UiState<String>.idle();
    expect(state.status, UiStatus.idle);
    expect(state.isIdle, isTrue);
    expect(state.isLoading, isFalse);
    expect(state.isSuccess, isFalse);
    expect(state.isError, isFalse);
  });

  test('UiState.loading creates loading state', () {
    final state = UiState<String>.loading();
    expect(state.status, UiStatus.loading);
    expect(state.isLoading, isTrue);
  });

  test('UiState.success holds data and cache flag', () {
    final state = UiState<String>.success('test_data', isFromCache: true);
    expect(state.status, UiStatus.success);
    expect(state.isSuccess, isTrue);
    expect(state.data, 'test_data');
    expect(state.isFromCache, isTrue);
  });

  test('UiState.error holds error message', () {
    final state = UiState<String>.error('Sunucu yanıt vermedi');
    expect(state.status, UiStatus.error);
    expect(state.isError, isTrue);
    expect(state.errorMessage, 'Sunucu yanıt vermedi');
  });
}
