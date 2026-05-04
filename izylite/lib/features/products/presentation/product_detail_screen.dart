import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:izylite/features/products/presentation/widgets/barcode_card.dart';
import '../../../core/constans/Colors.dart';
import '../../../core/presentation/widgets/custom_button.dart';
import '../../../core/presentation/widgets/custom_input.dart';
import '../data/product.dart';
import '../logic/product_bloc.dart';
import 'create_product_modal.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
    : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late List<dynamic> _localUnits;
  late int _localStock;

  @override
  void initState() {
    super.initState();
    _localUnits = List.from(widget.product.units);
    _localStock = widget.product.stock;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );

          if (state.isProductDeleted) {
            Navigator.pop(context, true);
            return;
          }

          if (state.deletedUnitId != null) {
            setState(() {
              _localUnits.removeWhere((unit) => unit.id == state.deletedUnitId);
              _localStock = _localUnits.length;
            });
          }

          if (state.addedUnits != null && state.addedUnits!.isNotEmpty) {
            setState(() {
              _localUnits.addAll(state.addedUnits!);
              _localStock = _localUnits.length;
            });
          }
        } else if (state is ProductError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Detalle de Producto')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Material(
                  color: AppColors.base200,
                  borderRadius: BorderRadius.circular(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.inventory_2,
                          color: AppColors.primary,
                          size: 40,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.name,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Stock: $_localStock un',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.base500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SERIALES DISPONIBLES',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.base600,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showAddSerialModal(context, widget.product.id);
                      },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Agregar serial',
                    ),
                  ],
                ),
              ),

              Expanded(
                child: state is ProductLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _localUnits.length,
                        itemBuilder: (context, index) {
                          final unit = _localUnits[index];
                          return BarcodeCard(
                            barcode: unit.barcode,
                            onDelete: () {
                              _confirmDisableUnit(
                                context,
                                unit.id,
                                unit.barcode,
                              );
                            },
                          );
                        },
                      ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              backgroundColor: Colors.red.shade50,
                              onPressed: state is ProductLoading
                                  ? null
                                  : () => _confirmDeleteProduct(context),
                              child: const Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              onPressed: state is ProductLoading
                                  ? null
                                  : () async {
                                      final bool? success =
                                          await CreateProductModal.show(
                                            context,
                                            product: widget.product,
                                          );

                                      if (success == true) {
                                        Navigator.pop(context, true);
                                      }
                                    },
                              child: const Text('Editar Producto'),
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
        );
      },
    );
  }

  void _showAddSerialModal(BuildContext context, String productId) {
    final TextEditingController _serialController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nuevo Serial',
              style: Theme.of(
                modalContext,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            CustomInput(
              label: 'Código de Barras / Serial',
              hint: 'Ej: SN-123456',
              controller: _serialController,
              prefixIcon: const Icon(
                Icons.qr_code_scanner,
                color: AppColors.primary,
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                _submitSerial(context, _serialController, productId);
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              onPressed: () =>
                  _submitSerial(context, _serialController, productId),
              child: const Text('Confirmar Registro'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitSerial(
    BuildContext context,
    TextEditingController controller,
    String productId,
  ) {
    final String newSerial = controller.text.trim();
    if (newSerial.isNotEmpty) {
      context.read<ProductBloc>().add(AddUnitEvent(productId, newSerial));
      Navigator.pop(context);
    }
  }

  void _confirmDisableUnit(
    BuildContext context,
    String unitId,
    String barcode,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Deshabilitar Serial'),
        content: Text(
          '¿Estás seguro de que deseas deshabilitar el serial "$barcode"? Esta acción lo removerá del inventario disponible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProductBloc>().add(DisableUnitEvent(unitId));
            },
            child: const Text(
              'Deshabilitar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Eliminar Producto',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar el producto "${widget.product.name}"? Se ocultará del inventario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProductBloc>().add(
                DeleteProductEvent(widget.product.id),
              );
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
