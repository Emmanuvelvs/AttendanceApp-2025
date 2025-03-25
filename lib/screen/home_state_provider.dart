// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:riverpod/riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'home_state.dart';

// class HomeStateNotifier extends StateNotifier<HomeState> {
//   HomeStateNotifier() : super(const HomeState(slidePosition: 0.0, isActive: false)) {
//     _init();
//   }

//   // Initialize state asynchronously
//   Future<void> _init() async {
//     await _loadState();
//   }

//   Future<void> _loadState() async {
//     final prefs = await SharedPreferences.getInstance();
//     double slidePos = prefs.getDouble('slidePosition') ?? 0.0;
//     bool activeState = prefs.getBool('isActive') ?? false;

//     state = HomeState(slidePosition: slidePos, isActive: activeState);
//   }

//   Future<void> _saveState() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setDouble('slidePosition', state.slidePosition);
//     await prefs.setBool('isActive', state.isActive);
//   }

//   void updateSlidePosition(double newPosition) {
//     state = state.copyWith(slidePosition: newPosition);
//     _saveState();
//   }

//   void toggleActiveState() {
//     state = state.copyWith(isActive: !state.isActive);
//     _saveState();
//   }
// }

// // ✅ Use FutureProvider for proper async initialization
// final homeStateProvider = StateNotifierProvider<HomeState>((ref) {
//   final notifier = HomeStateNotifier();
//    notifier._init();  // Ensure state is loaded before use
//   return notifier.state;
// }
// );
