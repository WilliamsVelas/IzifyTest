import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:izylite/features/sales/presentation/widgets/invoice_line_card.dart';
import '../../../core/constans/Colors.dart';
import '../data/invoice.dart';

class SaleDetailScreen extends StatelessWidget {
  final Invoice invoice;

  const SaleDetailScreen({Key? key, required this.invoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Factura #${invoice.invoiceNumber}'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: AppColors.base100,
            child: Material(
              elevation: 1,
              color: AppColors.base200,
              borderRadius: BorderRadius.circular(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total: \$${invoice.totalAmount.toStringAsFixed(2)}',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.base900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(invoice.date)}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.base500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'LÍNEAS DE FACTURA',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.base600,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: invoice.lines.length,
              itemBuilder: (context, index) {
                final line = invoice.lines[index];
                return InvoiceLineCard(line: line, index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
