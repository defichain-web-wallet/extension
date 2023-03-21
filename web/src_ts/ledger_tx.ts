
export class LedgerTransaction {
    version: number;
    inputs: LedgerTransactionInput[];
    outputs?: LedgerTransactionOutput[];
    lockTime?: number;
    txId: string;


    index: number;
    sequenceNumber: number;
    redeemScript: string;
    witnesses: String;
}


export class LedgerTransactionRaw {
    txId: string;
    rawTx: string;

    index: number;
    redeemScript: string;
}

export class LedgerTransactionInput {
    prevout: string;
    script: string;
    sequence: number;
    tree?: string;

    index: number;
    order: number;

} 

export class LedgerTransactionOutput {
    amount: number;
    script: string;
}