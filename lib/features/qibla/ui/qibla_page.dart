import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/qibla_viewmodel.dart';
import 'qibla_compass_painter.dart';

class QiblaPage extends StatelessWidget {
  const QiblaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aira Qibla Compass')),
      body: Consumer<QiblaViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => viewModel.retryPermissions(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (viewModel.heading == null || viewModel.qiblaBearing == null) {
            return const Center(child: Text('Waiting for sensor data...'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final compassSize = math
                  .min(constraints.maxWidth - 40, constraints.maxHeight * 0.46)
                  .clamp(220.0, 420.0)
                  .toDouble();

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          'Mecca, Saudi Arabia',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 10),
                        if (viewModel.distanceToQibla != null)
                          Text(
                            '${(viewModel.distanceToQibla! / 1000).toStringAsFixed(1)} km away',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(height: 32),
                        SizedBox.square(
                          dimension: compassSize,
                          child: CustomPaint(
                            painter: QiblaCompassPainter(
                              heading: viewModel.heading!,
                              qiblaBearing: viewModel.qiblaBearing!,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.spaceAround,
                            spacing: 24,
                            runSpacing: 16,
                            children: [
                              _buildInfoColumn(
                                'Latitude',
                                viewModel.userLatitude!.toStringAsFixed(4),
                              ),
                              _buildInfoColumn(
                                'Longitude',
                                viewModel.userLongitude!.toStringAsFixed(4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
