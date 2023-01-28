import 'dart:convert';
import 'package:defi_wallet/bloc/staking/staking_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/crypto_route_model.dart';
import 'package:defi_wallet/models/fiat_history_model.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/models/kyc_model.dart';
import 'package:defi_wallet/models/lock_staking_model.dart';
import 'package:defi_wallet/models/lock_user_model.dart';
import 'package:defi_wallet/models/lock_withdraw_model.dart';
import 'package:defi_wallet/models/staking_model.dart';
import 'package:defi_wallet/services/dfx_service.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../services/lock_service.dart';

class LockRequests {
  LockService lockService = LockService();
  EncryptHelper encryptHelper = EncryptHelper();

  Future<String> signUp(AccountModel account, ECPair keyPair) async {
    try {
      dynamic data = lockService.getAddressAndSignature(account, keyPair);

      final Uri url = Uri.parse('https://api.lock.space/v1/auth/sign-up');

      final headers = {
        'Content-type': 'application/json',
      };

      final body = jsonEncode(data);

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)['accessToken'];
      } else {
        return '';
      }
    } catch (_) {
      return '';
    }
  }

  Future<String> signIn(AccountModel account, ECPair keyPair) async {
    try {
      dynamic data = lockService.getAddressAndSignature(account, keyPair);

      final Uri url = Uri.parse('https://api.lock.space/v1/auth/sign-in');

      final headers = {
        'Content-type': 'application/json',
      };

      final body = jsonEncode(data);

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)['accessToken'];
      } else {
        return await signUp(account, keyPair);
      }
    } catch (_) {
      return '';
    }
  }

  Future<LockUserModel?> getKYC(String accessToken) async {
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
      return null;
    }
  }

  Future<LockUserModel?> getUser(String accessToken) async {
    try {
      final Uri url = Uri.parse('https://api.lock.space/v1/user');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final response = await http.get(url, headers: headers);
      dynamic data = jsonDecode(response.body);
      return LockUserModel.fromJson(data);
    } catch (_) {
      print(_);
      return null;
    }
  }

  Future<LockStakingModel?> getStaking(String accessToken) async {
    try {
      final Uri url = Uri.parse('https://api.lock.space/v1/staking?asset=DFI&blockchain=DeFiChain&strategy=Masternode');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final response = await http.get(url, headers: headers);
      dynamic data = jsonDecode(response.body);
      return LockStakingModel.fromJson(data);
    } catch (_) {
      print(_);
      return null;
    }
  }

  Future<bool> setDeposit(String accessToken, int stakingId, double amount, String txId) async {
    try {
      final Uri url = Uri.parse(
          'https://api.lock.space/v1/staking/$stakingId/deposit');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final body = jsonEncode({
        'amount': amount,
        'txId': txId
      });

      final response = await http.post(url, headers: headers, body: body);
      dynamic data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (_) {
      print(_);
      return false;
    }
  }

  Future<LockWithdrawModel?> requestWithdraw(String accessToken, int stakingId, double amount) async {
    try {
      final Uri url = Uri.parse(
          'https://api.lock.space/v1/staking/$stakingId/withdrawal');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final body = jsonEncode({
        'amount': amount,
      });

      final response = await http.post(url, headers: headers, body: body);
      dynamic data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return LockWithdrawModel.fromJson(data);
      } else {
        return null;
      }
    } catch (_) {
      print(_);
      return null;
    }
  }

  Future<LockStakingModel?> signedWithdraw(String accessToken,int stakingId, LockWithdrawModel withdrawModel) async {
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

      final response = await http.post(url, headers: headers, body: body);
      dynamic data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return LockStakingModel.fromJson(data);
      } else {
        return null;
      }
    } catch (_) {
      print(_);
      return null;
    }
  }

}
