import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:izylite/features/products/presentation/product_detail_screen.dart';
import '../../../core/constans/Colors.dart';
import '../../../core/presentation/widgets/custom_button.dart';
import '../../../core/presentation/widgets/item_card.dart';
import '../data/product.dart';
import '../data/product_repository.dart';
import '../logic/product_bloc.dart';
import 'create_product_modal.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PagingListener<int, Product>(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) => RefreshIndicator(
          onRefresh: () async => _pagingController.refresh(),
          child: PagedListView<int, Product>(
            state: state,
            fetchNextPage: fetchNextPage,
            padding: const EdgeInsets.all(16.0),
            builderDelegate: PagedChildBuilderDelegate<Product>(
              itemBuilder: (context, product, index) => ItemCard(
                title: product.name,
                subtitle: '${product.stock} unidades',
                amount: '\$${product.price.toStringAsFixed(2)}',
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.primary,
                onTap: () async {
                  final productsRepository = context.read<ProductsRepository>();

                  final bool? shouldRefresh = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RepositoryProvider.value(
                        value: productsRepository,
                        child: BlocProvider(
                          create: (_) =>
                              ProductBloc(repository: productsRepository),
                          child: ProductDetailScreen(product: product),
                        ),
                      ),
                    ),
                  );

                  if (shouldRefresh == true) {
                    _pagingController.refresh();
                  }
                },
              ),
              noItemsFoundIndicatorBuilder: (_) => const Center(
                child: Text('No hay productos en el inventario.'),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            onPressed: () async {
              final bool? shouldRefresh = await CreateProductModal.show(
                context,
              );

              if (shouldRefresh == true) {
                _pagingController.refresh();
              }
            },
            child: const Text('Agregar Producto'),
          ),
        ),
      ),
    );
  }
}
