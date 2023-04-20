import "core-js/actual";
import { listen } from "@ledgerhq/logs";
import AppDfi from "hw-app-dfi";

import Transport from "@ledgerhq/hw-transport"
import TransportWebUSB from "@ledgerhq/hw-transport-webusb";
import SpeculosTransport from "hw-transport-node-speculos-http";

import { Transaction } from "hw-app-dfi/lib/types";
import { LedgerTransactionRaw } from "./ledger_tx";

export class JellyWalletLedger {

  async getTransport(): Promise<Transport> {
    // return await SpeculosTransport.open({ baseURL: "172.30.77.173:5000" });
    return await TransportWebUSB.create();
  }

  async appLedgerDefichain(): Promise<AppDfi> {
    const transport = await this.getTransport();
    transport.exchangeTimeout = 1000;
    transport.unresponsiveTimeout = 1000;
    listen((log) => console.log(log));


    const dfi = new AppDfi(transport);
    return dfi;
  }

  //"DeFiChain Test" = testnet
  //"DeFiChain" = mainnet
  public async openLedgerDefichain(appName: string): Promise<number> {
    try {
      await this.getTransport();

      listen((log) => console.log(log));

      return 0;
    }
    catch (err) {
      console.log(err);
      throw err;
    }
  }



  public async signMessageLedger(path: string, message: string) {
    try {

      const appDfi = await this.appLedgerDefichain();
      var result = await appDfi.signMessageNew(path, Buffer.from(message).toString("hex"));
      var v = result['v'] + 27 + 4;
      var signature = Buffer.from(v.toString(16) + result['r'] + result['s'], 'hex').toString('base64');
      return signature;
    }
    catch (e) {
      console.log(e);
      return null;
    }
  }

  public async getAddress(path: string, verify: boolean): Promise<string> {
    try {

      const appDfi = await this.appLedgerDefichain();
      const timeoutError = new Error('TIME_OUT')
      const addressPromise = appDfi.getWalletPublicKey(path, {
        verify: verify,
        format: "bech32",
      });
      const timeoutPromise = new Promise<never>((_, reject) => {
        setTimeout(() => {
          reject(timeoutError);
        }, 2000);
      });

      const address = await Promise.race([addressPromise, timeoutPromise]);

      console.log(address);
      return JSON.stringify(address);
    } catch (e) {
      throw e;
    }
  };

  public async signTransactionRaw(transactionsJson: string, paths: string[], newTx: string, networkStr: string, changePath: string): Promise<string> {
    const transaction: LedgerTransactionRaw[] = JSON.parse(transactionsJson);

    const ledger = await this.appLedgerDefichain();
    const splitNewTx = await ledger.splitTransaction(newTx, true);
    const outputScriptHex = await ledger.serializeTransactionOutputs(splitNewTx).toString("hex");

    var inputs: Array<
      [Transaction, number, string | null | undefined, number | null | undefined]
    > = [];

    for (var tx of transaction) {
      var ledgerTransaction = await ledger.splitTransaction(tx.rawTx, true);

      inputs.push([ledgerTransaction, tx.index, tx.redeemScript, void 0]);
    }

    const txOut = await ledger.createPaymentTransactionNew({
      inputs: inputs,
      associatedKeysets: paths,
      outputScriptHex: outputScriptHex,
      segwit: true,
      additionals: ["bech32"],
      transactionVersion: 2,
      lockTime: 0,
      useTrustedInputForSegwit: true
    });

    return txOut;
  }
}


