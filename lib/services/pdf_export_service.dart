import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:bockaire/services/calculation_service.dart';
import 'package:bockaire/classes/carton.dart' as models;

/// Service for exporting quotes to PDF
class PDFExportService {
  static Future<void> exportQuotesPDF({
    required dynamic shipment,
    required List<dynamic> quotes,
    required List<dynamic> cartons,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy');
    final currency = NumberFormat.currency(symbol: '€', decimalDigits: 2);
    // Cast cartons to proper type
    final cartonList = cartons.cast<models.Carton>();
    final totals = CalculationService.calculateTotals(cartonList);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Shipping Quote Comparison',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generated: ${dateFormat.format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Shipment Details
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Shipment Details',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Origin',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '${shipment.originCity}, ${shipment.originPostal}',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 20),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Destination',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '${shipment.destCity}, ${shipment.destPostal}',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildPdfStat('Cartons', '${totals.cartonCount}'),
                    _buildPdfStat(
                      'Weight',
                      '${totals.chargeableKg.toStringAsFixed(1)} kg',
                    ),
                    _buildPdfStat(
                      'Volume',
                      '${(totals.totalVolumeCm3 / 1000000).toStringAsFixed(2)} m³',
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          // Quotes Table
          pw.Text(
            'Quote Comparison',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),

          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('Carrier & Service', isHeader: true),
                  _buildTableCell('Delivery Time', isHeader: true),
                  _buildTableCell('Weight', isHeader: true),
                  _buildTableCell('Price', isHeader: true),
                ],
              ),
              // Data rows
              ...quotes.asMap().entries.map((entry) {
                final index = entry.key;
                final quote = entry.value;
                final isCheapest = index == 0;

                return pw.TableRow(
                  decoration: isCheapest
                      ? const pw.BoxDecoration(color: PdfColors.green50)
                      : null,
                  children: [
                    _buildTableCell(
                      '${quote.carrier} ${quote.service}${isCheapest ? ' ★' : ''}',
                    ),
                    _buildTableCell('${quote.etaMin}-${quote.etaMax} days'),
                    _buildTableCell(
                      '${quote.chargeableKg.toStringAsFixed(1)} kg',
                    ),
                    _buildTableCell(
                      currency.format(quote.priceEur),
                      isBold: isCheapest,
                    ),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 24),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Best Option (Lowest Price)',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (quotes.isNotEmpty)
                  pw.Text(
                    '${quotes.first.carrier} ${quotes.first.service} - ${currency.format(quotes.first.priceEur)}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green700,
                    ),
                  ),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          // Footer
          pw.Text(
            'Note: Prices are estimates and may vary based on actual shipment conditions.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    // Show print dialog
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static pw.Widget _buildPdfStat(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 11,
          fontWeight: (isHeader || isBold)
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
          color: isHeader ? PdfColors.grey800 : PdfColors.black,
        ),
      ),
    );
  }
}
