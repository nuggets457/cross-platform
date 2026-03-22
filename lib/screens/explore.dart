import 'package:flutter/material.dart';

import '../app.dart';
import '../services/nasa_api.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/card_widget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // Holds InSight weather API response
  late Future<Map<String, dynamic>> _weather;

  @override
  void initState() {
    super.initState();
    // Load InSight weather data
    _weather = NasaService.fetchInSightWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenFrame(
        child: Column(
          children: [
            ScreenHeader(
              title: 'InSight',
              subtitle: 'Mars weather + NASA mission data integration',
              onBack: () => Navigator.pop(context),
            ),
            const SizedBox(height: 18),

            /// ================= NASA API INFO =================
            const StatCard(
              label: 'NASA API Endpoint',
              value:
                  'https://api.nasa.gov/insight_weather/?api_key=DEMO_KEY&feedtype=json&ver=1.0',
            ),
            const SizedBox(height: 10),
            const StatCard(
              label: 'Description',
              value:
                  'Provides Mars weather data collected by the InSight lander including temperature, wind, and pressure.',
            ),

            const SizedBox(height: 10),

            /// ================= WEATHER DATA =================
            FutureBuilder<Map<String, dynamic>>(
              future: _weather,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData) {
                  return const StatCard(
                    label: 'Weather Data',
                    value: 'No data available',
                  );
                }

                final data = snapshot.data!;
                final sols = data['sol_keys'] as List<dynamic>?;

                if (sols == null || sols.isEmpty) {
                  return const StatCard(
                    label: 'Weather Data',
                    value: 'No sol data found',
                  );
                }

                final latestSol = sols.last;
                final solData = data[latestSol];

                final temp = solData['AT']?['av']?.toString() ?? 'N/A';
                final wind = solData['HWS']?['av']?.toString() ?? 'N/A';
                final pressure = solData['PRE']?['av']?.toString() ?? 'N/A';

                return Column(
                  children: [
                    StatCard(
                      label: 'Latest Sol',
                      value: latestSol.toString(),
                    ),
                    const SizedBox(height: 10),
                    StatCard(
                      label: 'Temperature (°C)',
                      value: temp,
                    ),
                    const SizedBox(height: 10),
                    StatCard(
                      label: 'Wind Speed (m/s)',
                      value: wind,
                    ),
                    const SizedBox(height: 10),
                    StatCard(
                      label: 'Pressure (Pa)',
                      value: pressure,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 14),

            Expanded(
              child: Column(
                children: [
                  /// Static explanation cards
                  const StatCard(
                    label: 'Form block',
                    value:
                        'Mission name, rover, sol, sensor type',
                  ),
                  const SizedBox(height: 10),
                  const StatCard(
                    label: 'Analysis block',
                    value:
                        'Pattern recognition and trend summaries',
                  ),
                  const SizedBox(height: 10),
                  const StatCard(
                    label: 'Output block',
                    value:
                        'Readable weather stories and charts',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const AppBottomNav(currentRoute: AppRoutes.home),
          ],
        ),
      ),
    );
  }
}
