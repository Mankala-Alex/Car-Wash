import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/booking_flow/features_list_controller.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

class FeaturesListView extends GetView<FeaturesListController> {
  const FeaturesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        leadingWidth: 40,
        title: Text(
          'Door Step Services',
          style: TextStyle(
            fontSize: textTheme.titleLarge?.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.bgLight,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.services.length,
          itemBuilder: (context, index) {
            final service = controller.services[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.asset(
                      "assets/carwash/yellowcar.png",
                      height: 155,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // TITLE + PRICE
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            service.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                          ),
                        ),
                        Image.asset("assets/carwash/SAR.png",
                            width: 18, height: 18),
                        const SizedBox(width: 5),
                        Text(
                          service.price.toString(),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.bgBlackLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // DESCRIPTION
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                    child: Text(
                      service.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black,
                          ),
                    ),
                  ),

                  // FEATURES
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: service.features.map((f) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: AppColors.textGreenLight, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  f,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // BOOK NOW BUTTON
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.textWhiteLight,
                          backgroundColor: AppColors.secondaryLight,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Get.toNamed(
                            Routes.bookslot,
                            arguments: {
                              "image": "assets/carwash/yellowcar.png",
                              "name": service.name,
                              "description": service.description,
                              "price": service.price,
                              "features": service.features,
                            },
                          );
                        },
                        child: const Text('Book Now'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
