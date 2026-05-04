import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../core/constans/Colors.dart';
import '../../../core/presentation/widgets/custom_button.dart';
import '../../products/data/product.dart';
import '../../products/data/product_repository.dart';
import '../logic/sales_bloc.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({Key? key}) : super(key: key);

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final Map<Product, Set<String>> _cart = {};

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

  int get _totalItems {
    return _cart.values.fold(0, (sum, serials) => sum + serials.length);
  }

  double get _totalPrice {
    return _cart.entries.fold(
      0,
      (sum, entry) => sum + (entry.key.price * entry.value.length),
    );
  }

  void _showSerialSelectionModal(BuildContext context, Product product) {
    _cart[product] ??= {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Seleccionar Seriales\n${product.name}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${_cart[product]!.length} seleccionados',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: product.units.map((unit) {
                          final isSelected = _cart[product]!.contains(
                            unit.barcode,
                          );
                          return FilterChip(
                            label: Text(unit.barcode),
                            selected: isSelected,
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            checkmarkColor: AppColors.primary,
                            onSelected: (bool selected) {
                              setModalState(() {
                                if (selected) {
                                  _cart[product]!.add(unit.barcode);
                                } else {
                                  _cart[product]!.remove(unit.barcode);
                                }
                              });
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    onPressed: () => Navigator.pop(modalContext),
                    child: const Text('Confirmar Selección'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _processSale() {
    final hasItems = _cart.values.any((serials) => serials.isNotEmpty);

    if (!hasItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un producto para vender'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final List<Map<String, dynamic>> lines = [];

    _cart.forEach((product, serials) {
      if (serials.isNotEmpty) {
        lines.add({
          "productId": product.id,
          "productName": product.name,
          "unitPrice": product.price,
          "lineTotal": product.price * serials.length,
          "barcodes": serials.toList(),
        });
      }
    });

    final Map<String, dynamic> payload = {"total": _totalPrice, "lines": lines};

    context.read<SalesBloc>().add(ProcessSaleEvent(payload));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SalesBloc, SalesState>(
      listener: (context, state) {
        if (state is SaleProcessSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is SaleProcessError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Punto de Venta')),

        body: PagingListener<int, Product>(
          controller: _pagingController,
          builder: (context, state, fetchNextPage) => RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              _pagingController.refresh();
            },
            child: PagedListView<int, Product>(
              state: state,
              fetchNextPage: fetchNextPage,
              padding: const EdgeInsets.all(16.0),
              builderDelegate: PagedChildBuilderDelegate<Product>(
                itemBuilder: (context, product, index) {
                  final selectedQty = _cart[product]?.length ?? 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Stock disponible: ${product.stock} un'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (selectedQty > 0)
                            Text(
                              '$selectedQty seleccionados',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      onTap: () => _showSerialSelectionModal(context, product),
                    ),
                  );
                },
                noItemsFoundIndicatorBuilder: (_) => const Center(
                  child: Text('No hay productos en el inventario.'),
                ),
                firstPageErrorIndicatorBuilder: (_) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: CustomButton(
                      onPressed: () => _pagingController.refresh(),
                      child: const Text('Reintentar conexión'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total ($_totalItems items)',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Text(
                      '\$${_totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BlocBuilder<SalesBloc, SalesState>(
                  builder: (context, state) {
                    final bool isLoading = state is SaleProcessing;

                    return CustomButton(
                      onPressed: (_totalItems > 0 && !isLoading)
                          ? _processSale
                          : null,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Procesar Venta',
                              style: TextStyle(fontSize: 16),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
