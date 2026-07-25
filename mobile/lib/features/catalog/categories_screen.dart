import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_responsive.dart';
import 'homepage_provider.dart';
import 'search_screen.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _fallbackCategories = [
    {
      'id': 'cat-1',
      'name': 'Perfumes',
      'icon': LucideIcons.sparkles,
      'discount': 'UP TO 50% OFF',
      'subcategories': [
        {'name': 'Luxury Perfumes', 'image': 'https://kozmocart.com/media/products/oudh_khayali.jpg', 'tag': 'Popular'},
        {'name': 'Eau De Parfum', 'image': 'https://kozmocart.com/media/products/marj.jpg', 'tag': 'Trending'},
        {'name': 'Eau De Toilette', 'image': 'https://kozmocart.com/media/products/blue_star.jpg', 'tag': 'New'},
        {'name': 'Pocket Perfumes', 'image': 'https://kozmocart.com/media/products/white_oudh.jpg', 'tag': 'Flat 40% Off'},
      ]
    },
    {
      'id': 'cat-2',
      'name': 'Attar & Oils',
      'icon': LucideIcons.droplet,
      'discount': 'FLAT 30% OFF',
      'subcategories': [
        {'name': 'Pure Oud Oils', 'image': 'https://kozmocart.com/media/products/cambodi_oud.jpg', 'tag': 'Premium'},
        {'name': 'Non-Alcoholic Attar', 'image': 'https://kozmocart.com/media/products/musk_rizali.jpg', 'tag': 'Best Seller'},
        {'name': 'Floral Concentrates', 'image': 'https://kozmocart.com/media/products/rose_gulab.jpg', 'tag': 'Top Rated'},
      ]
    },
    {
      'id': 'cat-3',
      'name': 'Gift Sets',
      'icon': LucideIcons.gift,
      'discount': 'MIN 40% OFF',
      'subcategories': [
        {'name': 'Luxury Hamper Sets', 'image': 'https://kozmocart.com/media/products/luxury_box.jpg', 'tag': 'Gifting'},
        {'name': 'Travel Editions', 'image': 'https://kozmocart.com/media/products/travel_kit.jpg', 'tag': 'New'},
        {'name': 'Couple Fragrance Combos', 'image': 'https://kozmocart.com/media/products/combo_set.jpg', 'tag': 'Hot'},
      ]
    },
    {
      'id': 'cat-4',
      'name': 'Body & Sprays',
      'icon': LucideIcons.wind,
      'discount': 'UNDER ₹499',
      'subcategories': [
        {'name': 'Body Mists', 'image': 'https://kozmocart.com/media/products/mist_fresh.jpg', 'tag': 'Fresh'},
        {'name': 'Deodorant Sprays', 'image': 'https://kozmocart.com/media/products/deo_spray.jpg', 'tag': 'Daily Essential'},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final homepageData = ref.watch(homepageDataProvider);
    final apiCategories = homepageData.value?['categories'] as List?;

    final categoriesList = (apiCategories != null && apiCategories.isNotEmpty)
        ? apiCategories.map((c) => {
            'id': c['id']?.toString() ?? '',
            'name': c['name']?.toString() ?? 'Category',
            'discount': 'EXPLORE ALL',
            'subcategories': (c['subcategories'] as List? ?? []).map((sub) => {
              'name': sub['name']?.toString() ?? 'Collection',
              'image': sub['image']?.toString() ?? '',
              'tag': 'Best Value',
            }).toList(),
          }).toList()
        : _fallbackCategories;

    final selectedCat = categoriesList[_selectedCategoryIndex.clamp(0, categoriesList.length - 1)];
    final subcats = (selectedCat['subcategories'] as List?) ?? [];

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
      body: Row(
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
                            fontSize: 10.5,
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

          // ── Right Main Grid (Subcategories & Collections) ──
          Expanded(
            child: Container(
              color: Colors.white,
              child: CustomScrollView(
                slivers: [
                  // Promotional Header Banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryRose,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedCat['discount']?.toString() ?? 'EXCLUSIVE OFFERS',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
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

                  // Category Sub-sections Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: Text(
                        'EXPLORE COLLECTIONS',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),

                  // Subcategories Grid
                  SliverPadding(
                    padding: const EdgeInsets.all(14),
                    sliver: subcats.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  'Explore all items in ${selectedCat['name']}',
                                  style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted),
                                ),
                              ),
                            ),
                          )
                        : SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final sub = subcats[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => SearchScreen(initialQuery: sub['name']?.toString()),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceLight,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppTheme.borderLight, width: 0.8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF0F0F2),
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                            ),
                                            child: const Center(
                                              child: Icon(LucideIcons.package, size: 28, color: AppTheme.textMuted),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                sub['name']?.toString() ?? '',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.textNeutral,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                sub['tag']?.toString() ?? 'SHOP NOW',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.discountOrange,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: subcats.length,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
