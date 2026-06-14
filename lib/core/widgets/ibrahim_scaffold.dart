import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_strings.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

class IbrahimScaffold extends ConsumerStatefulWidget {
  final Widget child;
  const IbrahimScaffold({super.key, required this.child});

  @override
  ConsumerState<IbrahimScaffold> createState() => _IbrahimScaffoldState();
}

class _IbrahimScaffoldState extends ConsumerState<IbrahimScaffold> {

  void _onTabTapped(int index) {
    ref.read(currentTabProvider.notifier).state = index;
    switch (index) {
      case 0: context.go('/'); break;
      case 1: context.go('/quran'); break;
      case 2: context.go('/books'); break;
      case 3: context.push('/ai-assistant'); break;
      case 4: context.go('/explore'); break;
      case 5: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: ref.watch(currentTabProvider),
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.home_ar,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: AppStrings.quran_ar,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: AppStrings.books_ar,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: AppStrings.aiAssistant_ar,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: AppStrings.explore_ar,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppStrings.profile_ar,
          ),
        ],
      ),
    );
  }
}
