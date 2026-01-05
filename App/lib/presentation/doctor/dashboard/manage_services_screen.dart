import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:health_iot/service/doctor_service.dart';

class ManageServicesScreen extends StatefulWidget {
  final String doctorId;
  const ManageServicesScreen({super.key, required this.doctorId});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  final DoctorService _doctorService = DoctorService();
  List<dynamic> _services = [];
  List<dynamic> _filteredServices = [];

  // Trạng thái chọn nhiều
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchServices();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredServices = List.from(_services);
      } else {
        _filteredServices = _services.where((s) {
          final name = (s['name'] ?? '').toString().toLowerCase();
          return name.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    try {
      final data = await _doctorService.getAppointmentTypes(widget.doctorId);
      if (mounted) {
        setState(() {
          _services = data;
          _filteredServices = data;
          _isLoading = false;
          _isSelectionMode = false;
          _selectedIds.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    }
  }

  // --- ACTIONS ---

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _deleteSelected() async {
    final count = _selectedIds.length;
    final confirm = await _showConfirmDialog(
      title: "Xóa $count dịch vụ?",
      content: "Hành động này không thể hoàn tác.",
      confirmText: "Xóa vĩnh viễn",
      isDestructive: true,
    );

    if (confirm == true) {
      int successCount = 0;
      for (final id in _selectedIds) {
        final success = await _doctorService.deleteService(id);
        if (success) successCount++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đã xóa $successCount dịch vụ")),
        );
        _fetchServices();
      }
    }
  }

  Future<void> _deleteSingle(String id) async {
    final confirm = await _showConfirmDialog(
      title: "Xóa dịch vụ này?",
      content: "Dịch vụ sẽ bị ẩn khỏi danh sách đặt lịch.",
      confirmText: "Xóa",
      isDestructive: true,
    );

    if (confirm == true) {
      final success = await _doctorService.deleteService(id);
      if (success) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa dịch vụ")));
        _fetchServices();
      }
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text(content, style: GoogleFonts.inter()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Hủy", style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red : Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(confirmText, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openForm({Map<String, dynamic>? service}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _ServiceForm(
        service: service,
        onSubmit: (data) async {
          Navigator.pop(ctx);
          bool success;
          if (service == null) {
            success = await _doctorService.createService(data);
          } else {
            success = await _doctorService.updateService(service['id'].toString(), data);
          }

          if (success) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lưu thành công")));
            _fetchServices();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F766E)))
                : _filteredServices.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _fetchServices,
              color: const Color(0xFF0F766E),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: _filteredServices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _filteredServices[index];
                  final id = item['id'].toString();
                  final isSelected = _selectedIds.contains(id);

                  return _ServiceItemCard(
                    key: ValueKey(id),
                    service: item,
                    isSelected: isSelected,
                    isSelectionMode: _isSelectionMode,
                    onTap: () {
                      if (_isSelectionMode) {
                        _toggleSelection(id);
                      } else {
                        // Có thể mở form sửa khi tap
                        _openForm(service: item);
                      }
                    },
                    onLongPress: () {
                      if (!_isSelectionMode) {
                        setState(() {
                          _isSelectionMode = true;
                          _selectedIds.add(id);
                        });
                      }
                    },
                    onEdit: () => _openForm(service: item),
                    onDelete: () => _deleteSingle(id),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: !_isSelectionMode
          ? FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFF0F766E),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text("Tạo mới", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
      )
          : null,
      bottomNavigationBar: _isSelectionMode ? _buildSelectionBottomBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (_isSelectionMode) {
      return AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => setState(() {
            _isSelectionMode = false;
            _selectedIds.clear();
          }),
        ),
        title: Text(
          "${_selectedIds.length} đã chọn",
          style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        elevation: 1,
        shadowColor: Colors.black12,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (_selectedIds.length == _filteredServices.length) {
                  _selectedIds.clear();
                } else {
                  _selectedIds.addAll(_filteredServices.map((e) => e['id'].toString()));
                }
              });
            },
            child: Text(
              _selectedIds.length == _filteredServices.length ? "Bỏ chọn" : "Chọn tất cả",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF0F766E)),
            ),
          )
        ],
      );
    }

    return AppBar(
      title: const Text('Dịch vụ khám'),
      centerTitle: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.inter(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF1E293B)),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildSearchBar() {
    if (_isSelectionMode) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Tìm kiếm dịch vụ...",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        style: GoogleFonts.inter(),
      ),
    );
  }

  Widget _buildSelectionBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: Colors.red.shade200,
          ),
          icon: const Icon(Icons.delete_outline),
          label: Text("Xóa (${_selectedIds.length})"),
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
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(Icons.medical_services_outlined, size: 48, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            "Chưa có dịch vụ nào",
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            "Nhấn nút + để thêm gói khám mới",
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// --- ITEM CARD SỬA ĐỔI (SỬ DỤNG POPUP MENU THAY VÌ SLIDABLE) ---
class _ServiceItemCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceItemCard({
    super.key,
    required this.service,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final price = num.tryParse(service['price'].toString()) ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0FDFA) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: const Color(0xFF0F766E), width: 2)
            : Border.all(color: Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (isSelectionMode) ...[
                  Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? const Color(0xFF0F766E) : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 16),
                ],
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCFBF1), // Teal 100
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.medical_services_rounded, color: Color(0xFF0F766E), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['name'],
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _InfoChip(icon: Icons.timer_outlined, text: "${service['duration_minutes']} phút", color: Colors.orange),
                          const SizedBox(width: 8),
                          _InfoChip(icon: Icons.attach_money, text: formatCurrency.format(price), color: Colors.green),
                        ],
                      ),
                      if (service['description'] != null && service['description'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            service['description'],
                            style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                // MENU 3 CHẤM THAY THẾ CHO VUỐT
                if (!isSelectionMode)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue, size: 20),
                            SizedBox(width: 12),
                            Text("Chỉnh sửa"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 12),
                            Text("Xóa dịch vụ"),
                          ],
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _InfoChip({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
      ],
    );
  }
}

