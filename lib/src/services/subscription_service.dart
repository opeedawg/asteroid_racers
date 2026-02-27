import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  // Singleton pattern so we only initialize it once
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  // TODO: You will replace these with your actual keys from the RevenueCat dashboard later
  final String _appleApiKey = 'appl_api_key_placeholder';
  final String _googleApiKey = 'goog_api_key_placeholder';

  /// Initializes the RevenueCat SDK
  Future<
    void
  >
  initialize() async {
    // 1. Bypass initialization if we are on Web or Desktop!
    if (kIsWeb ||
        Platform.isWindows ||
        Platform.isLinux) {
      debugPrint(
        'RevenueCat is not supported on this platform. Bypassing init.',
      );
      return;
    }

    // 2. Otherwise, proceed with mobile initialization
    await Purchases.setLogLevel(
      LogLevel.debug,
    );

    PurchasesConfiguration? configuration;

    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(
        _googleApiKey,
      );
    } else if (Platform.isIOS ||
        Platform.isMacOS) {
      configuration = PurchasesConfiguration(
        _appleApiKey,
      );
    }

    if (configuration !=
        null) {
      await Purchases.configure(
        configuration,
      );
    }
  }

  /// Fetches the available packages (e.g., Lifetime Premium, Monthly, etc.)
  Future<
    List<
      Package
    >
  >
  fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current !=
              null &&
          offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages;
      }
      return [];
    } on PlatformException catch (
      e
    ) {
      debugPrint(
        'Error fetching offers: ${e.message}',
      );
      return [];
    }
  }

  /// Initiates the purchase flow for a specific package
  Future<
    bool
  >
  purchasePackage(
    Package package,
  ) async {
    try {
      // 1. Capture the PurchaseResult
      // Notice the .package named constructor!
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.package(
          package,
        ),
      );

      // 2. Access customerInfo from inside the result
      final isPremium =
          purchaseResult.customerInfo.entitlements.all['premium']?.isActive ??
          false;

      return isPremium;
    } on PlatformException catch (
      e
    ) {
      final errorCode = PurchasesErrorHelper.getErrorCode(
        e,
      );
      if (errorCode !=
          PurchasesErrorCode.purchaseCancelledError) {
        debugPrint(
          'Error purchasing package: ${e.message}',
        );
      }
      return false;
    }
  }

  /// Checks if the current user already has Premium (useful on app startup)
  Future<
    bool
  >
  checkPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all['premium']?.isActive ??
          false;
    } on PlatformException catch (
      e
    ) {
      debugPrint(
        'Error checking premium status: ${e.message}',
      );
      return false;
    }
  }
}
