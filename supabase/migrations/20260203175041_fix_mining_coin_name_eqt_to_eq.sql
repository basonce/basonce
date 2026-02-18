/*
  # Mining Coin Adını Düzelt: EQT → EQ

  1. Değişiklikler
    - Tüm sistemde coin adı "EQ" olacak (EQT değil)
    - claim_mining_earnings fonksiyonunu güncelle
    - Tutarlılık sağla

  2. Güvenlik
    - RLS politikaları değişmedi
    - Sadece coin adı düzeltmesi

  3. Notlar
    - EarnQuest token'ın resmi adı: EQ
    - Tüm sistemde standart hale getiriliyor
*/

-- Update claim function to use 'EQ' instead of 'EQT'
CREATE OR REPLACE FUNCTION claim_mining_earnings(p_user_id uuid)
RETURNS numeric AS $$
DECLARE
  pending_amount numeric;
  equipment_record RECORD;
BEGIN
  -- Calculate total pending
  pending_amount := calculate_pending_earnings(p_user_id);
  
  IF pending_amount <= 0 THEN
    RETURN 0;
  END IF;

  -- Update user balance (use 'EQ' not 'EQT')
  UPDATE user_balances
  SET balance = balance + pending_amount,
      updated_at = now()
  WHERE user_id = p_user_id
    AND coin = 'EQ';

  -- If EQ balance doesn't exist, create it
  IF NOT FOUND THEN
    INSERT INTO user_balances (user_id, coin, balance)
    VALUES (p_user_id, 'EQ', pending_amount);
  END IF;

  -- Record earnings
  INSERT INTO mining_earnings (user_id, amount, earning_type, claimed, claimed_at)
  VALUES (p_user_id, pending_amount, 'mining', true, now());

  -- Update last_claim_at for all equipment
  UPDATE user_mining_equipment
  SET last_claim_at = now(),
      total_earned = total_earned + pending_amount
  WHERE user_id = p_user_id
    AND is_active = true;

  -- Update daily stats
  INSERT INTO mining_stats (user_id, stat_date, total_earned, total_claimed)
  VALUES (p_user_id, CURRENT_DATE, pending_amount, pending_amount)
  ON CONFLICT (user_id, stat_date)
  DO UPDATE SET
    total_earned = mining_stats.total_earned + EXCLUDED.total_earned,
    total_claimed = mining_stats.total_claimed + EXCLUDED.total_claimed;

  RETURN pending_amount;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;