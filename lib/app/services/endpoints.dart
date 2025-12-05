class EndPoints {
  //booking slot
  static const apiGetAllServices = "services";
  static const apiGetfetchoffers = "offers";
  static const apiGetinstoreservices = "partners";
  //auth
  static const apiPostrequstotp = 'auth/request-otp'; //login
  static const apiPostverifyotp = 'auth/verify-otp'; //sign up
  static const apiPostsignup = 'auth/complete-signup';
  static const apiPostAddvehicle = 'customer-vehicles';
  static const apiGetslotdates = 'admin/dates';
  static const apiGettimeslots = 'admin/time-slots';
  // static const apiMobValidateOTP = 'MobProcess/MobValidateOTP';
  // static const apiResendOTP = 'MobProcess/ResendOTP';
}
