/*
  # Enable All Coins for Futures Trading

  1. Changes
    - Enable `is_futures_enabled` for all active coins except stablecoins (USDT, USDC)
    - This allows all coins to appear in the Futures market selector

  2. Affected Tables
    - `supported_coins`: Updated `is_futures_enabled` column

  3. Notes
    - USDT and USDC remain excluded as they are stablecoins and cannot be traded against themselves
    - All other active coins will now be available for perpetual futures trading
*/

UPDATE supported_coins
SET is_futures_enabled = true
WHERE is_active = true
  AND symbol NOT IN ('USDT', 'USDC')
  AND is_futures_enabled = false;
