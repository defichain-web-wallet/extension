
export class LedgerTransaction {
    version: number;
    inputs: LedgerTransactionInput[];
    outputs?: LedgerTransactionOutput[];
    lockTime?: number;
    txId: string;


    index: number;
    sequenceNumber: number;
    redeemScript: string;
    witnesses: String[] = [];
}

export class LedgerTransactionInput {
    prevout: string;
    script: string;
    sequence: number;
    tree?: string;

    index: number;

} 

export class LedgerTransactionOutput {
    amount: number;
    script: string;
}