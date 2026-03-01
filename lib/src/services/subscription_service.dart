import 'dart:io';

import 'package:asteroid_racers/src/services/logger_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    if (!Platform.isAndroid &&
        !Platform.isIOS) {
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
    void
  >
  fetchOffers(
    BuildContext context,
  ) async {
    try {
      Offerings offerings = await Purchases.getOfferings();

      if (offerings.current !=
              null &&
          offerings.current!.lifetime !=
              null) {
        PurchaseResult result = await Purchases.purchase(
          PurchaseParams.package(
            offerings.current!.lifetime!,
          ),
        );

        if (result.customerInfo.entitlements.all["premium"]?.isActive ==
            true) {
          // Check if the user is still on this screen before showing dialog
          if (!context.mounted) return;

          showDialog(
            context: context,
            builder:
                (
                  BuildContext context,
                ) => AlertDialog(
                  backgroundColor: const Color(
                    0xFF1E293B,
                  ), // Match your sci-fi theme
                  title: const Text(
                    "VIP Unlocked",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  content: const Text(
                    "Purchase successful! Welcome to the VIP club.",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ),
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(),
                    ),
                  ],
                ),
          );
        }
      }
    } on PlatformException catch (
      e,
      stack
    ) {
      if (!context.mounted) return;

      showDialog(
        context: context,
        builder:
            (
              BuildContext context,
            ) => AlertDialog(
              backgroundColor: const Color(
                0xFF1E293B,
              ),
              title: const Text(
                "Transmission Failed",
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
              content: Text(
                e.message ??
                    "An unknown error occurred.",
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
              actions: [
                TextButton(
                  child: const Text(
                    "Dismiss",
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(),
                ),
              ],
            ),
      );

      // Silently send the exact error and stack trace to your Supabase command center
      await LoggerService.logError(
        message: "RevenueCat Purchase Failed: ${e.message}",
        stackTrace: stack.toString(),
      );
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
