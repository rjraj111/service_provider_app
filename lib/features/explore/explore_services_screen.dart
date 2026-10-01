import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// Model representing a service category with photographic background and fallback icon
class ServiceCategoryItem {
  final String id;
  final String title;
  final String subtitle;
  final String startingPrice;
  final IconData icon;
  final Color themeColor;
  final String imageUrl;
  final bool isTrending;
  final bool isNew;
  final String group;
  final double rating;
  final String availablePros;
  final List<SubServiceItem> subServices;

  const ServiceCategoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.startingPrice,
    required this.icon,
    required this.themeColor,
    required this.imageUrl,
    this.isTrending = false,
    this.isNew = false,
    required this.group,
    this.rating = 4.8,
    required this.availablePros,
    this.subServices = const [],
  });
}

/// Sub-service item for quick booking within a category
class SubServiceItem {
  final String title;
  final String duration;
  final String price;
  final String description;

  const SubServiceItem({
    required this.title,
    required this.duration,
    required this.price,
    required this.description,
  });
}

/// A comprehensive Urban Company / Daraz style 'Explore Services' screen.
/// Features local Image.asset inside Stack with premium dark gradient overlays
/// for high text readability, live category search, and booking sheets.
class ExploreServicesScreen extends StatefulWidget {
  final String? initialQuery;

  const ExploreServicesScreen({super.key, this.initialQuery});

  @override
  State<ExploreServicesScreen> createState() => _ExploreServicesScreenState();
}

