import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Data'),
      ),
      body: Center(
        child: Text(
          'This is the Manage Data page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// class ManageScreen extends StatelessWidget {
//   final String collection;
//   final String title;
//   final Function(List<List<dynamic>>) onBooksImported;

//   const ManageScreen({
//     super.key,
//     required this.collection,
//     required this.title,
//     required this.onBooksImported,
//   });

//   Future<void> importData(BuildContext context) async {
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['csv'],
//       );
//       if (result != null) {
//         final fileBytes = result.files.single.bytes;
//         if (fileBytes != null) {
//           final csvData = CsvToListConverter()
//               .convert(String.fromCharCodes(fileBytes), eol: '\n');

//           onBooksImported(csvData.skip(1).toList());

//           // Simpan data ke Firestore
//           for (var row in csvData.skip(1)) {
//             if (row.length >= 4) {
//               await FirebaseFirestore.instance.collection(collection).add({
//                 'author': row[0],
//                 'quantity': int.tryParse(row[1].toString()) ?? 0,
//                 'title': row[2],
//                 'year': int.tryParse(row[3].toString()) ?? 0,
//               });
//             }
//           }

//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('CSV file successfully imported!')),
//           );
//         }
//       }
//     } catch (e) {
//       print("Error importing data: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error to import CSV file')),
//       );
//     }
//   }

//   // Mengekspor data ke PDF
//   Future<void> exportDataToPDF() async {
//     try {
//       final pdf = pw.Document();
//       final data =
//           await FirebaseFirestore.instance.collection(collection).get();

//       pdf.addPage(
//         pw.Page(
//           build: (pw.Context context) {
//             return pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text('$title Report', style: pw.TextStyle(fontSize: 24)),
//                 pw.SizedBox(height: 16),
//                 pw.Table.fromTextArray(
//                   headers: ['ID', 'Author', 'Quantity', 'Title', 'Year'],
//                   data: data.docs.map((doc) {
//                     final d = doc.data();
//                     return [
//                       doc.id,
//                       d['author'] ?? '',
//                       d['quantity']?.toString() ?? '0',
//                       d['title'] ?? '',
//                       d['year']?.toString() ?? ''
//                     ];
//                   }).toList(),
//                 ),
//               ],
//             );
//           },
//         ),
//       );
//       await Printing.sharePdf(
//         bytes: await pdf.save(),
//         filename: '$collection-report.pdf',
//       );
//     } catch (e) {
//       print('Error exporting PDF: $e');
//     }
//   }

//   Future<void> _showDeleteDialog(BuildContext context, String bookId) async {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Delete Book'),
//           content: const Text('Are you sure you want to delete this book?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 await FirebaseFirestore.instance
//                     .collection(collection)
//                     .doc(bookId)
//                     .delete();
//                 Navigator.of(context).pop();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Book deleted successfully!')),
//                 );
//               },
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _showUpdateDialog(BuildContext context, String bookId,
//       Map<String, dynamic> currentData) async {
//     final authorController = TextEditingController(text: currentData['author']);
//     final quantityController =
//         TextEditingController(text: currentData['quantity']?.toString());
//     final titleController = TextEditingController(text: currentData['title']);
//     final yearController =
//         TextEditingController(text: currentData['year']?.toString());

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Update Book'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: titleController,
//                 decoration: const InputDecoration(labelText: 'Title'),
//               ),
//               TextField(
//                 controller: authorController,
//                 decoration: const InputDecoration(labelText: 'Author'),
//               ),
//               TextField(
//                 controller: yearController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(labelText: 'Year'),
//               ),
//               TextField(
//                 controller: quantityController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(labelText: 'Quantity'),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 if (titleController.text.isNotEmpty &&
//                     authorController.text.isNotEmpty &&
//                     yearController.text.isNotEmpty &&
//                     quantityController.text.isNotEmpty) {
//                   await FirebaseFirestore.instance
//                       .collection(collection)
//                       .doc(bookId)
//                       .update({
//                     'title': titleController.text,
//                     'author': authorController.text,
//                     'year': int.tryParse(yearController.text) ?? 0,
//                     'quantity': int.tryParse(quantityController.text) ?? 0,
//                   });
//                   Navigator.of(context).pop();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Book updated successfully!')),
//                   );
//                 }
//               },
//               child: const Text('Update'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Manage $title'),
//         backgroundColor: Colors.teal,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Books Data Table',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Row(
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () => importData(context),
//                       icon: const Icon(Icons.upload_file),
//                       label: const Text('Import CSV'),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 12.0,
//                           horizontal: 16.0,
//                         ),
//                         backgroundColor: Colors.teal,
//                         textStyle: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                     const SizedBox(width: 18),
//                     ElevatedButton.icon(
//                       onPressed: exportDataToPDF,
//                       icon: const Icon(Icons.picture_as_pdf),
//                       label: const Text('Export PDF'),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 12.0,
//                           horizontal: 16.0,
//                         ),
//                         backgroundColor: Colors.orange,
//                         textStyle: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: SingleChildScrollView(
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection(collection)
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(
//                           child: CircularProgressIndicator(),
//                         );
//                       }
//                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                         return const Center(
//                           child: Text('No data available'),
//                         );
//                       }
//                       final data = snapshot.data!.docs;

//                       return DataTable(
//                         columnSpacing: 200.0,
//                         columns: const [
//                           DataColumn(label: Text('Author')),
//                           DataColumn(label: Text('Quantity')),
//                           DataColumn(label: Text('Title')),
//                           DataColumn(label: Text('Year')),
//                           DataColumn(label: Text('Action')),
//                         ],
//                         rows: data.map((doc) {
//                           final d = doc.data() as Map<String, dynamic>;
//                           return DataRow(
//                             cells: [
//                               DataCell(Text(d['author'] ?? '')),
//                               DataCell(Text(d['quantity']?.toString() ?? '0')),
//                               DataCell(Text(d['title'] ?? '')),
//                               DataCell(Text(d['year']?.toString() ?? '')),
//                               DataCell(Row(
//                                 children: [
//                                   IconButton(
//                                     icon: const Icon(Icons.edit),
//                                     color:
//                                         const Color.fromARGB(255, 198, 163, 36),
//                                     onPressed: () =>
//                                         _showUpdateDialog(context, doc.id, d),
//                                   ),
//                                   IconButton(
//                                     icon: const Icon(Icons.delete),
//                                     color: Colors.red,
//                                     onPressed: () =>
//                                         _showDeleteDialog(context, doc.id),
//                                   ),
//                                 ],
//                               )),
//                             ],
//                           );
//                         }).toList(),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
