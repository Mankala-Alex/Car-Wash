import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:my_new_app/app/bindings/auth/sign_up_binding.dart';
import 'package:my_new_app/app/bindings/booking_flow/book_slot_bindings.dart';
import 'package:my_new_app/app/bindings/booking_flow/confirmation_page_bindings.dart';
import 'package:my_new_app/app/bindings/booking_flow/features_list_bindings.dart';
import 'package:my_new_app/app/bindings/booking_flow/instore_wash_binding.dart';
import 'package:my_new_app/app/bindings/booking_flow/scratch_card_binding.dart';
import 'package:my_new_app/app/bindings/dashboard/dashboard_bindings.dart';
import 'package:my_new_app/app/bindings/dashboard/notification_binding.dart';
import 'package:my_new_app/app/bindings/profile/add_car_binding.dart';
import 'package:my_new_app/app/bindings/profile/add_location_binding.dart';
import 'package:my_new_app/app/bindings/profile/car_list_binding.dart';
import 'package:my_new_app/app/bindings/profile/help_n_support_binding.dart';
import 'package:my_new_app/app/bindings/profile/lang_change_binding.dart';
import 'package:my_new_app/app/bindings/profile/location_list_binding.dart';
import 'package:my_new_app/app/bindings/profile/my_coupons_binding.dart';
import 'package:my_new_app/app/bindings/profile/offer_screen_binding.dart';
import 'package:my_new_app/app/bindings/profile/offers_list_bindings.dart';
import 'package:my_new_app/app/views/auth/sign_up_view.dart';
import 'package:my_new_app/app/views/booking_flow/book_slot_view.dart';
import 'package:my_new_app/app/views/booking_flow/confirmation_page_view.dart';
import 'package:my_new_app/app/views/booking_flow/instore_wash_list_view.dart';
import 'package:my_new_app/app/views/booking_flow/scratch_card_view.dart';
import 'package:my_new_app/app/views/dashboard/dashboard_view.dart';
import 'package:my_new_app/app/views/dashboard/notifications_view.dart';
import 'package:my_new_app/app/views/profile/add_car_view.dart';
import 'package:my_new_app/app/views/profile/add_location_view.dart';
import 'package:my_new_app/app/views/profile/car_list_view.dart';
import 'package:my_new_app/app/views/profile/help_n_support_view.dart';
import 'package:my_new_app/app/views/profile/lang_change_view.dart';
import 'package:my_new_app/app/views/profile/locations_list_view.dart';
import 'package:my_new_app/app/views/profile/my_coupons_view.dart';
import 'package:my_new_app/app/views/profile/offer_screen_view.dart';
import 'package:my_new_app/app/views/profile/offers_list_view.dart';

import '../bindings/auth/lang_selection_binding.dart';
import '../bindings/auth/login_binding.dart';
import '../bindings/auth/otp_binding.dart';
import '../bindings/splash_screen_bindings.dart';
import '../views/auth/lang_selection_view.dart';
import '../views/auth/login_page_view.dart';
import '../views/auth/otp_screen_view.dart';
import '../views/booking_flow/features_list_view.dart';
import '../views/splash_screen_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initialPage = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreenView(),
      binding: SplashScreenBindings(),
    ),
    GetPage(
      name: Routes.langeSelection,
      page: () => const LangSelectionView(),
      binding: LangSelectionBindings(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.otpPage,
      page: () => const OtpScreenView(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: Routes.signUp,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),

    //dashboard
    GetPage(
      name: Routes.dashboard,
      page: () => DashboardView(),
      binding: DashboardBindings(),
    ),
    GetPage(
      name: Routes.bookslot,
      page: () => const BookSlotView(),
      binding: BookSlotBindings(),
    ),
    GetPage(
      name: Routes.featureslist,
      page: () => const FeaturesListView(),
      binding: FeaturesListBindings(),
    ),
    GetPage(
      name: Routes.confirmationpageview,
      page: () => const ConfirmationPageView(),
      binding: ConfirmationPageBindings(),
    ),
    GetPage(
      name: Routes.instorewash,
      page: () => const InstoreWashListView(),
      binding: InstoreWashBinding(),
    ),
    GetPage(
      name: Routes.carlist,
      page: () => const CarListView(),
      binding: CarListBinding(),
    ),
    GetPage(
      name: Routes.addcar,
      page: () => const AddCarView(),
      binding: AddCarBinding(),
    ),
    GetPage(
      name: Routes.locationslist,
      page: () => const LocationsListView(),
      binding: LocationListBinding(),
    ),
    GetPage(
      name: Routes.addlocation,
      page: () => const AddLocationView(),
      binding: AddLocationBinding(),
    ),
    GetPage(
      name: Routes.notification,
      page: () => const NotificationsView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: Routes.help,
      page: () => const HelpNSupportView(),
      binding: HelpNSupportBinding(),
    ),
    GetPage(
      name: Routes.langchange,
      page: () => const LangChangeView(),
      binding: LangChangeBinding(),
    ),
    GetPage(
      name: Routes.mycoupons,
      page: () => const MyCouponsView(),
      binding: MyCouponsBinding(),
    ),
    GetPage(
      name: Routes.scratchcard,
      page: () => const ScratchCardView(),
      binding: ScratchCardBinding(),
    ),
    GetPage(
      name: Routes.offers,
      page: () => const OffersListView(),
      binding: OffersListBindings(),
    ),
    GetPage(
      name: Routes.offerscreen,
      page: () => const OfferScreenView(),
      binding: OfferScreenBinding(),
    ),
  ];
}
