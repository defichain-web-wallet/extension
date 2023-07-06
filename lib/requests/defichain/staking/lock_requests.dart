import 'dart:convert';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/lock_analytics_model.dart';
import 'package:defi_wallet/models/lock_staking_model.dart';
import 'package:defi_wallet/models/lock_user_model.dart';
import 'package:defi_wallet/models/lock_withdraw_model.dart';
import 'package:defi_wallet/models/network/staking/staking_model.dart';
import 'package:defi_wallet/models/network/staking/withdraw_model.dart';
import 'package:defi_wallet/services/lock_service.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:http/http.dart' as http;


class LockRequests {
  static Future<String?> signUp(Map<String, String> data) async {
    try {
      final Uri url = Uri.parse('https://api.lock.space/v1/auth/sign-up');

      final headers = {
        'Content-type': 'application/json',
      };

      final body = jsonEncode(data);

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)['accessToken'];
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  static Future<LockUserModel> getKYC(String accessToken) async {
    try {
      final Uri url = Uri.parse('https://api.lock.space/v1/kyc');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final response = await http.post(url, headers: headers);
      dynamic data = jsonDecode(response.body);
      return LockUserModel.fromJson(data);
    } catch (_) {
      print(_);
      throw 'Request error'; //TODO: add error model
    }
  }

  static Future<StakingModel> getStaking(String accessToken, String blockchain, String strategy) async {
    try {
      final Uri url = Uri.parse(
          'https://api.lock.space/v1/staking?blockchain=$blockchain&strategy=$strategy');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final response = await http.get(url, headers: headers);
      dynamic data = jsonDecode(response.body);
      return StakingModel.fromJson(data);
    } catch (error) {
      throw error; // TODO: need to add error model for all cases
    }
  }

  Future<void> updateRewards(
      String accessToken,
      dynamic rewardRoutes,
      int stakingId,
      ) async {
    try {
      final Uri url = Uri.parse(
          'https://api.lock.space/v1/staking/$stakingId/reward-routes');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final body = jsonEncode(rewardRoutes);

      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Error.safeToString(response.body);
      }
    } catch (err) {
      throw err;
    }
  }

  static Future<String?> signIn(Map<String, String> data) async {
    try {

      final Uri url = Uri.parse('https://api.lock.space/v1/auth/sign-in');

      final headers = {
        'Content-type': 'application/json',
      };

      final body = jsonEncode(data);

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)['accessToken'];
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  static Future<LockAnalyticsModel?> getAnalytics(String accessToken, String asset, String blockchain, String strategy) async {
    try {
      final Uri url = Uri.parse('https://api.lock.space/v1/analytics/staking?asset=DFI&blockchain=DeFiChain&strategy=Masternode');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final response = await http.get(url, headers: headers);
      dynamic data = jsonDecode(response.body);
      return LockAnalyticsModel.fromJson(data);
    } catch (_) {
      print(_);
      return null;
    }
  }

  static Future<bool> setDeposit(
      String accessToken,
      int stakingId,
      double amount,
      String asset,
      String txId,
      ) async {
    try {
      final Uri url =
      Uri.parse('https://api.lock.space/v1/staking/$stakingId/deposit');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final body = jsonEncode({'amount': amount, 'txId': txId, 'asset': asset});

      final response = await http.post(url, headers: headers, body: body);
      dynamic data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (err) {
      print(err);
      throw err;
    }
  }

  static Future<WithdrawModel> requestWithdraw(
      String accessToken,
      int stakingId,
      double amount,
      String asset
      ) async {
    try {
      final Uri url =
      Uri.parse('https://api.lock.space/v1/staking/$stakingId/withdrawal');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final body = jsonEncode({
        'amount': amount,
        'asset': asset,
      });

      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic data = jsonDecode(response.body);
        return WithdrawModel.fromJson(data);
      } else {
        throw 'Request error';
      }
    } catch (err) {
      print(err);
      throw err;
    }
  }

  static Future<StakingModel> signedWithdraw(
      String accessToken,
      int stakingId,
      WithdrawModel withdrawModel,
      ) async {
    try {
      final Uri url = Uri.parse(
          'https://api.lock.space/v1/staking/$stakingId/withdrawal/${withdrawModel.id}/sign');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final body = jsonEncode({
        'signature': withdrawModel.signature,
      });

      final response = await http.patch(url, headers: headers, body: body);
      dynamic data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return StakingModel.fromJson(data);
      } else {
       throw 'Request error';
      }
    } catch (err) {
      print(err);
      throw err;
    }
  }

  static Future<List<WithdrawModel>?> getWithdraws(
      String accessToken,
      int stakingId
      ) async {
    try {
      final Uri url =
      Uri.parse('https://api.lock.space/v1/staking/$stakingId/withdrawal/drafts');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> data = jsonDecode(response.body);
        List<WithdrawModel> list = List.generate(
            data.length, (index) => WithdrawModel.fromJson(data[index]));
        return list;
      } else {
        return [];
      }
    } catch (err) {
      print(err);
      throw err;
    }
  }

  static Future<WithdrawModel?> changeAmountWithdraw(
      String accessToken,
      int stakingId, int withdrawId, double amount
      ) async {
    try {
      final Uri url =
      Uri.parse('https://api.lock.space/v1/staking/$stakingId/withdrawal/$withdrawId/amount');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final body = jsonEncode({
        'amount': amount,
      });

      final response = await http.patch(url, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic data = jsonDecode(response.body);
        return WithdrawModel.fromJson(data);
      } else {
        return null;
      }
    } catch (err) {
      print(err);
      throw err;
    }
  }

  static Future<WithdrawModel?> signWithdraw(
      String accessToken,
      int stakingId,
      LockWithdrawModel withdrawModel,
      ) async {
    try {
      final Uri url = Uri.parse(
          'https://api.lock.space/v1/staking/$stakingId/withdrawal/${withdrawModel.id}/sign');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final body = jsonEncode({
        'signature': withdrawModel.signature,
      });

      final response = await http.patch(url, headers: headers, body: body);
      dynamic data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return WithdrawModel.fromJson(data);
      } else {
        return null;
      }
    } catch (err) {
      print(err);
      throw err;
    }
  }


}
