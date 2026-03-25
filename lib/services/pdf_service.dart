import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/detection_result.dart';

class PdfService {
  Future<File> generateReport(DetectionResult result) async {
    final pdf = pw.Document();
    
    // Load image safely
    pw.MemoryImage? image;
    try {
      final file = File(result.imagePath);
      if (await file.exists()) {
        image = pw.MemoryImage(
          await file.readAsBytes(),
        );
      }
    } catch (e) {
      // Image loading failed
    }

    final accentColor = PdfColor.fromInt(0xFF00BFA5); // Teal accent
    final organicColor = PdfColor.fromInt(0xFF4CAF50); // Green
    final chemicalColor = PdfColor.fromInt(0xFFFF9800); // Orange

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          final isCritical = result.severity == 'High' || result.severity == 'Critical';
          
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- Header ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PLANTIFY', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, letterSpacing: 2, color: accentColor)),
                      pw.Text('Smart Disease Detection Report', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(16),
                    ),
                    child: pw.Text(
                      DateTime.now().toString().split('.')[0],
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // --- Main Result Card ---
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Plant Image
                    pw.Container(
                      width: 120,
                      height: 120,
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(6),
                        color: PdfColors.grey100,
                        image: image != null ? pw.DecorationImage(image: image, fit: pw.BoxFit.cover) : null,
                      ),
                      child: image == null 
                          ? pw.Center(child: pw.Text('No Image', style: pw.TextStyle(color: PdfColors.grey400, fontSize: 10)))
                          : null,
                    ),
                    pw.SizedBox(width: 16),
                    // Result Text
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('DETECTED ISSUE', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            result.diseaseName.toUpperCase(),
                            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Row(children: [
                            _buildBadge(
                              'Severity: ${result.severity}', 
                              isCritical ? PdfColors.red100 : PdfColors.orange100,
                              isCritical ? PdfColors.red900 : PdfColors.orange900,
                            ),
                            pw.SizedBox(width: 8),
                            _buildBadge(
                              'Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%', 
                              PdfColors.blue50,
                              PdfColors.blue900,
                            ),
                          ]),
                          pw.SizedBox(height: 12),
                          pw.Text(
                            result.description,
                            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800, lineSpacing: 1.5),
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // --- Highlight Section ---
              if (result.highlight != null) ...[
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    border: pw.Border.all(color: PdfColors.blue200),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('KEY HIGHLIGHT', style: pw.TextStyle(color: PdfColors.blue800, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        result.highlight!,
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.blue900),
                      ),
                      if (result.highlightUrl != null) ...[
                        pw.SizedBox(height: 4),
                        pw.Text('Read more: ${result.highlightUrl}', style: pw.TextStyle(fontSize: 8, color: PdfColors.blue700, fontStyle: pw.FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),
              ],

              // --- Symptoms Section ---
              pw.Text('Symptoms Observed', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Wrap(
                spacing: 8,
                runSpacing: 8,
                children: result.symptoms.map((s) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(4),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Text(s, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                )).toList(),
              ),

              pw.SizedBox(height: 24),

              // --- Treatment Plan Header ---
              pw.Text('Recommended Action Plan', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),

              // --- Treatment Cards (Side by Side) ---
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Organic
                  pw.Expanded(
                    child: _buildTreatmentSection(
                      'Organic Method', 
                      result.organicTreatment.title,
                      result.organicTreatment.steps,
                      result.organicTreatment.duration,
                      organicColor,
                      result.organicTreatment.sourceUrl,
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  // Chemical
                  pw.Expanded(
                    child: _buildTreatmentSection(
                      'Chemical Method', 
                      result.chemicalTreatment.title,
                      result.chemicalTreatment.steps,
                      result.chemicalTreatment.duration,
                      chemicalColor,
                      result.chemicalTreatment.sourceUrl,
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // --- Footer ---
              pw.Divider(color: PdfColors.grey300),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Generated by Plantify App', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  pw.Text('Disclaimer: AI diagnosis should be verified by an expert.', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final fileName = 'Plantify_Report_${result.cropName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildBadge(String text, PdfColor bg, PdfColor fg) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(text, style: pw.TextStyle(color: fg, fontSize: 9, fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.Widget _buildTreatmentSection(String type, String title, List<String> steps, String duration, PdfColor color, String? sourceUrl) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: color, width: 3)),
        color: PdfColors.grey50,
      ),
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(type.toUpperCase(), style: pw.TextStyle(color: color, fontSize: 8, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.SizedBox(height: 8),
          ...steps.map((step) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('• ', style: pw.TextStyle(color: color, fontWeight: pw.FontWeight.bold)),
                pw.Expanded(child: pw.Text(step, style: pw.TextStyle(fontSize: 9, lineSpacing: 1.2))),
              ],
            ),
          )),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(2),
            ),
            child: pw.Text('Duration: $duration', style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
          ),
          if (sourceUrl != null) ...[
            pw.SizedBox(height: 8),
            pw.Text('Source: $sourceUrl', style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
          ],
        ],
      ),
    );
  }
}