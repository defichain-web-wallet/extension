import 'dart:convert';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:http/http.dart' as http;

class AssetsRequests {
  static Future<List<dynamic>> _getTokensResponse(
    AbstractNetworkModel network,
    String path, {
    String? next,
  }) async {
    final query = {
      'size': '200',
    };

    if (next != null) {
      query['next'] = next;
    }

    final Uri url = Uri.https(
      Hosts.oceanDefichainHome,
      '/v0/${network.networkType.networkStringLowerCase}/$path',
      query,
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final tokens = List.from(json['data']);
        if (json['page'] != null) {
          final nextTokens = await _getTokensResponse(
            network,
            path,
            next: json['page']['next'],
          );
          tokens.addAll(nextTokens);
        }

        return tokens;
      } else {
        return [];
      }
    } catch (err) {
      throw err;
    }
  }

  static Future<List<TokenModel>> getTokens(
    AbstractNetworkModel network, {
    String json = '',
  }) async {
    try {
      final data;
      if (json == '') {
        data = await _getTokensResponse(network, 'tokens');
      } else {
        data = jsonDecode(json);
      }
      List<TokenModel> tokens = List.generate(
        data.length,
        (index) => TokenModel.fromJSON(
          data[index],
          networkName: network.networkType.networkName,
        ),
      );
      return tokens;
    } catch (err) {
      return [];
    }
  }

  static Future<List<AssetPairModel>?> getPoolPairs(
    AbstractNetworkModel network, {
    String json = '',
  }) async {
    try {
      final data;
      if (json == '') {
        data = await _getTokensResponse(network, 'poolpairs');
      } else {
        data = jsonDecode(json);
      }

      List<AssetPairModel> poolPairs = List.generate(
        data.length,
        (index) => AssetPairModel.fromJson(data[index]),
      );

      return poolPairs;
    } catch (_) {
      return null;
    }
  }
}
