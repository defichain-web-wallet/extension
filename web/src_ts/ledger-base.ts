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
import { LedgerTransaction } from "./ledger_tx";
import * as defichainlib from "defichainjs-lib";
import { buffer } from "stream/consumers";

export class JellyWalletLedger {

  async appLedgerDefichain(): Promise<AppDfi> {
    const transport = await SpeculosTransport.open({ baseURL: "192.168.8.140:5000" });
    //  const transport = await TransportWebUSB.create();

    listen((log) => console.log(log));

    const btc = new AppDfi(transport);
    return btc;
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

  public async signTransaction(transaction: LedgerTransaction[], paths: string[], newTx: string, networkStr: string): Promise<string[]> {
    const ledger = await this.appLedgerDefichain();
    const splitNewTx = await ledger.splitTransaction(newTx, true);
    const outputScriptHex = await ledger.serializeTransactionOutputs(splitNewTx).toString("hex");

    var inputs: Array<
      [Transaction, number, string | null | undefined, number | null | undefined]
    > = [];

    for (var tx of transaction) {
      var ledgerInputs: TransactionInput[] = [];
      var ledgerOutputs: TransactionOutput[] = [];
      var ledgerTransaction: Transaction;


      tx.inputs.forEach(ins => {
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
      });
      tx.outputs.forEach(outs => {
        var amount = Buffer.allocUnsafe(8);
        amount.writeInt32LE(outs.amount & -1);
        amount.writeUInt32LE(Math.floor(outs.amount / 0x100000000), 4);

        ledgerOutputs.push({
          amount: amount,
          script: Buffer.from(outs.script, "hex")
        })
      });


      var lock = Buffer.allocUnsafe(4);
      lock.writeUInt32LE(tx.lockTime);

      var witness = Buffer.alloc(0);

      if (tx.witnesses) {
        var offset = 0;
        var witnessLength = tx.witnesses.reduce((sum, w) => { return sum + w.length / 2 }, 0);
        var buffer = Buffer.alloc(1 + tx.witnesses.length + witnessLength);

        buffer.writeInt8(tx.witnesses.length, offset++);
        tx.witnesses.forEach(w => {
          buffer.writeInt8(w.length/2, offset++);
          var witnessHex = Buffer.from(w, "hex");
          witnessHex.copy(buffer, offset);
          offset += witnessHex.length;
        });

        witness = buffer;
      }

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
        witness: witness
      };
      console.log(ledgerTransaction);
      inputs.push([ledgerTransaction, tx.index, void 0, void 0]);
    }
    const segwit = true;
    const signArg: SignP2SHTransactionArg = {
      inputs: inputs,
      associatedKeysets: paths,
      outputScriptHex: outputScriptHex,
      segwit: segwit,
      lockTime: 0,
      sigHashType: 1,
      transactionVersion: 4,

    };

    
    // const txOut = await ledger.createPaymentTransactionNew({
    //   inputs: inputs,
    //   associatedKeysets: paths,
    //   outputScriptHex: outputScriptHex,
    //   segwit: true,
    //   additionals: ["bech32"],
    //   transactionVersion: 4
    // });

    // console.log(txOut);

     const ledgerSignatures = await ledger.signP2SHTransaction(signArg);
     console.log(ledgerSignatures);

    return ledgerSignatures;
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


