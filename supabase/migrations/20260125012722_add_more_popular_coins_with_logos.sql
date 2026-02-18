/*
  # Add More Popular Cryptocurrencies with Real Logos

  1. Updates
    - Add 50+ popular cryptocurrencies
    - Add real logo URLs from cryptocurrency icons CDN
    - Update existing coins with logo URLs
    - Add more networks for popular coins

  2. Coins Added
    - Major coins: ADA, DOT, AVAX, LINK, UNI, ATOM, XRP, DOGE, SHIB, etc.
    - DeFi tokens: AAVE, MKR, COMP, SNX, YFI, etc.
    - Layer 2: ARB, OP, IMX, etc.
    - Stablecoins: DAI, BUSD, TUSD, etc.
*/

-- Update existing coins with logo URLs
UPDATE supported_coins SET icon_url = 'https://assets.coincap.io/assets/icons/usdt@2x.png' WHERE symbol = 'USDT';
UPDATE supported_coins SET icon_url = 'https://assets.coincap.io/assets/icons/btc@2x.png' WHERE symbol = 'BTC';
UPDATE supported_coins SET icon_url = 'https://assets.coincap.io/assets/icons/eth@2x.png' WHERE symbol = 'ETH';
UPDATE supported_coins SET icon_url = 'https://assets.coincap.io/assets/icons/bnb@2x.png' WHERE symbol = 'BNB';
UPDATE supported_coins SET icon_url = 'https://assets.coincap.io/assets/icons/trx@2x.png' WHERE symbol = 'TRX';
UPDATE supported_coins SET icon_url = 'https://assets.coincap.io/assets/icons/usdc@2x.png' WHERE symbol = 'USDC';
UPDATE supported_coins SET icon_url = 'https://assets.coincap.io/assets/icons/sol@2x.png' WHERE symbol = 'SOL';
UPDATE supported_coins SET icon_url = 'https://assets.coincap.io/assets/icons/matic@2x.png' WHERE symbol = 'MATIC';

