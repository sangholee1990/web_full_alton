import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 스크롤 상태를 관리하는 Provider
final isScrolledProvider = StateProvider<bool>((ref) {
  return false;
});