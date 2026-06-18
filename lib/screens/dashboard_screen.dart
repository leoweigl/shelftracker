import 'package:flutter/material.dart';
import 'package:shelftracker/screens/reading_log_screen.dart';
import '../utils/book_actions.dart';
import 'book_list_screen.dart';
import 'wishlist_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _comingSoon(BuildContext context, String what) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$what coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ShelfTracker')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('Reading Log'),
          const SizedBox(height: 8),
          _CardGrid(
            children: [
              _DashboardCard(
                icon: Icons.auto_stories,
                label: 'View\nLog',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReadingLogScreen()),
                ),
              ),
              _DashboardCard(
                icon: Icons.done_all,
                label: 'Log\nRead',
                onTap: () => showLogReadOptions(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader('Book Management'),
          const SizedBox(height: 8),
          _CardGrid(
            children: [
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
                label: 'Add',
                onTap: () => showAddOptions(context),
              ),
              _DashboardCard(
                icon: Icons.category,
                label: 'Categories',
                onTap: () => _comingSoon(context, 'Category overview'),
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
        ],
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
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
