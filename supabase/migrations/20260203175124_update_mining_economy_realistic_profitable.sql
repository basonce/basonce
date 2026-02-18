/*
  # Gerçekçi ve Sürdürülebilir Mining Ekonomisi

  1. Değişiklikler
    - Mining kazançları gerçekçi seviyelere ayarlandı
    - ROI süreleri: 8-21 gün (Binance benzeri)
    - Kullanıcılara hala cazip ama platform için sürdürülebilir
    - Elektrik maliyetleri kaldırıldı (basitlik için)

  2. Yeni Ekonomi Modeli
    **FREE Starter:**
    - 0.0002 EQ/saat = 0.0048 EQ/gün = 0.144 EQ/ay
    - Değer: ~$0.036/ay (ortalama EQ fiyatı $0.25)
    
    **GPU Rig (1 EQ):**
    - 0.002 EQ/saat = 0.048 EQ/gün
    - ROI: 21 gün
    - Aylık: 1.44 EQ = ~$0.36
    
    **ASIC Miner (5 EQ):**
    - 0.012 EQ/saat = 0.288 EQ/gün
    - ROI: 17 gün
    - Aylık: 8.64 EQ = ~$2.16
    
    **Mining Container (20 EQ):**
    - 0.06 EQ/saat = 1.44 EQ/gün
    - ROI: 14 gün
    - Aylık: 43.2 EQ = ~$10.80
    
    **Industrial Farm (80 EQ):**
    - 0.3 EQ/saat = 7.2 EQ/gün
    - ROI: 11 gün
    - Aylık: 216 EQ = ~$54
    
    **Quantum Rig (400 EQ):**
    - 2 EQ/saat = 48 EQ/gün
    - ROI: 8.3 gün
    - Aylık: 1440 EQ = ~$360

  3. Sürdürülebilirlik
    - 1000 kullanıcı senaryosu:
      - 900 free: 4.32 EQ/gün = ~$1.08/gün
      - 100 paid (ortalama): ~1000 EQ/gün = ~$250/gün
    - Platform trading fee'leriyle karşılanabilir
    - Withdrawal limitleriyle kontrol edilebilir

  4. Notlar
    - Elektrik maliyeti kaldırıldı (kullanıcı deneyimi basitleşti)
    - ROI süreleri gerçekçi (Binance: 7-30 gün)
    - Yüksek yatırım yapanlar hızlı kazanıyor (teşvik)
*/

-- Update equipment earning rates
UPDATE mining_equipment_types SET 
  earning_rate = 0.0002,
  electricity_cost = 0,
  description = 'Free starter equipment - Start mining immediately!'
WHERE is_starter = true;

UPDATE mining_equipment_types SET 
  earning_rate = 0.002,
  electricity_cost = 0,
  description = 'GPU Mining Rig - Steady passive income (ROI: 21 days)'
WHERE name = 'GPU Mining Rig';

UPDATE mining_equipment_types SET 
  earning_rate = 0.012,
  electricity_cost = 0,
  description = 'Professional ASIC miner - Strong returns (ROI: 17 days)'
WHERE name = 'ASIC Miner S19';

UPDATE mining_equipment_types SET 
  earning_rate = 0.06,
  electricity_cost = 0,
  description = 'Industrial container setup - High output (ROI: 14 days)'
WHERE name = 'Mining Container';

UPDATE mining_equipment_types SET 
  earning_rate = 0.3,
  electricity_cost = 0,
  description = 'Complete mining farm - Premium profits (ROI: 11 days)'
WHERE name = 'Industrial Farm';

UPDATE mining_equipment_types SET 
  earning_rate = 2,
  electricity_cost = 0,
  description = 'Next-gen quantum technology - Maximum earnings (ROI: 8 days)'
WHERE name = 'Quantum Mining Rig';

-- Simplified calculation function (no electricity cost)
CREATE OR REPLACE FUNCTION calculate_pending_earnings(p_user_id uuid)
RETURNS numeric AS $$
DECLARE
  total_pending numeric := 0;
  equipment_record RECORD;
  hours_elapsed numeric;
  base_earning numeric;
  boost_multiplier numeric := 1;
BEGIN
  -- Get active boosts
  SELECT COALESCE(SUM(multiplier), 0) INTO boost_multiplier
  FROM mining_boosts
  WHERE user_id = p_user_id
    AND is_active = true
    AND expires_at > now();
  
  IF boost_multiplier = 0 THEN
    boost_multiplier := 1;
  END IF;

  -- Calculate earnings for each equipment
  FOR equipment_record IN
    SELECT 
      ume.id,
      ume.last_claim_at,
      met.earning_rate,
      ume.level
    FROM user_mining_equipment ume
    JOIN mining_equipment_types met ON ume.equipment_type_id = met.id
    WHERE ume.user_id = p_user_id
      AND ume.is_active = true
  LOOP
    -- Calculate hours elapsed since last claim
    hours_elapsed := EXTRACT(EPOCH FROM (now() - equipment_record.last_claim_at)) / 3600.0;
    
    -- Cap at 72 hours max accumulation (3 days)
    IF hours_elapsed > 72 THEN
      hours_elapsed := 72;
    END IF;
    
    -- Base earning with level bonus (5% per level)
    base_earning := equipment_record.earning_rate * (1 + (equipment_record.level - 1) * 0.05);
    
    -- Apply boost
    total_pending := total_pending + (base_earning * hours_elapsed * boost_multiplier);
  END LOOP;

  RETURN GREATEST(total_pending, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;