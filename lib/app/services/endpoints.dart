class EndPoints {
  //booking slot
  static const apiGetAllServices = "services";
  static const apiGetfetchoffers = "offers";
  static const apiGetPublicPartners = "partners/public";
  //auth
  static const apiPostrequstotp = 'auth/request-otp'; //login
  static const apiPostverifyotp = 'auth/verify-otp'; //sign up
  static const apiPostsignup = 'auth/complete-signup';

  //sms login
  static const apiPostRequestOtpPhone = 'authentical/send-otp';
  static const apiPostVerifyOtpPhone = 'authentical/verify-otp';
  static const apiPostSignupPhone = 'authentical/complete-signup';

  static const apiPostAddvehicle = 'customer-vehicles';
  static const apiGetslotdates = 'admin/dates';
  static const apiGettimeslots = 'admin/time-slots';
  static const apiPostbookslot = 'bookings';
  static const apiCheckCustomerServiceability = 'service-areas/availability';
  static const apiGetbookinghistory = 'bookings/history';
  static const apiGetvehicles = 'customer-vehicles';
  static const apiGetcoupons = 'coupons/customer';
  static const apiGetcouponslist = 'coupons/list';
  static const apigetcoupondetails = 'coupons/details';
  static const apiPostLogOut = 'auth/logout';

  static const apiPlaceAutocomplete = "maps/autocomplete";

  static const apiPlaceDetails = "maps/place-details";

  static const apiGetTermsAndConditions =
      "legal-documents/public/TERMS_AND_CONDITIONS";
  static const apiGetPrivacyPolicy = "legal-documents/public/PRIVACY_POLICY";

  static const apigetadvertisements = "advertisements";

  //payment
  // payment

  static const apiPaymentCreate = "payment/create";

  static const apiPaymentStatus = "payment/status";

  static const apiPaymentStatusByAttempt = "payment/status/attempt";

  static const apiCreateReview = "reviews";
  static const apiGetReviewByBooking = "reviews/booking";
  static const apiGetMyReviews = "reviews/my";
}
