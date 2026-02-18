# 📱 MANUEL CÜZDAN SİSTEMİ - KULLANIM KILAVUZU

## Neden Manuel Sistem?

Başlangıçta fazla kullanıcı olmayacağı için 100,000 cüzdan oluşturmak gereksiz. Bu sistemle:

✅ **Kontrollü Başlangıç**: Sadece ihtiyaç kadar cüzdan eklersiniz
✅ **Kolay Yönetim**: Her şey admin panelden tek tıkla
✅ **Esnek**: İstediğiniz zaman toplu veya tek tek ekleyebilirsiniz
✅ **Güvenli**: Cüzdanları Trust Wallet veya başka bir yerde oluşturun, sadece adresi ekleyin

---

## 🚀 HIZLI BAŞLANGIÇ

### 1. Admin Panele Giriş

1. Admin hesabıyla giriş yapın
2. Sağ üst köşeden **Admin Dashboard** tıklayın
3. **"Wallet Pool"** tab'ına geçin

### 2. İlk Cüzdanınızı Ekleyin

**Tek Cüzdan Ekleme:**
1. **"Cüzdan Ekle"** butonuna tıklayın
2. Network seçin (BEP-20 veya TRC-20)
3. Cüzdan adresini girin
4. Private key **opsiyonel** (boş bırakabilirsiniz)
5. **"Ekle"** butonuna tıklayın

**Örnek:**
```
Network: BEP-20
Address: 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
Private Key: (boş bırakın veya girin)
```

### 3. Toplu Cüzdan Ekleme

Birden fazla cüzdanı tek seferde eklemek için:

1. **"Toplu Ekle"** butonuna tıklayın
2. Her satıra bir cüzdan, bu formatta:
   ```
   NETWORK, ADDRESS
   ```
3. Örnek:
   ```
   BEP20, 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
   TRC20, TYASr5UV6HEcXatwdFQfmLVUqQQQMUxHLS
   BEP20, 0x8ba1f109551bD432803012645Ac136ddd64DBA72
   TRC20, TMuA6YqfCeX8EhbfYEg5y7S4DqzSJireY9
   ```
4. **"Toplu Ekle"** butonuna tıklayın

---

## 💰 CÜZDAN OLUŞTURMA (Trust Wallet ile)

### BEP-20 Cüzdan Oluşturma:

1. **Trust Wallet** uygulamasını açın
2. **Receive** → **Smart Chain (BNB)** seçin
3. Adresi kopyalayın (0x ile başlar)
4. Admin panele bu adresi ekleyin

### TRC-20 Cüzdan Oluşturma:

1. **Trust Wallet** uygulamasını açın
2. **Receive** → **TRON (TRX)** seçin
3. Adresi kopyalayın (T ile başlar)
4. Admin panele bu adresi ekleyin

### MetaMask ile de yapabilirsiniz:

1. MetaMask'te **yeni hesap** oluşturun
2. Adresi kopyalayın
3. Admin panele ekleyin

---

## 🔄 KULLANICI ATAMASI (Otomatik)

Sistem otomatik çalışıyor! Yeni kullanıcı kayıt olunca:

1. ✅ Database'den boş bir BEP-20 cüzdan atanır
2. ✅ Database'den boş bir TRC-20 cüzdan atanır
3. ✅ Kullanıcı deposit sayfasında kendi adreslerini görür

**Siz hiçbir şey yapmanıza gerek yok - otomatik!**

---

## 💵 DEPOSIT İŞLEMLERİ

### Adım 1: Blockchain'de Kontrol

Kullanıcı para gönderdiğinde:

1. **BSCScan** (BEP-20 için): https://bscscan.com
2. **TronScan** (TRC-20 için): https://tronscan.org
3. Kullanıcının deposit adresini arayın
4. İşlemin (TX) onaylandığını görün

### Adım 2: Manuel Güncelleme

1. Admin Dashboard → **"Deposits"** tab'ına gidin
2. Kullanıcıyı bulun (email veya ID ile ara)
3. **"Bakiye Ekle"** butonuna tıklayın
4. Formu doldurun:
   - **Coin**: USDT (veya başka)
   - **Miktar**: 100.00
   - **Not**: TX hash ekleyin (isteğe bağlı)
5. **"Bakiye Ekle"** butonuna tıklayın

**ÖRNEK:**
```
Kullanıcı: john@example.com
Coin: USDT
Miktar: 500.00
Not: BscScan TX: 0x1234abcd... (Onaylı)
```

### Adım 3: Kullanıcı Bakiyesini Görür

Kullanıcı sayfayı yenilediğinde yeni bakiyesini görür!

---

## 🔍 CÜZDAN YÖNETİMİ

### Cüzdanları Görüntüleme

**Admin Dashboard → Wallet Pool** tab'ında:

- 📊 **İstatistikler**: Toplam, Atanmış, Boşta
- 🔑 **Master Wallets**: Ana cüzdanlar
- 📋 **Tüm Cüzdanlar**: Detaylı liste

### Cüzdan Silme

Sadece **atanmamış** cüzdanlar silinebilir:

1. Cüzdan listesinde çöp kutusu ikonu
2. Onay ver
3. Silindi!

**NOT:** Kullanıcıya atanmış cüzdanlar silinemez (güvenlik için)

---

## 📊 İSTATİSTİKLER

Admin panelde görebileceğiniz bilgiler:

