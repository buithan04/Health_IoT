import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:health_iot/service/doctor_service.dart';

// --- ENUM & EXTENSION ---
enum NotePriority { high, medium, low }
enum NoteCategory { general, patient, administrative, prescription }

extension PriorityUIExtension on NotePriority {
  Color get color {
    switch (this) {
      case NotePriority.high: return const Color(0xFFEF4444);
      case NotePriority.medium: return const Color(0xFFF59E0B);
      case NotePriority.low: return const Color(0xFF10B981);
    }
  }
  String get label {
    switch (this) {
      case NotePriority.high: return 'Cao';
      case NotePriority.medium: return 'Trung bình';
      case NotePriority.low: return 'Thấp';
    }
  }
  String get code => name.toUpperCase();
}

extension CategoryUIExtension on NoteCategory {
  String get label {
    switch (this) {
      case NoteCategory.general: return 'Chung';
      case NoteCategory.patient: return 'Bệnh nhân';
      case NoteCategory.administrative: return 'Hành chính';
      case NoteCategory.prescription: return 'Đơn thuốc';
    }
  }
  String get code => name.toUpperCase();
}

// --- MODEL UI WRAPPER ---
class NoteUI {
  final int id;
  final String cleanContent;
  final String rawContent;
  final DateTime createdAt;
  final NotePriority priority;
  final NoteCategory category;

  NoteUI({
    required this.id,
    required this.cleanContent,
    required this.rawContent,
    required this.createdAt,
    required this.priority,
    required this.category,
  });
}

class DoctorNotesScreen extends StatefulWidget {
  const DoctorNotesScreen({super.key});

  @override
  State<DoctorNotesScreen> createState() => _DoctorNotesScreenState();
}

class _DoctorNotesScreenState extends State<DoctorNotesScreen> {
  final DoctorService _doctorService = DoctorService();

  List<NoteUI> _allNotes = [];
  List<NoteUI> _filteredNotes = [];
  bool _isLoading = true;

  NoteCategory? _selectedCategory;
  bool _sortByPriority = true;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  // --- 1. LOGIC PARSE TỪ BACKEND ---
  NoteUI _parseNoteFromBackend(Note backendNote) {
    String content = backendNote.content;

    // Mặc định
    NotePriority p = NotePriority.low;
    NoteCategory c = NoteCategory.general;

    // Tách Priority
    if (content.contains('[HIGH]')) {
      p = NotePriority.high;
      content = content.replaceAll('[HIGH]', '');
    } else if (content.contains('[MEDIUM]')) {
      p = NotePriority.medium;
      content = content.replaceAll('[MEDIUM]', '');
    } else if (content.contains('[LOW]')) {
      p = NotePriority.low;
      content = content.replaceAll('[LOW]', '');
    }

    // Tách Category
    for (var cat in NoteCategory.values) {
      String tag = '[${cat.code}]';
      if (content.contains(tag)) {
        c = cat;
        content = content.replaceAll(tag, '');
        break;
      }
    }

    // Xử lý ngày tháng an toàn
    DateTime createdDate = DateTime.now();
    if (backendNote.createdAt != null) {
      try {
        createdDate = DateTime.parse(backendNote.createdAt!);
        // Cộng thêm 7 tiếng nếu server trả về giờ UTC (tùy chỉnh nếu cần)
        // createdDate = createdDate.add(const Duration(hours: 7));
      } catch (e) {
        print("Lỗi parse ngày: $e");
      }
    }

    return NoteUI(
      id: backendNote.id,
      cleanContent: content.trim().isEmpty ? "Không có nội dung" : content.trim(),
      rawContent: backendNote.content,
      createdAt: createdDate,
      priority: p,
      category: c,
    );
  }

  // --- 2. LOGIC FORMAT ĐỂ GỬI LÊN SERVER ---
  String _formatContentForBackend(String text, NotePriority p, NoteCategory c) {
    return "[${p.code}] [${c.code}] $text";
  }

