enum ApiEndpoint {
  kycinitiate('/auth/kyc/initiate'),
  phonerequestotp('/auth/phone/request-otp'),
  phoneverifyotp('/auth/phone/verify-otp'),
  completeregistration('/auth/complete-registration'),
  routes('/routes'),
  trips('/trips'),
  tripSearch('/trips/search'),
  bookings('/bookings'),
  kycverifyotp('/auth/kyc/verify-otp'),
  subscriptionPlans('/subscription-plans'),
  myRides('/bookings/my-rides');
  

  final String path;

  const ApiEndpoint(this.path);

  String get fullPath => path;
}