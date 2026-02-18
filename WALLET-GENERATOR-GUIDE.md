# 🔐 Cüzdan Havuzu için Adres Oluşturma Rehberi

Bu rehber, Wallet Pool Management sistemine eklemek için cüzdan adresleri oluşturmanıza yardımcı olur.

## 📋 İçindekiler

1. [Hızlı Başlangıç](#hızlı-başlangıç)
2. [Toplu BEP20 + TRC20 Cüzdan Oluşturma](#toplu-bep20--trc20-cüzdan-oluşturma)
3. [Sadece BEP20 Cüzdanlar](#sadece-bep20-cüzdanlar)
4. [Sadece TRC20 Cüzdanlar](#sadece-trc20-cüzdanlar)
5. [Manuel Cüzdan Ekleme](#manuel-cüzdan-ekleme)
6. [Güvenlik Uyarıları](#güvenlik-uyarıları)

---

## 🚀 Hızlı Başlangıç

### 1. Toplu Cüzdan Oluşturma (Önerilen)

```bash
# 10 adet karışık (BEP20 + TRC20) cüzdan oluştur
node generate-wallets-bulk.js 10 BOTH

# 20 adet sadece BEP20 cüzdan oluştur
node generate-wallets-bulk.js 20 BEP20

# 15 adet sadece TRC20 cüzdan oluştur
node generate-wallets-bulk.js 15 TRC20
```

### 2. Çıktıyı Kopyalayın

Script çalıştıktan sonra **"TOPLU EKLEME İÇİN FORMAT"** bölümünü kopyalayın:

```
BEP20, 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb, 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
TRC20, T9yD14Nj9j7xAB4dbGeiX9h8unkKHxuWwb, 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
...
```

### 3. Admin Paneline Ekleyin

1. Admin Dashboard'a gidin
2. **"Cüzdan Havuzu Yönetimi"** sekmesine tıklayın
3. **"Toplu Ekle"** butonuna tıklayın
4. Kopyaladığınız metni yapıştırın
5. **"Toplu Ekle"** butonuna basın

---

## 📦 Detaylı Kullanım

### Toplu BEP20 + TRC20 Cüzdan Oluşturma

```bash
node generate-wallets-bulk.js 50 BOTH
```

Bu komut:
- 50 adet cüzdan oluşturur (25 BEP20 + 25 TRC20)
- Her cüzdan için private key üretir
- Toplu ekleme formatında çıktı verir

### Sadece BEP20 Cüzdanlar

```bash
node generate-wallets-bulk.js 100 BEP20
```

Bu komut:
- 100 adet BEP20 (BSC) cüzdan oluşturur
- Ethereum uyumlu adresler (0x ile başlar)
- 42 karakter uzunluğunda

**Format Örneği:**
```
BEP20, 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb, 0xac0974bec39...
```

### Sadece TRC20 Cüzdanlar

```bash
node generate-tron-wallets.js 50
```

Bu komut:
- 50 adet TRC20 (TRON) cüzdan oluşturur
- T ile başlayan adresler
- 34 karakter uzunluğunda

**Format Örneği:**
```
TRC20, T9yD14Nj9j7xAB4dbGeiX9h8unkKHxuWwb, 0x59c6995e998f...
```

---

## 🖊️ Manuel Cüzdan Ekleme

### Admin Panelden Tek Tek Ekleme:

1. **"Cüzdan Ekle"** butonuna tıklayın
2. Network seçin (BEP20 veya TRC20)
3. Cüzdan adresini girin
4. Private key'i girin (opsiyonel)
5. **"Ekle"** butonuna basın

### Mevcut Cüzdanlarınızı Kullanma:

Eğer zaten cüzdanlarınız varsa:

```bash
# Metamask, Trust Wallet, vb. dan adresinizi alın
# Format:
BEP20, YOUR_ADDRESS, YOUR_PRIVATE_KEY
TRC20, YOUR_TRON_ADDRESS, YOUR_PRIVATE_KEY
```

---

## 🔒 Güvenlik Uyarıları

### ⚠️ MUTLAKA YAPMANIZ GEREKENLER:

1. **Private Key'leri GÜVENLİ Tutun**
   - Asla GitHub'a yüklemeyin
   - Asla kimseyle paylaşmayın
   - Şifreli bir yerde saklayın

2. **Test Önce, Gerçek Para Sonra**
   - İlk önce küçük miktarlar ile test edin
   - Cüzdan adreslerini doğrulayın
   - Network'leri karıştırmayın

3. **Yedekleme**
   - Tüm cüzdan bilgilerini yedekleyin
   - Private key'leri offline saklayın
   - Master cüzdanınızı özellikle koruyun

4. **Adres Formatları**
   - BEP20: `0x` ile başlar, 42 karakter
   - TRC20: `T` ile başlar, 34 karakter
   - ❌ **Yanlış ağa para gönderirseniz kaybolur!**

---

## 🛠️ Gerçek Üretim İçin TRON Cüzdanları

Gerçek TRON cüzdanları için TronWeb kullanın:

```bash
npm install tronweb
```

```javascript
const TronWeb = require('tronweb');
const account = TronWeb.utils.accounts.generateAccount();

console.log('Adres:', account.address.base58);
console.log('Private Key:', account.privateKey);
```

---

## 📊 Cüzdan Havuzu İstatistikleri

Admin panelinde görebileceğiniz bilgiler:

- 📦 Toplam Cüzdan Sayısı
- ✅ Atanmış Cüzdanlar
- ⏳ Boşta Bekleyen Cüzdanlar
- 🟠 BEP20 Cüzdan Sayısı
- 🔴 TRC20 Cüzdan Sayısı

---

## 🆘 Sık Sorulan Sorular

### Kaç cüzdan oluşturmalıyım?

- Küçük platform: 50-100 cüzdan
- Orta platform: 500-1000 cüzdan
- Büyük platform: 5000+ cüzdan

### Private key olmadan çalışır mı?

Evet, ancak:
- ✅ Deposit (yatırma) çalışır
- ❌ Otomatik withdrawal çalışmaz
- 🔧 Manuel withdrawal yapmanız gerekir

### Cüzdanlar nasıl kullanıcılara atanır?

- Kullanıcı ilk kez deposit yaparken
- Otomatik olarak boş cüzdan atanır
- Her kullanıcıya özel cüzdan

---

## 📞 Destek

Sorun yaşarsanız:
1. Adres formatlarını kontrol edin
2. Network'ü doğru seçtiğinizden emin olun
3. Private key'lerin doğru kopyalandığını kontrol edin

---

**✨ Başarılar!**
