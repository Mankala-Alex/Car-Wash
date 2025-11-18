// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../config/constants.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// showPDFDialog(String pdfUrl, {name = "Report"}) {
//   if (pdfUrl.contains("http")) {
//     pdfUrl = pdfUrl;
//   } else if (pdfUrl.contains("HMSImages")) {
//     pdfUrl = Constants.imageBaseUrlHost + pdfUrl;
//   } else {
//     pdfUrl = Constants.imageBaseUrl + pdfUrl;
//   }
//   return Get.dialog(
//     barrierColor: Constants.bgBackDropColor,
//     Dialog(
//       backgroundColor: Colors.white,
//       insetPadding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
//       child: Container(
//         decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(14)), border: Border.all(color: Colors.grey.shade200)),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // const SizedBox(height: 15),
//             Padding(
//               padding: const EdgeInsets.only(top: 10, right: 10, bottom: 10, left: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       name,
//                       textAlign: TextAlign.left,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         color: Color.fromARGB(255, 10, 22, 41),
//                         fontWeight: FontWeight.w600,
//                       ),
//                       maxLines: 2, // Allow the title to span two lines
//                       overflow: TextOverflow.visible, // Ellipsis if the text is too long
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.share, size: 20),
//                         onPressed: () async {
//                           // await launchURL(url);
//                           //await downloadAndShareFile(Get.context!, pdfUrl, "Report");
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.close, size: 25),
//                         onPressed: () {
//                           Get.back();
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const Divider(
//               height: 0,
//               color: Color.fromARGB(255, 228, 230, 232),
//             ),
//             Expanded(
//               child: Container(
//                 margin: const EdgeInsets.only(bottom: 20),
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: SfPdfViewer.network(pdfUrl),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

// // Future<void> downloadAndShareFile(BuildContext context, fileUrl, fileName) async {
// //   try {
// //     // Get the app's temporary directory
// //     loadingPopUp(true);
// //     final directory = await getTemporaryDirectory();

// //     // File path where the file will be saved
// //     final filePath = '${directory.path}/$fileName.${fileUrl.split('.').last}';

// //     // Download the file using Dio
// //     Dio dio = Dio();
// //     await dio.download(fileUrl, filePath);
// //     loadingPopUp(false);
// //     // Share the file
// //     Share.shareXFiles([XFile(filePath)], text: "Report");
// //   } catch (e) {
// //     // Handle errors
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text("Error: $e")),
// //     );
// //     loadingPopUp(false);
// //     await Share.share(
// //       fileUrl,
// //     );
// //   }
// // }
