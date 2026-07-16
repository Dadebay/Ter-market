// import 'package:atlas/widgets/app_network_image.dart';
// import 'package:flutter/material.dart';

// class BannerDetailScreen extends StatelessWidget {
//   final String title;
//   final String imageUrl;
//   final String body;

//   const BannerDetailScreen({
//     super.key,
//     required this.title,
//     required this.imageUrl,
//     required this.body,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         surfaceTintColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.black),
//         title: Text(
//           title,
//           style: const TextStyle(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             fontFamily: 'Gilroy',
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.only(bottom: 32),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: AppNetworkImage(
//                   url: imageUrl,
//                   width: double.infinity,
//                   height: 220,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Text(
//                 body,
//                 style: const TextStyle(
//                   fontSize: 15,
//                   height: 1.6,
//                   color: Color(0xFF303030),
//                   fontFamily: 'Gilroy',
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
