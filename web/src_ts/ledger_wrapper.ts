import "core-js/actual";
import { JellyWalletLedger } from "./ledger_dfi";
import { JellyWalletBtcLedger } from "./ledger_btc";

import Transport from "@ledgerhq/hw-transport"

import { listen } from "@ledgerhq/logs";
import TransportWebHID from "@ledgerhq/hw-transport-webhid";
import SpeculosTransport from "hw-transport-node-speculos-http";

export class LedgerJellywalletWrapper {

    private ledger = new JellyWalletLedger();
    private ledgerBtc = new JellyWalletBtcLedger();

    async getTransport(): Promise<Transport> {
        // return await SpeculosTransport.open({ baseURL: "172.27.3.96:5000" });
        return await TransportWebHID.create();
    }

    private parseAppName(buffer: Buffer) {
        const appNameLength = buffer[1];

        const appNameBuffer = buffer.slice(2, 2 + appNameLength);

        return appNameBuffer.toString("utf8");
    }

    public async openApp(appName: string): Promise<boolean> {
        try {
            listen((log) => console.log(log));
            const targetAppName = appName == "dfi" ? "DeFiChain" : (appName == "test" ? "Bitcoin Test": "Bitcoin");

            var transport = await this.getTransport();
            const response = await transport.send(0xb0, 0x01, 0x00, 0x00); //app information, need to decode first!

            const openAppName = this.parseAppName(response);

            console.log("get info", response, openAppName);

            if (openAppName == targetAppName) {
                await transport.close();
                return;
            }


            const quitApp = await transport.send(0xb0, 0xa7, 0x00, 0x00);
            console.log("close app", quitApp);
            await transport.close();
            await new Promise(f => setTimeout(f, 500));

            transport = await this.getTransport();
            const appNameBuffer = Buffer.from([...[...targetAppName].map(c => c.charCodeAt(0))]);
            const launchApp = await transport.send(0xe0, 0xd8, 0x00, 0x00, appNameBuffer);
            console.log("launch app", launchApp);
            await new Promise(f => setTimeout(f, 500));

            await transport.close();

            return false;
        }
        catch (err) {
            console.log(err);
            throw err;
        }
    }


    public async getAddress(appName: string, path: string, verify: boolean): Promise<string> {
        await(this.openApp(appName));
        var transport = await this.getTransport();
        try {
            if (appName.toLocaleLowerCase() == "btc" || appName.toLocaleLowerCase() == "test") {
                return await this.ledgerBtc.getAddress(transport, path, verify);
            }
            return await this.ledger.getAddress(transport, path, verify);
        }
        finally {
            await transport.close();
        }
    }


    public async signMessageLedger(appName: string, path: string, message: string): Promise<string> {
        await(this.openApp(appName));
        var transport = await this.getTransport();
        try {
            if (appName.toLocaleLowerCase() == "btc" || appName.toLocaleLowerCase() == "test") {
                return await this.ledgerBtc.signMessageLedger(transport, path, message);
            }
            return await this.ledger.signMessageLedger(transport, path, message);
        }
        finally {
            await transport.close();
        }
    }


    public async signTransactionRaw(appName: string, transactionsJson: string, paths: string[], newTx: string, networkStr: string, changePath: string): Promise<string> {
        await(this.openApp(appName));
        var transport = await this.getTransport();
        try {
            if (appName.toLocaleLowerCase() == "btc" || appName.toLocaleLowerCase() == "test") {
                return await this.ledgerBtc.signTransactionRaw(transport, transactionsJson, paths, newTx, networkStr, changePath);
            }
            return await this.ledger.signTransactionRaw(transport, transactionsJson, paths, newTx, networkStr, changePath);
        }
        finally {
            await transport.close();
        }
    }
}