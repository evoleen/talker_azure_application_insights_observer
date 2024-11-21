import 'dart:io';
import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:http/http.dart';
import 'package:talker/talker.dart';

/// Talker observer that logs data to Azure Application Insights
class TalkerAzureApplicationInsightsObserver extends TalkerObserver {
  TelemetryClient? _telemetryClient;
  final String? sessionsId;

  /// when [sessionId] is set all the log records will be tagged with [sessionId]
  /// value, which can be used in the azure application insights to query all logs
  /// relevant to a session. NOTE that each session should have a unique [sessionId]
  TalkerAzureApplicationInsightsObserver({
    String? connectionString,
    TelemetryClient? telemetryClient,
    Client? httpClient,
    this.sessionsId,
  }) {
    connectionString ??=
        Platform.environment['APPLICATIONINSIGHTS_CONNECTION_STRING'];

    if (telemetryClient != null) {
      _telemetryClient = telemetryClient;
    } else if (connectionString != null) {
      _telemetryClient = TelemetryClient(
        processor: BufferedProcessor(
          next: TransmissionProcessor(
            connectionString: connectionString,
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
      stackTrace: err.stackTrace,
      additionalProperties: {
        if (Platform.environment['WEBSITE_SITE_NAME'] != null)
          'appName': Platform.environment['WEBSITE_SITE_NAME']!,
        if (Platform.environment['WEBSITE_OWNER_NAME'] != null)
          'appId': Platform.environment['WEBSITE_OWNER_NAME']!,
        if (sessionsId != null) 'sessionId': sessionsId!,
      },
    );
  }

  @override
  void onException(TalkerException err) {
    _telemetryClient?.trackError(
      severity: _talkerLevelToSeverity(err.logLevel ?? LogLevel.error),
      error: err.generateTextMessage(),
      stackTrace: err.stackTrace,
      additionalProperties: {
        if (Platform.environment['WEBSITE_SITE_NAME'] != null)
          'appName': Platform.environment['WEBSITE_SITE_NAME']!,
        if (Platform.environment['WEBSITE_OWNER_NAME'] != null)
          'appId': Platform.environment['WEBSITE_OWNER_NAME']!,
        if (sessionsId != null) 'sessionId': sessionsId!,
      },
    );
  }

  @override
  void onLog(TalkerData log) {
    _telemetryClient?.trackTrace(
      severity: _talkerLevelToSeverity(log.logLevel ?? LogLevel.info),
      message: log.generateTextMessage(),
      additionalProperties: {
        if (Platform.environment['WEBSITE_SITE_NAME'] != null)
          'appName': Platform.environment['WEBSITE_SITE_NAME']!,
        if (Platform.environment['WEBSITE_OWNER_NAME'] != null)
          'appId': Platform.environment['WEBSITE_OWNER_NAME']!,
        if (sessionsId != null) 'sessionId': sessionsId!,
      },
    );
  }
}
