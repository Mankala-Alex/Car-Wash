class EndPoints {
  //support / help center
  static const apiSupportFaqCategories = 'support/faq/categories';
  static const apiSupportFaqQuestions = 'support/faq/questions';
  static const apiSupportConversation = 'support/conversation';
  static const apiSupportConversations = 'support/conversations';
  static const apiSupportBookings = 'support/bookings';

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

  //coupons (customer is view-only; coupons are redeemed by the partner app)
  static const apiGetMyCoupons = 'coupons/my';
  static const apigetcoupondetails = 'coupons/details';

  static const apiPostLogOut = 'auth/logout';

  //account deletion (App Store / Play Store requirement)
  static const apiDeleteMyAccount = 'customers/me';

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

  //payment methods (card / apple pay)
  static const apiPaymentMethods = "payment/methods";
  static const apiApplePayCreate = "payment/apple-pay/create";

  //saved cards (Paymob tokenization)
  static const apiSavedCards = "payment/cards";

  static const apiCreateReview = "reviews";
  static const apiGetReviewByBooking = "reviews/booking";
  static const apiGetMyReviews = "reviews/my";
}
