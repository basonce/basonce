# 🚀 VERCEL DEPLOYMENT GUIDE

Bu proje Vercel'de çalışmaya hazır! Namecheap domain'inizi bağlamak için:

## 📋 ADIM 1: GITHUB'A YÜKLE (5 dakika)

### Yöntem A: GitHub Desktop (Kolay)
1. [GitHub Desktop indir](https://desktop.github.com/)
2. File → Add Local Repository → Bu klasörü seç
3. "Publish repository" butonuna bas
4. ✅ Bitti!

### Yöntem B: Komut Satırı
```bash
# Proje klasöründe:
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/KULLANICI_ADIN/REPO_ADIN.git
git push -u origin main
```

---

## 📋 ADIM 2: VERCEL'E DEPLOY (5 dakika)

1. **Vercel'e Git:** https://vercel.com/signup
   - GitHub ile giriş yap (ÜCRETSİZ)

2. **Yeni Proje Ekle:**
   - "Add New..." → "Project"
   - GitHub repo'nu seç
   - "Import" butonuna bas

3. **Ayarlar (OTOMATIK ALGILAYACAK):**
   - Framework: Vite ✅
   - Build Command: `npm run build` ✅
   - Output Directory: `dist` ✅

4. **Environment Variables Ekle:**
   ```
   VITE_SUPABASE_URL=your_supabase_url
   VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

5. **Deploy butonuna bas!**
   - 2-3 dakika bekle
   - Site canlıya çıktı! 🎉
   - Örnek link: `https://your-project.vercel.app`

---

## 📋 ADIM 3: NAMECHEAP DOMAIN BAĞLA (15 dakika)

### Namecheap'te:

1. **Domain yönetimine git:**
   - Domain List → Domain'ini seç → Manage

2. **Advanced DNS sekmesine git**

3. **Mevcut kayıtları SİL:**
   - Parking page kayıtlarını kaldır

4. **YENİ KAYITLAR EKLE:**

   **A Record:**
   ```
   Type: A Record
   Host: @
   Value: 76.76.21.21
   TTL: Automatic
   ```

   **CNAME Record:**
   ```
   Type: CNAME Record
   Host: www
   Value: cname.vercel-dns.com.
   TTL: Automatic
   ```

### Vercel'de:

1. **Projeye git → Settings → Domains**

2. **Domain ekle:**
   - `yourdomain.com` yaz
   - "Add" butonuna bas

3. **www subdomain ekle:**
   - `www.yourdomain.com` yaz
   - "Add" butonuna bas

4. **SSL Sertifikası:**
   - Otomatik oluşacak (10-20 dakika)
   - ✅ HTTPS hazır!

---

## ✅ TAMAMLANDI!

Site şu adreslerden erişilebilir:
- ✅ `https://yourdomain.com`
- ✅ `https://www.yourdomain.com`
- ✅ `https://your-project.vercel.app` (yedek link)

---

## 🔄 OTOMATIK DEPLOY

Her GitHub'a kod yüklediğinde:
- ✅ Vercel otomatik deploy yapar
- ✅ 2-3 dakikada canlıya çıkar
- ✅ Hata varsa e-posta ile bildirim gelir

---

## 🎯 HER DEĞİŞİKLİKTE:

```bash
git add .
git commit -m "Update yapıldı"
git push
```

Vercel otomatik algılar ve deploy eder! 🚀

---

## 📞 SORUN ÇIKARSA:

1. **Build hatası:** Vercel dashboard'da "Deployments" → Logs
2. **Domain çalışmıyor:** DNS propagation (24 saate kadar sürebilir)
3. **SSL hatası:** 10-20 dakika bekle, otomatik halleder

---

## 💡 NAMECHEAP STELLAR PLUS NE OLACAK?

- Domain için DNS kullanmaya devam edeceksin
- Hosting (Stellar Plus) kullanmayacaksın
- Para zarar etmez, başka projeler için kullanabilirsin
- Vercel çok daha hızlı ve profesyonel!
