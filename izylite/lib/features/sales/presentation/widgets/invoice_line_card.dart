import 'package:flutter/material.dart';
import '../../../../core/constans/Colors.dart';
import '../../data/invoice_lines.dart';

class InvoiceLineCard extends StatelessWidget {
  final InvoiceLine line;
  final int index;

  const InvoiceLineCard({Key? key, required this.line, required this.index})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        elevation: 1,
        color: AppColors.base200,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Text(
                '${index + 1}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.base900,
                ),
              ),
              const SizedBox(width: 4),
              Container(height: 20, width: 2, color: AppColors.base400),
              const SizedBox(width: 12),

              Expanded(
                flex: 4,
                child: Text(
                  line.productName,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.base900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Expanded(
                flex: 1,
                child: Text(
                  '${line.quantity} un',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.base600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              Expanded(
                flex: 2,
                child: Text(
                  '\$${line.lineTotal.toStringAsFixed(2)}',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.base800,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
