import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/services/news_service.dart';

class Article {
  const Article({
    required this.id,
    required this.headline,
    required this.summary,
    required this.imageUrl,
    required this.sourceName,
    required this.sourceUrl,
    required this.publishedAt,
    required this.category,
  });
  final String id, headline, summary, imageUrl, sourceName, sourceUrl, category;
  final DateTime? publishedAt;
  factory Article.fromApi(NewsArticle a, String category) => Article(
    id: a.url ?? '${a.title}-${a.publishedAt}',
    headline: (a.title ?? 'Untitled story').replaceAll(
      RegExp(r'\s*\[\+\d+ chars\]$'),
      '',
    ),
    summary:
        a.description ??
        a.content ??
        'Open this story to read the full report from the original publisher.',
    imageUrl: a.urlToImage ?? '',
    sourceName: a.source?.name ?? 'Unknown source',
    sourceUrl: a.url ?? '',
    publishedAt: DateTime.tryParse(a.publishedAt ?? ''),
    category: category,
  );
}

final repositoryProvider = Provider((_) => NewsRepository(NewsService()));

class NewsRepository {
  NewsRepository(this.service);
  final NewsService service;
  Future<List<Article>> headlines(String cat) async =>
      (await service.getTopHeadlines(
            category: cat == 'Top stories' ? null : cat.toLowerCase(),
          )).articles
          .map(
            (a) => Article.fromApi(a, cat == 'Top stories' ? 'General' : cat),
          )
          .toList();
  Future<List<Article>> search(String q) async => (await service.searchNews(
    query: q,
    sortBy: 'publishedAt',
  )).articles.map((a) => Article.fromApi(a, 'Search')).toList();
}

final categoryProvider = StateProvider<String>((_) => 'Top stories');
final latestNewsProvider = FutureProvider<List<Article>>(
  (ref) => ref.watch(repositoryProvider).headlines(ref.watch(categoryProvider)),
);
final searchQueryProvider = StateProvider<String>((_) => '');
final searchResultsProvider = FutureProvider<List<Article>>((ref) {
  final q = ref.watch(searchQueryProvider);
  return q.trim().isEmpty
      ? Future.value(const [])
      : ref.watch(repositoryProvider).search(q);
});
final savedProvider = StateNotifierProvider<SavedNotifier, Set<Article>>(
  (_) => SavedNotifier(),
);

class SavedNotifier extends StateNotifier<Set<Article>> {
  SavedNotifier() : super({});
  void toggle(Article a) {
    final updated = {...state};
    updated.contains(a) ? updated.remove(a) : updated.add(a);
    state = updated;
  }
}

final topicsProvider = StateNotifierProvider<TopicsNotifier, Set<String>>(
  (_) => TopicsNotifier(),
);

class TopicsNotifier extends StateNotifier<Set<String>> {
  TopicsNotifier() : super({'Technology', 'Science', 'Health'});
  void toggle(String t) {
    final updated = {...state};
    updated.contains(t) ? updated.remove(t) : updated.add(t);
    state = updated;
  }
}

final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.light);
