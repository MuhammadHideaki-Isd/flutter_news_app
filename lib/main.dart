// ignore_for_file: use_null_aware_elements, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/core/theme/app_theme.dart';
import 'package:news_app/features/news/news_provider.dart';
import 'package:news_app/shared/widgets/news_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');
  runApp(const ProviderScope(child: InforminApp()));
}

class InforminApp extends ConsumerWidget {
  const InforminApp({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    title: 'Informin',
    theme: informinTheme(Brightness.light),
    darkTheme: informinTheme(Brightness.dark),
    themeMode: ref.watch(themeModeProvider),
    routerConfig: router,
  );
}

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (c, s, child) => NewsShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomePage()),
        GoRoute(path: '/explore', builder: (_, __) => const ExplorePage()),
        GoRoute(path: '/saved', builder: (_, __) => const SavedPage()),
        GoRoute(path: '/following', builder: (_, __) => const ForYouPage()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      ],
    ),
    GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
    GoRoute(
      path: '/article',
      builder: (c, s) => ArticlePage(article: s.extra! as Article),
    ),
  ],
);

class NewsShell extends StatelessWidget {
  const NewsShell({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext c) {
    final loc = GoRouterState.of(c).uri.path;
    final index = [
      '/home',
      '/explore',
      '/saved',
      '/following',
      '/profile',
    ].indexOf(loc).clamp(0, 4);
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            c.go(['/home', '/explore', '/saved', '/following', '/profile'][i]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Latest',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'For you',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header(this.title, {super.key, this.action});
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
        ),
        if (action != null) action!,
      ],
    ),
  );
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  static const categories = [
    'Top stories',
    'General',
    'Technology',
    'Business',
    'Sports',
    'Health',
    'Science',
    'Entertainment',
  ];
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final category = ref.watch(categoryProvider);
    final news = ref.watch(latestNewsProvider);
    return ListView(
      children: [
        Header(
          'informin',
          action: IconButton(
            onPressed: () => c.push('/search'),
            icon: const Icon(Icons.search),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 8),
          child: Text(
            'Latest news',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: categories
                .map(
                  (x) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(x),
                      selected: category == x,
                      onSelected: (_) =>
                          ref.read(categoryProvider.notifier).state = x,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        news.when(
          loading: () => const _FeedLoading(),
          error: (_, __) =>
              _ErrorRetry(onRetry: () => ref.invalidate(latestNewsProvider)),
          data: (items) => items.isEmpty
              ? const _Empty(
                  'No current stories are available for this category.',
                )
              : Column(
                  children: [
                    FeaturedNewsCard(
                      article: items.first,
                      onTap: () => c.push('/article', extra: items.first),
                    ),
                    if (items.length > 1) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 18, 20, 4),
                        child: Text(
                          'More to know',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ...items
                          .skip(1)
                          .map(
                            (a) => NewsCard(
                              article: a,
                              onTap: () => c.push('/article', extra: a),
                            ),
                          ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final topics = ref.watch(topicsProvider);
    const all = [
      'General',
      'Technology',
      'Business',
      'Sports',
      'Health',
      'Science',
      'Entertainment',
    ];
    return ListView(
      children: [
        Header(
          'Explore',
          action: IconButton(
            onPressed: () => c.push('/search'),
            icon: const Icon(Icons.search),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Text('Find a subject worth following.'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: all
                .map(
                  (t) => ActionChip(
                    avatar: Icon(
                      topics.contains(t) ? Icons.check : Icons.add,
                      size: 16,
                    ),
                    label: Text(t),
                    onPressed: () =>
                        ref.read(topicsProvider.notifier).toggle(t),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Trending now',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
        ),
        ref
            .watch(latestNewsProvider)
            .when(
              loading: () => const _FeedLoading(),
              error: (_, __) =>
                  const _Empty('Trending stories are unavailable.'),
              data: (a) => Column(
                children: a
                    .take(3)
                    .map(
                      (x) => NewsCard(
                        article: x,
                        onTap: () => c.push('/article', extra: x),
                      ),
                    )
                    .toList(),
              ),
            ),
      ],
    );
  }
}

class SavedPage extends ConsumerWidget {
  const SavedPage({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final saved = ref.watch(savedProvider);
    return ListView(
      children: [
        const Header('Saved articles'),
        if (saved.isEmpty)
          const _Empty(
            'Save stories for later\nBookmarks from your reading will appear here.',
          )
        else
          ...saved.map(
            (a) => NewsCard(
              article: a,
              onTap: () => c.push('/article', extra: a),
            ),
          ),
      ],
    );
  }
}

class ForYouPage extends ConsumerWidget {
  const ForYouPage({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final topics = ref.watch(topicsProvider);
    final news = ref.watch(latestNewsProvider);
    return ListView(
      children: [
        const Header('For you'),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
          child: Text('Based on the topics you follow'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 8,
            children: topics.map((x) => Chip(label: Text(x))).toList(),
          ),
        ),
        news.when(
          loading: () => const _FeedLoading(),
          error: (_, __) =>
              const _Empty('Your personalized feed is unavailable.'),
          data: (all) {
            final items = all
                .where((a) => topics.contains(a.category))
                .toList();
            return items.isEmpty
                ? const _Empty(
                    'Follow topics in Explore to personalize this feed.',
                  )
                : Column(
                    children: items
                        .map(
                          (a) => NewsCard(
                            article: a,
                            onTap: () => c.push('/article', extra: a),
                          ),
                        )
                        .toList(),
                  );
          },
        ),
      ],
    );
  }
}

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final topics = ref.watch(topicsProvider);
    return ListView(
      children: [
        const Header('Preferences'),
        const ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text('Your Informin'),
          subtitle: Text('Personalize your news experience'),
        ),
        const Divider(),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode_outlined),
          title: const Text('Dark mode'),
          subtitle: Text(mode == ThemeMode.dark ? 'On' : 'Off'),
          value: mode == ThemeMode.dark,
          onChanged: (_) => ref.read(themeModeProvider.notifier).state =
              mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
        ),
        ListTile(
          leading: const Icon(Icons.topic_outlined),
          title: const Text('Followed topics'),
          subtitle: Text(topics.isEmpty ? 'None selected' : topics.join(', ')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => c.go('/explore'),
        ),
      ],
    );
  }
}

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});
  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final q = ref.watch(searchQueryProvider);
    final result = ref.watch(searchResultsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (v) =>
                  ref.read(searchQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search the news',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () =>
                      ref.read(searchQueryProvider.notifier).state =
                          controller.text,
                  icon: const Icon(Icons.arrow_forward),
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: q.isEmpty
                  ? const _Empty('Search for a topic, source, or story.')
                  : result.when(
                      loading: () => const _FeedLoading(),
                      error: (_, __) =>
                          const _Empty('Search is unavailable right now.'),
                      data: (items) => items.isEmpty
                          ? const _Empty(
                              'No stories found. Try another search.',
                            )
                          : ListView(
                              children: items
                                  .map(
                                    (a) => NewsCard(
                                      article: a,
                                      onTap: () => c.push('/article', extra: a),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticlePage extends ConsumerWidget {
  const ArticlePage({super.key, required this.article});
  final Article article;
  @override
  Widget build(BuildContext c, WidgetRef ref) => Scaffold(
    appBar: AppBar(actions: [BookmarkButton(article)]),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      children: [
        NewsMetadata(article),
        const SizedBox(height: 12),
        Text(
          article.headline,
          style: const TextStyle(
            fontSize: 30,
            height: 1.1,
            fontWeight: FontWeight.w700,
            letterSpacing: -.8,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          article.sourceName,
          style: TextStyle(color: Theme.of(c).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 18),
        NewsImage(url: article.imageUrl, width: double.infinity, height: 230),
        const SizedBox(height: 18),
        Text(
          article.summary,
          style: const TextStyle(
            fontSize: 19,
            height: 1.42,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'This is a short preview. Continue to the original publisher to read the complete report.',
          style: TextStyle(fontSize: 16, height: 1.55),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: article.sourceUrl.isEmpty
              ? null
              : () => launchUrl(
                  Uri.parse(article.sourceUrl),
                  mode: LaunchMode.externalApplication,
                ),
          icon: const Icon(Icons.open_in_new),
          label: Text('Read full article at ${article.sourceName}'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ],
    ),
  );
}

class _FeedLoading extends StatelessWidget {
  const _FeedLoading();
  @override
  Widget build(BuildContext c) => const Padding(
    padding: EdgeInsets.all(44),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _Empty extends StatelessWidget {
  const _Empty(this.message);
  final String message;
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.fromLTRB(32, 80, 32, 20),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(color: Theme.of(c).colorScheme.onSurfaceVariant),
    ),
  );
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.all(40),
    child: Column(
      children: [
        const Text('We couldn’t load the latest news.'),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    ),
  );
}
