const assets = {
  "eth": "ethereum",
  "dash": "dash",
  "usdt": "tether",
  "usdc": "usd-coin",
  "uni": "uniswap",
  "toncoin": "the-open-network",
  "okb": "okb",
  "link": "chainlink",
  "matic": "matic-network",
  "dai": "bridged-dai-stablecoin-linea",
  "wbtc": "bridged-wrapped-bitcoin-stargate",
  "steth": "staked-ether",
  "shib": "niccagewaluigielmo42069inu",
  "aave": "aave",
};

const currencies = {
  "btc": "btc",
  "usdt": "usd",
  "euroc": "eur",
};

class EthereumRateModel {
  Map<dynamic, dynamic> rates;

  EthereumRateModel({
    required this.rates,
  });


  double assetPrice(String targetAsset, String convertedAsset) {
    String? key = assets[targetAsset.toLowerCase()];
    String? convertedKey = currencies[convertedAsset.toLowerCase()];
    return this.rates[key][convertedKey];
  }
}

