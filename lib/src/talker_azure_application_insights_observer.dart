import 'dart:io';
import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:http/http.dart';
import 'package:talker/talker.dart';

/// Talker observer that logs data to Azure Application Insights
class TalkerAzureApplicationInsightsObserver extends TalkerObserver {
  TelemetryClient? _telemetryClient;

  TalkerAzureApplicationInsightsObserver({
    String? connectionString,
    TelemetryClient? telemetryClient,
    Client? httpClient,
  }) {
    connectionString ??=
        Platform.environment['APPLICATIONINSIGHTS_CONNECTION_STRING'];

    if (telemetryClient != null) {
      _telemetryClient = telemetryClient;
    } else if (connectionString != null) {
      final connectionStringElements = connectionString.split(';');

      final instrumentationKeyCandidates = connectionStringElements
          .where((e) => e.startsWith('InstrumentationKey='))
          .toList();

      // if we get an incorrect connection string, don't log anything
      if (instrumentationKeyCandidates.isEmpty) {
        return;
      }

      final instrumentationKey = instrumentationKeyCandidates.first
          .substring('InstrumentationKey='.length);

      _telemetryClient = TelemetryClient(
        processor: BufferedProcessor(
          next: TransmissionProcessor(
            instrumentationKey: instrumentationKey,
            httpClient: httpClient ?? Client(),
            timeout: const Duration(seconds: 10),
          ),
        ),
      );
    }
  }

  Severity _talkerLevelToSeverity(LogLevel logLevel) {
    switch (logLevel) {
      case LogLevel.critical:
        return Severity.critical;
      case LogLevel.error:
        return Severity.error;
      case LogLevel.warning:
        return Severity.warning;
      case LogLevel.info:
        return Severity.information;
      case LogLevel.verbose:
        return Severity.verbose;
      case LogLevel.debug:
        return Severity.verbose;
    }
  }

  @override
  void onError(TalkerError err) {
    _telemetryClient?.trackError(
      severity: _talkerLevelToSeverity(err.logLevel ?? LogLevel.error),
      error: err.generateTextMessage(),
    );
  }

  @override
  void onException(TalkerException err) {
    _telemetryClient?.trackError(
      severity: _talkerLevelToSeverity(err.logLevel ?? LogLevel.error),
      error: err.generateTextMessage(),
    );
  }

  @override
  void onLog(TalkerData log) {
    _telemetryClient?.trackTrace(
      severity: _talkerLevelToSeverity(log.logLevel ?? LogLevel.info),
      message: log.generateTextMessage(),
    );
  }
}
