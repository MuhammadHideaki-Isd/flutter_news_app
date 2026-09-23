import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:news_app/features/news/news_provider.dart';

class NewsImage extends StatelessWidget {
  const NewsImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  });
  final String url;
  final double width, height;
  @override
  Widget build(BuildContext c) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: url.isEmpty
        ? _fallback()
        : CachedNetworkImage(
            imageUrl: url,
            width: width,
            height: height,
            fit: BoxFit.cover,
            placeholder: (_, __) => _fallback(),
            errorWidget: (_, __, ___) => _fallback(),
          ),
  );
  Widget _fallback() => Container(
    width: width,
    height: height,
    color: Colors.black12,
    child: const Icon(Icons.image_outlined),
  );
}

class NewsMetadata extends StatelessWidget {
  const NewsMetadata(this.article, {super.key});
  final Article article;
  @override
  Widget build(BuildContext c) {
    final label = article.publishedAt == null
        ? 'Recently'
        : DateFormat('d MMM y, HH:mm').format(article.publishedAt!.toLocal());
    return Text(
      '${article.category.toUpperCase()}  ·  ${article.sourceName}  ·  $label',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        color: Theme.of(c).colorScheme.primary,
      ),
    );
  }
}

class BookmarkButton extends ConsumerWidget {
  const BookmarkButton(this.article, {super.key});
  final Article article;
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final saved = ref.watch(savedProvider).contains(article);
    return IconButton(
      onPressed: () => ref.read(savedProvider.notifier).toggle(article),
      icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
      color: Theme.of(c).colorScheme.primary,
    );
  }
}

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.article, required this.onTap});
  final Article article;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext c) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 12, 15),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(c).dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NewsMetadata(article),
                const SizedBox(height: 5),
                Text(
                  article.headline,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  article.summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(c).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              NewsImage(url: article.imageUrl, width: 88, height: 88),
              Positioned(right: -4, bottom: -4, child: BookmarkButton(article)),
            ],
          ),
        ],
      ),
    ),
  );
}

class FeaturedNewsCard extends StatelessWidget {
  const FeaturedNewsCard({
    super.key,
    required this.article,
    required this.onTap,
  });
  final Article article;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext c) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NewsImage(url: article.imageUrl, width: double.infinity, height: 190),
          const SizedBox(height: 12),
          NewsMetadata(article),
          const SizedBox(height: 6),
          Text(
            article.headline,
            style: const TextStyle(
              fontSize: 24,
              height: 1.14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            article.summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(c).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    ),
  );
}
