class EndPoints {
  //auth
  static const apiGetMobNationalityIdType = 'MobProcess/GetMobNationalityIdType';
  static const apiSetAppMobUser = 'MobProcess/SetAppMobUser';
  static const apiMobValidateOTP = 'MobProcess/MobValidateOTP';
  static const apiResendOTP = 'MobProcess/ResendOTP';

  //appointment

  static const apiGetMobAllCategory = 'MobProcess/GetMobAllCategory';
  static const apiGetMobPhysicianByCategory = 'MobProcess/GetMobPhysicianByCategory';
  static const apiGetMobSlotsByDoctorId = 'MobProcess/GetMobSlotsByDoctorId';
  static const apiGetMobReviews = 'MobProcess/GetMobReviews';
  static const apiGetMobFamilyMembers = 'MobProcess/GetMobFamilyMembers';
  static const apiSetFamilyMember = 'MobProcess/SetFamilyMember';
  static const apiGetMobRelation = 'MobProcess/GetMobRelation';
  static const apiGetMobDoctorDetail = 'MobProcess/GetMobDoctorDetail';
  static const apiGetMobAppointments = 'MobProcess/GetMobAppointments';

  //reports
  static const apiGetMobPatientEMR = 'MobProcess/GetMobPatientEMR';
  static const apiGetMobEMRHistory = 'MobProcess/GetMobEMRHistory';
  static const apiGetMobPatientLab = 'MobProcess/GetMobPatientLab';
  static const apiGetMobLabHistory = 'MobProcess/GetMobLabHistory';
  static const apiGetMobPatientProcedure = 'MobProcess/GetMobPatientProcedure';
  static const apiGetMobProcedureHistory = 'MobProcess/GetMobProcedureHistory';
  static const apiGetMobPatientRadiology = 'MobProcess/GetMobPatientRadiology';
  static const apiGetMobRadiologyHistory = 'MobProcess/GetMobRadiologyHistory';
  static const apiGetMobPatientPrescription = 'MobProcess/GetMobPatientPrescription';
  static const apiGetMobPrescriptionHistory = 'MobProcess/GetMobPrescriptionHistory';
  static const apiGetMobPatientSickLeave = 'MobProcess/GetMobPatientSickLeave';
  static const apiGetMobSickLeave = 'MobProcess/GetMobSickLeave';
  static const apiGetMobPatientMedicalReport = 'MobProcess/GetMobPatientMedicalReport';
  static const apiGetMobMedicalReport = 'MobProcess/GetMobMedicalReport';
  static const apimedicalReportId = 'MobProcess/medicalReportId';

  static const apiGetMobOfferList = 'MobProcess/GetMobOfferList';
  static const apiGetMobOffers = 'MobProcess/GetMobOffers';
  static const apiGetMobAppMUser = 'MobProcess/GetMobAppMUser';
  static const apiGetMobReviewDetail = 'MobProcess/GetMobReviewDetail';
  static const apiGetMobWalletInfo = 'MobProcess/GetMobWalletInfo';
  static const apiSetMobAddMoneyWallet = 'MobProcess/SetMobAddMoneyWallet';
  static const apiGetMobNotification = 'MobProcess/GetMobNotification';
  static const apiGetMobClearNotification = 'MobProcess/GetMobClearNotification';
  static const apiSetMobBookFollowUp = 'MobProcess/SetMobBookFollowUp';
  static const apiSetMobStarRating = 'MobProcess/SetMobStarRating';

  //dashboard
  static const apiGetMobHomePage = 'MobProcess/GetMobHomePage';
  static const apiGetMobConfirmationDetails = 'MobProcess/GetMobConfirmationDetails';
  static const apiGetCoupon = 'MobProcess/GetCoupon';
  static const apiMobChangeLang = 'MobProcess/MobChangeLang';
  static const apiMobLogout = 'MobProcess/MobLogout';
  static const apiMobCancelAppointment = 'MobProcess/MobCancelAppointment';
  static const apiMobUploadPatientimage = 'MobProcess/MobUploadPatientimage';
  static const apideleteImage = 'patientmaster/deleteImage';
  static const apiGetMobAppointmentDetail = 'MobProcess/GetMobAppointmentDetail';
  static const apiSetMobRescheduleAppointment = 'MobProcess/SetMobRescheduleAppointment';
  static const apiUpdateMobFamilyMember = 'MobProcess/UpdateMobFamilyMember';
  static const apiSetMobPatientMaster = 'MobProcess/SetMobPatientMaster';
  static const apiGetMobLocationById = 'MobProcess/GetMobLocationById';

  //new patient registration
  static const apiGetReligionAll = 'MasterProcessI/GetReligionAll';

  static const apigetAll = 'country/getAll';
  static const apiGetOccupationAll = 'MasterProcessI/GetOccupationAll';
  static const apigetreferencegroupid20 = 'ReferenceValue/getreferencegroupid/20';
  static const apigetreferencegroupid5 = 'ReferenceValue/getreferencegroupid/5';
  static const apigetreferencegroupid3 = 'ReferenceValue/getreferencegroupid/3';
}
