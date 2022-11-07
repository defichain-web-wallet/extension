import "core-js/actual";
import { listen } from "@ledgerhq/logs";
import AppDfi from "hw-app-dfi";

import TransportWebUSB from "@ledgerhq/hw-transport-webusb";
import SpeculosTransport from "hw-transport-node-speculos-http";

import {
  bitcoin,
  testnet,
  defichain,
  defichain_testnet,
} from "defichainjs-lib/src/networks";

import { SignP2SHTransactionArg } from "hw-app-dfi/lib/signP2SHTransaction";

import { serializeTransaction } from "hw-app-dfi/lib/serializeTransaction";
import { Transaction, TransactionInput, TransactionOutput } from "hw-app-dfi/lib/types";
import { LedgerTransaction, LedgerTransactionRaw } from "./ledger_tx";
import * as defichainlib from "defichainjs-lib";
import { buffer } from "stream/consumers";
import { crypto } from "bitcoinjs-lib";

export class JellyWalletLedger {

  async appLedgerDefichain(): Promise<AppDfi> {
    const transport = await SpeculosTransport.open({ baseURL: "192.168.119.128:5000" });
    //const transport = await TransportWebUSB.create();

    listen((log) => console.log(log));

    const btc = new AppDfi(transport);
    return btc;
  }

  public async signMessage(path: string, message: string) {
    try {

      const appBtc = await this.appLedgerDefichain();
      var result = await appBtc.signMessageNew(path, Buffer.from(message).toString("hex"));
      var v = result['v'] + 27 + 4;
      var signature = Buffer.from(v.toString(16) + result['r'] + result['s'], 'hex').toString('base64');
      return signature;
    }
    catch (e) {
      console.log(e);
      return null;
    }
  }

  public async getAddress(path: string, verify: boolean) {
    try {

      const appBtc = await this.appLedgerDefichain();
      const address = await appBtc.getWalletPublicKey(path, {
        verify: verify,
        format: "bech32",
      });
      console.log(address);
      return address;
    } catch (e) {
      console.log(e);
      return null;
    }
  };

  public async signTransactionRaw(transaction: LedgerTransactionRaw[], paths: string[], newTx: string, networkStr: string, changePath: string): Promise<string> {
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

  public async signTransaction(transaction: LedgerTransaction[], paths: string[], newTx: string, networkStr: string): Promise<string> {
    const ledger = await this.appLedgerDefichain();
    const splitNewTx = await ledger.splitTransaction(newTx, true);
    const outputScriptHex = await ledger.serializeTransactionOutputs(splitNewTx).toString("hex");

    var inputs: Array<
      [Transaction, number, string | null | undefined, number | null | undefined]
    > = [];

    console.log(transaction);

    for (var tx of transaction) {
      var ledgerInputs: TransactionInput[] = [];
      var ledgerOutputs: TransactionOutput[] = [];
      var ledgerTransaction: Transaction;


      for (var ins of tx.inputs.sort(function (a, b) { return a.order - b.order })) {
        var sequence = Buffer.allocUnsafe(4);
        sequence.writeUInt32LE(ins.sequence);
        var prevout = Buffer.from(ins.prevout, "hex");

        if (prevout.length == 36) {
          prevout = Buffer.concat([prevout.slice(0, 32).reverse(), prevout.slice(32, 36).reverse()]);
        }
        else {
          prevout = prevout.reverse();
        }

        ledgerInputs.push({
          prevout: prevout,
          script: Buffer.from(ins.script).reverse(),
          sequence: sequence.reverse(),
          tree: ins.tree ? Buffer.from(ins.tree, "hex") : Buffer.alloc(0)
        });
        console.log("add input " + ins.prevout + "@" + ins.index);
      }
      for (var outs of tx.outputs) {
        var amount = Buffer.allocUnsafe(8);
        amount.writeInt32LE(outs.amount & -1);
        amount.writeUInt32LE(Math.floor(outs.amount / 0x100000000), 4);

        ledgerOutputs.push({
          amount: amount,
          script: Buffer.from(outs.script, "hex")
        })
      }


      var lock = Buffer.allocUnsafe(4);
      lock.writeUInt32LE(tx.lockTime);

      var version = Buffer.allocUnsafe(4);
      version.writeInt32LE(tx.version);
      ledgerTransaction = {

        inputs: ledgerInputs,
        outputs: ledgerOutputs,
        version: version,
        locktime: lock,
        extraData: Buffer.alloc(0),
        nExpiryHeight: Buffer.alloc(0),
        nVersionGroupId: Buffer.alloc(0),
        timestamp: Buffer.alloc(0),
        witness: Buffer.from(tx.witnesses, "hex")
      };
      console.log(ledgerTransaction);
      inputs.push([ledgerTransaction, tx.index, tx.redeemScript, void 0]);

      var inputTxBuffer = serializeTransaction(ledgerTransaction, true);
      var inputTxid = crypto.hash256(inputTxBuffer).toString("hex");

      if (inputTxid != tx.txId) {
        ledgerTransaction.inputs = ledgerInputs.reverse();
      }
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


  public rawTxToPsbt(rawTx: any, network: any) {
    //const psbtTx = new PsbtTransaction(txBuffer);
    // const psbtBase = new PsbtBase(psbtTx);
    // const psbt = new Psbt({ network: getNetwork(network) }, psbtBase);

    // const base64 = psbt.toBase64();

    // console.log(base64);
  }

  private getNetwork(network: string) {
    switch (network) {
      case "bitcoin":
        return bitcoin;
      case "bitcoin_testnet":
      case "testnet":
        return testnet;
      case "defichain":
        return defichain;
      case "defichain_testnet":
        return defichain_testnet;
      default:
        return defichain;
    }
  }

}


