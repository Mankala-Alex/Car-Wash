import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/tract_technician_controller.dart';

class TractTechnicianView extends GetView<TrackTechnicianController> {
  const TractTechnicianView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final booking = controller.booking.value;

        return Stack(
          children: [
            // ================= MAP BACKGROUND =================
            Positioned.fill(
              child: Image.asset(
                "assets/carwash/map.png",
                fit: BoxFit.cover,
              ),
            ),

            // ================= ROUTE LINE =================
            Positioned.fill(
              child: CustomPaint(
                painter: RoutePainter(),
              ),
            ),

            // ================= START MARKER =================
            const Positioned(
              top: 140,
              left: 80,
              child: _LocationMarker(
                icon: Icons.home,
                color: Colors.orange,
              ),
            ),

            // ================= END MARKER =================
            const Positioned(
              bottom: 280,
              right: 80,
              child: _LocationMarker(
                icon: Icons.location_on,
                color: Colors.red,
              ),
            ),

            // ================= TOP BAR =================
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const _CircleButton(icon: Icons.arrow_back),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                booking.vehicle.isEmpty
                                    ? "Tracking service"
                                    : booking.vehicle,
                                style: const TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Text(
                              "Live",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================= BOTTOM CARD =================
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                width: MediaQuery.of(context).size.width * 0.92,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== EXPECTED TIME =====
                    Text(
                      booking.scheduledAt == null
                          ? "Expected soon"
                          : "Scheduled at ${booking.scheduledAt}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      booking.status,
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 14),

                    // ===== STATUS PROGRESS =====
                    _statusProgress(booking.status),

                    const SizedBox(height: 18),

                    // ===== TECHNICIAN ROW =====
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              AssetImage("assets/profile/profile.png"),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.washerName.isEmpty
                                    ? "Technician Assigned"
                                    : booking.washerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Booking ID: ${booking.bookingCode}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const _ActionIcon(icon: Icons.phone),
                        const SizedBox(width: 10),
                        const _ActionIcon(icon: Icons.chat),
                        const SizedBox(width: 10),
                        const _ActionIcon(icon: Icons.more_vert),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ================= STATUS PROGRESS =================
  Widget _statusProgress(String status) {
    bool assigned = status == "ASSIGNED" ||
        status == "ARRIVED" ||
        status == "IN_PROGRESS" ||
        status == "COMPLETED";

    bool arrived =
        status == "ARRIVED" || status == "IN_PROGRESS" || status == "COMPLETED";

    bool inProgress = status == "IN_PROGRESS" || status == "COMPLETED";

    bool completed = status == "COMPLETED";

    Color active = Colors.orange;
    Color inactive = Colors.grey.shade400;

    return Row(
      children: [
        // ===== ASSIGNED =====
        _stepIcon(
          icon: Icons.assignment_turned_in,
          active: assigned,
        ),

        _stepDivider(active: arrived),

        // ===== ARRIVED =====
        _stepIcon(
          icon: Icons.location_on,
          active: arrived,
        ),

        _stepDivider(active: inProgress),

        // ===== IN PROGRESS =====
        _stepIcon(
          icon: Icons.local_car_wash,
          active: inProgress,
        ),

        _stepDivider(active: completed),

        // ===== COMPLETED =====
        _stepIcon(
          icon: Icons.check_circle,
          active: completed,
        ),
      ],
    );
  }
}

Widget _stepIcon({required IconData icon, required bool active}) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: active ? Colors.orange : Colors.grey.shade200,
      border: Border.all(
        color: active ? Colors.orange : Colors.grey.shade400,
      ),
    ),
    child: Icon(
      icon,
      size: 18,
      color: active ? Colors.white : Colors.grey,
    ),
  );
}

Widget _stepDivider({required bool active}) {
  return Expanded(
    child: Divider(
      thickness: 2,
      color: active ? Colors.orange : Colors.grey.shade300,
    ),
  );
}

// ================= SMALL WIDGETS =================

class _CircleButton extends StatelessWidget {
  final IconData icon;
  const _CircleButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  const _ActionIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20),
    );
  }
}

class _LocationMarker extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _LocationMarker({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

// ================= ROUTE PAINTER =================

class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(90, 180)
      ..quadraticBezierTo(160, 260, 120, 340)
      ..quadraticBezierTo(80, 420, 180, 500)
      ..quadraticBezierTo(260, 580, 280, 650);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
