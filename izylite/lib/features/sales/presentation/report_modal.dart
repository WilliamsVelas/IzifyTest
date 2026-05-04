import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:izylite/core/constans/Colors.dart';
import '../../../core/presentation/widgets/custom_button.dart';
import '../../products/data/product.dart';
import '../../products/data/product_repository.dart';

class ReportModal extends StatefulWidget {
  const ReportModal({Key? key}) : super(key: key);

  static Future<Map<String, dynamic>?> show(BuildContext context) {
    final productsRepo = context.read<ProductsRepository>();

    return showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => RepositoryProvider.value(
        value: productsRepo,
        child: const ReportModal(),
      ),
    );
  }

  @override
  State<ReportModal> createState() => _ReportModalState();
}

class _ReportModalState extends State<ReportModal> {
  DateTimeRange? _selectedDateRange;
  Product? _selectedProduct;

  late final _pagingController = PagingController<int, Product>(
    getNextPageKey: (state) =>
    state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) =>
        context.read<ProductsRepository>().getProducts(page: pageKey),
  );

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final DateTime now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _selectedDateRange ?? DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _generateReport() {
    final Map<String, dynamic> filters = {};

    if (_selectedDateRange != null) {
      filters['startDate'] = _selectedDateRange!.start.toIso8601String();
      filters['endDate'] = _selectedDateRange!.end.toIso8601String();
    }

    if (_selectedProduct != null) {
      filters['productId'] = _selectedProduct!.id;
      filters['productName'] = _selectedProduct!.name;
    }

    Navigator.pop(context, filters);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generar Reporte',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Filtra los datos para exportar. Si lo dejas en blanco, se generará el reporte general.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          const Text('Rango de Fechas', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDateRange,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDateRange == null
                          ? 'Seleccionar fechas (Opcional)'
                          : '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                      style: TextStyle(
                        color: _selectedDateRange == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  if (_selectedDateRange != null)
                    GestureDetector(
                      onTap: () => setState(() => _selectedDateRange = null),
                      child: const Icon(Icons.close, color: Colors.grey, size: 20),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filtrar por Producto', style: TextStyle(fontWeight: FontWeight.bold)),
              if (_selectedProduct != null)
                GestureDetector(
                  onTap: () => setState(() => _selectedProduct = null),
                  child: const Text('Limpiar', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: PagingListener<int, Product>(
                controller: _pagingController,
                builder: (context, state, fetchNextPage) => PagedListView<int, Product>(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  padding: const EdgeInsets.all(8.0),
                  builderDelegate: PagedChildBuilderDelegate<Product>(
                    itemBuilder: (context, product, index) {
                      final isSelected = _selectedProduct?.id == product.id;

                      return Card(
                        elevation: 0,
                        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? Colors.blue : Colors.transparent,
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          title: Text(product.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: Colors.blue)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedProduct = product;
                            });
                          },
                        ),
                      );
                    },
                    noItemsFoundIndicatorBuilder: (_) => const Center(
                      child: Text('No hay productos disponibles.'),
                    ),
                    firstPageErrorIndicatorBuilder: (_) => Center(
                      child: CustomButton(
                        onPressed: () => _pagingController.refresh(),
                        child: const Text('Reintentar'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          CustomButton(
            onPressed: _generateReport,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Descargar Reporte', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
