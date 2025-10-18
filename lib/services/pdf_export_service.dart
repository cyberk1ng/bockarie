import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:bockaire/services/calculation_service.dart';
import 'package:bockaire/classes/carton.dart' as models;
import 'package:bockaire/config/pdf_constants.dart';
import 'package:bockaire/config/ui_strings.dart';

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
        margin: const pw.EdgeInsets.all(PdfConstants.pageMargin),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  UIStrings.pdfTitleComparison,
                  style: pw.TextStyle(
                    fontSize: PdfConstants.headerFontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: PdfConstants.spacingSmall),
                pw.Text(
                  'Generated: ${dateFormat.format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: PdfConstants.smallFontSize,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: PdfConstants.spacingLarge),

          // Shipment Details
          pw.Container(
            padding: const pw.EdgeInsets.all(PdfConstants.sectionPadding),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  UIStrings.pdfSectionShipment,
                  style: pw.TextStyle(
                    fontSize: PdfConstants.sectionFontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: PdfConstants.spacingMedium),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            UIStrings.labelOrigin,
                            style: const pw.TextStyle(
                              fontSize: PdfConstants.smallFontSize,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '${shipment.originCity}, ${shipment.originPostal}',
                            style: pw.TextStyle(
                              fontSize: PdfConstants.bodyFontSize,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: PdfConstants.spacingLarge),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            UIStrings.labelDestination,
                            style: const pw.TextStyle(
                              fontSize: PdfConstants.smallFontSize,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '${shipment.destCity}, ${shipment.destPostal}',
                            style: pw.TextStyle(
                              fontSize: PdfConstants.bodyFontSize,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: PdfConstants.spacingMedium),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: PdfConstants.spacingMedium),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildPdfStat(
                      UIStrings.labelCartons,
                      '${totals.cartonCount}',
                    ),
                    _buildPdfStat(
                      UIStrings.labelWeight,
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

          pw.SizedBox(height: PdfConstants.spacingXLarge),

          // Quotes Table
          pw.Text(
            UIStrings.pdfSectionQuotes,
            style: pw.TextStyle(
              fontSize: PdfConstants.sectionFontSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: PdfConstants.spacingMedium),

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

          pw.SizedBox(height: PdfConstants.spacingXLarge),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(PdfConstants.sectionPadding),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  UIStrings.pdfBestOption,
                  style: pw.TextStyle(
                    fontSize: PdfConstants.bodyFontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (quotes.isNotEmpty)
                  pw.Text(
                    '${quotes.first.carrier} ${quotes.first.service} - ${currency.format(quotes.first.priceEur)}',
                    style: pw.TextStyle(
                      fontSize: PdfConstants.bodyFontSize,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green700,
                    ),
                  ),
              ],
            ),
          ),

          pw.SizedBox(height: PdfConstants.spacingXLarge),

          // Footer
          pw.Text(
            UIStrings.pdfNoteEstimates,
            style: const pw.TextStyle(
              fontSize: PdfConstants.footerFontSize,
              color: PdfColors.grey600,
            ),
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
          style: const pw.TextStyle(
            fontSize: PdfConstants.smallFontSize,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: PdfConstants.bodyFontSize,
            fontWeight: pw.FontWeight.bold,
          ),
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
      padding: const pw.EdgeInsets.all(PdfConstants.spacingSmall),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? PdfConstants.smallFontSize : 11,
          fontWeight: (isHeader || isBold)
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
          color: isHeader ? PdfColors.grey800 : PdfColors.black,
        ),
      ),
    );
  }
}
