import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/widgets/custom_button.dart';
import '../../../core/presentation/widgets/custom_input.dart';
import '../data/product.dart';
import '../data/product_repository.dart';
import '../logic/product_bloc.dart';

class CreateProductModal extends StatefulWidget {
  final Product? productToEdit;

  const CreateProductModal({Key? key, this.productToEdit}) : super(key: key);

  static Future<bool?> show(BuildContext context, {Product? product}) {
    final repository = context.read<ProductsRepository>();

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider<ProductBloc>(
        create: (_) => ProductBloc(repository: repository),
        child: CreateProductModal(productToEdit: product),
      ),
    );
  }

  @override
  State<CreateProductModal> createState() => _CreateProductModalState();
}

class _CreateProductModalState extends State<CreateProductModal> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _qtyController = TextEditingController();
  final _barcodeController = TextEditingController();
  bool _isAutoGenerate = true;
  List<String> _manualBarcodes = [];

  bool get _isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.productToEdit!.name;
      _priceController.text = widget.productToEdit!.price.toString();
      _descController.text = widget.productToEdit!.description ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _qtyController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  void _addManualBarcode() {
    final code = _barcodeController.text.trim();
    if (code.isNotEmpty && !_manualBarcodes.contains(code)) {
      setState(() {
        _manualBarcodes.add(code);
        _barcodeController.clear();
      });
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();

    if (name.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nombre y precio son obligatorios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double? price = double.tryParse(priceText);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El precio debe ser un número válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Map<String, dynamic> payload = {
      'name': name,
      'price': price,
      if (_descController.text.trim().isNotEmpty)
        'description': _descController.text.trim(),
    };

    if (_isEditing) {
      context.read<ProductBloc>().add(
        UpdateProductEvent(widget.productToEdit!.id, payload),
      );
    } else {
      if (_isAutoGenerate) {
        final int qty = int.tryParse(_qtyController.text.trim()) ?? 0;
        if (qty <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ingresa una cantidad válida mayor a 0'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        payload['qty'] = qty;
      } else {
        if (_manualBarcodes.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debes agregar al menos un serial manual'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        payload['barcodes'] = _manualBarcodes;
      }

      context.read<ProductBloc>().add(CreateProductEvent(payload));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductActionSuccess) {
          Navigator.pop(context, true);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Editar Producto' : 'Crear Nuevo Producto',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              CustomInput(
                label: 'Nombre del Producto *',
                hint: 'Ej: Coca Cola 2L',
                controller: _nameController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              CustomInput(
                label: 'Precio *',
                hint: 'Ej: 2.50',
                controller: _priceController,
                inputType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              CustomInput(
                label: 'Descripción (Opcional)',
                hint: 'Detalles del producto...',
                controller: _descController,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),

              if (!_isEditing) ...[
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Ingreso de Stock Inicial',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Cantidad (Auto)'),
                        value: true,
                        groupValue: _isAutoGenerate,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) =>
                            setState(() => _isAutoGenerate = val!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Escanear Seriales'),
                        value: false,
                        groupValue: _isAutoGenerate,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) =>
                            setState(() => _isAutoGenerate = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_isAutoGenerate) ...[
                  CustomInput(
                    label: 'Cantidad a ingresar',
                    hint: 'Ej: 50',
                    controller: _qtyController,
                    inputType: TextInputType.number,
                  ),
                ] else ...[
                  CustomInput(
                    label: 'Escanear Serial / Código',
                    hint: 'Presiona enter o el botón al terminar',
                    controller: _barcodeController,
                    onFieldSubmitted: (_) => _addManualBarcode(),
                  ),
                  const SizedBox(height: 12),

                  if (_manualBarcodes.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _manualBarcodes
                          .map(
                            (code) => Chip(
                              label: Text(code),
                              onDeleted: () {
                                setState(() {
                                  _manualBarcodes.remove(code);
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                ],
                const SizedBox(height: 32),
              ],

              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  return CustomButton(
                    onPressed: state is ProductLoading ? null : _submit,
                    child: state is ProductLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isEditing ? 'Guardar Cambios' : 'Crear Producto',
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
