import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/constans/Colors.dart';
import '../../products/presentation/product_screen.dart';
import '../../sales/presentation/sales_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String userName;

  const DashboardScreen({Key? key, this.userName = 'Administrador'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          toolbarHeight: 80,
          title: Row(
            children: [
              SvgPicture.asset(
                'assets/svgs/izyfi_logo.svg',
                height: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bienvenido a Izify',
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      userName,
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Ventas'),
              Tab(text: 'Productos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [ SalesScreen(), ProductsScreen() ],
        ),
      ),
    );
  }
}