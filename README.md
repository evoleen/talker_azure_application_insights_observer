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

The observer will auto-configure itself if deployed on Azure and a connection to Application Insights is setup. Auto-configuration happens by reading the environment variable `APPLICATIONINSIGHTS_CONNECTION_STRING`.

Alternatively either a connection or an existing instance of `TelemetryClient` can be supplied.

If no parameters are supplied and the environment variable doesn't exist, the observer will not submit any logs (but also not produce any errors).
