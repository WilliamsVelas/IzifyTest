import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/product.dart';
import '../data/product_repository.dart';

abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DisableUnitEvent extends ProductEvent {
  final String unitId;

  DisableUnitEvent(this.unitId);

  @override
  List<Object?> get props => [unitId];
}

class DeleteProductEvent extends ProductEvent {
  final String productId;

  DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

abstract class ProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddUnitEvent extends ProductEvent {
  final String productId;
  final String barcode;

  AddUnitEvent(this.productId, this.barcode);

  @override
  List<Object?> get props => [productId, barcode];
}

class CreateProductEvent extends ProductEvent {
  final Map<String, dynamic> productData;
  CreateProductEvent(this.productData);
  @override
  List<Object?> get props => [productData];
}

class UpdateProductEvent extends ProductEvent {
  final String productId;
  final Map<String, dynamic> productData;

  UpdateProductEvent(this.productId, this.productData);

  @override
  List<Object?> get props => [productId, productData];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductActionSuccess extends ProductState {
  final String message;
  final String? deletedUnitId;
  final List<ProductUnit>? addedUnits;
  final bool isProductDeleted;

  ProductActionSuccess(
    this.message, {
    this.deletedUnitId,
    this.addedUnits,
    this.isProductDeleted = false,
  });

  @override
  List<Object?> get props => [
    message,
    deletedUnitId,
    addedUnits,
    isProductDeleted,
  ];
}

class ProductError extends ProductState {
  final String error;

  ProductError(this.error);

  @override
  List<Object?> get props => [error];
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductsRepository _repository;

  ProductBloc({required ProductsRepository repository})
    : _repository = repository,
      super(ProductInitial()) {
    on<DisableUnitEvent>(_onDisableUnit);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<AddUnitEvent>(_onAddUnit);
  }

  Future<void> _onDisableUnit(
    DisableUnitEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final success = await _repository.disableUnit(event.unitId);
      if (success) {
        emit(
          ProductActionSuccess(
            "Serial deshabilitado correctamente",
            deletedUnitId: event.unitId,
          ),
        );
      } else {
        emit(ProductError("No se pudo deshabilitar el serial"));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final success = await _repository.deleteProduct(event.productId);
      if (success) {
        emit(
          ProductActionSuccess(
            "Producto eliminado correctamente",
            isProductDeleted: true,
          ),
        );
      } else {
        emit(ProductError("Error al eliminar el producto"));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onAddUnit(
    AddUnitEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final newUnits = await _repository.addUnit(
        event.productId,
        event.barcode,
      );

      if (newUnits != null && newUnits.isNotEmpty) {
        emit(
          ProductActionSuccess(
            "Nuevo serial registrado correctamente",
            addedUnits: newUnits,
          ),
        );
      } else {
        emit(ProductError("Error al registrar el serial"));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onCreateProduct(
      CreateProductEvent event,
      Emitter<ProductState> emit,
      ) async {
    emit(ProductLoading());
    try {
      final success = await _repository.createProduct(event.productData);
      if (success) {
        emit(ProductActionSuccess("Producto creado exitosamente"));
      } else {
        emit(ProductError("Error al crear el producto"));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
      UpdateProductEvent event,
      Emitter<ProductState> emit,
      ) async {
    emit(ProductLoading());
    try {
      final success = await _repository.updateProduct(event.productId, event.productData);
      if (success) {
        emit(ProductActionSuccess("Producto actualizado correctamente"));
      } else {
        emit(ProductError("Error al actualizar el producto"));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}