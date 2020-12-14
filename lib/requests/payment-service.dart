class StripeTransactionRespone {
  String message;
  bool success;
  StripeTransactionRespone({this.message, this.success});
}

class StripeService {
  static String apiBase = "https://api.stripe.com/v1";
  static String secret = "";

  static init() {}
}
