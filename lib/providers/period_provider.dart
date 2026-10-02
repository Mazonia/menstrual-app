import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/period_model.dart';
import '../services/period_service.dart';

class PeriodProvider with ChangeNotifier {
  final PeriodService _periodService = PeriodService();
  Period? _currentPeriod;
  List<Period> _periodHistory = [];
  bool _isLoading = false;

  Period? get currentPeriod => _currentPeriod;
  List<Period> get periodHistory => _periodHistory;
  bool get isLoading => _isLoading;

  // Initialize provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // First load from local storage (faster startup)
      await loadData();

      // Then try to sync with Firebase if user is logged in
      if (_periodService.isLoggedIn) {
        await _syncWithFirebase();
      }
    } catch (e) {
      print('Error initializing period data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new period
  Future<void> addPeriod({
    required DateTime startDate,
    int cycleLength = 28,
    int periodLength = 5,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final period = Period(
        startDate: startDate,
        cycleLength: cycleLength,
        periodLength: periodLength,
      );

      _currentPeriod = period;
      _periodHistory.add(period);

      // Save to both local storage and Firebase
      await saveData();

      if (_periodService.isLoggedIn) {
        await _periodService.savePeriod(period);
      }
    } catch (e) {
      print('Error adding period: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update cycle length
  Future<void> updateCycleLength(int newCycleLength) async {
    if (_currentPeriod != null) {
      _isLoading = true;
      notifyListeners();

      try {
        final updatedPeriod = Period(
          startDate: _currentPeriod!.startDate,
          cycleLength: newCycleLength,
          periodLength: _currentPeriod!.periodLength,
        );

        _currentPeriod = updatedPeriod;

        // Update in history
        final index = _periodHistory.indexWhere(
          (p) => p.startDate == updatedPeriod.startDate,
        );

        if (index != -1) {
          _periodHistory[index] = updatedPeriod;
        }

        // Save to both local storage and Firebase
        await saveData();

        if (_periodService.isLoggedIn) {
          await _periodService.updatePeriod(updatedPeriod);
          await _periodService.saveUserSettings(
            cycleLength: newCycleLength,
            periodLength: updatedPeriod.periodLength,
          );
        }
      } catch (e) {
        print('Error updating cycle length: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Update period length
  Future<void> updatePeriodLength(int newPeriodLength) async {
    if (_currentPeriod != null) {
      _isLoading = true;
      notifyListeners();

      try {
        final updatedPeriod = Period(
          startDate: _currentPeriod!.startDate,
          cycleLength: _currentPeriod!.cycleLength,
          periodLength: newPeriodLength,
        );

        _currentPeriod = updatedPeriod;

        // Update in history
        final index = _periodHistory.indexWhere(
          (p) => p.startDate == updatedPeriod.startDate,
        );

        if (index != -1) {
          _periodHistory[index] = updatedPeriod;
        }

        // Save to both local storage and Firebase
        await saveData();

        if (_periodService.isLoggedIn) {
          await _periodService.updatePeriod(updatedPeriod);
          await _periodService.saveUserSettings(
            cycleLength: updatedPeriod.cycleLength,
            periodLength: newPeriodLength,
          );
        }
      } catch (e) {
        print('Error updating period length: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Save data to SharedPreferences
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save current period
    if (_currentPeriod != null) {
      await prefs.setString(
        'currentPeriod',
        jsonEncode(_currentPeriod!.toJson()),
      );
    }

    // Save period history
    final historyJson = _periodHistory.map((p) => p.toJson()).toList();
    await prefs.setString('periodHistory', jsonEncode(historyJson));
  }

  // Load data from SharedPreferences
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load current period
    final currentPeriodJson = prefs.getString('currentPeriod');
    if (currentPeriodJson != null) {
      _currentPeriod = Period.fromJson(jsonDecode(currentPeriodJson));
    }

    // Load period history
    final historyJson = prefs.getString('periodHistory');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      _periodHistory = decoded.map((item) => Period.fromJson(item)).toList();
    }
  }

  // Sync with Firebase data
  Future<void> _syncWithFirebase() async {
    try {
      // Get user settings
      final settings = await _periodService.getUserSettings();
      if (settings != null) {
        // Apply settings to current period if available
        if (_currentPeriod != null &&
            settings.containsKey('cycleLength') &&
            settings.containsKey('periodLength')) {
          final updatedPeriod = Period(
            startDate: _currentPeriod!.startDate,
            cycleLength: settings['cycleLength'],
            periodLength: settings['periodLength'],
          );
          _currentPeriod = updatedPeriod;
        }
      }

      // Get periods from Firebase
      final cloudPeriods = await _periodService.getAllPeriods();

      if (cloudPeriods.isNotEmpty) {
        // Merge with local data
        final Map<String, Period> periodMap = {};

        // Add local periods to map
        for (final period in _periodHistory) {
          periodMap[period.startDate.toIso8601String()] = period;
        }

        // Add or update with cloud periods
        for (final period in cloudPeriods) {
          periodMap[period.startDate.toIso8601String()] = period;
        }

        // Convert back to list and sort
        _periodHistory = periodMap.values.toList();
        _periodHistory.sort((a, b) => b.startDate.compareTo(a.startDate));

        // Update current period to most recent
        if (_periodHistory.isNotEmpty) {
          _currentPeriod = _periodHistory.first;
        }

        // Save merged data locally
        await saveData();
      } else if (_periodHistory.isNotEmpty) {
        // Upload local data to Firebase
        for (final period in _periodHistory) {
          await _periodService.savePeriod(period);
        }

        // Save settings
        if (_currentPeriod != null) {
          await _periodService.saveUserSettings(
            cycleLength: _currentPeriod!.cycleLength,
            periodLength: _currentPeriod!.periodLength,
          );
        }
      }

      // Start listening for real-time updates
      _startRealtimeUpdates();
    } catch (e) {
      print('Error syncing with Firebase: $e');
    }
  }

  // Listen for real-time updates
  void _startRealtimeUpdates() {
    if (!_periodService.isLoggedIn) return;

    _periodService.periodStream().listen((periods) {
      if (periods.isNotEmpty) {
        _periodHistory = periods;
        // Sort by date (newest first)
        _periodHistory.sort((a, b) => b.startDate.compareTo(a.startDate));
        _currentPeriod = _periodHistory.first;
        notifyListeners();
      }
    });
  }

  // Check if a date is a period day
  bool isPeriodDay(DateTime date) {
    for (final period in _periodHistory) {
      if (date.isAfter(period.startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(period.endDate.add(const Duration(days: 1)))) {
        return true;
      }
    }
    return false;
  }

  // Check if a date is an ovulation day
  bool isOvulationDay(DateTime date) {
    if (_currentPeriod == null) return false;

    final ovulationDate = _currentPeriod!.ovulationDate;
    return date.year == ovulationDate.year &&
        date.month == ovulationDate.month &&
        date.day == ovulationDate.day;
  }

  // Check if a date is in fertile window
  bool isFertileDay(DateTime date) {
    if (_currentPeriod == null) return false;

    for (final fertileDay in _currentPeriod!.fertileWindow) {
      if (date.year == fertileDay.year &&
          date.month == fertileDay.month &&
          date.day == fertileDay.day) {
        return true;
      }
    }
    return false;
  }
}
