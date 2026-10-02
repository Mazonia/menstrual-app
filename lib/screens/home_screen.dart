import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/period_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/period_calendar.dart';
import '../utils/notification_service.dart';
import '../screens/account_settings_screen.dart';
import 'dart:async';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?.displayName ?? 'User';
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Period Tracker'),
            Text(
              'Welcome, $userName',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip:
                themeProvider.isDarkMode
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog(context);
            },
          ),
          // Sign out button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _confirmSignOut(context);
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      // Add drawer
      drawer: _buildUserDrawer(context),
      body: Consumer<PeriodProvider>(
        builder: (context, periodProvider, child) {
          return periodProvider.currentPeriod == null
              ? _buildFirstTimeView(context)
              : _buildDashboard(context, periodProvider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddPeriodDialog(context);
        },
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign Out'),
            backgroundColor: isDarkMode ? Colors.grey.shade800 : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: isSmallScreen ? 16 : 24,
            ),
            content: SizedBox(
              width: isSmallScreen ? null : 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: isSmallScreen ? 48 : 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Are you sure you want to sign out?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Get auth provider
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );

                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (context) =>
                              const Center(child: CircularProgressIndicator()),
                    );

                    // Sign out directly
                    await authProvider.signOut();

                    // Close dialogs
                    Navigator.of(context).pop(); // Close loading dialog
                    Navigator.of(context).pop(); // Close confirmation dialog

                    // Navigation to login screen happens automatically via AuthWrapper
                  } catch (e) {
                    // Close loading indicator if it's showing
                    Navigator.of(context).pop();

                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error signing out: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );

                    // Close confirmation dialog
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Sign Out'),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
    );
  }

  Widget _buildFirstTimeView(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?.displayName ?? 'User';
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;
    final padding = mediaQuery.padding;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 24 : 48,
        vertical: 16,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.pink.shade900.withOpacity(0.2)
                      : Colors.pink.shade50,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      isDarkMode
                          ? Colors.pink.shade800.withOpacity(0.3)
                          : Colors.pink.shade200.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Icon(
              Icons.calendar_today,
              size: isSmallScreen ? 60 : 80,
              color: isDarkMode ? Colors.pink.shade200 : Colors.pink,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            'Welcome to Period Tracker,',
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.pink.shade200 : null,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            userName,
            style: TextStyle(
              fontSize: isSmallScreen ? 22 : 28,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.pink.shade300 : Colors.pink,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 8 : 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.grey.shade800.withOpacity(0.5)
                      : Colors.pink.shade50.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode ? Colors.pink.shade800 : Colors.pink.shade100,
                width: 1,
              ),
            ),
            child: Text(
              'Track your period, ovulation, and fertile days with a personalized calendar',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: isDarkMode ? Colors.grey.shade300 : Colors.pink.shade800,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: isSmallScreen ? 24 : 32),
          ElevatedButton(
            onPressed: () {
              _showAddPeriodDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.pink.shade700 : Colors.pink,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 24 : 32,
                vertical: isSmallScreen ? 12 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_circle_outline),
                const SizedBox(width: 8),
                Text(
                  'Start Tracking',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, PeriodProvider provider) {
    final currentPeriod = provider.currentPeriod!;
    final nextPeriodDate = currentPeriod.nextPeriodStart;
    final ovulationDate = currentPeriod.ovulationDate;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Your Next Period',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  PeriodDateUtils.formatDate(nextPeriodDate),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  PeriodDateUtils.getDaysUntilNext(nextPeriodDate),
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Ovulation Day',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  PeriodDateUtils.formatDate(ovulationDate),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  PeriodDateUtils.getDaysUntilNext(ovulationDate),
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cycle Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Cycle Length: ${currentPeriod.cycleLength} days',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  'Period Length: ${currentPeriod.periodLength} days',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  'Last Period: ${PeriodDateUtils.formatDate(currentPeriod.startDate)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Calendar',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const PeriodCalendar(),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CalendarLegendItem(color: Colors.red, label: 'Period'),
            _CalendarLegendItem(color: Colors.green, label: 'Ovulation'),
            _CalendarLegendItem(
              color: Colors.lightGreen,
              label: 'Fertile Window',
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showAddPeriodDialog(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    int cycleLength = 28;
    int periodLength = 5;
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Add Period',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: isDarkMode ? Colors.grey.shade800 : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: isSmallScreen ? 16 : 24,
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? double.infinity : 450,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'When did your last period start?',
                    style: TextStyle(fontSize: isSmallScreen ? 15 : 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(PeriodDateUtils.formatDate(selectedDate)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data:
                                isDarkMode
                                    ? ThemeData.dark().copyWith(
                                      colorScheme: ColorScheme.dark(
                                        primary: Colors.pink.shade300,
                                        onPrimary: Colors.white,
                                        surface: Colors.grey.shade800,
                                        onSurface: Colors.white,
                                      ),
                                    )
                                    : ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Colors.pink,
                                      ),
                                    ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        selectedDate = pickedDate;
                        (context as Element).markNeedsBuild();
                      }
                    },
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.grey.shade900.withOpacity(0.3)
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.loop, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Cycle Length (days)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          min: 21,
                          max: 35,
                          divisions: 14,
                          label: cycleLength.toString(),
                          value: cycleLength.toDouble(),
                          onChanged: (value) {
                            cycleLength = value.toInt();
                            (context as Element).markNeedsBuild();
                          },
                        ),
                        Text(
                          '$cycleLength days',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkMode ? Colors.pink.shade200 : Colors.pink,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 10),
                        Row(
                          children: [
                            const Icon(Icons.calendar_view_day, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Period Length (days)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          min: 2,
                          max: 10,
                          divisions: 8,
                          label: periodLength.toString(),
                          value: periodLength.toDouble(),
                          onChanged: (value) {
                            periodLength = value.toInt();
                            (context as Element).markNeedsBuild();
                          },
                        ),
                        Text(
                          '$periodLength days',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkMode ? Colors.pink.shade200 : Colors.pink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDarkMode ? Colors.pink.shade700 : Colors.pink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final provider = Provider.of<PeriodProvider>(
                  context,
                  listen: false,
                );
                await provider.addPeriod(
                  startDate: selectedDate,
                  cycleLength: cycleLength,
                  periodLength: periodLength,
                );

                // Schedule notifications
                final notificationService = NotificationService();
                await notificationService.schedulePeriodReminder(
                  provider.currentPeriod!.nextPeriodStart,
                );
                await notificationService.scheduleOvulationReminder(
                  provider.currentPeriod!.ovulationDate,
                );

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        );
      },
    );
  }

  Future<void> _showSettingsDialog(BuildContext context) async {
    final provider = Provider.of<PeriodProvider>(context, listen: false);
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;

    if (provider.currentPeriod == null) {
      // No period data yet, show message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add your period data first'),
          backgroundColor: isDarkMode ? Colors.grey.shade800 : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
      return;
    }

    int cycleLength = provider.currentPeriod!.cycleLength;
    int periodLength = provider.currentPeriod!.periodLength;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Settings',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: isDarkMode ? Colors.grey.shade800 : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: isSmallScreen ? 16 : 24,
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? double.infinity : 450,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.pink.shade900.withOpacity(0.2)
                              : Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isDarkMode
                                ? Colors.pink.shade800
                                : Colors.pink.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Adjust your cycle settings',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 15 : 16,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        Row(
                          children: [
                            const Icon(Icons.loop, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Cycle Length (days)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          min: 21,
                          max: 35,
                          divisions: 14,
                          label: cycleLength.toString(),
                          value: cycleLength.toDouble(),
                          activeColor:
                              isDarkMode ? Colors.pink.shade300 : Colors.pink,
                          onChanged: (value) {
                            cycleLength = value.toInt();
                            (context as Element).markNeedsBuild();
                          },
                        ),
                        Text(
                          '$cycleLength days',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkMode ? Colors.pink.shade200 : Colors.pink,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 10),
                        Row(
                          children: [
                            const Icon(Icons.calendar_view_day, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Period Length (days)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          min: 2,
                          max: 10,
                          divisions: 8,
                          label: periodLength.toString(),
                          value: periodLength.toDouble(),
                          activeColor:
                              isDarkMode ? Colors.pink.shade300 : Colors.pink,
                          onChanged: (value) {
                            periodLength = value.toInt();
                            (context as Element).markNeedsBuild();
                          },
                        ),
                        Text(
                          '$periodLength days',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkMode ? Colors.pink.shade200 : Colors.pink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.notifications),
                    label: const Text('Reset Notifications'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode ? Colors.blue.shade700 : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final notificationService = NotificationService();
                      await notificationService.cancelAllNotifications();
                      await notificationService.schedulePeriodReminder(
                        provider.currentPeriod!.nextPeriodStart,
                      );
                      await notificationService.scheduleOvulationReminder(
                        provider.currentPeriod!.ovulationDate,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Notifications reset'),
                          backgroundColor:
                              isDarkMode ? Colors.green.shade800 : Colors.green,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDarkMode ? Colors.pink.shade700 : Colors.pink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (cycleLength != provider.currentPeriod!.cycleLength) {
                  await provider.updateCycleLength(cycleLength);
                }

                if (periodLength != provider.currentPeriod!.periodLength) {
                  await provider.updatePeriodLength(periodLength);
                }

                // Update notifications
                final notificationService = NotificationService();
                await notificationService.cancelAllNotifications();
                await notificationService.schedulePeriodReminder(
                  provider.currentPeriod!.nextPeriodStart,
                );
                await notificationService.scheduleOvulationReminder(
                  provider.currentPeriod!.ovulationDate,
                );

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        );
      },
    );
  }

  // Build user drawer
  Widget _buildUserDrawer(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;

    final user = authProvider.user;
    final userName = user?.displayName ?? 'User';
    final userEmail = user?.email ?? 'No email available';

    return Drawer(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : null,
      width:
          isSmallScreen
              ? mediaQuery.size.width * 0.75
              : 350, // Responsive width
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: isSmallScreen ? 180 : 220,
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 16 : 24,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.pink.shade800 : Colors.pink.shade200,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: isSmallScreen ? 35 : 45,
                    backgroundColor:
                        isDarkMode ? Colors.pink.shade200 : Colors.pink.shade50,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 28 : 36,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkMode
                                ? Colors.pink.shade900
                                : Colors.pink.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 18 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Account Settings'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to account settings screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        themeProvider.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      title: Text(
                        themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      onTap: () {
                        themeProvider.toggleTheme();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.red),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _confirmSignOut(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            // App info section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Period Tracker v1.0',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _CalendarLegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
