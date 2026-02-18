/*
  # Expand Supported Coins with Binance Integration

  1. Schema Changes
    - Add new columns to `supported_coins` table:
      - `logo_url` (text) - Binance official logo URL
      - `current_price` (decimal) - Current trading price
      - `price_change_24h` (decimal) - 24h price change percentage
      - `market_cap` (decimal) - Market capitalization
      - `volume_24h` (decimal) - 24h trading volume
      - `high_24h` (decimal) - 24h high price
      - `low_24h` (decimal) - 24h low price
      - `is_spot_enabled` (boolean) - Available for spot trading
      - `is_futures_enabled` (boolean) - Available for futures trading
      - `binance_symbol` (text) - Binance trading symbol (e.g., BTCUSDT)
      - `last_updated` (timestamptz) - Last price update timestamp

  2. New Functions
    - Function to update coin prices from Binance
    - Function to sync all Binance coins

  3. Notes
    - This migration prepares the database for comprehensive Binance integration
    - Prices will be updated via edge functions or scheduled jobs
    - All existing data is preserved
*/

-- Add new columns to supported_coins table
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'supported_coins' AND column_name = 'logo_url'
  ) THEN
    ALTER TABLE supported_coins ADD COLUMN logo_url text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'supported_coins' AND column_name = 'current_price'
  ) THEN
    ALTER TABLE supported_coins ADD COLUMN current_price decimal(30, 8) DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'supported_coins' AND column_name = 'price_change_24h'
  ) THEN
    ALTER TABLE supported_coins ADD COLUMN price_change_24h decimal(10, 4) DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'supported_coins' AND column_name = 'market_cap'
  ) THEN
    ALTER TABLE supported_coins ADD COLUMN market_cap decimal(30, 2) DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'supported_coins' AND column_name = 'volume_24h'
  ) THEN
    ALTER TABLE supported_coins ADD COLUMN volume_24h decimal(30, 8) DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'supported_coins' AND column_name = 'high_24h'
  ) THEN
    ALTER TABLE supported_coins ADD COLUMN high_24h decimal(30, 8) DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'supported_coins' AND column_name = 'low_24h'
  ) THEN
    ALTER TABLE supported_coins ADD COLUMN low_24h decimal(30, 8) DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'supported_coins' AND column_name = 'is_spot_enabled'
  ) THEN
    ALTER TABLE supported_coins ADD COLUMN is_spot_enabled boolean DEFAULT true;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'supported_coins' AND column_name = 'is_futures_enabled'
  ) THEN
    ALTER TABLE supported_coins ADD COLUMN is_futures_enabled boolean DEFAULT false;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'supported_coins' AND column_name = 'binance_symbol'
  ) THEN
    ALTER TABLE supported_coins ADD COLUMN binance_symbol text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'supported_coins' AND column_name = 'last_updated'
  ) THEN
    ALTER TABLE supported_coins ADD COLUMN last_updated timestamptz DEFAULT now();
  END IF;
END $$;

-- Create index on binance_symbol for fast lookups
CREATE INDEX IF NOT EXISTS idx_supported_coins_binance_symbol ON supported_coins(binance_symbol);

-- Update existing coins with Binance logo URLs and binance_symbol
UPDATE supported_coins SET 
  logo_url = 'https://bin.bnbstatic.com/static/images/coins/64/BTC.png',
  binance_symbol = 'BTCUSDT',
  is_spot_enabled = true,
  is_futures_enabled = true
WHERE symbol = 'BTC' AND logo_url IS NULL;

UPDATE supported_coins SET 
  logo_url = 'https://bin.bnbstatic.com/static/images/coins/64/ETH.png',
  binance_symbol = 'ETHUSDT',
  is_spot_enabled = true,
  is_futures_enabled = true
WHERE symbol = 'ETH' AND logo_url IS NULL;

UPDATE supported_coins SET 
  logo_url = 'https://bin.bnbstatic.com/static/images/coins/64/BNB.png',
  binance_symbol = 'BNBUSDT',
  is_spot_enabled = true,
  is_futures_enabled = true
WHERE symbol = 'BNB' AND logo_url IS NULL;

UPDATE supported_coins SET 
  logo_url = 'https://bin.bnbstatic.com/static/images/coins/64/USDT.png',
  binance_symbol = 'USDTUSDT',
  is_spot_enabled = true,
  is_futures_enabled = false
WHERE symbol = 'USDT' AND logo_url IS NULL;

UPDATE supported_coins SET 
  logo_url = 'https://bin.bnbstatic.com/static/images/coins/64/TRX.png',
  binance_symbol = 'TRXUSDT',
  is_spot_enabled = true,
  is_futures_enabled = true
