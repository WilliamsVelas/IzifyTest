import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/invoice.dart';
import '../data/sale_report.dart';
import '../data/sales_repository.dart';

abstract class SalesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchSalesPage extends SalesEvent {
  final int pageKey;

  FetchSalesPage(this.pageKey);

  @override
  List<Object?> get props => [pageKey];
}

class ProcessSaleEvent extends SalesEvent {
  final Map<String, dynamic> saleData;

  ProcessSaleEvent(this.saleData);

  @override
  List<Object?> get props => [saleData];
}

abstract class SalesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SalesInitial extends SalesState {}

class SalesPageLoaded extends SalesState {
  final List<Invoice> newSales;
  final int pageKey;
  final bool isLastPage;

  SalesPageLoaded(this.newSales, this.pageKey, this.isLastPage);

  @override
  List<Object?> get props => [newSales, pageKey, isLastPage];
}

class SalesPageError extends SalesState {
  final String error;

  SalesPageError(this.error);

  @override
  List<Object?> get props => [error];
}

class SaleProcessing extends SalesState {}

class SaleProcessSuccess extends SalesState {
  final String message;

  SaleProcessSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class GenerateReportEvent extends SalesEvent {
  final String? productId;
  final String? startDate;
  final String? endDate;

  GenerateReportEvent({this.productId, this.startDate, this.endDate});

  @override
  List<Object?> get props => [productId, startDate, endDate];
}

class ReportGenerating extends SalesState {}

class ReportGeneratedSuccess extends SalesState {
  final SalesReportResponse reportData;

  ReportGeneratedSuccess(this.reportData);

  @override
  List<Object?> get props => [reportData];
}

class ReportGenerationError extends SalesState {
  final String error;

  ReportGenerationError(this.error);

  @override
  List<Object?> get props => [error];
}

class SaleProcessError extends SalesState {
  final String error;

  SaleProcessError(this.error);

  @override
  List<Object?> get props => [error];
}

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final SalesRepository _repository;

  SalesBloc({required SalesRepository repository})
      : _repository = repository,
        super(SalesInitial()) {
    on<FetchSalesPage>(_onFetchSalesPage);
    on<ProcessSaleEvent>(_onProcessSale);
    on<GenerateReportEvent>(_onGenerateReport);
  }

  Future<void> _onFetchSalesPage(
      FetchSalesPage event,
      Emitter<SalesState> emit,
      ) async {
    try {
      final newSales = await _repository.getSales(page: event.pageKey);

      final isLastPage = newSales.length < 15;

      emit(SalesPageLoaded(newSales, event.pageKey, isLastPage));
    } catch (e) {
      emit(SalesPageError(e.toString()));
    }
  }

  Future<void> _onProcessSale(
      ProcessSaleEvent event,
      Emitter<SalesState> emit,
      ) async {
    emit(SaleProcessing());
    try {
      final success = await _repository.processSale(event.saleData);
      if (success) {
        emit(SaleProcessSuccess("Venta procesada exitosamente"));
      } else {
        emit(SaleProcessError("No se pudo procesar la venta"));
      }
    } catch (e) {
      emit(SaleProcessError(e.toString()));
    }
  }

  Future<void> _onGenerateReport(
      GenerateReportEvent event,
      Emitter<SalesState> emit,
      ) async {
    emit(ReportGenerating());
    try {
      final reportData = await _repository.getSalesReport(
        productId: event.productId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(ReportGeneratedSuccess(reportData));
    } catch (e) {
      emit(ReportGenerationError(e.toString()));
    }
  }
}
