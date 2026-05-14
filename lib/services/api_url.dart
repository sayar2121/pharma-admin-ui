class ApiUrl {
  static const String baseUrl =
      "http://10.0.2.2:8000"; // Replace with your actual backend URL

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

  // Inventory Endpoints
  static const String addToInventory = "$baseUrl/medicine-inventory/create";
  static const String getInventoryByShop = "$baseUrl/medicine-inventory/get-all-by-shop"; // Append shopId
  static const String updateInventory = "$baseUrl/medicine-inventory/update-by"; // Append inventoryId
  static const String deleteInventory = "$baseUrl/medicine-inventory/delete-by"; // Append inventoryId
}
