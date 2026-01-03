import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_iot/service/article_service.dart';
import 'package:app_iot/models/patient/article_model.dart'; // <--- IMPORT MODEL

class HealthArticlesScreen extends StatefulWidget {
  const HealthArticlesScreen({super.key});

  @override
  State<HealthArticlesScreen> createState() => _HealthArticlesScreenState();
}

class _HealthArticlesScreenState extends State<HealthArticlesScreen> {
  final ArticleService _service = ArticleService();

  // Dùng List<Article> chuẩn
  List<Article> _articles = [];
  bool _isLoading = true;

  final List<String> _categories = ['Tất cả', 'Sức khỏe chung', 'Dinh dưỡng', 'Tim mạch'];
  String _selectedCategory = 'Tất cả';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() => _isLoading = true);

    // Service trả về List<Article> xịn
    final data = await _service.getArticles(
      category: _selectedCategory,
      search: _searchQuery,
    );

    if (mounted) {
      setState(() {
        _articles = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Bài viết sức khỏe',
          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: Column(
        children: [
          _CustomHeaderContent(
            categories: _categories,
            selectedIndex: _categories.indexOf(_selectedCategory),
            onCategorySelected: (index) {
              setState(() {
                _selectedCategory = _categories[index];
              });
              _loadArticles();
            },
            onSearchSubmitted: (value) {
              setState(() {
                _searchQuery = value;
              });
              _loadArticles();
            },
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _articles.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 50, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text("Không tìm thấy bài viết nào", style: GoogleFonts.inter(color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                final article = _articles[index];

                // Truyền Object Article vào Card (Code sạch hơn)
                return _ArticleCard(
                  article: article, // <--- Thay vì truyền từng trường lẻ tẻ
                  onTap: () {
                    final url = Uri.encodeComponent(article.contentUrl);
                    final title = Uri.encodeComponent(article.title);
                    context.push('/health-articles/read?url=$url&title=$title');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- CẬP NHẬT WIDGET CON ---

// (Giữ nguyên _CustomHeaderContent và _SearchBar vì không đổi logic)
class _CustomHeaderContent extends StatelessWidget {
  // ... Copy lại code cũ của bạn vào đây ...
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;
  final Function(String) onSearchSubmitted;

  const _CustomHeaderContent({
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
    required this.onSearchSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.cyan.shade500],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchBar(onSubmitted: onSearchSubmitted),
          const SizedBox(height: 16),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return ActionChip(
                  label: Text(categories[index]),
                  onPressed: () => onCategorySelected(index),
                  backgroundColor: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                  side: BorderSide.none,
                  labelStyle: GoogleFonts.inter(
                    color: isSelected ? const Color(0xFF14B8A6) : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final Function(String) onSubmitted;
  const _SearchBar({required this.onSubmitted});
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: (value) => onSubmitted(value),
      textInputAction: TextInputAction.search,
      style: GoogleFonts.inter(fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Tìm kiếm bài viết...',
        hintStyle: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
        filled: true, 
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        isDense: true,
      ),
    );
  }
}

// CẬP NHẬT: Nhận vào Model Article
class _ArticleCard extends StatelessWidget {
  final Article article; // Dùng Model
  final VoidCallback onTap;

  const _ArticleCard({
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bìa (Model đã xử lý URL rồi, dùng luôn)
            Image.network(
              article.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(height: 180, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)));
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(article.category.toUpperCase(), style: GoogleFonts.inter(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.1)),
                      Text(article.sourceName, style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(article.title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(article.description, style: GoogleFonts.inter(color: Colors.grey[700], height: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}