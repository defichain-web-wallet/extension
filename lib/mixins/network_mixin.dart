import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/settings_model.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin NetworkMixin {
  String currentNetworkName() {
    SettingsModel settings = SettingsHelper.settings;
    String network = settings.network!;
    if (network == 'mainnet') {
      return (settings.isBitcoin!) ? 'Bitcoin Mainnet' : 'DefiChain Mainnet';
    } else {
      return (settings.isBitcoin!) ? 'Bitcoin Testnet' : 'DefiChain Testnet';
    }
  }

  NetworkTypeModel? addressNetwork(context, String address) {
    final addressCubit = BlocProvider.of<AddressBookCubit>(context);
    final networkType = addressCubit.getNetworkType(context, address);
    return networkType;
  }
}
