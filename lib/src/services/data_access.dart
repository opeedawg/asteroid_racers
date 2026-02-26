import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asteroid_racers/src/models/lookup_item.dart';

class DataAccess {
  static final DataAccess _instance = DataAccess._internal();
  factory DataAccess() => _instance;
  DataAccess._internal();

  final _supabase = Supabase.instance.client;

  // Pristine master list from DB
  List<
    LookupItem
  >?
  _masterLookups;
  // The list actually served to the UI (Filtered if not premium)
  List<
    LookupItem
  >?
  _cachedLookups;

  Map<
    String,
    dynamic
  >?
  _pilotSettings;
  int? _pilotDbId;

  Future<
    void
  >
  initializeSession() async {
    final user = _supabase.auth.currentUser;
    if (user ==
        null) {
      return;
    }

    final pilotData = await _supabase
        .from(
          'pilot',
        )
        .select(
          'id, settings',
        )
        .eq(
          'auth_id',
          user.id,
        )
        .single();

    _pilotDbId = pilotData['id'];
    _pilotSettings =
        pilotData['settings']
            as Map<
              String,
              dynamic
            >;

    final authResult = await _supabase
        .from(
          'lookup',
        )
        .select(
          'id',
        )
        .eq(
          'lookup_key',
          'AuthenticationResult',
        )
        .eq(
          'name',
          'Login Success',
        )
        .single();

    await _supabase
        .from(
          'authentication',
        )
        .insert(
          {
            'pilot_id': _pilotDbId,
            'result_id': authResult['id'],
          },
        );

    debugPrint(
      'Session initialized and login recorded for Pilot #$_pilotDbId',
    );
  }

  bool isPremium() {
    return _pilotSettings?['is_premium'] ??
        false;
  }

  Future<
    List<
      LookupItem
    >
  >
  getLookups({
    bool forceRefresh = false,
  }) async {
    // 1. Fetch from DB if master is empty or refresh requested
    if (_masterLookups ==
            null ||
        forceRefresh) {
      final data = await _supabase
          .from(
            'lookup',
          )
          .select()
          .order(
            'id',
            ascending: true,
          );

      _masterLookups = data
          .map(
            (
              row,
            ) => LookupItem.fromJson(
              row,
            ),
          )
          .toList();
    }

    // 2. Return everything if they are premium
    if (isPremium()) {
      _cachedLookups = _masterLookups;
      return _cachedLookups!;
    }

    // 3. Apply Freemium Enforcement filter to the master list
    _cachedLookups = _masterLookups!.where(
      (
        item,
      ) {
        if (item.key ==
                'BoardSize' &&
            ![
              'Small',
              'Regular',
            ].contains(
              item.name,
            )) {
          return false;
        }
        if (item.key ==
                'GameSpeed' &&
            ![
              'Very Slow',
              'Slow',
              'Normal',
            ].contains(
              item.name,
            )) {
          return false;
        }
        if (item.key ==
                'AIDifficulty' &&
            ![
              'Easy',
              'Normal',
            ].contains(
              item.name,
            )) {
          return false;
        }
        if (item.key ==
                'Theme' &&
            item.name !=
                'Classic') {
          return false;
        }
        return true;
      },
    ).toList();

    return _cachedLookups!;
  }

  String getPilotTag() {
    return _supabase.auth.currentUser?.userMetadata?['tag']
            as String? ??
        'Unknown';
  }

  Map<
    String,
    dynamic
  >
  getLastPlayedSettings() {
    return _pilotSettings?['last_played']
            as Map<
              String,
              dynamic
            >? ??
        {};
  }

  Future<
    void
  >
  updateLastPlayed(
    Map<
      String,
      dynamic
    >
    newSettings,
  ) async {
    if (_pilotDbId ==
        null) {
      return;
    }

    _pilotSettings!['last_played'] = newSettings;

    await _supabase
        .from(
          'pilot',
        )
        .update(
          {
            'settings': _pilotSettings,
          },
        )
        .eq(
          'id',
          _pilotDbId!,
        );

    debugPrint(
      'Last played settings saved to DB.',
    );
  }

  /// Calculates the difference between available options and free options
  int getHiddenCount(
    String key,
  ) {
    if (_masterLookups ==
        null) {
      return 0;
    }
    if (isPremium()) return 0;

    // Count every option in the database for this key
    final totalCount = _masterLookups!
        .where(
          (
            item,
          ) =>
              item.key ==
              key,
        )
        .length;

    // Recalculate what the "Free" count would be
    final filteredCount = _masterLookups!.where(
      (
        item,
      ) {
        if (item.key !=
            key) {
          return false;
        }

        if (key ==
                'BoardSize' &&
            ![
              'Small',
              'Regular',
            ].contains(
              item.name,
            )) {
          return false;
        }
        if (key ==
                'GameSpeed' &&
            ![
              'Very Slow',
              'Slow',
              'Normal',
            ].contains(
              item.name,
            )) {
          return false;
        }
        if (key ==
                'AIDifficulty' &&
            ![
              'Easy',
              'Normal',
            ].contains(
              item.name,
            )) {
          return false;
        }
        if (key ==
                'Theme' &&
            item.name !=
                'Classic') {
          return false;
        }

        return true;
      },
    ).length;

    return totalCount -
        filteredCount;
  }

  Future<
    Map<
      String,
      dynamic
    >
  >
  getDetailedPilotStats() async {
    if (_pilotDbId ==
        null) {
      return {};
    }

    try {
      // 1. Get creation date
      final pilotRow = await _supabase
          .from(
            'pilot',
          )
          .select(
            'created_at',
          )
          .eq(
            'id',
            _pilotDbId!,
          )
          .single();

      // 2. Count total matches (v2 Syntax: direct count)
      final int totalMatches = await _supabase
          .from(
            'match',
          )
          .count(
            CountOption.exact,
          )
          .eq(
            'pilot_id',
            _pilotDbId!,
          );

      // 3. Count wins (Assuming result_id 1 is 'Win')
      final int totalWins = await _supabase
          .from(
            'match',
          )
          .count(
            CountOption.exact,
          )
          .eq(
            'pilot_id',
            _pilotDbId!,
          )
          .eq(
            'result_id',
            1,
          );

      double winRate =
          totalMatches >
              0
          ? (totalWins /
                    totalMatches) *
                100
          : 0.0;

      return {
        'joined': pilotRow['created_at'],
        'totalMatches': totalMatches,
        'winRate': winRate.toStringAsFixed(
          1,
        ),
      };
    } catch (
      e
    ) {
      debugPrint(
        'Error fetching stats: $e',
      );
      return {
        'joined': DateTime.now().toString(),
        'totalMatches': 0,
        'winRate': '0.0',
      };
    }
  }
}