class _ServiceForm extends StatefulWidget {
  final Map<String, dynamic>? service;
  final Function(Map<String, dynamic>) onSubmit;

  const _ServiceForm({this.service, required this.onSubmit});

  @override
  State<_ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<_ServiceForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _durationCtrl;
  late TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.service?['name'] ?? '');
    _priceCtrl = TextEditingController(text: widget.service?['price']?.toString() ?? '');
    _durationCtrl = TextEditingController(text: widget.service?['duration_minutes']?.toString() ?? '30');
    _descCtrl = TextEditingController(text: widget.service?['description'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.service == null ? "Thêm dịch vụ mới" : "Cập nhật dịch vụ",
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel("Tên dịch vụ"),
            TextFormField(
              controller: _nameCtrl,
              decoration: _inputDecoration("VD: Khám tổng quát, Tư vấn online..."),
              validator: (v) => v!.isEmpty ? "Vui lòng nhập tên" : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Chi phí (VNĐ)"),
                      TextFormField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number, // Chỉ cho nhập số
                        decoration: _inputDecoration("VD: 500000"),
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Vui lòng nhập giá";

                          // Loại bỏ dấu chấm/phẩy nếu người dùng nhập định dạng tiền tệ (tùy chọn)
                          // v = v.replaceAll('.', '').replaceAll(',', '');

                          final price = double.tryParse(v);
                          if (price == null) return "Giá không hợp lệ";
                          if (price < 0) return "Giá không được âm";

                          // [FIX] Kiểm tra giới hạn Database NUMERIC(10, 2)
                          // Giá trị phải nhỏ hơn 100.000.000 (100 triệu)
                          if (price >= 100000000) {
                            return "Giá phải nhỏ hơn 100 triệu";
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Thời lượng (Phút)"),
                      TextFormField(
                        controller: _durationCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("VD: 30"),
                        validator: (v) => v!.isEmpty ? "Nhập phút" : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel("Mô tả (Tùy chọn)"),
            TextFormField(
              controller: _descCtrl,
              decoration: _inputDecoration("Thông tin chi tiết về gói khám..."),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSubmit({
                      'name': _nameCtrl.text,
                      'price': double.tryParse(_priceCtrl.text) ?? 0,
                      'duration': int.tryParse(_durationCtrl.text) ?? 30,
                      'description': _descCtrl.text,
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  "Lưu thông tin",
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF64748B), fontSize: 14)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5)),
    );
  }
}