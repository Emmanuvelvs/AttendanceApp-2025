import 'package:flutter/material.dart';

@immutable
class HomeState {
  final double slidePosition;
  final bool isActive;

  const HomeState({required this.slidePosition, required this.isActive});

  HomeState copyWith({double? slidePosition, bool? isActive}) {
    return HomeState(
      slidePosition: slidePosition ?? this.slidePosition,
      isActive: isActive ?? this.isActive,
    );
  }
}
