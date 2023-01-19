import { JellyWalletLedger } from "./ledger-base.js";

(<any>window).jelly_init = () => {
    console.log("init jellywallet");
    if(!(<any>window).ledger)
        (<any>window).ledger = new JellyWalletLedger();
};