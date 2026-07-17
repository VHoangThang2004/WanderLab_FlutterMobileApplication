import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/destination_provider.dart';
import 'destination_detail_screen.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DestinationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Search
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Khám phá thế giới',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Bạn muốn đi đâu?',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => provider.searchDestinations(value),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm điểm đến...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.tune, color: Colors.white, size: 20),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Categories
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: provider.categories.length,
                itemBuilder: (context, index) {
                  final category = provider.categories[index];
                  final isSelected = category == provider.selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          provider.setCategory(category);
                        }
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : Colors.grey.shade300,
                        ),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Destinations Grid
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.destinations.isEmpty
                      ? const Center(child: Text('Không tìm thấy điểm đến nào.'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: provider.destinations.length,
                          itemBuilder: (context, index) {
                            final dest = provider.destinations[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration: const Duration(milliseconds: 500),
                                    pageBuilder: (_, __, ___) => DestinationDetailScreen(destination: dest),
                                    transitionsBuilder: (_, animation, __, child) {
                                      return FadeTransition(opacity: animation, child: child);
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Hero(
                                        tag: 'dest_${dest.id}',
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.asset(
                                                dest.imageUrl,
                                                fit: BoxFit.cover,
                                              ),
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              dest.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on, size: 12, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    'Việt Nam', // Mock location
                                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.star, color: Colors.amber, size: 14),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${dest.rating}',
                                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '\$${dest.price.toInt()}',
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