  Future<void> _fetchNotes() async {
    setState(() => _isLoading = true);
    try {
      // Gọi service lấy List<Note>
      final serviceNotes = await _doctorService.getNotes();

      // Map sang NoteUI
      final mappedNotes = serviceNotes.map((n) => _parseNoteFromBackend(n)).toList();

      if (mounted) {
        setState(() {
          _allNotes = mappedNotes;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi UI fetch notes: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<NoteUI> temp = List.from(_allNotes);

    // Lọc theo danh mục
    if (_selectedCategory != null) {
      temp = temp.where((note) => note.category == _selectedCategory).toList();
    }

    // Sắp xếp
    if (_sortByPriority) {
      temp.sort((a, b) => a.priority.index.compareTo(b.priority.index)); // High (0) lên đầu
    } else {
      temp.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Mới nhất lên đầu
    }

    setState(() {
      _filteredNotes = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Ghi chú công việc', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_sortByPriority ? Icons.flag_rounded : Icons.access_time_rounded, color: const Color(0xFF64748B)),
            tooltip: _sortByPriority ? "Xếp theo Ưu tiên" : "Xếp theo Thời gian",
            onPressed: () {
              setState(() {
                _sortByPriority = !_sortByPriority;
                _applyFilters();
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
                : _filteredNotes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) => _buildNoteCard(_filteredNotes[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteBottomSheet(context),
        backgroundColor: const Color(0xFF0D9488),
        icon: const Icon(Icons.add_rounded),
        label: Text('Thêm mới', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          _buildFilterChip(null, 'Tất cả'),
          ...NoteCategory.values.map((cat) => _buildFilterChip(cat, cat.label)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(NoteCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedCategory = category;
            _applyFilters();
          });
        },
        backgroundColor: Colors.grey[100],
        selectedColor: const Color(0xFF0D9488).withOpacity(0.15),
        labelStyle: GoogleFonts.inter(
          color: isSelected ? const Color(0xFF0D9488) : const Color(0xFF64748B),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildNoteCard(NoteUI note) {
    String dateStr = DateFormat('dd/MM HH:mm').format(note.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF64748B).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showNoteBottomSheet(context, note: note),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                      child: Text(note.category.label.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: note.priority.color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          Icon(Icons.flag_rounded, size: 12, color: note.priority.color),
                          const SizedBox(width: 4),
                          Text(note.priority.label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: note.priority.color)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(note.cleanContent, style: GoogleFonts.inter(fontSize: 15, height: 1.5, color: const Color(0xFF334155)), maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateStr, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
                    InkWell(
                      onTap: () => _showDeleteConfirmationDialog(note.id),
                      child: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFFEF4444)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.teal.withOpacity(0.05), shape: BoxShape.circle),
            child: const Icon(Icons.note_alt_rounded, size: 64, color: Colors.teal),
          ),
          const SizedBox(height: 16),
          Text('Chưa có ghi chú nào', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
        ],
      ),
    );
  }

  void _showNoteBottomSheet(BuildContext context, {NoteUI? note}) {
    final isEditing = note != null;
    final controller = TextEditingController(text: note?.cleanContent ?? '');
    NotePriority selectedPrio = note?.priority ?? NotePriority.low;
    NoteCategory selectedCat = note?.category ?? NoteCategory.general;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 24, left: 24, right: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isEditing ? 'Chỉnh sửa ghi chú' : 'Thêm ghi chú mới', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text("Mức độ ưu tiên", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  Row(
                    children: NotePriority.values.map((p) {
                      final isSelected = selectedPrio == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(p.label),
                          selected: isSelected,
                          onSelected: (val) => setModalState(() => selectedPrio = p),
                          selectedColor: p.color.withOpacity(0.2),
                          labelStyle: TextStyle(color: isSelected ? p.color : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                          side: BorderSide(color: isSelected ? p.color : Colors.grey.shade300),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text("Danh mục", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: NoteCategory.values.map((c) {
                      final isSelected = selectedCat == c;
                      return ChoiceChip(
                        label: Text(c.label),
                        selected: isSelected,
                        onSelected: (val) => setModalState(() => selectedCat = c),
                        selectedColor: Colors.teal.withOpacity(0.2),
                        labelStyle: TextStyle(color: isSelected ? Colors.teal : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                        side: BorderSide(color: isSelected ? Colors.teal : Colors.grey.shade300),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Nhập nội dung công việc...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (controller.text.trim().isEmpty) return;
                        final finalContent = _formatContentForBackend(controller.text.trim(), selectedPrio, selectedCat);
                        if (isEditing) {
                          await _doctorService.updateNote(note.id, finalContent);
                        } else {
                          await _doctorService.createNote(finalContent);
                        }
                        if(context.mounted) Navigator.pop(ctx);
                        _fetchNotes();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text('Lưu ghi chú', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              await _doctorService.deleteNote(id);
              _fetchNotes();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}