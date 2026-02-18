-- 💰 MASTER WALLET KURULUMU
-- Bu SQL'i Supabase SQL Editor'de çalıştırın

-- Yukarıdaki generate-wallet.js çıktısındaki değerleri buraya yapıştırın:
-- SİZİN GERÇEK BİLGİLERİNİZİ KULLANIN!

-- BSC Mainnet için Master Wallet
INSERT INTO hot_wallet_config (
  network,
  currency,
  address,
  private_key_encrypted,
  balance,
  min_balance_threshold,
  is_active
) VALUES (
  'bsc',
  'BNB',
  'BURAYA_SIZIN_CUZDAN_ADRESINIZI_YAPISTIN',  -- Örnek: 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb2
  'BURAYA_ENCRYPTED_KEY_YAPISTIN',            -- Örnek: MHhhYzA5NzRiZWMz...
  0,
  0.1,  -- 0.1 BNB'nin altına düşerse uyarı
  true
);

-- Polygon Mainnet için (isteğe bağlı)
INSERT INTO hot_wallet_config (
  network,
  currency,
  address,
  private_key_encrypted,
  balance,
  min_balance_threshold,
  is_active
) VALUES (
  'polygon',
  'MATIC',
  'BURAYA_SIZIN_CUZDAN_ADRESINIZI_YAPISTIN',  -- Aynı adres kullanılabilir
  'BURAYA_ENCRYPTED_KEY_YAPISTIN',
  0,
  10,   -- 10 MATIC'in altına düşerse uyarı
  true
);

-- ✅ KONTROL EDIN
SELECT
  network,
  currency,
  address,
  balance,
  is_active
FROM hot_wallet_config;
