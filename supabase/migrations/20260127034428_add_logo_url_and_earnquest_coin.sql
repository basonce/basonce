/*
  # Add Logo URLs and EarnQuest Coin to Supported Coins

  1. Changes
    - Add `logo_url` column to `supported_coins` table
    - Insert EarnQuest (EQ) coin with logo
    - Update existing coins with logo URLs from cryptologos.cc

  2. Security
    - No RLS changes needed (table already has proper RLS)
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'supported_coins' AND column_name = 'logo_url'
  ) THEN
    ALTER TABLE supported_coins ADD COLUMN logo_url text;
  END IF;
END $$;

INSERT INTO supported_coins (symbol, name, logo_url)
VALUES ('EQ', 'EarnQuest', '/earnquest-logo-icon-2 copy copy copy copy copy copy copy.png')
ON CONFLICT (symbol) DO UPDATE SET logo_url = EXCLUDED.logo_url;

UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/bitcoin-btc-logo.png' WHERE symbol = 'BTC';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/ethereum-eth-logo.png' WHERE symbol = 'ETH';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/bnb-bnb-logo.png' WHERE symbol = 'BNB';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/solana-sol-logo.png' WHERE symbol = 'SOL';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/xrp-xrp-logo.png' WHERE symbol = 'XRP';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/cardano-ada-logo.png' WHERE symbol = 'ADA';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/dogecoin-doge-logo.png' WHERE symbol = 'DOGE';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/avalanche-avax-logo.png' WHERE symbol = 'AVAX';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/polkadot-new-dot-logo.png' WHERE symbol = 'DOT';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/polygon-matic-logo.png' WHERE symbol = 'MATIC';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/chainlink-link-logo.png' WHERE symbol = 'LINK';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/cosmos-atom-logo.png' WHERE symbol = 'ATOM';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/litecoin-ltc-logo.png' WHERE symbol = 'LTC';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/uniswap-uni-logo.png' WHERE symbol = 'UNI';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/ethereum-classic-etc-logo.png' WHERE symbol = 'ETC';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/stellar-xlm-logo.png' WHERE symbol = 'XLM';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/near-protocol-near-logo.png' WHERE symbol = 'NEAR';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/algorand-algo-logo.png' WHERE symbol = 'ALGO';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/vechain-vet-logo.png' WHERE symbol = 'VET';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/aptos-apt-logo.png' WHERE symbol = 'APT';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/filecoin-fil-logo.png' WHERE symbol = 'FIL';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/arbitrum-arb-logo.png' WHERE symbol = 'ARB';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/optimism-ethereum-op-logo.png' WHERE symbol = 'OP';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/aave-aave-logo.png' WHERE symbol = 'AAVE';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/1inch-1inch-logo.png' WHERE symbol = '1INCH';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/axie-infinity-axs-logo.png' WHERE symbol = 'AXS';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/basic-attention-token-bat-logo.png' WHERE symbol = 'BAT';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/bitcoin-cash-bch-logo.png' WHERE symbol = 'BCH';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/pancakeswap-cake-logo.png' WHERE symbol = 'CAKE';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/chiliz-chz-logo.png' WHERE symbol = 'CHZ';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/compound-comp-logo.png' WHERE symbol = 'COMP';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/curve-dao-token-crv-logo.png' WHERE symbol = 'CRV';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/multi-collateral-dai-dai-logo.png' WHERE symbol = 'DAI';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/dash-dash-logo.png' WHERE symbol = 'DASH';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/enjin-coin-enj-logo.png' WHERE symbol = 'ENJ';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/eos-eos-logo.png' WHERE symbol = 'EOS';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/fantom-ftm-logo.png' WHERE symbol = 'FTM';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/the-graph-grt-logo.png' WHERE symbol = 'GRT';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/hedera-hbar-logo.png' WHERE symbol = 'HBAR';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/internet-computer-icp-logo.png' WHERE symbol = 'ICP';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/immutable-x-imx-logo.png' WHERE symbol = 'IMX';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/iota-miota-logo.png' WHERE symbol = 'IOTA';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/loopring-lrc-logo.png' WHERE symbol = 'LRC';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/decentraland-mana-logo.png' WHERE symbol = 'MANA';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/maker-mkr-logo.png' WHERE symbol = 'MKR';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/neo-neo-logo.png' WHERE symbol = 'NEO';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/the-sandbox-sand-logo.png' WHERE symbol = 'SAND';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/shiba-inu-shib-logo.png' WHERE symbol = 'SHIB';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/synthetix-snx-logo.png' WHERE symbol = 'SNX';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/stacks-stx-logo.png' WHERE symbol = 'STX';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/sushiswap-sushi-logo.png' WHERE symbol = 'SUSHI';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/theta-theta-logo.png' WHERE symbol = 'THETA';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/tron-trx-logo.png' WHERE symbol = 'TRX';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/usd-coin-usdc-logo.png' WHERE symbol = 'USDC';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/tether-usdt-logo.png' WHERE symbol = 'USDT';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/monero-xmr-logo.png' WHERE symbol = 'XMR';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/tezos-xtz-logo.png' WHERE symbol = 'XTZ';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/zcash-zec-logo.png' WHERE symbol = 'ZEC';
UPDATE supported_coins SET logo_url = 'https://cryptologos.cc/logos/zilliqa-zil-logo.png' WHERE symbol = 'ZIL';