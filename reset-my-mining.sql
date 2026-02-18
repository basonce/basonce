-- Reset Mining Equipment to Test Real User Experience
-- This will delete all your mining equipment and let you start fresh

-- Step 1: Check current equipment
SELECT
  id,
  equipment_type_id,
  (SELECT name FROM mining_equipment_types WHERE id = equipment_type_id) as equipment_name,
  total_earned_usdt,
  session_earned_usdt,
  status
FROM user_mining_equipment
WHERE user_id = auth.uid();

-- Step 2: Delete all equipment (uncomment to execute)
-- DELETE FROM user_mining_equipment WHERE user_id = auth.uid();

-- Step 3: System will automatically give you FREE CPU Miner on next login

-- Note: This does NOT reset your USDT balance
-- If you want to reset balance too, uncomment below:
-- UPDATE user_balances SET available = 0, locked = 0 WHERE user_id = auth.uid() AND coin_symbol = 'USDT';
