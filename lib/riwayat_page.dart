import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model.dart';
import 'package:flutter_application_1/restapi.dart';
import 'package:flutter_application_1/config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPage createState() => _HistoryPage();
}

class _HistoryPage extends State<HistoryPage> {
  DataService ds = DataService();
  List data = [];
  List<KeuanganModel> keuangan = [];

  selectAll() async {
    data = jsonDecode(await ds.selectAll(token, project, 'keuangan', appid));
    keuangan = data.map((e) => KeuanganModel.fromJson(e)).toList();

    setState(() {
      keuangan = keuangan;
    });
  }

  @override
  void initState() {
    super.initState();
    selectAll();
  }

  Future<void> exportDataToPDF() async {
    try {
      final pdf = pw.Document();

      final data = await ds.selectAll(token, project, 'keuangan', appid);
      final List<dynamic> dataList = jsonDecode(data);

      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Keuangan Report',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: [
                  'ID',
                  'Date',
                  'Type',
                  'Name',
                  'Amount',
                  'Category',
                  'Description'
                ],
                data: dataList.map((item) {
                  return [
                    item['_id'],
                    item['date'] ?? '',
                    item['type'] ?? '',
                    item['name'] ?? '',
                    item['amount']?.toString() ?? '0',
                    item['category'] ?? '',
                    item['description'] ?? ''
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ));
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'keuangan-report.pdf',
      );
    } catch (e) {
      print('Error exporting PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Data'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  ElevatedButton.icon(
                    onPressed: exportDataToPDF,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text('Export PDF',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: keuangan.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                            Colors.green[300]), // Warna header
                        dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            // Warna bergantian untuk baris
                            if (states.contains(MaterialState.selected)) {
                              return Colors.green[100];
                            }
                            return null;
                          },
                        ),
                        columnSpacing: 24.0, // Spasi antar kolom
                        horizontalMargin: 16.0, // Margin horizontal
                        dividerThickness: 1, // Ketebalan pembagi
                        border: TableBorder.all(
                          color: Colors.black45,
                          width: 1,
                          borderRadius: BorderRadius.circular(5),
                        ), // Border pada tabel
                        columns: const [
                          DataColumn(
                              label: Text('Date',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black))),
                          DataColumn(
                              label: Text('Type',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black))),
                          DataColumn(
                              label: Text('Name',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black))),
                          DataColumn(
                              label: Text('Amount',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black))),
                          DataColumn(
                              label: Text('Category',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black))),
                          DataColumn(
                              label: Text('Description',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black))),
                        ],
                        rows: keuangan.map((item) {
                          return DataRow(cells: [
                            DataCell(Text(item.date,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14))),
                            DataCell(Text(item.type,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14))),
                            DataCell(Text(item.name,
                                textAlign: TextAlign.left,
                                style: const TextStyle(fontSize: 14))),
                            DataCell(Text(item.amount,
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 14))),
                            DataCell(Text(item.category,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14))),
                            DataCell(Text(item.description,
                                textAlign: TextAlign.left,
                                style: const TextStyle(fontSize: 14))),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
