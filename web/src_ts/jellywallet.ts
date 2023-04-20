import { JellyWalletLedger } from "./ledger-base.js";
import { getLedgerDevices, isSupported, getFirstLedgerDevice } from "@ledgerhq/hw-transport-webusb/lib/webusb";
import SpeculosHttpTransport from "hw-transport-node-speculos-http";

(<any>window).jelly_init = () => {
    console.log("init jellywallet");
    if (!(<any>window).ledger)
        (<any>window).ledger = new JellyWalletLedger();
};


(<any>window).openAppInTab = () => {
    chrome.tabs.create({
        'url': chrome.runtime.getURL("index.html#window")
    });
}

(<any>window).isUsbSupported = async () => {
    var transport = await new JellyWalletLedger().getTransport();

    if(transport instanceof SpeculosHttpTransport) {
        return 0;
    }
    
    if (await isSupported()) {
        try {
            var devices = await getFirstLedgerDevice();
            if (devices) {
                return 0;
            }
        }
        catch(err) {
            const isInPopup = function() {
                return (typeof chrome != undefined && chrome.extension) ?
                    chrome.extension.getViews({ type: "popup" }).length > 0 : null;
            }

            if(!isInPopup()) {
                return 2;
            }

            console.log(err);
            return 1;
        }
    }
    return 1;
}