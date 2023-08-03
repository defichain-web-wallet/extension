import "core-js/actual";
import { listen } from "@ledgerhq/logs";
import AppBtc from "@ledgerhq/hw-app-btc";


import Transport from "@ledgerhq/hw-transport"
import { Transaction } from "@ledgerhq/hw-app-btc/lib/types";
import { LedgerTransactionRaw } from "./ledger_tx";

export class JellyWalletBtcLedger {



    async appLedgerBitcoin(transport: Transport): Promise<AppBtc> {
        transport.exchangeTimeout = 1000;
        transport.unresponsiveTimeout = 1000;
        listen((log) => console.log(log));


        const dfi = new AppBtc({ transport: transport, currency: "bitcoin_testnet" });
        return dfi;
    }


    public async signMessageLedger(transport: Transport, path: string, message: string) {
        try {

            const appBtc = await this.appLedgerBitcoin(transport);
            var result = await appBtc.signMessage(path, Buffer.from(message).toString("hex"));
            var v = result['v'] + 27 + 4;
            var signature = Buffer.from(v.toString(16) + result['r'] + result['s'], 'hex').toString('base64');
            return signature;
        }
        catch (e) {
            console.log(e);
            return null;
        }
    }

    public async getAddress(transport: Transport, path: string, verify: boolean): Promise<string> {
        try {

            const appBtc = await this.appLedgerBitcoin(transport);
            const timeoutError = new Error('TIME_OUT')
            const addressPromise = appBtc.getWalletPublicKey(path, {
                verify: verify,
                format: "bech32"
            });
            const timeoutPromise = new Promise<never>((_, reject) => {
                setTimeout(() => {
                    reject(timeoutError);
                }, 5000);
            });

            const address = await Promise.race([addressPromise, timeoutPromise]);

            console.log(address);
            return JSON.stringify(address);
        } catch (e) {
            console.log(e);
            throw e;
        }
    };

    public async signTransactionRaw(transport: Transport, transactionsJson: string, paths: string[], newTx: string, networkStr: string, changePath: string): Promise<string> {
        const transaction: LedgerTransactionRaw[] = JSON.parse(transactionsJson);

        const ledger = await this.appLedgerBitcoin(transport);
        const splitNewTx = await ledger.splitTransaction(newTx, true);
        const outputScriptHex = await ledger.serializeTransactionOutputs(splitNewTx).toString("hex");

        var inputs: Array<
            [Transaction, number, string | null | undefined, number | null | undefined]
        > = [];

        for (var tx of transaction) {
            var ledgerTransaction = await ledger.splitTransaction(tx.rawTx, true);

            inputs.push([ledgerTransaction, tx.index, tx.redeemScript, void 0]);
        }

        const txOut = await ledger.createPaymentTransaction({
            inputs: inputs,
            associatedKeysets: paths,
            outputScriptHex: outputScriptHex,
            segwit: true,
            additionals: ["bech32"],
            lockTime: 0,
            useTrustedInputForSegwit: true
        });

        return txOut;
    }
}


