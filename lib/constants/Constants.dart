import 'package:event_bus/event_bus.dart';


class Constants {

  static final String REDIRECT_URL = "http://1.yubo725.sinaapp.com/osc/osc.php";

  static final String LOGIN_URL = "https://www.oschina.net/action/oauth2/authorize?client_id=4rWcDXCNTV5gMWxtagxI&response_type=code&redirect_uri=" + REDIRECT_URL;

  static final String OSC_CLIENT_ID = "4rWcDXCNTV5gMWxtagxI";

  // for test
//  static final String OSC_ACCESS_TOKEN = "d6b9179f-ced7-4f68-92dd-58c5b3b3bc0a";

  static final String END_LINE_TAG = "COMPLETE";

  static EventBus eventBus = new EventBus();
  
}