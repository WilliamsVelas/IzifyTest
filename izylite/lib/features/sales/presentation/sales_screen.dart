import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:izylite/features/sales/data/invoice.dart';
import 'package:izylite/features/sales/presentation/pos_screen.dart';
import 'package:izylite/features/sales/presentation/report_modal.dart';
import 'package:izylite/features/sales/presentation/sale_detail_screen.dart';
import '../../../core/constans/Colors.dart';
import '../../../core/presentation/widgets/custom_button.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../core/presentation/widgets/item_card.dart';
import '../../../core/utils/pdf_report_service.dart';
import '../../products/data/product_repository.dart';
import '../data/sales_repository.dart';
import '../logic/sales_bloc.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({Key? key}) : super(key: key);

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  Map<String, dynamic>? _lastAppliedFilters;
  late final SalesBloc _salesBloc;

  late final _pagingController = PagingController<int, Invoice>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) =>
        context.read<SalesRepository>().getSales(page: pageKey),
  );

  @override
  void initState() {
    super.initState();
    _salesBloc = SalesBloc(repository: context.read<SalesRepository>());
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _salesBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SalesBloc, SalesState>(
      bloc: _salesBloc,
      listener: (context, state) {
        if (state is ReportGenerating) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Generando reporte...'),
              duration: Duration(seconds: 1),
            ),
          );
        } else if (state is ReportGeneratedSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          PdfReportService.generateAndShare(
            state.reportData,
            startDate: _lastAppliedFilters?['startDate'],
            endDate: _lastAppliedFilters?['endDate'],
            productName: _lastAppliedFilters?['productName'],
          );
        } else if (state is ReportGenerationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        body: PagingListener<int, Invoice>(
          controller: _pagingController,
          builder: (context, state, fetchNextPage) => RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              _pagingController.refresh();
            },
            child: PagedListView<int, Invoice>(
              state: state,
              fetchNextPage: fetchNextPage,
              padding: const EdgeInsets.all(16.0),
              builderDelegate: PagedChildBuilderDelegate<Invoice>(
                itemBuilder: (context, sale, index) => ItemCard(
                  title: 'Factura',
                  subtitle: '#${sale.invoiceNumber}',
                  amount: '\$${sale.totalAmount.toStringAsFixed(2)}',
                  icon: Icons.receipt_long_rounded,
                  iconColor: AppColors.success,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SaleDetailScreen(invoice: sale),
                      ),
                    );
                  },
                ),
                noItemsFoundIndicatorBuilder: (_) =>
                    const Center(child: Text('No hay ventas registradas aún.')),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: CustomButton(
                    backgroundColor: AppColors.base200,
                    onPressed: () async {
                      final filters = await ReportModal.show(context);

                      if (filters != null) {
                        _lastAppliedFilters = filters;
                        _salesBloc.add(
                          GenerateReportEvent(
                            startDate: filters['startDate'],
                            endDate: filters['endDate'],
                            productId: filters['productId'],
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Reportes',
                      style: TextStyle(color: AppColors.base900),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    onPressed: () async {
                      final productsRepository = context
                          .read<ProductsRepository>();
                      final salesRepository = context.read<SalesRepository>();

                      final bool? saleCompleted = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MultiRepositoryProvider(
                            providers: [
                              RepositoryProvider.value(
                                value: productsRepository,
                              ),
                              RepositoryProvider.value(value: salesRepository),
                            ],
                            child: BlocProvider<SalesBloc>(
                              create: (_) =>
                                  SalesBloc(repository: salesRepository),
                              child: const PosScreen(),
                            ),
                          ),
                        ),
                      );
                      if (saleCompleted == true) {
                        _pagingController.refresh();
                      }
                    },
                    child: const Text('Agregar Venta'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