-- Insert more popular coins
INSERT INTO supported_coins (symbol, name, icon_url, is_trending, sort_order, is_active) VALUES
  ('XRP', 'Ripple', 'https://assets.coincap.io/assets/icons/xrp@2x.png', true, 6, true),
  ('ADA', 'Cardano', 'https://assets.coincap.io/assets/icons/ada@2x.png', true, 7, true),
  ('DOGE', 'Dogecoin', 'https://assets.coincap.io/assets/icons/doge@2x.png', true, 8, true),
  ('DOT', 'Polkadot', 'https://assets.coincap.io/assets/icons/dot@2x.png', false, 9, true),
  ('AVAX', 'Avalanche', 'https://assets.coincap.io/assets/icons/avax@2x.png', false, 10, true),
  ('LINK', 'Chainlink', 'https://assets.coincap.io/assets/icons/link@2x.png', false, 11, true),
  ('ATOM', 'Cosmos', 'https://assets.coincap.io/assets/icons/atom@2x.png', false, 12, true),
  ('UNI', 'Uniswap', 'https://assets.coincap.io/assets/icons/uni@2x.png', false, 13, true),
  ('LTC', 'Litecoin', 'https://assets.coincap.io/assets/icons/ltc@2x.png', false, 14, true),
  ('BCH', 'Bitcoin Cash', 'https://assets.coincap.io/assets/icons/bch@2x.png', false, 15, true),
  ('SHIB', 'Shiba Inu', 'https://assets.coincap.io/assets/icons/shib@2x.png', false, 16, true),
  ('DAI', 'Dai', 'https://assets.coincap.io/assets/icons/dai@2x.png', false, 17, true),
  ('APT', 'Aptos', 'https://assets.coincap.io/assets/icons/apt@2x.png', false, 18, true),
  ('ARB', 'Arbitrum', 'https://assets.coincap.io/assets/icons/arb@2x.png', false, 19, true),
  ('OP', 'Optimism', 'https://assets.coincap.io/assets/icons/op@2x.png', false, 20, true),
  ('FTM', 'Fantom', 'https://assets.coincap.io/assets/icons/ftm@2x.png', false, 21, true),
  ('NEAR', 'NEAR Protocol', 'https://assets.coincap.io/assets/icons/near@2x.png', false, 22, true),
  ('ALGO', 'Algorand', 'https://assets.coincap.io/assets/icons/algo@2x.png', false, 23, true),
  ('VET', 'VeChain', 'https://assets.coincap.io/assets/icons/vet@2x.png', false, 24, true),
  ('ICP', 'Internet Computer', 'https://assets.coincap.io/assets/icons/icp@2x.png', false, 25, true),
  ('FIL', 'Filecoin', 'https://assets.coincap.io/assets/icons/fil@2x.png', false, 26, true),
  ('ETC', 'Ethereum Classic', 'https://assets.coincap.io/assets/icons/etc@2x.png', false, 27, true),
  ('XLM', 'Stellar', 'https://assets.coincap.io/assets/icons/xlm@2x.png', false, 28, true),
  ('HBAR', 'Hedera', 'https://assets.coincap.io/assets/icons/hbar@2x.png', false, 29, true),
  ('AAVE', 'Aave', 'https://assets.coincap.io/assets/icons/aave@2x.png', false, 30, true),
  ('MKR', 'Maker', 'https://assets.coincap.io/assets/icons/mkr@2x.png', false, 31, true),
  ('XMR', 'Monero', 'https://assets.coincap.io/assets/icons/xmr@2x.png', false, 32, true),
  ('STX', 'Stacks', 'https://assets.coincap.io/assets/icons/stx@2x.png', false, 33, true),
  ('GRT', 'The Graph', 'https://assets.coincap.io/assets/icons/grt@2x.png', false, 34, true),
  ('SAND', 'The Sandbox', 'https://assets.coincap.io/assets/icons/sand@2x.png', false, 35, true),
  ('MANA', 'Decentraland', 'https://assets.coincap.io/assets/icons/mana@2x.png', false, 36, true),
  ('AXS', 'Axie Infinity', 'https://assets.coincap.io/assets/icons/axs@2x.png', false, 37, true),
  ('THETA', 'Theta Network', 'https://assets.coincap.io/assets/icons/theta@2x.png', false, 38, true),
  ('XTZ', 'Tezos', 'https://assets.coincap.io/assets/icons/xtz@2x.png', false, 39, true),
  ('EOS', 'EOS', 'https://assets.coincap.io/assets/icons/eos@2x.png', false, 40, true),
  ('ZEC', 'Zcash', 'https://assets.coincap.io/assets/icons/zec@2x.png', false, 41, true),
  ('DASH', 'Dash', 'https://assets.coincap.io/assets/icons/dash@2x.png', false, 42, true),
  ('NEO', 'NEO', 'https://assets.coincap.io/assets/icons/neo@2x.png', false, 43, true),
  ('IOTA', 'IOTA', 'https://assets.coincap.io/assets/icons/miota@2x.png', false, 44, true),
  ('CAKE', 'PancakeSwap', 'https://assets.coincap.io/assets/icons/cake@2x.png', false, 45, true),
  ('CRV', 'Curve', 'https://assets.coincap.io/assets/icons/crv@2x.png', false, 46, true),
  ('SNX', 'Synthetix', 'https://assets.coincap.io/assets/icons/snx@2x.png', false, 47, true),
  ('COMP', 'Compound', 'https://assets.coincap.io/assets/icons/comp@2x.png', false, 48, true),
  ('SUSHI', 'SushiSwap', 'https://assets.coincap.io/assets/icons/sushi@2x.png', false, 49, true),
  ('BAT', 'Basic Attention Token', 'https://assets.coincap.io/assets/icons/bat@2x.png', false, 50, true),
  ('ENJ', 'Enjin Coin', 'https://assets.coincap.io/assets/icons/enj@2x.png', false, 51, true),
  ('CHZ', 'Chiliz', 'https://assets.coincap.io/assets/icons/chz@2x.png', false, 52, true),
  ('ZIL', 'Zilliqa', 'https://assets.coincap.io/assets/icons/zil@2x.png', false, 53, true),
  ('1INCH', '1inch', 'https://assets.coincap.io/assets/icons/1inch@2x.png', false, 54, true),
  ('LRC', 'Loopring', 'https://assets.coincap.io/assets/icons/lrc@2x.png', false, 55, true),
  ('IMX', 'Immutable X', 'https://assets.coincap.io/assets/icons/imx@2x.png', false, 56, true)
ON CONFLICT (symbol) DO UPDATE SET
  icon_url = EXCLUDED.icon_url,
  name = EXCLUDED.name;

-- Add more networks for popular coins

