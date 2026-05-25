class ApiUrl {
  static const String baseUrl =
      "http://10.0.2.2:8000"; // Replace with your actual backend URL
  static const String wsBaseUrl =
      "ws://10.0.2.2:8000"; // Replace with your actual WebSocket URL

  // Pharma Shop Authentication and Profile Endpoints
  static const String signup = "$baseUrl/auth/pharma-shop/signup";
  static const String login = "$baseUrl/auth/pharma-shop/login";
  static const String getShopById =
      "$baseUrl/auth/pharma-shop/get-by"; // Append shopId
  static const String updateShopById =
      "$baseUrl/auth/pharma-shop/update-by"; // Append shopId
  static const String deleteShopById =
      "$baseUrl/auth/pharma-shop/delete-by"; // Append shopId

  // Medicine Endpoints
  static const String getAllMedicines = "$baseUrl/medicines/get-all";
  static const String searchMedicines = "$baseUrl/medicines/search";

  // About Us Endpoints
  static const String aboutUs = "$baseUrl/about-us";
  static const String getAboutUsAll = "$aboutUs/get-all";
  static String getAboutUsById(int id) => "$aboutUs/get-by/$id";

  // Helper for image URLs
  static String imageUrl(String path) => "$baseUrl/$path";

  // WebSocket Endpoints
  static String shopWebSocket(String shopId) => "$wsBaseUrl/orders-ws/shop/$shopId";

  // Terms and Conditions Endpoints
  static const String termsConditions = "$baseUrl/terms-conditions";
  static const String getTermsConditionsAll = "$termsConditions/get-all";

  // Privacy Policy Endpoints
  static const String privacyPolicies = "$baseUrl/privacy-policies";
  static const String getPrivacyPoliciesAll = "$privacyPolicies/get-all";
}
