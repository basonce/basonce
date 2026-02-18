# ⚡ Hızlı Kullanım - Cüzdan Oluşturma

## 🚀 3 Adımda Cüzdan Havuzu Oluşturma

### 1️⃣ Cüzdanları Oluştur

Terminalden bu komutlardan birini çalıştır:

```bash
# 10 adet karışık cüzdan (5 BEP20 + 5 TRC20)
npm run generate:wallets

# 20 adet BEP20 cüzdan
npm run generate:bep20

# 20 adet TRC20 cüzdan
npm run generate:trc20

# Veya istediğiniz sayıda:
node generate-wallets-bulk.js 100 BOTH
```

### 2️⃣ Çıktıyı Kopyala

Script çalıştıktan sonra ekranda **"TOPLU EKLEME İÇİN FORMAT"** yazısını göreceksiniz.

Onun altındaki satırları kopyalayın:

```
BEP20, 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb, 0xac097...
TRC20, T9yD14Nj9j7xAB4dbGeiX9h8unkKHxuWwb, 0x59c69...
BEP20, 0x1234567890123456789012345678901234567890, 0x12345...
...
```

### 3️⃣ Admin Paneline Ekle

1. Uygulamayı aç ve Admin Dashboard'a git
2. **"Cüzdan Havuzu Yönetimi"** sekmesine tıkla
3. **"Toplu Ekle"** butonuna tıkla
4. Kopyaladığın metni yapıştır
5. **"Toplu Ekle"** butonuna bas

**✅ Bitti! Cüzdanlar sisteme eklendi.**

---

## 📊 Ne Kadar Cüzdan Oluşturmalıyım?

- **Test için:** 10-20 cüzdan yeterli
- **Küçük platform:** 100-500 cüzdan
- **Orta platform:** 1000-2000 cüzdan
- **Büyük platform:** 5000+ cüzdan

---

## 🔐 Güvenlik - MUTLAKA OKUYUN!

### ⚠️ SAKLAYIN:
- Private key'leri güvenli bir yere kaydedin
- Asla GitHub'a yüklemeyin
- Şifreli bir dosyada tutun

### ⚠️ DİKKAT:
- **BEP20 adresi:** `0x` ile başlar (42 karakter)
- **TRC20 adresi:** `T` ile başlar (34 karakter)
- **Yanlış ağa para gönderirseniz kaybolur!**

---

## 🎯 Master Cüzdan (Toplu Para İçin)

Master cüzdan oluşturmak için:

```bash
npm run generate:master
```

Bu cüzdan **TÜM kullanıcılardan gelen paraların toplandığı ana cüzdan**.

**Çok önemli:** Bu cüzdanın private key'ini çok güvenli tutun!

---

## 📝 Örnek Kullanım

```bash
# 50 karışık cüzdan oluştur
node generate-wallets-bulk.js 50 BOTH

# Çıktıyı kopyala (TOPLU EKLEME İÇİN FORMAT kısmını)

# Admin panelinde Toplu Ekle'ye yapıştır

# Sisteme eklenen cüzdanları görüntüle
# Admin > Cüzdan Havuzu Yönetimi
```

---

## 💡 İpuçları

1. **İlk test:** Önce 5-10 cüzdan oluştur, test et
2. **Gerçek para:** Test başarılıysa daha fazla oluştur
3. **Yedekleme:** Tüm cüzdan bilgilerini yedekle
4. **Monitoring:** Admin panelden istatistikleri takip et

---

## 🆘 Sorun mu Yaşıyorsun?

### Adres formatı hatalı diyor?

- BEP20: `0x` ile başlamalı
- TRC20: `T` ile başlamalı
- Uzunluklara dikkat et (BEP20: 42, TRC20: 34)

### Private key hatası?

- Private key opsiyonel, boş bırakabilirsiniz
- Otomatik withdrawal için gerekli
- Manuel withdrawal yapacaksanız gerek yok

### Cüzdanlar görünmüyor?

- Sayfayı yenile (F5)
- Admin girişi yaptığınızdan emin ol
- Browser console'da hata var mı kontrol et

---

**✨ Kolay gelsin!**