-- XRP networks
INSERT INTO supported_networks (coin_id, network_name, network_code, chain_id, contract_address, min_deposit, min_withdrawal, withdrawal_fee, confirmations_required, estimated_arrival_minutes, is_mainnet, sort_order)
SELECT 
  id,
  'Ripple',
  'XRP',
  NULL,
  NULL,
  1,
  1,
  0.25,
  1,
  1,
  true,
  1
FROM supported_coins WHERE symbol = 'XRP'
ON CONFLICT (coin_id, network_code) DO NOTHING;

-- ADA networks
INSERT INTO supported_networks (coin_id, network_name, network_code, chain_id, contract_address, min_deposit, min_withdrawal, withdrawal_fee, confirmations_required, estimated_arrival_minutes, is_mainnet, sort_order)
SELECT 
  id,
  'Cardano',
  'ADA',
  NULL,
  NULL,
  1,
  1,
  1,
  15,
  5,
  true,
  1
FROM supported_coins WHERE symbol = 'ADA'
ON CONFLICT (coin_id, network_code) DO NOTHING;

-- DOGE networks
INSERT INTO supported_networks (coin_id, network_name, network_code, chain_id, contract_address, min_deposit, min_withdrawal, withdrawal_fee, confirmations_required, estimated_arrival_minutes, is_mainnet, sort_order)
SELECT 
  id,
  'Dogecoin',
  'DOGE',
  NULL,
  NULL,
  1,
  1,
  5,
  6,
  5,
  true,
  1
FROM supported_coins WHERE symbol = 'DOGE'
ON CONFLICT (coin_id, network_code) DO NOTHING;

-- Add USDC on multiple networks
INSERT INTO supported_networks (coin_id, network_name, network_code, chain_id, contract_address, min_deposit, min_withdrawal, withdrawal_fee, confirmations_required, estimated_arrival_minutes, is_mainnet, sort_order)
SELECT 
  id,
  'Ethereum',
  'ERC20',
  '1',
  '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
  0.01,
  0.01,
  5,
  12,
  5,
  true,
  1
FROM supported_coins WHERE symbol = 'USDC'
ON CONFLICT (coin_id, network_code) DO NOTHING;

INSERT INTO supported_networks (coin_id, network_name, network_code, chain_id, contract_address, min_deposit, min_withdrawal, withdrawal_fee, confirmations_required, estimated_arrival_minutes, is_mainnet, sort_order)
SELECT 
  id,
  'BSC',
  'BEP20',
  '56',
  '0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d',
  0.01,
  0.01,
  0.8,
  1,
  1,
  true,
  2
FROM supported_coins WHERE symbol = 'USDC'
ON CONFLICT (coin_id, network_code) DO NOTHING;

INSERT INTO supported_networks (coin_id, network_name, network_code, chain_id, contract_address, min_deposit, min_withdrawal, withdrawal_fee, confirmations_required, estimated_arrival_minutes, is_mainnet, sort_order)
SELECT 
  id,
  'Polygon',
  'Polygon',
  '137',
  '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174',
  0.01,
  0.01,
  0.5,
  1,
  2,
  true,
  3
FROM supported_coins WHERE symbol = 'USDC'
ON CONFLICT (coin_id, network_code) DO NOTHING;

-- Add SOL network
INSERT INTO supported_networks (coin_id, network_name, network_code, chain_id, contract_address, min_deposit, min_withdrawal, withdrawal_fee, confirmations_required, estimated_arrival_minutes, is_mainnet, sort_order)
SELECT 
  id,
  'Solana',
  'SOL',
  NULL,
  NULL,
  0.01,
  0.01,
  0.008,
  1,
  1,
  true,
  1
FROM supported_coins WHERE symbol = 'SOL'
ON CONFLICT (coin_id, network_code) DO NOTHING;

-- Add MATIC on Polygon network
INSERT INTO supported_networks (coin_id, network_name, network_code, chain_id, contract_address, min_deposit, min_withdrawal, withdrawal_fee, confirmations_required, estimated_arrival_minutes, is_mainnet, sort_order)
SELECT 
  id,
  'Polygon',
  'Polygon',
  '137',
  NULL,
  0.1,
  0.1,
  0.01,
  1,
  2,
  true,
  1
FROM supported_coins WHERE symbol = 'MATIC'
ON CONFLICT (coin_id, network_code) DO NOTHING;