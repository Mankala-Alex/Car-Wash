import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/booking_flow/confirmation_page_controller.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

class ConfirmationPageView extends GetView<ConfirmationPageController> {
  const ConfirmationPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar area using Stack for the translucent map
      body: Stack(
        children: [
          // Background map image
          Positioned.fill(
            child: Image.asset(
              'assets/carwash/map.png', // replace with your map asset
              fit: BoxFit.cover,
            ),
          ),
          // Top navigation bar
          Positioned(
            top: 48,
            left: 18,
            right: 18,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const Text(
                  'Track Your Wash',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 24,
                  child: Icon(Icons.more_horiz, color: Colors.black),
                ),
              ],
            ),
          ),
          // The draggable bottom sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 18,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'Arriving in 12 mins',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: AssetImage(
                              'assets/carwash/avatar.png'), // your staff image
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Alex R.',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              const Text(
                                'Premium Exterior Wash',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.star,
                                  color: Color(0xFF1566A6), size: 18),
                              SizedBox(width: 4),
                              Text(
                                '4.9',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1566A6),
                                    fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStepIcon(
                              Icons.check_circle, "Confirmed", Colors.blue),
                          _buildStepLine(),
                          _buildStepIcon(Icons.person_outline, "Staff Assigned",
                              Colors.blue),
                          _buildStepLine(),
                          _buildStepIcon(
                              Icons.directions_car, "On the Way", Colors.blue,
                              filled: true),
                          _buildStepLine(),
                          _buildStepIcon(
                              Icons.opacity, "In Progress", Colors.grey[400]),
                          _buildStepLine(),
                          _buildStepIcon(
                              Icons.check, "Completed", Colors.grey[400]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[50],
                              foregroundColor: const Color(0xFF1566A6),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {},
                            icon: const Icon(Icons.chat_outlined),
                            label: const Text('Chat',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryLight,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {},
                            icon: const Icon(Icons.call),
                            label: const Text('Call',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon(IconData icon, String label, Color? color,
      {bool filled = false}) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: filled ? color?.withOpacity(0.12) : Colors.white,
          radius: 23,
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 24,
      height: 2.5,
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 2),
    );
  }
}
