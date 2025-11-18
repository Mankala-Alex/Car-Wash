import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart'; // Ensure this import is correct
import 'package:get/get.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

import '../../controllers/dashboard/dashboard_controller.dart';
import '../../routes/app_routes.dart'; // To navigate to Routes.BOOK_SLOT

class Page1View extends GetView<DashboardController> {
  const Page1View({super.key});
  final List<String> bannerImages = const [
    'assets/carwash/carwheel.png',
    'assets/carwash/splash_image.jpg',
    'assets/carwash/yellowcar.png', // Add more if you have them
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.account_circle_sharp),
            SizedBox(width: 10),
            Text(
              "CAR WASH",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B), // Dark text color
              ),
            ),
            Spacer(),
            Icon(Icons.notifications),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Carousel Section ---
            FlutterCarousel(
              options: FlutterCarouselOptions(
                height: 180,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.85,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                enableInfiniteScroll: true,
                showIndicator: true,
                slideIndicator: CircularSlideIndicator(
                  slideIndicatorOptions: const SlideIndicatorOptions(
                    currentIndicatorColor: Colors.black,
                    indicatorBackgroundColor: Colors.white,
                    indicatorRadius: 3,
                    itemSpacing: 15,
                  ),
                ),
              ),
              items: bannerImages.map((imagePath) {
                return Builder(
                  builder: (context) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        image: DecorationImage(
                          image: AssetImage(imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: AppColors.warningLight),
                  child: Center(child: Text("50% OFF"))),
            ),
            // --- Doorstep & In-Store Wash Buttons ---
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SERVICE CARDS USING THE SAME WIDGET ---
                  ServiceCard(
                    title: "Doorstep Wash",
                    subtitle: "Convenience at your home",
                    buttonText: "Book Now",
                    imagePath: "assets/carwash/door_step.png",
                    onTap: () {
                      Get.toNamed(Routes.featureslist);
                    },
                  ),

                  ServiceCard(
                    title: "In-Store Wash",
                    subtitle: "Visit us for a premium clean",
                    buttonText: "Book Now",
                    imagePath: "assets/carwash/in_store.png",
                    discountText: "50% OFF",
                    onTap: () {
                      Get.toNamed(Routes.bookslot);
                    },
                  ),
                  //BOOK NOW BUTTON//
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //       horizontal: 20, vertical: 16),
                  //   margin: const EdgeInsets.only(top: 16),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(16),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.grey.shade300,
                  //         blurRadius: 15,
                  //         offset: const Offset(0, 4),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           // Left Car Icon Box
                  //           Container(
                  //             padding: const EdgeInsets.all(12),
                  //             decoration: BoxDecoration(
                  //               color: Colors.blue.shade50,
                  //               borderRadius: BorderRadius.circular(12),
                  //             ),
                  //             child: const Icon(
                  //               Icons.directions_car,
                  //               size: 28,
                  //               color: Colors.blue,
                  //             ),
                  //           ),
                  //           const SizedBox(
                  //             width: 5,
                  //           ),
                  //           const Expanded(
                  //             child: Text(
                  //               "MERCEDES BENZ",
                  //               style: TextStyle(
                  //                   fontSize: 14,
                  //                   fontWeight: FontWeight.w600,
                  //                   color: AppColors.textDefaultLight),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       SizedBox(
                  //         height: 15,
                  //       ),
                  //       GestureDetector(
                  //         onTap: () {
                  //           Get.toNamed(Routes.featureslist);
                  //         },
                  //         child: Container(
                  //           padding: const EdgeInsets.all(10),
                  //           decoration: BoxDecoration(
                  //             color: AppColors.primaryLight,
                  //             borderRadius: BorderRadius.circular(12),
                  //           ),
                  //           child: const Row(
                  //             children: [
                  //               Text(
                  //                 "Book Now",
                  //                 style: TextStyle(
                  //                     fontSize: 18,
                  //                     fontWeight: FontWeight.w600,
                  //                     color: AppColors.bgLight),
                  //               ),
                  //               // Icon(Icons.arrow_forward_ios,
                  //               //     size: 16, color: AppColors.bgLight),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  const SizedBox(height: 30),

                  // --- Featured Services Title ---
                  // Text(
                  //   "Featured Services",
                  //   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  //         fontWeight: FontWeight.bold,
                  //         color: const Color(0xFF1E293B), // Dark text color
                  //       ),
                  // ),
                  // const SizedBox(height: 20),

                  // --- Featured Services Grid ---
                  // GridView.builder(
                  //   shrinkWrap:
                  //       true, // Important for GridView inside SingleChildScrollView
                  //   physics:
                  //       const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                  //   itemCount: 4, // Number of featured service items
                  //   gridDelegate:
                  //       const SliverGridDelegateWithFixedCrossAxisCount(
                  //     crossAxisCount: 2, // 2 items per row
                  //     crossAxisSpacing: 16, // Horizontal spacing
                  //     mainAxisSpacing: 16, // Vertical spacing
                  //     childAspectRatio: 0.95, // Adjust item height vs. width
                  //   ),
                  //   itemBuilder: (context, index) {
                  //     switch (index) {
                  //       case 0:
                  //         return _buildFeaturedServiceCard(context,
                  //             imagePath:
                  //                 'assets/carwash/basic_wash.png', // Replace with your image
                  //             title: "Basic Wash", onTap: () {
                  //           Get.toNamed(Routes
                  //               .bookslot); // Navigate to booking with pre-selected service
                  //         });
                  //       case 1:
                  //         return _buildFeaturedServiceCard(context,
                  //             imagePath:
                  //                 'assets/carwash/polish_car.png', // Replace with your image
                  //             title: "Premium Detail", onTap: () {
                  //           Get.toNamed(Routes.bookslot);
                  //         });
                  //       case 2:
                  //         return _buildFeaturedServiceCard(context,
                  //             imagePath:
                  //                 'assets/carwash/interior2.png', // Replace with your image
                  //             title: "Interior Cleaning", onTap: () {
                  //           Get.toNamed(Routes.bookslot);
                  //         });
                  //       case 3:
                  //         return _buildFeaturedServiceCard(context,
                  //             imagePath:
                  //                 'assets/carwash/interior_car.png', // Replace with your image
                  //             title: "Interior Cleaning", onTap: () {
                  //           Get.toNamed(Routes.bookslot);
                  //         });
                  //       default:
                  //         return Container(); // Fallback
                  //     }
                  //   },
                  // ),
                ],
              ),
            ),
            //const SizedBox(height: 30), // Padding at the bottom
          ],
        ),
      ),
    );
  }

  // Helper widget for Carousel items
  Widget _buildCarouselItem(
    BuildContext context, {
    required String imagePath,
    required String title,
    required String subtitle,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3), // Darken image for text readability
            BlendMode.darken,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end, // Align text to bottom
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for Doorstep/In-Store buttons
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80, // Fixed height for the buttons
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center icon and text
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Flexible(
                // Allows text to wrap or shrink if needed
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.2, // Adjust line height for multiline text
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for Featured Service cards
  Widget _buildFeaturedServiceCard(
    BuildContext context, {
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white, // Default background
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.35), // Darken image slightly
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final String imagePath;
  final String? discountText;
  final VoidCallback? onTap;

  const ServiceCard(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.buttonText,
      required this.imagePath,
      this.discountText,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 15,
              offset: const Offset(5, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // If discount available → show badge
                  if (discountText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        discountText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  if (discountText != null) const SizedBox(height: 8),

                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade900,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Button
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                        // color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(30),
                        color: AppColors.primaryLight
                        //   colors: [
                        //     Color(0xFF6B42F2),
                        //     Color(0xFF825AD9),
                        //   ],
                        //   begin: Alignment.centerLeft,
                        //   end: Alignment.centerRight,
                        // ),
                        ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buttonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.arrow_forward,
                            color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right Image Section
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: 150,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_carousel_widget/flutter_carousel_widget.dart'; // This might not be needed for this specific design
// import 'package:get/get.dart';
// import 'package:my_new_app/app/routes/app_routes.dart';

// import '../../controllers/dashboard/dashboard_controller.dart';

// class Page1View extends GetView<DashboardController> {
//   const Page1View({super.key});

//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F8FA), // Light grey background
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         toolbarHeight: 80, // Adjust as needed
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Hello, Alex!",
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFF1E293B), // Dark text color
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               "Ready to make your car shine?",
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.notifications_none_outlined, size: 28, color: const Color(0xFF1E293B)),
//             onPressed: () {
//               // Handle notification tap
//             },
//           ),
//           SizedBox(width: 8),
//           IconButton(
//             icon: Icon(Icons.camera_alt_outlined, size: 28, color: const Color(0xFF1E293B)),
//             onPressed: () {
//               // Handle camera tap
//             },
//           ),
//           SizedBox(width: 16),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 20),

//               // Doorstep Wash Card
//               Container(
//                 width: screenWidth,
//                 height: screenHeight * 0.45, // Adjust height as needed
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   color: Colors.blue, // Placeholder for the gradient and image
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       spreadRadius: 1,
//                       blurRadius: 10,
//                       offset: Offset(0, 5),
//                     ),
//                   ],
//                   image: DecorationImage(
//                     image: AssetImage('assets/carwash/home_car.png'), // Replace with your image asset
//                     fit: BoxFit.cover,
//                     alignment: Alignment.center,
//                   ),
//                 ),
//                 child: Container( // Gradient overlay to make text readable
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.black.withOpacity(0.3),
//                         Colors.black.withOpacity(0.0),
//                         Colors.black.withOpacity(0.0),
//                         Colors.black.withOpacity(0.0),
//                         Colors.black.withOpacity(0.3),
//                       ],
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Doorstep Wash",
//                           style: TextStyle(
//                             fontSize: 26,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         Text(
//                           "Convenience delivered to your home.",
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.white70,
//                           ),
//                         ),
//                         Spacer(), // Pushes content to the top
//                         ElevatedButton(
//                           onPressed: () {
//                             // Handle Explore button tap
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             foregroundColor: const Color(0xFF2196F3), // Button text color
//                             padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             elevation: 0,
//                           ),
//                           child: Text(
//                             "Explore",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               SizedBox(height: 20),

//               // In-Store Wash Card
//               Container(
//                 width: screenWidth,
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       spreadRadius: 1,
//                       blurRadius: 5,
//                       offset: Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "In-Store Wash",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: const Color(0xFF1E293B),
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         Text(
//                           "Visit our premium wash center for an\nexpress service.",
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFCC00), // Yellow color for 50% OFF
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         "50% off",
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: 20),

//               // Quick Booking
//               Container(
//                 width: screenWidth,
//                 padding: const EdgeInsets.all(15),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       spreadRadius: 1,
//                       blurRadius: 5,
//                       offset: Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.directions_car_filled_outlined, color: Colors.grey[700], size: 28),
//                     SizedBox(width: 15),
//                     Expanded(
//                       child: Text(
//                         "Tesla Model 3", // Replace with dynamic car model
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xFF1E293B),
//                         ),
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         Get.toNamed(Routes.bookslot);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF2196F3), // Blue button
//                         foregroundColor: Colors.white,
//                         padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: Text(
//                         "Book Now",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: 20),

//               // Featured Services Title
//               Text(
//                 "Featured Services",
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF1E293B),
//                 ),
//               ),
//               SizedBox(height: 15),

