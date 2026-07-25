import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/animated_background.dart';
import '../../core/widgets/product_card.dart';
import 'homepage_provider.dart';
import 'search_screen.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  int _selectedCategoryIndex = 0;

  final Map<String, List<Map<String, dynamic>>> _curatedSubcategories = {
    'Eau de Parfum (EDP)': [
      {'name': 'Luxury EDP Collection', 'tag': 'Popular', 'icon': LucideIcons.sparkles},
      {'name': 'Intense EDP Spray', 'tag': 'Long Lasting', 'icon': LucideIcons.flame},
      {'name': 'Signature EDP Edits', 'tag': 'Trending', 'icon': LucideIcons.star},
      {'name': 'Travel Size EDP', 'tag': 'Best Value', 'icon': LucideIcons.packageCheck},
    ],
    'Eau de Toilette (EDT)': [
      {'name': 'Fresh EDT Sprays', 'tag': 'Daily Wear', 'icon': LucideIcons.wind},
      {'name': 'Citrus & Aqua EDT', 'tag': 'Summer Special', 'icon': LucideIcons.droplets},
      {'name': 'Floral EDT Notes', 'tag': 'Top Rated', 'icon': LucideIcons.heart},
      {'name': 'Sport EDT Editions', 'tag': 'Active', 'icon': LucideIcons.zap},
    ],
    'Niche and Classic': [
      {'name': 'Private Blend Niche', 'tag': 'Exclusive', 'icon': LucideIcons.gem},
      {'name': 'Artisanal Perfumes', 'tag': 'Prestige', 'icon': LucideIcons.award},
      {'name': 'Vintage Classics', 'tag': 'Heritage', 'icon': LucideIcons.crown},
      {'name': 'Unisex Niche Elixirs', 'tag': 'Best Seller', 'icon': LucideIcons.sparkles},
    ],
    'Oudh (Oriental)': [
      {'name': 'Pure Cambodi Oud', 'tag': 'Prestige', 'icon': LucideIcons.flame},
      {'name': 'Royal Oud Oil Attar', 'tag': '100% Pure', 'icon': LucideIcons.droplet},
      {'name': 'Smokey Oud Wood', 'tag': 'Signature', 'icon': LucideIcons.shieldCheck},
      {'name': 'Oriental Bakhoor & Incense', 'tag': 'Traditional', 'icon': LucideIcons.sun},
    ],
  };

  final List<Map<String, dynamic>> _fallbackCategories = [
    {
      'id': 'cat-1',
      'name': 'Eau de Parfum (EDP)',
      'icon': LucideIcons.sparkles,
      'discount': 'EXPLORE ALL',
      'subcategories': [
        {'name': 'Luxury EDP Collection', 'tag': 'Popular', 'icon': LucideIcons.sparkles},
        {'name': 'Intense EDP Spray', 'tag': 'Long Lasting', 'icon': LucideIcons.flame},
        {'name': 'Signature EDP Edits', 'tag': 'Trending', 'icon': LucideIcons.star},
        {'name': 'Travel Size EDP', 'tag': 'Best Value', 'icon': LucideIcons.packageCheck},
      ]
    },
    {
      'id': 'cat-2',
      'name': 'Eau de Toilette (EDT)',
      'icon': LucideIcons.droplets,
      'discount': 'EXPLORE ALL',
      'subcategories': [
        {'name': 'Fresh EDT Sprays', 'tag': 'Daily Wear', 'icon': LucideIcons.wind},
        {'name': 'Citrus & Aqua EDT', 'tag': 'Summer Special', 'icon': LucideIcons.droplets},
        {'name': 'Floral EDT Notes', 'tag': 'Top Rated', 'icon': LucideIcons.heart},
        {'name': 'Sport EDT Editions', 'tag': 'Active', 'icon': LucideIcons.zap},
      ]
    },
    {
      'id': 'cat-3',
      'name': 'Niche and Classic',
      'icon': LucideIcons.gem,
      'discount': 'EXCLUSIVE',
      'subcategories': [
        {'name': 'Private Blend Niche', 'tag': 'Exclusive', 'icon': LucideIcons.gem},
        {'name': 'Artisanal Perfumes', 'tag': 'Prestige', 'icon': LucideIcons.award},
        {'name': 'Vintage Classics', 'tag': 'Heritage', 'icon': LucideIcons.crown},
        {'name': 'Unisex Niche Elixirs', 'tag': 'Best Seller', 'icon': LucideIcons.sparkles},
      ]
    },
    {
      'id': 'cat-4',
      'name': 'Oudh (Oriental)',
      'icon': LucideIcons.flame,
      'discount': 'EXPLORE ALL',
      'subcategories': [
        {'name': 'Pure Cambodi Oud', 'tag': 'Prestige', 'icon': LucideIcons.flame},
        {'name': 'Royal Oud Oil Attar', 'tag': '100% Pure', 'icon': LucideIcons.droplet},
        {'name': 'Smokey Oud Wood', 'tag': 'Signature', 'icon': LucideIcons.shieldCheck},
        {'name': 'Oriental Bakhoor & Incense', 'tag': 'Traditional', 'icon': LucideIcons.sun},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final homepageData = ref.watch(homepageDataProvider);
    final apiCategories = homepageData.value?['categories'] as List?;

    // Extract all products from homepage data
    final rawProductsList = [
      ...?(homepageData.value?['featured_products'] as List?),
      ...?(homepageData.value?['new_arrivals'] as List?),
      ...?(homepageData.value?['best_sellers'] as List?),
      ...?(homepageData.value?['products'] as List?),
    ];

    final Map<String, dynamic> uniqueProductsMap = {};
    for (var p in rawProductsList) {
      if (p is Map<String, dynamic>) {
        final id = p['id']?.toString() ?? p['name']?.toString() ?? '';
        if (id.isNotEmpty) uniqueProductsMap[id] = p;
      }
    }
    final List<dynamic> allProducts = uniqueProductsMap.values.toList();

    final categoriesList = (apiCategories != null && apiCategories.isNotEmpty)
        ? apiCategories.map((c) {
            final catName = c['name']?.toString() ?? 'Category';
            final apiSubs = (c['subcategories'] as List? ?? []).map((sub) => {
              'name': sub['name']?.toString() ?? 'Collection',
              'tag': 'Best Value',
              'icon': LucideIcons.sparkles,
            }).toList();

            final subcatsResolved = apiSubs.isNotEmpty
                ? apiSubs
                : (_curatedSubcategories[catName] ?? [
                    {'name': 'Featured Fragrances', 'tag': 'Top Rated', 'icon': LucideIcons.star},
                    {'name': 'New Arrivals', 'tag': 'Trending', 'icon': LucideIcons.sparkles},
                    {'name': 'Best Sellers', 'tag': 'Popular', 'icon': LucideIcons.flame},
                    {'name': 'Gift Collections', 'tag': 'Special', 'icon': LucideIcons.gift},
                  ]);

            return {
              'id': c['id']?.toString() ?? '',
              'name': catName,
              'discount': 'EXPLORE ALL',
              'subcategories': subcatsResolved,
            };
          }).toList()
        : _fallbackCategories;

    final selectedCat = categoriesList[_selectedCategoryIndex.clamp(0, categoriesList.length - 1)];

    // Filter products matching current category
    final String catId = selectedCat['id']?.toString() ?? '';
    final String catNameLower = selectedCat['name']?.toString().toLowerCase() ?? '';

    List<dynamic> categoryProducts = allProducts.where((p) {
      if (p is! Map<String, dynamic>) return false;
      final pCatId = p['category_id']?.toString() ?? '';
      final pCatName = (p['category']?['name']?.toString() ?? p['category_name']?.toString() ?? '').toLowerCase();
      final pTitle = (p['title']?.toString() ?? p['name']?.toString() ?? '').toLowerCase();

      if (catId.isNotEmpty && pCatId == catId) return true;
      if (catNameLower.isNotEmpty && (pCatName.contains(catNameLower) || catNameLower.contains(pCatName))) return true;

      if (catNameLower.contains('edp') && (pTitle.contains('edp') || pTitle.contains('parfum'))) return true;
      if (catNameLower.contains('edt') && (pTitle.contains('edt') || pTitle.contains('toilette'))) return true;
      if (catNameLower.contains('oud') && (pTitle.contains('oud') || pTitle.contains('attar'))) return true;
      if (catNameLower.contains('niche') && (pTitle.contains('niche') || pTitle.contains('intense'))) return true;

      return false;
    }).toList();

    // If specific filter returns no match, show all available products as fallback so screen is never blank
    if (categoryProducts.isEmpty && allProducts.isNotEmpty) {
      categoryProducts = allProducts;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 16,
        title: Text(
          'CATEGORIES',
          style: GoogleFonts.montserrat(
            color: AppTheme.textNeutral,
            fontSize: R.font(context, 13),
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search, size: 20, color: AppTheme.textNeutral),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBackground(
        child: Row(
          children: [
            // ── Left Sidebar (Root Categories) ──
            Container(
              width: 105,
              color: AppTheme.surfaceLight,
              child: ListView.builder(
                itemCount: categoriesList.length,
                itemBuilder: (context, index) {
                  final cat = categoriesList[index];
                  final isSelected = index == _selectedCategoryIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategoryIndex = index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppTheme.surfaceLight,
                        border: Border(
                          left: BorderSide(
                            color: isSelected ? AppTheme.primaryRose : Colors.transparent,
                            width: 4,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat['icon'] as IconData? ?? LucideIcons.layers,
                            size: 20,
                            color: isSelected ? AppTheme.primaryRose : AppTheme.textMuted,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat['name']?.toString() ?? '',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppTheme.primaryRose : AppTheme.textNeutral,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Right Main Grid (Subcategories & Live Products) ──
            Expanded(
              child: Container(
                color: Colors.white,
                child: CustomScrollView(
                  key: ValueKey(_selectedCategoryIndex),
                  slivers: [
                    // Promotional Header Banner
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SearchScreen(
                                  categoryId: selectedCat['id']?.toString(),
                                  title: selectedCat['name']?.toString(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFF0F5), Color(0xFFFFE4E6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.primaryRose.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedCat['name']?.toString().toUpperCase() ?? '',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryRose,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'EXPLORE ALL PRODUCTS (${categoryProducts.length})',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.textNeutral,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(LucideIcons.chevronRight, size: 18, color: AppTheme.primaryRose),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),



                    // Live Products Section Title
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'FEATURED PRODUCTS',
                              style: GoogleFonts.montserrat(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            Text(
                              '${categoryProducts.length} ITEMS',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryRose,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Live Product Cards Grid
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.67,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 10,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index < 0 || index >= categoryProducts.length) {
                              return const SizedBox.shrink();
                            }
                            final productMap = categoryProducts[index] as Map<String, dynamic>;
                            return ProductCard(product: productMap);
                          },
                          childCount: categoryProducts.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
