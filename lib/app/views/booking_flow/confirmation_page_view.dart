import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/bindings/booking_flow/scratch_card_binding.dart';
import 'package:my_new_app/app/controllers/booking_flow/confirmation_page_controller.dart';
import 'package:my_new_app/app/controllers/dashboard/dashboard_controller.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/theme/app_theme.dart';
import 'package:my_new_app/app/views/booking_flow/scratch_card_view.dart';

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
            top: 55,
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
                  'Track Your Wh',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
                const CircleAvatar(
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
                        const CircleAvatar(
                          radius: 28,
                          backgroundImage: AssetImage(
                              'assets/carwash/avatar.png'), // your staff image
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Alex R.',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: AppColors.textDefaultLight),
                              ),
                              Text(
                                'Premium Exterior Wash',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textLightGrayLight),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            //color: AppColors.borderLightGrayLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.star, color: Colors.green, size: 20),
                              SizedBox(width: 4),
                              Text(
                                '4.9',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDefaultLight,
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
                          _buildStepIcon(Icons.check_circle, "Confirmed",
                              AppColors.successLight),
                          _buildStepLine(),
                          _buildStepIcon(Icons.person_outline, "Staff Assigned",
                              AppColors.successLight),
                          _buildStepLine(),
                          _buildStepIcon(Icons.directions_car, "On the Way",
                              AppColors.successLight,
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
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.secondaryLight,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                      color: AppColors.secondaryLight)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Get.offAllNamed(Routes.dashboard,
                                  arguments: 1); // Go to History tab
                            },

                            //icon: const Icon(Icons.chat_outlined),
                            label: const Text('View History',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.secondaryLight,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryLight,
                              foregroundColor: AppColors.textWhiteLight,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Get.to(
                                () => const ScratchCardView(),
                                binding: ScratchCardBinding(),
                                opaque: false,
                                fullscreenDialog: true,
                                transition: Transition.fade,
                              );
                            },
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
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textDefaultLight,
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
      color: Colors.grey[400],
      margin: const EdgeInsets.symmetric(horizontal: 2),
    );
  }
}
