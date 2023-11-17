class Hosts {
  static const String mainnetHost = 'ocean.mydefichain.com';
  static const String testnetHost = 'testnet-ocean.mydefichain.com:8443';
  static const String myDefichainMainnet = 'https://$mainnetHost/v0';
  static const String myDefichainTestnet = 'https://$testnetHost/v0';

  static const String fallbackMainnetHost = 'ocean.defichain.com';
  static const String fallbackTestnetHost = 'testnet.ocean.jellyfishsdk.com';
  static const String fallbackMainnetUrl = 'https://$fallbackMainnetHost/v0';
  static const String fallbackTestnetUrl = 'https://$fallbackTestnetHost/v0';

  static const String defiScanHome = 'defiscan.live';
  static const String defiScanLiveTx = 'https://$defiScanHome/transactions/';
  static const String blockcypherHome = 'live.blockcypher.com';
  static const String blockcypherApi = 'https://api.blockcypher.com/v1';
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
  static const String termsAndConditions = 'https://jellywallet.io/terms-and-conditions/';
  static const String telegramGroup = 'https://t.me/jellywallet_eng';
}

class ScreenSizes {
  static const double xSmall = 328;
  static const double small = 458;
  static const double medium = 890;
  static const double large = 1440;
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