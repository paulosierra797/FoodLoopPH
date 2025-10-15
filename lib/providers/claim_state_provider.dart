import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to track recently claimed items for immediate UI feedback
final claimedItemsProvider =
    StateNotifierProvider<ClaimedItemsNotifier, Set<String>>((ref) {
  return ClaimedItemsNotifier();
});

class ClaimedItemsNotifier extends StateNotifier<Set<String>> {
  ClaimedItemsNotifier() : super({});

  // Add an item to the claimed list
  void addClaimedItem(String itemId) {
    state = {...state, itemId};

    // Remove from claimed list after a delay to allow real-time updates to catch up
    Future.delayed(Duration(seconds: 3), () {
      removeClaimedItem(itemId);
    });
  }

  // Remove an item from the claimed list
  void removeClaimedItem(String itemId) {
    final newState = Set<String>.from(state);
    newState.remove(itemId);
    state = newState;
  }

  // Check if an item is recently claimed
  bool isRecentlyClaimed(String itemId) {
    return state.contains(itemId);
  }
}
