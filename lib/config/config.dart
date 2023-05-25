class Hosts {
  static const String oceanDefichainHome = 'ocean.defichain.com';
  static const String oceanDefichain = 'https://$oceanDefichainHome/v0';
  static const String myDefichain = 'http://ocean.mydefichain.com:3000/v0';
  static const String ocean = 'https://testnet-ocean.mydefichain.com:8443/v0';

  static const String defiScanHome = 'defiscan.live';
  static const String defiScanLiveTx = 'https://$defiScanHome/transactions/';
  static const String blockcypherHome = 'live.blockcypher.com';
  static const String blockcypherApi = 'https://api.blockcypher.com/v1';
  static const String blockstreamApi = 'blockstream.info';
}

class DfxApi {
  static const String home = 'api.dfx.swiss';
  static const String url = 'https://$home';
  static const String historyUrl = 'https://api.dfi.tax/p01/hst/';
}

class LockApi {
  static const String home = 'api.lock.space';
  static const String url = 'https://$home';
}

class JellyLinks {
  static const String termsAndConditions =
      'https://jellywallet.io/terms-and-conditions/';
  static const String telegramGroup = 'https://t.me/jellywallet_eng';
}

class ScreenSizes {
  static const double xSmall = 328;
  static const double small = 458;
  static const double medium = 890;
}

class TickerTimes {
  static const int tickerBeforeLockMilliseconds = 60000 * 5;
  static const int durationAccessToken = 162000000; // 45h
}

class ToolbarSizes {
  static const double toolbarHeight = 55;
  static const double toolbarHeightWithBottom = 105;
}

class StorageConstants {
  static const int storageVersion = 2;
}
