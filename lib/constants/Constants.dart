import 'package:event_bus/event_bus.dart';

class Constants {

  static final String redirectUrl = "http://osc.yubo.me/logincallback";

  static final String loginUrl = "https://www.oschina.net/action/oauth2/authorize?client_id=4rWcDXCNTV5gMWxtagxI&response_type=code&redirect_uri=" + redirectUrl;

  static final String oscClientID = "4rWcDXCNTV5gMWxtagxI";

  static final String endLineTag = "COMPLETE";

  static final EventBus eventBus = new EventBus();
}