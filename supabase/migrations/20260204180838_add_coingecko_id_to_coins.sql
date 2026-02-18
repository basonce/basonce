/*
  # Add CoinGecko ID to supported_coins

  1. Changes
    - Add `coingecko_id` column to `supported_coins` table
    - This will enable fetching prices from CoinGecko API for coins not available on Binance
    - Populate common coin IDs
  
  2. Purpose
    - Many coins are not available on Binance Futures (USDC, DAI, SATS, RATS, BOBA, etc.)
    - CoinGecko provides price data for 10,000+ coins
    - Hybrid approach: Binance for major coins, CoinGecko for others
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'supported_coins' AND column_name = 'coingecko_id'
  ) THEN
    ALTER TABLE supported_coins 
    ADD COLUMN coingecko_id TEXT;

    CREATE INDEX IF NOT EXISTS idx_coingecko_id ON supported_coins(coingecko_id);
  END IF;
END $$;

UPDATE supported_coins SET coingecko_id = 'bitcoin' WHERE symbol = 'BTC';
UPDATE supported_coins SET coingecko_id = 'ethereum' WHERE symbol = 'ETH';
UPDATE supported_coins SET coingecko_id = 'binancecoin' WHERE symbol = 'BNB';
UPDATE supported_coins SET coingecko_id = 'tether' WHERE symbol = 'USDT';
UPDATE supported_coins SET coingecko_id = 'usd-coin' WHERE symbol = 'USDC';
UPDATE supported_coins SET coingecko_id = 'dai' WHERE symbol = 'DAI';
UPDATE supported_coins SET coingecko_id = 'solana' WHERE symbol = 'SOL';
UPDATE supported_coins SET coingecko_id = 'cardano' WHERE symbol = 'ADA';
UPDATE supported_coins SET coingecko_id = 'ripple' WHERE symbol = 'XRP';
UPDATE supported_coins SET coingecko_id = 'dogecoin' WHERE symbol = 'DOGE';
UPDATE supported_coins SET coingecko_id = 'polkadot' WHERE symbol = 'DOT';
UPDATE supported_coins SET coingecko_id = 'matic-network' WHERE symbol = 'MATIC';
UPDATE supported_coins SET coingecko_id = 'avalanche-2' WHERE symbol = 'AVAX';
UPDATE supported_coins SET coingecko_id = 'chainlink' WHERE symbol = 'LINK';
UPDATE supported_coins SET coingecko_id = 'cosmos' WHERE symbol = 'ATOM';
UPDATE supported_coins SET coingecko_id = 'uniswap' WHERE symbol = 'UNI';
UPDATE supported_coins SET coingecko_id = 'litecoin' WHERE symbol = 'LTC';
UPDATE supported_coins SET coingecko_id = 'bitcoin-cash' WHERE symbol = 'BCH';
UPDATE supported_coins SET coingecko_id = 'shiba-inu' WHERE symbol = 'SHIB';
UPDATE supported_coins SET coingecko_id = 'aptos' WHERE symbol = 'APT';
UPDATE supported_coins SET coingecko_id = 'arbitrum' WHERE symbol = 'ARB';
UPDATE supported_coins SET coingecko_id = 'optimism' WHERE symbol = 'OP';
UPDATE supported_coins SET coingecko_id = 'fantom' WHERE symbol = 'FTM';
UPDATE supported_coins SET coingecko_id = 'near' WHERE symbol = 'NEAR';
UPDATE supported_coins SET coingecko_id = 'algorand' WHERE symbol = 'ALGO';
UPDATE supported_coins SET coingecko_id = 'vechain' WHERE symbol = 'VET';
UPDATE supported_coins SET coingecko_id = 'internet-computer' WHERE symbol = 'ICP';
UPDATE supported_coins SET coingecko_id = 'filecoin' WHERE symbol = 'FIL';
UPDATE supported_coins SET coingecko_id = 'ethereum-classic' WHERE symbol = 'ETC';
UPDATE supported_coins SET coingecko_id = 'stellar' WHERE symbol = 'XLM';
UPDATE supported_coins SET coingecko_id = 'hedera-hashgraph' WHERE symbol = 'HBAR';
UPDATE supported_coins SET coingecko_id = 'aave' WHERE symbol = 'AAVE';
UPDATE supported_coins SET coingecko_id = 'pepe' WHERE symbol = 'PEPE';
UPDATE supported_coins SET coingecko_id = 'maker' WHERE symbol = 'MKR';
UPDATE supported_coins SET coingecko_id = 'injective-protocol' WHERE symbol = 'INJ';
UPDATE supported_coins SET coingecko_id = 'monero' WHERE symbol = 'XMR';
UPDATE supported_coins SET coingecko_id = 'blockstack' WHERE symbol = 'STX';
UPDATE supported_coins SET coingecko_id = 'sui' WHERE symbol = 'SUI';
UPDATE supported_coins SET coingecko_id = 'sei-network' WHERE symbol = 'SEI';
UPDATE supported_coins SET coingecko_id = 'the-graph' WHERE symbol = 'GRT';
UPDATE supported_coins SET coingecko_id = 'celestia' WHERE symbol = 'TIA';
UPDATE supported_coins SET coingecko_id = 'the-sandbox' WHERE symbol = 'SAND';
UPDATE supported_coins SET coingecko_id = 'decentraland' WHERE symbol = 'MANA';
UPDATE supported_coins SET coingecko_id = 'axie-infinity' WHERE symbol = 'AXS';
UPDATE supported_coins SET coingecko_id = 'theta-token' WHERE symbol = 'THETA';
UPDATE supported_coins SET coingecko_id = 'tezos' WHERE symbol = 'XTZ';
UPDATE supported_coins SET coingecko_id = 'eos' WHERE symbol = 'EOS';
UPDATE supported_coins SET coingecko_id = 'zcash' WHERE symbol = 'ZEC';
UPDATE supported_coins SET coingecko_id = '1inch' WHERE symbol = '1INCH';
UPDATE supported_coins SET coingecko_id = 'alchemy-pay' WHERE symbol = 'ACH';
UPDATE supported_coins SET coingecko_id = 'boba-network' WHERE symbol = 'BOBA';
UPDATE supported_coins SET coingecko_id = 'ordinals' WHERE symbol = 'SATS';
UPDATE supported_coins SET coingecko_id = 'rats' WHERE symbol = 'RATS';
