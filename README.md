Forwards all log events from Talker to Azure Application Insights.

## Usage

```dart
import 'package:talker/talker.dart';
import 'package:talker_azure_application_insights_observer/talker_azure_application_insights_observer.dart';

void main() {
  final azureInsightsObserver = TalkerAzureApplicationInsightsObserver(
      connectionString: '<APPLICATION_INSIGHTS_CONNECTION_STRING>');

  final talker = Talker(observer: azureInsightsObserver);

  talker.info('Info message sent via Talker to Azure Application Insights');
}
```

## Additional information

Use either a connection string or supply an existing instance of `TelemetryClient`. If neither are supplied, no logs are sent to Application Insights.