### Genel İstatistikler:
- **Toplam Cüzdan**: Kaç tane cüzdan eklediniz
- **Atanmış**: Kaç kullanıcıya verildi
- **Boşta**: Kaç cüzdan hazır bekliyor
- **BEP-20**: BSC network cüzdan sayısı
- **TRC-20**: TRON network cüzdan sayısı

### Master Wallet:
- **Current Balance**: Şu an master wallet'ta ne kadar para var
- **Total Collected**: Toplam ne kadar para toplandı

---

## ⚠️ ÖNEMLİ NOTLAR

### 1. Private Key Hakkında

- **Opsiyonel**: Sistemde private key saklamanız gerekmez
- **Manuel işlemler için**: Sadece adresi ekleyin, para Trust Wallet'tan manuel gönderin
- **Otomatik sistemler için**: Private key gerekli (ileride)

### 2. Master Wallet

Master wallet'a **manuel** para gönderebilirsiniz:

- Withdrawal işlemleri için
- Tüm para toplanacak yer
- **BNB/TRX bakiyesi olmalı** (gas fee için)

### 3. Güvenlik

- ✅ Cüzdanları güvenli yerde oluşturun (Trust Wallet, MetaMask)
- ✅ Private keyleri **asla** paylaşmayın
- ✅ Master wallet'ı **özel** bir yerde saklayın
- ✅ Admin hesabına 2FA ekleyin

### 4. Bakiye Güncellerken

- ✅ **Mutlaka** blockchain'de TX kontrol edin
- ✅ İşlem onaylanmadan bakiye eklemeyin
- ✅ Not kısmına TX hash yazın (kayıt için)
- ✅ Miktarı doğru girin (kopyala-yapıştır)

---

## 📝 ÖRNEK SENARYOLAR

### Senaryo 1: İlk 10 Kullanıcı

1. Trust Wallet'ta 10 BEP-20 cüzdan oluştur
2. Trust Wallet'ta 10 TRC-20 cüzdan oluştur
3. Admin panelden "Toplu Ekle" ile hepsini ekle
4. Kullanıcılar kayıt olsun - otomatik atanır!

### Senaryo 2: Kullanıcı Deposit Yaptı

1. Kullanıcı: "100 USDT gönderdim"
2. BscScan'de kontrol et: ✅ Onaylandı
3. Admin → Deposits → Kullanıcıyı bul
4. Bakiye Ekle: 100 USDT
5. Not: "TX: 0x1234..."
6. Ekle!

### Senaryo 3: Daha Fazla Cüzdan Lazım

1. Trust Wallet'ta 20 yeni cüzdan oluştur
2. Excel'de listeyi hazırla:
   ```
   BEP20, 0xAddress1
   TRC20, TAddress1
   BEP20, 0xAddress2
   TRC20, TAddress2
   ...
   ```
3. Kopyala → Admin panel → Toplu Ekle → Yapıştır
4. Ekle - Bitti!

---

## 🎯 AVANTAJLAR

### Manual sistem ile:

✅ **Başlangıç hızlı**: 5 dakikada hazır
✅ **Kontrollü büyüme**: İhtiyaç kadar cüzdan
✅ **Kolay yönetim**: UI'dan her şey yapılır
✅ **Güvenli**: Cüzdanlar sizin kontrolünüzde
✅ **Esnek**: Trust Wallet, MetaMask, vs. kullanabilirsiniz
✅ **Şeffaf**: Her işlemi blockchain'de görürsünüz

---

## 🔮 İLERİDE OTOMATİK SİSTEME GEÇİŞ

Kullanıcı sayısı arttığında otomatik sisteme geçebilirsiniz:

1. `generate-100k-wallets.js` çalıştırın
2. 100,000 cüzdan otomatik oluşur
3. Deposit monitoring edge function aktif edin
4. Artık her şey otomatik!

**Mevcut manuel cüzdanlar silinmez - devam eder!**

---

## ❓ SSS

**S: Kaç cüzdan eklemeliyim?**
A: Beklediğiniz kullanıcı sayısı x 2 (her kullanıcı BEP20 + TRC20)

**S: Private key eklemek zorunda mıyım?**
A: Hayır! Manuel işlemler için adres yeterli.

**S: Master wallet ne?**
A: Tüm paranın toplandığı ana cüzdan. Withdrawal buradan yapılır.

**S: Deposit ne zaman onaylanır?**
A: Blockchain'de onaylandıktan sonra siz manuel eklersiniz.

**S: Otomatik deposit izleme var mı?**
A: Şu an manuel. İleride edge function ile otomatik yapılabilir.

**S: Withdrawal nasıl yapılır?**
A: Manuel olarak master wallet'tan kullanıcı adresine gönderin. Admin panelde yakında otomatik olacak.

**S: Cüzdan silersem ne olur?**
A: Sadece atanmamış cüzdanları silebilirsiniz. Kullanıcıya atanmış cüzdan silinemez.

**S: Toplu eklerken hata aldım?**
A: Format kontrolü yapın. Her satır: `NETWORK, ADDRESS` şeklinde olmalı.

---

## 🎓 ÖZET

1. ✅ Admin Panel → Wallet Pool
2. ✅ "Cüzdan Ekle" veya "Toplu Ekle"
3. ✅ Kullanıcılar kayıt olunca otomatik atanır
4. ✅ Deposit gelince blockchain'de kontrol et
5. ✅ Admin → Deposits → Manuel bakiye ekle
6. ✅ Kullanıcı mutlu!

**Başarılar!** 🚀

Sorularınız için: Dokümantasyona bakın veya support@yourapp.com
