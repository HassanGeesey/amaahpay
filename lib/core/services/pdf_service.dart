import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../data/models/sale_model.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/product_model.dart';
import '../constants/app_theme.dart';

class PdfService {
  static final _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _dateFormat = DateFormat('MMM d, yyyy h:mm a');
  static final _sosRate = 2700.0;
  
  static PdfColor get _navyColor => PdfColor.fromInt(0xFF0F2A44);

  static Future<File> generateSalesReportPdf({
    required List<SaleModel> sales,
    required String title,
    String? customerName,
  }) async {
    final pdf = pw.Document();
    
    final totalUsd = sales.fold<double>(0, (sum, s) => sum + s.totalUsd);
    final totalCash = sales.fold<double>(0, (sum, s) => sum + s.cashPaidUsd);
    final totalDeposit = sales.fold<double>(0, (sum, s) => sum + s.depositUsedUsd);
    final totalCredit = sales.fold<double>(0, (sum, s) => sum + s.creditAddedUsd);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(title, customerName),
              pw.SizedBox(height: 20),
              _buildSummary(totalUsd, totalCash, totalDeposit, totalCredit),
              pw.SizedBox(height: 20),
              _buildSalesTable(sales),
              pw.SizedBox(height: 20),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return _savePdf(pdf, title);
  }

  static Future<File> generateCustomerReportPdf({
    required CustomerModel customer,
    required List<SaleModel> sales,
  }) async {
    final pdf = pw.Document();
    
    final totalSpent = sales.fold<double>(0, (sum, s) => sum + s.totalUsd);
    final totalPaid = sales.fold<double>(0, (sum, s) => sum + s.cashPaidUsd + s.depositUsedUsd);
    final remainingCredit = customer.creditBalance;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildCustomerHeader(customer, totalSpent),
              pw.SizedBox(height: 20),
              _buildCustomerSummary(totalSpent, totalPaid, remainingCredit),
              pw.SizedBox(height: 20),
              _buildSalesTable(sales),
              pw.SizedBox(height: 20),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return _savePdf(pdf, 'Customer_${customer.name}');
  }

  static Future<File> generateSummaryReportPdf({
    required List<SaleModel> sales,
    required String dateRangeLabel,
  }) async {
    final pdf = pw.Document();
    
    final totalUsd = sales.fold<double>(0, (sum, s) => sum + s.totalUsd);
    final totalCash = sales.fold<double>(0, (sum, s) => sum + s.cashPaidUsd);
    final totalDeposit = sales.fold<double>(0, (sum, s) => sum + s.depositUsedUsd);
    final totalCredit = sales.fold<double>(0, (sum, s) => sum + s.creditAddedUsd);
    final transactionCount = sales.length;
    final avgPerSale = transactionCount > 0 ? totalUsd / transactionCount : 0.0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSummaryHeader('Sales Summary', dateRangeLabel),
              pw.SizedBox(height: 24),
              _buildSummaryGrid(totalUsd, totalCash, totalDeposit, totalCredit, transactionCount, avgPerSale),
              pw.SizedBox(height: 24),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return _savePdf(pdf, 'Summary_$dateRangeLabel');
  }

  static Future<File> generateInventoryReportPdf({
    required List<ProductModel> products,
  }) async {
    final pdf = pw.Document();
    
    final totalProducts = products.length;
    final totalValue = products.fold<double>(0, (sum, p) => sum + p.defaultPriceUsd);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildInventoryHeader(totalProducts, totalValue),
              pw.SizedBox(height: 24),
              _buildProductsTable(products),
              pw.SizedBox(height: 24),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return _savePdf(pdf, 'Inventory_Report');
  }

  static Future<File> savePdfDirect(pw.Document pdf, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${dir.path}/${filename}_$timestamp.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildSummaryHeader(String title, String dateRange) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _navyColor,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'AmaahPay',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                title,
                style: const pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 14,
                ),
              ),
              if (customerName != null) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  'Customer: $customerName',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          pw.Text(
            _dateFormat.format(DateTime.now()),
            style: const pw.TextStyle(
              color: PdfColors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerHeader(CustomerModel customer, double totalSpent) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _navyColor,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'AmaahPay - Customer Statement',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    customer.name,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    customer.phone.isNotEmpty ? customer.phone : 'No phone',
                    style: const pw.TextStyle(color: PdfColors.white, fontSize: 12),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total Spent: ${_currencyFormat.format(totalSpent)}',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '${(totalSpent * _sosRate).toStringAsFixed(0)} SOS',
                    style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummary(double total, double cash, double deposit, double credit) {
    return pw.Row(
      children: [
        _SummaryBox('Total Sales', total, PdfColor.fromInt(NeoTheme.primaryNavy.value)),
        pw.SizedBox(width: 12),
        _SummaryBox('Cash', cash, PdfColors.green),
        pw.SizedBox(width: 12),
        _SummaryBox('Deposit', deposit, PdfColors.blue),
        pw.SizedBox(width: 12),
        _SummaryBox('Credit', credit, PdfColors.amber),
      ],
    );
  }

  static pw.Widget _buildCustomerSummary(double total, double paid, double credit) {
    return pw.Row(
      children: [
        _SummaryBox('Total Spent', total, PdfColor.fromInt(NeoTheme.primaryNavy.value)),
        pw.SizedBox(width: 12),
        _SummaryBox('Total Paid', paid, PdfColors.green),
        pw.SizedBox(width: 12),
        _SummaryBox('Credit Balance', credit, PdfColors.amber),
      ],
    );
  }

  static pw.Widget _buildSalesTable(List<SaleModel> sales) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: _navyColor,
          ),
          children: [
            _tableHeader('Date'),
            _tableHeader('Total'),
            _tableHeader('Cash'),
            _tableHeader('Deposit'),
            _tableHeader('Credit'),
          ],
        ),
        ...sales.map((s) => pw.TableRow(
          children: [
            _tableCell(_dateFormat.format(s.createdAt.toLocal())),
            _tableCell(_currencyFormat.format(s.totalUsd)),
            _tableCell(_currencyFormat.format(s.cashPaidUsd)),
            _tableCell(_currencyFormat.format(s.depositUsedUsd)),
            _tableCell(s.creditAddedUsd > 0 
              ? '+${_currencyFormat.format(s.creditAddedUsd)}' 
              : '-'),
          ],
        )),
      ],
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 16),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by AmaahPay',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
          pw.Text(
            'Page 1',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ],
      ),
    );
  }

  static Future<File> _savePdf(pw.Document pdf, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/${filename}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}

class _SummaryBox extends pw.StatelessWidget {
  final String label;
  final double value;
  final PdfColor color;

  _SummaryBox(this.label, this.value, this.color);

  @override
  pw.Widget build(pw.Context context) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 10,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value),
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}