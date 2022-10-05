let openRequest = indexedDB.open("rates", 1);
let openStoreRequest = indexedDB.open("store", 1);

async function setupRates() {
    var tokensMainnetResponse = await fetch('https://ocean.defichain.com/v0/mainnet/tokens?size=200')
        .then((response) => {
            return response.json();
        });
    var tokensTestnetResponse = await fetch('https://ocean.defichain.com/v0/testnet/tokens?size=200')
        .then((response) => {
            return response.json();
        });
    var poolpairsMainnetResponse = await fetch('https://ocean.defichain.com/v0/mainnet/poolpairs?size=200')
        .then((response) => {
            return response.json();
        });
    var poolpairsTestnetResponse = await fetch('https://ocean.defichain.com/v0/testnet/poolpairs?size=200')
        .then((response) => {
            return response.json();
        });
    var ratesResponse = await fetch('https://api.exchangerate.host/latest?base=USD')
        .then((response) => {
            return response.json();
        });

    let db = openRequest.result;
    let transaction = db.transaction("box", "readwrite");

    let rates = transaction.objectStore("box");

    let tokensMainnet = {
        key: 'tokensMainnet',
        data: JSON.stringify(tokensMainnetResponse["data"])
    };
    let tokensTestnet = {
        key: 'tokensTestnet',
        data: JSON.stringify(tokensTestnetResponse["data"])
    };
    let poolpairsMainnet = {
        key: 'poolpairsMainnet',
        data: JSON.stringify(poolpairsMainnetResponse["data"])
    };
    let poolpairsTestnet = {
        key: 'poolpairsTestnet',
        data: JSON.stringify(poolpairsTestnetResponse["data"])
    };
    let ratesTestnet = {
        key: 'rates',
        data: JSON.stringify(ratesResponse["rates"])
    };
    rates.put(tokensMainnet);
    rates.put(tokensTestnet);
    rates.put(poolpairsMainnet);
    rates.put(poolpairsTestnet);
    rates.put(ratesTestnet);
}

openRequest.onupgradeneeded = function() {
    let db = openRequest.result;
    if (!db.objectStoreNames.contains('box')) {
        db.createObjectStore('box', {keyPath: 'key'});
    }
};

openRequest.onerror = function() {
    console.error("Error", openRequest.error);
};

openRequest.onsuccess = async () => {
    const tickerForLoadData = 300000;

    (function foo() {
        setupRates();
    })();

    setInterval(async () => await setupRates(), tickerForLoadData)
};

openStoreRequest.onupgradeneeded = function() {
    let db = openStoreRequest.result;
    if (!db.objectStoreNames.contains('box')) {
        db.createObjectStore('box', {keyPath: 'key'});
    }
};

openStoreRequest.onerror = function() {
    console.error("Error", openRequest.error);
};

openStoreRequest.onsuccess = (event) => {
    const tickerForLoadData = 300000;

    (function foo() {
        let db = openStoreRequest.result;
        let transaction = db.transaction("box", "readwrite");

        let store = transaction.objectStore("box");
        let hash = {
            key: 'auth_time',
            data: '111'
        };
        store.put(hash);
    })();

    setInterval(() => {
        let db = openStoreRequest.result;
        let transaction = db.transaction("box", "readwrite");

        let store = transaction.objectStore("box");
        let openTime = store.get('auth_time');
//        if (openTime.result.data === '222') {
//            let hash = {
//                key: 'auth_time',
//                data: ''
//            };
//            store.put(hash);
//        }
        openTime.onsuccess = (e) => {
            console.log(e.target.result);
        };

        openTime.onerror = (e) => {
            console.log("Error Getting: ", e);
        };
//        console.log(openTime.result);
    }, 5000)
};