//               // Featured Services Scrollable List
//               SizedBox(
//                 height: 150, // Height for the horizontal scrollable cards
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     _buildServiceCard(
//                       icon: Icons.water_drop_outlined,
//                       serviceName: "Basic Wash",
//                       price: "\$25",
//                       duration: "30m",
//                     ),
//                     SizedBox(width: 15),
//                     _buildServiceCard(
//                       icon: Icons.water_drop_outlined, // Placeholder, replace with actual logo or icon
//                       serviceName: "Premium Detail",
//                       price: "\$80",
//                       duration: "1.5h",
//                       isPremium: true, // Example to differentiate icon/logo if needed
//                     ),
//                     SizedBox(width: 15),
//                     _buildServiceCard(
//                       icon: Icons.chair_outlined, // Placeholder for interior clean
//                       serviceName: "Interior Clean",
//                       price: "\$40",
//                       duration: "1h",
//                     ),
//                     SizedBox(width: 15),
//                     // Add more service cards as needed
//                   ],
//                 ),
//               ),

//               SizedBox(height: 20),

//               // Promotional Banner (Bottom)
//               Container(
//                 width: screenWidth,
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1E293B), // Dark blue/grey background
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       spreadRadius: 1,
//                       blurRadius: 10,
//                       offset: Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "First Doorstep Wash?",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           SizedBox(height: 5),
//                           Text(
//                             "Get 50% OFF on your next In-Store visit!",
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.white70,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Icon(
//                       Icons.discount_outlined, // Or a custom coupon icon
//                       color: const Color(0xFFFFCC00), // Yellow
//                       size: 40,
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: 30), // Extra space at the bottom
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper widget for building service cards
//   Widget _buildServiceCard({
//     required IconData icon,
//     required String serviceName,
//     required String price,
//     required String duration,
//     bool isPremium = false, // To handle 'RKLE' logo for premium
//   }) {
//     return Container(
//       width: 150, // Fixed width for each service card
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF0F4F8), // Light grey background for icon
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: isPremium
//                 ? Image.asset(
//                     'assets/images/rkle_logo.png', // Replace with your RKLE logo asset
//                     height: 24,
//                     width: 24,
//                   )
//                 : Icon(icon, size: 24, color: const Color(0xFF2196F3)),
//           ),
//           SizedBox(height: 10),
//           Text(
//             serviceName,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF1E293B),
//             ),
//           ),
//           SizedBox(height: 5),
//           Row(
//             children: [
//               Text(
//                 price,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: const Color(0xFF2196F3),
//                 ),
//               ),
//               Text(
//                 " • $duration",
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
