import { JellyWalletLedger } from "./ledger-base.js";

(<any>window).jelly_init = () => {
    console.log("init jellywallet");
    (<any>window).ledger = new JellyWalletLedger();
};