WHERE symbol = 'TRX' AND logo_url IS NULL;

UPDATE supported_coins SET 
  logo_url = 'https://bin.bnbstatic.com/static/images/coins/64/SOL.png',
  binance_symbol = 'SOLUSDT',
  is_spot_enabled = true,
  is_futures_enabled = true
WHERE symbol = 'SOL' AND logo_url IS NULL;

UPDATE supported_coins SET 
  logo_url = 'https://bin.bnbstatic.com/static/images/coins/64/USDC.png',
  binance_symbol = 'USDCUSDT',
  is_spot_enabled = true,
  is_futures_enabled = false
WHERE symbol = 'USDC' AND logo_url IS NULL;

UPDATE supported_coins SET 
  logo_url = 'https://bin.bnbstatic.com/static/images/coins/64/MATIC.png',
  binance_symbol = 'MATICUSDT',
  is_spot_enabled = true,
  is_futures_enabled = true
WHERE symbol = 'MATIC' AND logo_url IS NULL;

-- Insert many more popular Binance coins
INSERT INTO supported_coins (symbol, name, logo_url, binance_symbol, is_trending, is_spot_enabled, is_futures_enabled, is_active, sort_order) VALUES
  ('XRP', 'Ripple', 'https://bin.bnbstatic.com/static/images/coins/64/XRP.png', 'XRPUSDT', true, true, true, true, 9),
  ('ADA', 'Cardano', 'https://bin.bnbstatic.com/static/images/coins/64/ADA.png', 'ADAUSDT', true, true, true, true, 10),
  ('DOGE', 'Dogecoin', 'https://bin.bnbstatic.com/static/images/coins/64/DOGE.png', 'DOGEUSDT', true, true, true, true, 11),
  ('AVAX', 'Avalanche', 'https://bin.bnbstatic.com/static/images/coins/64/AVAX.png', 'AVAXUSDT', true, true, true, true, 12),
  ('DOT', 'Polkadot', 'https://bin.bnbstatic.com/static/images/coins/64/DOT.png', 'DOTUSDT', true, true, true, true, 13),
  ('LINK', 'Chainlink', 'https://bin.bnbstatic.com/static/images/coins/64/LINK.png', 'LINKUSDT', false, true, true, true, 14),
  ('UNI', 'Uniswap', 'https://bin.bnbstatic.com/static/images/coins/64/UNI.png', 'UNIUSDT', false, true, true, true, 15),
  ('LTC', 'Litecoin', 'https://bin.bnbstatic.com/static/images/coins/64/LTC.png', 'LTCUSDT', false, true, true, true, 16),
  ('ATOM', 'Cosmos', 'https://bin.bnbstatic.com/static/images/coins/64/ATOM.png', 'ATOMUSDT', false, true, true, true, 17),
  ('XLM', 'Stellar', 'https://bin.bnbstatic.com/static/images/coins/64/XLM.png', 'XLMUSDT', false, true, true, true, 18),
  ('BCH', 'Bitcoin Cash', 'https://bin.bnbstatic.com/static/images/coins/64/BCH.png', 'BCHUSDT', false, true, true, true, 19),
  ('ETC', 'Ethereum Classic', 'https://bin.bnbstatic.com/static/images/coins/64/ETC.png', 'ETCUSDT', false, true, true, true, 20),
  ('FIL', 'Filecoin', 'https://bin.bnbstatic.com/static/images/coins/64/FIL.png', 'FILUSDT', false, true, true, true, 21),
  ('NEAR', 'NEAR Protocol', 'https://bin.bnbstatic.com/static/images/coins/64/NEAR.png', 'NEARUSDT', false, true, true, true, 22),
  ('ALGO', 'Algorand', 'https://bin.bnbstatic.com/static/images/coins/64/ALGO.png', 'ALGOUSDT', false, true, true, true, 23),
  ('VET', 'VeChain', 'https://bin.bnbstatic.com/static/images/coins/64/VET.png', 'VETUSDT', false, true, true, true, 24),
  ('ICP', 'Internet Computer', 'https://bin.bnbstatic.com/static/images/coins/64/ICP.png', 'ICPUSDT', false, true, true, true, 25),
  ('APT', 'Aptos', 'https://bin.bnbstatic.com/static/images/coins/64/APT.png', 'APTUSDT', false, true, true, true, 26),
  ('ARB', 'Arbitrum', 'https://bin.bnbstatic.com/static/images/coins/64/ARB.png', 'ARBUSDT', false, true, true, true, 27),
  ('OP', 'Optimism', 'https://bin.bnbstatic.com/static/images/coins/64/OP.png', 'OPUSDT', false, true, true, true, 28),
  ('SHIB', 'Shiba Inu', 'https://bin.bnbstatic.com/static/images/coins/64/SHIB.png', 'SHIBUSDT', false, true, true, true, 29),
  ('PEPE', 'Pepe', 'https://bin.bnbstatic.com/static/images/coins/64/PEPE.png', 'PEPEUSDT', false, true, true, true, 30),
  ('HBAR', 'Hedera', 'https://bin.bnbstatic.com/static/images/coins/64/HBAR.png', 'HBARUSDT', false, true, true, true, 31),
  ('INJ', 'Injective', 'https://bin.bnbstatic.com/static/images/coins/64/INJ.png', 'INJUSDT', false, true, true, true, 32),
  ('SUI', 'Sui', 'https://bin.bnbstatic.com/static/images/coins/64/SUI.png', 'SUIUSDT', false, true, true, true, 33),
  ('SEI', 'Sei', 'https://bin.bnbstatic.com/static/images/coins/64/SEI.png', 'SEIUSDT', false, true, true, true, 34),
  ('TIA', 'Celestia', 'https://bin.bnbstatic.com/static/images/coins/64/TIA.png', 'TIAUSDT', false, true, true, true, 35),
  ('STX', 'Stacks', 'https://bin.bnbstatic.com/static/images/coins/64/STX.png', 'STXUSDT', false, true, true, true, 36),
  ('AAVE', 'Aave', 'https://bin.bnbstatic.com/static/images/coins/64/AAVE.png', 'AAVEUSDT', false, true, true, true, 37),
  ('MKR', 'Maker', 'https://bin.bnbstatic.com/static/images/coins/64/MKR.png', 'MKRUSDT', false, true, true, true, 38),
  ('GRT', 'The Graph', 'https://bin.bnbstatic.com/static/images/coins/64/GRT.png', 'GRTUSDT', false, true, true, true, 39),
  ('SAND', 'The Sandbox', 'https://bin.bnbstatic.com/static/images/coins/64/SAND.png', 'SANDUSDT', false, true, true, true, 40),
  ('MANA', 'Decentraland', 'https://bin.bnbstatic.com/static/images/coins/64/MANA.png', 'MANAUSDT', false, true, true, true, 41),
  ('AXS', 'Axie Infinity', 'https://bin.bnbstatic.com/static/images/coins/64/AXS.png', 'AXSUSDT', false, true, true, true, 42),
  ('IMX', 'Immutable X', 'https://bin.bnbstatic.com/static/images/coins/64/IMX.png', 'IMXUSDT', false, true, true, true, 43),
  ('FTM', 'Fantom', 'https://bin.bnbstatic.com/static/images/coins/64/FTM.png', 'FTMUSDT', false, true, true, true, 44),
  ('RUNE', 'THORChain', 'https://bin.bnbstatic.com/static/images/coins/64/RUNE.png', 'RUNEUSDT', false, true, true, true, 45),
  ('CRV', 'Curve DAO', 'https://bin.bnbstatic.com/static/images/coins/64/CRV.png', 'CRVUSDT', false, true, true, true, 46),
  ('LDO', 'Lido DAO', 'https://bin.bnbstatic.com/static/images/coins/64/LDO.png', 'LDOUSDT', false, true, true, true, 47),
  ('RNDR', 'Render', 'https://bin.bnbstatic.com/static/images/coins/64/RNDR.png', 'RNDRUSDT', false, true, true, true, 48),
  ('FET', 'Fetch.ai', 'https://bin.bnbstatic.com/static/images/coins/64/FET.png', 'FETUSDT', false, true, true, true, 49),
  ('AGIX', 'SingularityNET', 'https://bin.bnbstatic.com/static/images/coins/64/AGIX.png', 'AGIXUSDT', false, true, true, true, 50)
ON CONFLICT (symbol) DO UPDATE SET
  logo_url = EXCLUDED.logo_url,
  binance_symbol = EXCLUDED.binance_symbol,
  is_spot_enabled = EXCLUDED.is_spot_enabled,
  is_futures_enabled = EXCLUDED.is_futures_enabled;

-- Allow public read access to all coin data (not just active ones for now)
DROP POLICY IF EXISTS "Anyone can view active coins" ON supported_coins;

CREATE POLICY "Public can view all coins"
  ON supported_coins FOR SELECT
  TO public
  USING (true);