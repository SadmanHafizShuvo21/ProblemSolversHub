import 'package:flutter/material.dart';
import 'package:problem_solvers_hub/ui/models/dummy_data.dart';
import 'package:problem_solvers_hub/ui/widgets/post_card.dart';
import 'package:problem_solvers_hub/ui/widgets/section_title.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.tune))],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 22),
            Text(
              'Search by topic or challenge',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search problems, tags, authors',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 22),
            const SectionTitle(label: 'Trending topics'),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kFeedTopics.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return Chip(
                    label: Text(kFeedTopics[index]),
                    backgroundColor: const Color(0xFFE8EBFF),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle(label: 'Top insights'),
            Expanded(
              child: ListView.separated(
                itemCount: kFeedPosts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return PostCard(post: kFeedPosts[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
