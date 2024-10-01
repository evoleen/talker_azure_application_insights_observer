import 'package:talker/talker.dart';
import 'package:talker_azure_application_insights_observer/talker_azure_application_insights_observer.dart';

void main() {
  final azureInsightsObserver = TalkerAzureApplicationInsightsObserver(
      connectionString: '<APPLICATION_INSIGHTS_CONNECTION_STRING>');

  final talker = Talker(observer: azureInsightsObserver);

  talker.info('Info message sent via Talker to Azure Application Insights');
}
