const mainnetApi = 'http://ocean.mydefichain.com/v0';
const testnetApi = 'https://testnet-ocean.mydefichain.com:8443/v0';

let openRequest = indexedDB.open("rates", 1);

async function loadTokens(api, path, next = 0) {
    var result
    var nextLoadedTokens = []
    var nextPage = next != 0 ? `&next=${next}` : ''
    var response = await fetch(api + `${path}?size=200` + nextPage)
        .then((response) => response.json())

    if (response.hasOwnProperty('page')) {
        var next = response.page.next
        nextLoadedTokens = await loadTokens(api, path, next)
    }
    return [...response['data'], ...nextLoadedTokens]
}


async function setupRates() {
    var tokensMainnetData = await loadTokens(mainnetApi, '/mainnet/tokens')

    var tokensTestnetData = await loadTokens(testnetApi, '/testnet/tokens')

    var poolpairsMainnetData = await loadTokens(mainnetApi, '/mainnet/poolpairs')

    var poolpairsTestnetData = await loadTokens(testnetApi, '/testnet/poolpairs')

    var ratesResponse = await fetch('https://api.exchangerate.host/latest?base=USD')
        .then((response) => {
            return response.json();
        });

    let db = openRequest.result;
    let transaction = db.transaction("box", "readwrite");

    let rates = transaction.objectStore("box");

    let tokensMainnet = {
        key: 'tokensMainnet',
        data: JSON.stringify(tokensMainnetData)
    };
    let tokensTestnet = {
        key: 'tokensTestnet',
        data: JSON.stringify(tokensTestnetData)
    };
    let poolpairsMainnet = {
        key: 'poolpairsMainnet',
        data: JSON.stringify(poolpairsMainnetData)
    };
    let poolpairsTestnet = {
        key: 'poolpairsTestnet',
        data: JSON.stringify(poolpairsTestnetData)
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
