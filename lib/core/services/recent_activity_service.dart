import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RecentActivity {
  final String id;
  final String title;
  final String subtitle;
  final String route;
  final String icon;
  final DateTime timestamp;
  final Map<String, dynamic>? extra;

  const RecentActivity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.timestamp,
    this.extra,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'route': route,
        'icon': icon,
        'timestamp': timestamp.toIso8601String(),
        'extra': extra,
      };

  factory RecentActivity.fromJson(Map<String, dynamic> json) => RecentActivity(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        route: json['route'] as String,
        icon: json['icon'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        extra: json['extra'] as Map<String, dynamic>?,
      );
}

class RecentActivityService {
  static const String _boxName = 'settings';
  static const String _key = 'recent_activities';
  static const int _maxItems = 30;

  List<RecentActivity> getActivities() {
    final box = Hive.box(_boxName);
    final raw = box.get(_key, defaultValue: <String>[]) as List;
    return raw
        .map((e) => RecentActivity.fromJson(json.decode(e as String) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> record({
    required String id,
    required String title,
    required String subtitle,
    required String route,
    required String icon,
    Map<String, dynamic>? extra,
  }) async {
    final box = Hive.box(_boxName);
    final raw = box.get(_key, defaultValue: <String>[]) as List;
    final list = raw.cast<String>();

    list.removeWhere((e) {
      final item = RecentActivity.fromJson(json.decode(e) as Map<String, dynamic>);
      return item.id == id;
    });

    final activity = RecentActivity(
      id: id,
      title: title,
      subtitle: subtitle,
      route: route,
      icon: icon,
      timestamp: DateTime.now(),
      extra: extra,
    );

    list.insert(0, json.encode(activity.toJson()));

    if (list.length > _maxItems) {
      list.removeRange(_maxItems, list.length);
    }

    await box.put(_key, list);
  }
}

final recentActivityProvider = Provider<RecentActivityService>((ref) {
  return RecentActivityService();
});

final recentActivitiesProvider = Provider<List<RecentActivity>>((ref) {
  final service = ref.watch(recentActivityProvider);
  return service.getActivities();
});

Future<void> recordActivity({
  required String id,
  required String title,
  String subtitle = '',
  required String route,
  required String icon,
  Map<String, dynamic>? extra,
}) async {
  final service = RecentActivityService();
  await service.record(
    id: id,
    title: title,
    subtitle: subtitle,
    route: route,
    icon: icon,
    extra: extra,
  );
}
