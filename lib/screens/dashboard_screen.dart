import 'package:flutter/material.dart';
import 'package:shelftracker/screens/reading_log_screen.dart';
import '../utils/book_actions.dart';
import 'book_list_screen.dart';
import 'wishlist_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ShelfTracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _CardGrid(
          children: [
            _DashboardCard(
              icon: Icons.auto_stories,
              label: 'Reading\nLog',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReadingLogScreen()),
              ),
            ),
            _DashboardCard(
              icon: Icons.shelves,
              label: 'Bookshelf',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookListScreen()),
              ),
            ),
            _DashboardCard(
              icon: Icons.add_circle_outline,
              label: 'Add Book',
              onTap: () => showAddBookOptions(context),
            ),
            _DashboardCard(
              icon: Icons.favorite_border,
              label: 'Wishlist',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardGrid extends StatelessWidget {
  final List<Widget> children;
  const _CardGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: children,
    );
  }
}