class _ExploreServicesScreenState extends State<ExploreServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGroup = 'All';

  final List<String> _groups = [
    'All',
    'Trending 🔥',
    'Repairs',
    'Home Care',
    'Beauty & Grooming',
    'Logistics',
  ];

  late final List<ServiceCategoryItem> _allCategories;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
    _allCategories = _initCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ServiceCategoryItem> _initCategories() {
    return const [
      ServiceCategoryItem(
        id: 'ac_repair',
        title: 'AC Repair & Service',
        subtitle: 'Jet servicing, gas charge & repairs',
        startingPrice: '৳499',
        icon: Icons.ac_unit_rounded,
        themeColor: Color(0xFF06B6D4), // Cyan
        imageUrl: 'lib/assets/images/ac repair.png',
        isTrending: true,
        group: 'Repairs',
        rating: 4.9,
        availablePros: '38 Pros nearby',
        subServices: [
          SubServiceItem(
            title: 'Split AC Master Foam Servicing',
            duration: '45 mins',
            price: '৳650',
            description: 'High-pressure foam wash of indoor and outdoor cooling coils.',
          ),
          SubServiceItem(
            title: 'Refrigerant Gas Leakage & Refill',
            duration: '60 mins',
            price: '৳1,800',
            description: 'Leak test, copper pipe brazing, and complete gas charging.',
          ),
          SubServiceItem(
            title: 'Complete AC Uninstallation & Fitting',
            duration: '90 mins',
            price: '৳1,200',
            description: 'Safe disassembly and new mounting with level bracket adjustment.',
          ),
        ],
      ),
      ServiceCategoryItem(
        id: 'home_cleaning',
        title: 'Deep Home Cleaning',
        subtitle: 'Kitchen, bathroom & full house',
        startingPrice: '৳799',
        icon: Icons.cleaning_services_rounded,
        themeColor: Color(0xFF10B981), // Emerald
        imageUrl: 'lib/assets/images/home cleaning.png',
        isTrending: true,
        group: 'Home Care',
        rating: 4.85,
        availablePros: '52 Pros nearby',
        subServices: [
          SubServiceItem(
            title: 'Deep Bathroom Sanitization',
            duration: '60 mins',
            price: '৳799',
            description: 'Anti-bacterial chemical scrub of tiles, grout, fittings & basin.',
          ),
          SubServiceItem(
            title: 'Complete Kitchen Degreasing',
            duration: '90 mins',
            price: '৳1,299',
            description: 'Exhaust fan, stove burners, grease traps and kitchen cabinets.',
          ),
          SubServiceItem(
            title: 'Full Apartment Spring Cleaning (3BHK)',
            duration: '4 hours',
            price: '৳3,499',
            description: 'Complete floor scrubbing, window wipe down, vacuuming & dusting.',
          ),
        ],
      ),
      ServiceCategoryItem(
        id: 'plumbing',
        title: 'Plumbing Solutions',
        subtitle: 'Leaks, fittings, pipe drainage & pumps',
        startingPrice: '৳350',
        icon: Icons.plumbing_rounded,
        themeColor: Color(0xFF3B82F6), // Blue
        imageUrl: 'lib/assets/images/plumbing solution.png',
        isTrending: true,
        group: 'Repairs',
        rating: 4.92,
        availablePros: '44 Pros nearby',
        subServices: [
          SubServiceItem(
            title: 'Water Pipe Leak Repair & Joint Replacement',
            duration: '45 mins',
            price: '৳450',
            description: 'Detection of seepage, PVC pipe cutting, and new fittings.',
          ),
          SubServiceItem(
            title: 'Clogged Basin & Waste Drain Opening',
            duration: '30 mins',
            price: '৳350',
            description: 'Manual snake cable and chemical unblocking of blockages.',
          ),
          SubServiceItem(
            title: 'Water Motor Pump Repair & Wiring',
            duration: '75 mins',
            price: '৳850',
            description: 'Capacitor replacement, bearing lubrication and pump setup.',
          ),
        ],
      ),
      ServiceCategoryItem(
        id: 'electrician',
        title: 'Certified Electrician',
        subtitle: 'Switchboards, fans, lights & wiring',
        startingPrice: '৳300',
        icon: Icons.electrical_services_rounded,
        themeColor: Color(0xFFF59E0B), // Amber
        imageUrl: 'lib/assets/images/electrician working pic.png',
        group: 'Repairs',
        rating: 4.88,
        availablePros: '60 Pros nearby',
        subServices: [
          SubServiceItem(
            title: 'Ceiling Fan Installation & Regulator Setup',
            duration: '30 mins',
            price: '৳300',
            description: 'Balancing blades, hanging bracket test, and speed switch.',
          ),
          SubServiceItem(
            title: 'Short Circuit & Fuse Diagnostic',
            duration: '45 mins',
            price: '৳500',
            description: 'Troubleshooting tripping breakers and high-voltage sockets.',
          ),
        ],
      ),
      ServiceCategoryItem(
        id: 'appliance_repair',
        title: 'Appliance Repair',
        subtitle: 'Washing machines, fridges & ovens',
        startingPrice: '৳450',
        icon: Icons.home_repair_service_rounded,
        themeColor: Color(0xFF8B5CF6), // Violet
        imageUrl: 'lib/assets/images/appliance repair.png',
        group: 'Repairs',
        rating: 4.79,
        availablePros: '29 Pros nearby',
        subServices: [
          SubServiceItem(
            title: 'Refrigerator Cooling & Gas Check',
            duration: '60 mins',
            price: '৳700',
            description: 'Thermostat inspection, relay replacement and coil defrost.',
          ),
          SubServiceItem(
            title: 'Washing Machine Drum & Motor Repair',
            duration: '75 mins',
            price: '৳800',
            description: 'Fixing spin cycle failure, drain pump blockage, and belt.',
          ),
        ],
      ),
      ServiceCategoryItem(
        id: 'carpentry',
        title: 'Carpentry & Furniture',
        subtitle: 'Door lock, hinge, cabinet & bed repair',
        startingPrice: '৳400',
        icon: Icons.carpenter_rounded,
        themeColor: Color(0xFFD97706), // Warm Amber
        imageUrl: 'lib/assets/images/curpentry and furniture.png',
        group: 'Repairs',
        rating: 4.82,
        availablePros: '22 Pros nearby',
        subServices: [
          SubServiceItem(
            title: 'Door Lock & Handle Replacement',
            duration: '40 mins',
            price: '৳400',
            description: 'Installation of high-security mortise or cylindrical locks.',
          ),
        ],
      ),
      ServiceCategoryItem(
        id: 'painting',
        title: 'Painting & Decor',
        subtitle: 'Interior, exterior & damp wall fix',
        startingPrice: '৳1,200',
        icon: Icons.format_paint_rounded,
        themeColor: Color(0xFFEF4444), // Red
        imageUrl: 'lib/assets/images/painting and decor.png',
        group: 'Home Care',
        rating: 4.86,
        availablePros: '19 Pros nearby',
      ),
      ServiceCategoryItem(
        id: 'pest_control',
        title: 'Pest Control Services',
        subtitle: 'Cockroach, bedbug & termite relief',
        startingPrice: '৳650',
        icon: Icons.pest_control_rounded,
        themeColor: Color(0xFF84CC16), // Lime
        imageUrl: 'lib/assets/images/pest control services.png',
        group: 'Home Care',
        rating: 4.75,
        availablePros: '27 Pros nearby',
      ),
      ServiceCategoryItem(
        id: 'beauty_salon',
        title: 'Salon & Spa for Women',
        subtitle: 'Facial, manicure, pedicure & waxing',
        startingPrice: '৳550',
        icon: Icons.face_retouching_natural_rounded,
        themeColor: Color(0xFFEC4899), // Pink
        imageUrl: 'lib/assets/images/salon and spa.png',
        isTrending: true,
        group: 'Beauty & Grooming',
        rating: 4.93,
        availablePros: '41 Pros nearby',
      ),
      ServiceCategoryItem(
        id: 'mens_grooming',
        title: 'Men\'s Grooming',
        subtitle: 'Haircut, beard styling & head massage',
        startingPrice: '৳350',
        icon: Icons.content_cut_rounded,
        themeColor: Color(0xFF6366F1), // Indigo
        imageUrl: 'lib/assets/images/mens groaming.png',
        group: 'Beauty & Grooming',
        rating: 4.81,
        availablePros: '33 Pros nearby',
      ),
      ServiceCategoryItem(
        id: 'smart_home',
        title: 'Smart Home & CCTV',
        subtitle: 'Camera setup, smart bell & sensors',
        startingPrice: '৳999',
        icon: Icons.videocam_rounded,
        themeColor: Color(0xFF4F46E5), // Deep Violet
        imageUrl: 'lib/assets/images/smart home and cctv.png',
        isNew: true,
        group: 'Repairs',
        rating: 4.87,
        availablePros: '16 Pros nearby',
      ),
      ServiceCategoryItem(
        id: 'packers_movers',
        title: 'Packers & Movers',
        subtitle: 'Apartment shifting & fragile moving',
        startingPrice: '৳2,500',
        icon: Icons.local_shipping_rounded,
        themeColor: Color(0xFFEA580C), // Orange
        imageUrl: 'lib/assets/images/packers and movers.png',
        group: 'Logistics',
        rating: 4.79,
        availablePros: '18 Pros nearby',
      ),
      ServiceCategoryItem(
        id: 'car_wash',
        title: 'Car Wash & Detailing',
        subtitle: 'Waterless wash, interior vacuum & polish',
        startingPrice: '৳450',
        icon: Icons.local_car_wash_rounded,
        themeColor: Color(0xFF0284C7), // Sky Blue
        imageUrl: 'lib/assets/images/car wash.png',
        group: 'Home Care',
        rating: 4.84,
        availablePros: '24 Pros nearby',
      ),
      ServiceCategoryItem(
        id: 'laundry_service',
        title: 'Laundry & Dry Clean',
        subtitle: 'Wash, fold, steam press & premium care',
        startingPrice: '৳250',
        icon: Icons.local_laundry_service_rounded,
        themeColor: Color(0xFF0D9488), // Teal
        imageUrl: 'lib/assets/images/laundry and dry wash.png',
        group: 'Home Care',
        rating: 4.78,
        availablePros: '31 Pros nearby',
      ),
    ];
  }

  List<ServiceCategoryItem> get _filteredCategories {
    final query = _searchController.text.trim().toLowerCase();

    return _allCategories.where((item) {
      final matchesGroup = _selectedGroup == 'All' ||
          (_selectedGroup == 'Trending 🔥' && item.isTrending) ||
          item.group == _selectedGroup;

      if (!matchesGroup) return false;

      if (query.isEmpty) return true;

      return item.title.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query) ||
          item.group.toLowerCase().contains(query);
    }).toList();
  }

  void _openCategoryDetail(ServiceCategoryItem category) {
    HapticFeedback.lightImpact();
    final colors = AppColorsResolved.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.45,
        maxChildSize: 0.94,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textHint.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    // Photographic Hero Banner with Image.asset
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              category.imageUrl,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.1),
                                    Colors.black.withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 18,
                              bottom: 14,
                              right: 18,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          category.title,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(color: Colors.black87, blurRadius: 10),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.55),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.white30),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${category.rating}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Starts ${category.startingPrice} · ${category.availablePros}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF5EFFD4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Quick Specs
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: category.themeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: category.themeColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            category.availablePros,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: category.themeColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            '30-Day Service Warranty',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      category.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),
                    Divider(color: colors.border, height: 1),
                    const SizedBox(height: 16),

                    Text(
                      'Select a Service Package',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sub-services cards
                    if (category.subServices.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Standard fixed rate: ${category.startingPrice} per visit.',
                            style: TextStyle(fontSize: 13, color: colors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ...category.subServices.map(
                        (sub) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colors.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sub.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      sub.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colors.textSecondary,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          '⏱ ${sub.duration}',
                                          style: TextStyle(fontSize: 11.5, color: colors.textHint),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          sub.price,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  context.push(
                                    '/provider-details',
                                    extra: {
                                      'service': '${category.title} · ${sub.title}',
                                      'name': 'Top Verified Provider',
                                      'rate': sub.price,
                                      'avatarUrl': category.imageUrl,
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Book',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.push(
                            '/provider-details',
                            extra: {
                              'service': category.title,
                              'rate': category.startingPrice,
                              'avatarUrl': category.imageUrl,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: category.themeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          'Find Best ${category.title} Professional',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayCategories = _filteredCategories;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(colors, isDark),
      body: Column(
        children: [
          // ─── Subtle Search Bar ─────────────────────────────────────────
          _buildSearchBar(colors, isDark),

          // ─── Filter Category Chips ──────────────────────────────────────
          _buildFilterChips(colors, isDark),

          const SizedBox(height: 8),

          // ─── Categories GridView with Stack + Image.asset + Dark Gradient Overlay
          Expanded(
            child: displayCategories.isEmpty
                ? _buildEmptyState(colors)
                : GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.86,
                    ),
                    itemCount: displayCategories.length,
                    itemBuilder: (context, index) {
                      final item = displayCategories[index];
                      return _buildPhotographicCategoryCard(
                        item: item,
                        colors: colors,
                        isDark: isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ─── App Bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(AppColorsResolved colors, bool isDark) {
    return AppBar(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: colors.textPrimary),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            'Over 100+ doorstep certified services',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: Icon(Icons.notifications_outlined, color: colors.textPrimary, size: 22),
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  // ─── Subtle Search Bar ──────────────────────────────────────────────────────

  Widget _buildSearchBar(AppColorsResolved colors, bool isDark) {
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          style: TextStyle(fontSize: 14, color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search AC, Plumbing, Cleaning, Salon...',
            hintStyle: TextStyle(fontSize: 13, color: colors.textHint),
            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.cancel_rounded, size: 18, color: colors.textHint),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // ─── Filter Category Chips ──────────────────────────────────────────────────

  Widget _buildFilterChips(AppColorsResolved colors, bool isDark) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _groups.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final group = _groups[idx];
          final isSelected = _selectedGroup == group;

          return Center(
            child: ChoiceChip(
              label: Text(group),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() => _selectedGroup = group);
                  HapticFeedback.selectionClick();
                }
              },
              selectedColor: AppColors.primary,
              backgroundColor: colors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.primary : colors.border,
                width: isSelected ? 1.4 : 1,
              ),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : colors.textSecondary,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  // ─── Category Card with Image.asset inside Stack + Dark Gradient ────────────

  Widget _buildPhotographicCategoryCard({
    required ServiceCategoryItem item,
    required AppColorsResolved colors,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: item.themeColor.withValues(alpha: isDark ? 0.35 : 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ─── 1. Category Image ────────────────────────────────────────────
            Image.asset(
              item.imageUrl,
              fit: BoxFit.cover,
            ),

            // ─── 2. Dark Gradient Overlay at the Bottom ───────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.28),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                    Colors.black.withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.30, 0.65, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // ─── 3. Card Content & Tappable InkWell ───────────────────────────
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openCategoryDetail(item),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Badges (Trending / New) & Price Tag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (item.isTrending)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF97316), Color(0xFFEF4444)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                '🔥 Trending',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            )
                          else if (item.isNew)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),

                          // Price Tag with dark glassmorphism
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white24, width: 0.8),
                            ),
                            child: Text(
                              item.startingPrice,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF5EFFD4),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Bottom Content: Category Name, Subtitle, and Rating
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bold, Crisp, Bright White Category Name
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.3,
                              height: 1.2,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 10),
                                Shadow(color: Colors.black87, blurRadius: 6),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Subtitle
                          Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.82),
                              fontWeight: FontWeight.w500,
                              shadows: const [
                                Shadow(color: Colors.black, blurRadius: 6),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Rating & Pros
                          Row(
                            children: [
                              const Text('⭐ ', style: TextStyle(fontSize: 11)),
                              Text(
                                '${item.rating}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                ' · ${item.availablePros.split(' ').first} Pros',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.78),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty State ────────────────────────────────────────────────────────────

  Widget _buildEmptyState(AppColorsResolved colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded, size: 48, color: colors.textHint),
            ),
            const SizedBox(height: 16),
            Text(
              'No services found',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try searching for another term like "AC", "Cleaner", or "Plumbing".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() => _selectedGroup = 'All');
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset Search & Filters'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
