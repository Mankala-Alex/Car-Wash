import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:my_new_app/app/bindings/booking_flow/book_slot_bindings.dart';
import 'package:my_new_app/app/bindings/booking_flow/confirmation_page_bindings.dart';
import 'package:my_new_app/app/bindings/booking_flow/features_list_bindings.dart';
import 'package:my_new_app/app/bindings/dashboard/dashboard_bindings.dart';
import 'package:my_new_app/app/views/booking_flow/book_slot_view.dart';
import 'package:my_new_app/app/views/booking_flow/confirmation_page_view.dart';
import 'package:my_new_app/app/views/dashboard/dashboard_view.dart';

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
      page: () => const LoginPageView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.otpPage,
      page: () => const OtpScreenView(),
      binding: OtpBinding(),
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
      name: Routes.confirmationpage,
      page: () => const ConfirmationPageView(),
      binding: ConfirmationPageBindings(),
    ),
  ];
}

//     GetPage(
//       name: Routes.accountVerification,
//       page: () => const AccountVerificationView(),
//       binding: AccountVerificationBindings(),
//     ),
//     GetPage(
//       name: Routes.verifyDetails,
//       page: () => const VerifyDetailsView(),
//       binding: VerifyDetailsBindings(),
//     ),
//     GetPage(
//       name: Routes.register,
//       page: () => const RegisterView(),
//       binding: RegisterBindings(),
//     ),
//     GetPage(
//       name: Routes.locationChange,
//       page: () => const LocationChangeView(),
//       binding: LocationChangeBindings(),
//     ),
//     GetPage(
//       name: Routes.dashboard,
//       page: () => DashboardView(),
//       binding: DashboardBindings(),
//     ),
//     GetPage(
//       name: Routes.specialities,
//       page: () => const SpecialitiesView(),
//       binding: SpecialitiesBindings(),
//     ),
//     GetPage(
//       name: Routes.doctorsList,
//       page: () => const DoctorsListView(),
//       binding: DoctorsListBindings(),
//     ),
//     GetPage(
//       name: Routes.doctorslots,
//       page: () => const DoctorSlotsView(),
//       binding: DoctorSlotsBindings(),
//     ),
//     GetPage(
//       name: Routes.addfamilymember,
//       page: () => const AddFamilyMemberView(),
//       binding: AddFamilyMemberBinding(),
//     ),
//     GetPage(
//       name: Routes.billtotal,
//       page: () => const BillTotalView(),
//       binding: BillTotalBinding(),
//     ),
//     GetPage(
//       name: Routes.doctorslist,
//       page: () => const DoctorsListView(),
//       binding: DoctorsListBindings(),
//     ),
//     GetPage(
//       name: Routes.selectpatient,
//       page: () => const SelectPatientView(),
//       binding: SelectPatientBinding(),
//     ),
//     GetPage(
//       name: Routes.addfamilymember,
//       page: () => const AddFamilyMemberView(),
//       binding: AddFamilyMemberBinding(),
//     ),
//     GetPage(
//       name: Routes.reviewpay,
//       page: () => const ReviewPayView(),
//       binding: ReviewPayBinding(),
//     ),
//     GetPage(
//       name: Routes.billtotal,
//       page: () => const BillTotalView(),
//       binding: BillTotalBinding(),
//     ),
//     GetPage(
//       name: Routes.bookingConfirmed,
//       page: () => const BookingConfirmedView(),
//       binding: BookingConfirmedBinding(),
//     ),
//     GetPage(
//       name: Routes.patientemrlist,
//       page: () => const PatientEmrListView(),
//       binding: PatientEmrListBinding(),
//     ),
//     GetPage(
//       name: Routes.patientemrhistory,
//       page: () => const PatientEmrHistoryView(),
//       binding: PatientEmrBinding(),
//     ),
//     GetPage(
//       name: Routes.patientlabreportlist,
//       page: () => const PatientLabReportListView(),
//       binding: PatientLabReportListBinding(),
//     ),
//     GetPage(
//       name: Routes.patientlabreport,
//       page: () => const PatientLabReportView(),
//       binding: PatientLabReportBinding(),
//     ),
//     GetPage(
//       name: Routes.proceduredetailslist,
//       page: () => const ProcedureDetailsListView(),
//       binding: ProcedureDetailsListBinding(),
//     ),
//     GetPage(
//       name: Routes.proceduredetails,
//       page: () => const ProcedureDetailsView(),
//       binding: ProcedureDetailBinding(),
//     ),
//     GetPage(
//       name: Routes.radiologydetailsList,
//       page: () => const RadiologyDetailsListView(),
//       binding: RadiologyDetailsBinding(),
//     ),
//     GetPage(
//       name: Routes.radiologydetails,
//       page: () => const RadiologyDetailsView(),
//       binding: RadiologyDetailsBinding(),
//     ),
//     GetPage(
//       name: Routes.prescriptiondetailslist,
//       page: () => const PrescriptionDetailsListView(),
//       binding: PrescriptionDetailsListBinding(),
//     ),
//     GetPage(
//       name: Routes.prescriptiondetails,
//       page: () => const PrescriptionDetailsView(),
//       binding: PrescriptionDetailsListBinding(),
//     ),
//     GetPage(
//       name: Routes.sickleaveletterslist,
//       page: () => const SickLeaveLettersListView(),
//       binding: SickLeaveLettersListBinding(),
//     ),
//     GetPage(
//       name: Routes.sickleaveletter,
//       page: () => const SickLeaveLetterView(),
//       binding: SickLeaveLetterBinding(),
//     ),
//     GetPage(
//       name: Routes.medicalreportslist,
//       page: () => const MedicalReportsListView(),
//       binding: MedicalReportsListBinding(),
//     ),
//     GetPage(
//       name: Routes.medicalreport,
//       page: () => const MedicalReportView(),
//       binding: MedicalReportBinding(),
//     ),
//     GetPage(
//       name: Routes.account_details,
//       page: () => const AccountDetailsView(),
//       binding: AccountDetailsBindings(),
//     ),
//     GetPage(
//       name: Routes.notificationsettings,
//       page: () => const NotificationSettingsView(),
//       binding: NotificationSettingsBindings(),
//     ),
//     GetPage(
//       name: Routes.privacypolicy,
//       page: () => const PrivacyPolicyView(),
//       binding: PrivacyPolicyBindings(),
//     ),
//     GetPage(
//       name: Routes.wallet,
//       page: () => const WalletView(),
//       binding: WalletBinding(),
//     ),
//     GetPage(
//       name: Routes.changelanguage,
//       page: () => const ChangeLanguageView(),
//       binding: ChangeLanguageBindings(),
//     ),
//     GetPage(
//       name: Routes.notification,
//       page: () => const NotificationView(),
//       binding: NotificationBinding(),
//     ),
//     GetPage(
//       name: Routes.offerlist,
//       page: () => const OfferListView(),
//       binding: OfferListBinding(),
//     ),
//     GetPage(
//       name: Routes.offerdetails,
//       page: () => const OfferDetailsView(),
//       binding: OfferDetailsBinding(),
//     ),
//     GetPage(
//       name: Routes.patientlist,
//       page: () => const PatientListView(),
//       binding: PatientListBinding(),
//     ),
//     GetPage(
//       name: Routes.patientlistaddfamilymember,
//       page: () => const PatientListAddFamilyMemberView(),
//       binding: PatientListAddFamilyMemberBinding(),
//     ),
//     GetPage(
//       name: Routes.profilereviews,
//       page: () => const ProfileReviewsView(),
//       binding: ProfileReviewsBinding(),
//     ),
//     GetPage(
//       name: Routes.addmoneywallet,
//       page: () => const AddMoneyWalletView(),
//       binding: AddMoneyWalletBinding(),
//     ),
//     GetPage(
//       name: Routes.bookFollowUp,
//       page: () => const BookFollowUpView(),
//       binding: BookFollowUpBinding(),
//     ),
//     GetPage(
//       name: Routes.rescheduleSlots,
//       page: () => const RescheduleSlotsView(),
//       binding: RescheduleSlotsBindings(),
//     ),
//     GetPage(
//       name: Routes.recheduleConfirmed,
//       page: () => const RescheduleConfirmedView(),
//       binding: RecheduleConfirmedBinding(),
//     ),
//     GetPage(
//       name: Routes.starrating,
//       page: () => const StarRatingView(),
//       binding: StarRatingBinding(),
//     ),
//   ];
// }
