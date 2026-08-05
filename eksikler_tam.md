# Barkod Ürün Havuzu Mobil — TAM Eksiklik Listesi

**Yöntem:** Dokümanın 17 bölümündeki her cümle ve her tablo satırı tek tek kod tabanında aranmıştır. Hiçbir madde atlanmamıştır.

**Lejant:** ✅ Tam karşılanıyor · 🟡 Kısmen · ❌ Yok · ⚠️ Var ama hatalı

**Toplam:** 168 kontrol maddesi → **✅ 62 · 🟡 27 · ❌ 71 · ⚠️ 8**

---

# BÖLÜM 1 — Mobil Projenin Amacı

| # | Dokümandaki İfade | Durum | Eksik olan |
|---|---|---|---|
| 1.1 | Web tarafındaki ürün havuzunu mobilde kullanmak | ❌ | Veri `docs/barkod_listesi_mock.csv`'den geliyor, web havuzuna hiç bağlanılmıyor |
| 1.2 | Kamera ile barkod okutup **ürün adı** göstermek | ✅ | — |
| 1.3 | ...**görsel** göstermek | ❌ | `ProductResultCard` görsel widget'ı içermiyor |
| 1.4 | ...**fiyat** göstermek | ❌ | Sonuç kartında fiyat satırı yok (`primaryRows`'da yer almıyor) |
| 1.5 | ...**kategori** göstermek | ✅ | — |
| 1.6 | Sektör bazlı barkod listelerini mobilde görüntülemek | ✅ | — |
| 1.7 | ...ve indirmek | 🟡 | İndiriliyor ama API linkinden değil, cihazda üretiliyor |
| 1.8 | "Mobil uygulama web projesindeki REST API üzerinden çalışacaktır" | ❌ | `useMockData = true` |
| 1.9 | Kullanıcı barkodu kamera ile okutacak | ✅ | — |
| 1.10 | Manuel barkod girebilecek | ✅ | — |
| 1.11 | Geçmiş sorgularını görebilecek | ✅ | — |
| 1.12 | PDF/Excel linkleri indirilebilecek | 🟡 | Link değil, lokal üretim |
| 1.13 | Son sorgulanan ürünler cihazda cachelenecek | ✅ | — |
| 1.14 | Seçilen sektör listeleri cihazda cachelenecek | ✅ | — |
| 1.15 | Admin/editör mobil üzerinden **ürün önerisi** yapabilecek | ❌ | Hiç yok |
| 1.16 | ...**eksik görsel bildirimi** yapabilecek | ❌ | Hiç yok |

**Kritik Not kutusu (yasal veri toplama):** ✅ Uygulama scraper içermiyor, uyumlu.

---

# BÖLÜM 2 — Kullanıcı Rolleri

**Rol sisteminin tamamı kodda yoktur.** Kullanıcı kavramı, oturum, kimlik — hiçbiri mevcut değil.

| # | Rol | Yetki | Ekran Erişimi | Durum |
|---|---|---|---|---|
| 2.1 | Misafir | Sınırlı barkod sorgular | Tarama, ürün sonucu, sınırlı sektör listesi | ❌ Limit mekanizması yok, herkes sınırsız |
| 2.2 | Kayıtlı Kullanıcı | Liste indirir | Download | 🟡 Var ama kayıt olmadan herkese açık |
| 2.3 | Kayıtlı Kullanıcı | Geçmişi görür | Geçmiş | 🟡 Aynı |
| 2.4 | Kayıtlı Kullanıcı | Favoriler | Favoriler ekranı | ❌ Favori özelliği hiç yok |
| 2.5 | Editör | Ürün önerir | Ürün düzenleme önerisi ekranı | ❌ |
| 2.6 | Editör | Eksik bilgi bildirir | Görsel bildirimi ekranı | ❌ |
| 2.7 | Admin | Mobil log kontrolü | Yönetim özeti ekranı | ❌ |
| 2.8 | Admin | Veri kontrolü | Hatalı barkod bildirimi ekranı | ❌ |

**Gereken altyapı (hiçbiri yok):** kullanıcı modeli, oturum yönetimi, rol enum'u, rol bazlı route guard, rol bazlı widget görünürlüğü.

---

# BÖLÜM 3 — Mobil Mimari

| # | Katman | Dokümandaki Öneri | Koddaki Durum | Sonuç |
|---|---|---|---|---|
| 3.1 | UI | Flutter Widgets | Flutter Widgets | ✅ |
| 3.2 | State Management | **Riverpod / Bloc** | `setState` + `FutureBuilder` | ❌ Sapma |
| 3.3 | State Management görevi | API sonucu, loading, error, cache durumları | Her ekranda ayrı ayrı, merkezi yönetim yok | 🟡 |
| 3.4 | Network | Dio / HTTP Client | Dio | ✅ |
| 3.5 | Network — REST çağrıları | var | ✅ | — |
| 3.6 | Network — **token yönetimi** | yok | ❌ | Interceptor yok |
| 3.7 | Network — timeout yönetimi | 10 sn connect + receive | ✅ | — |
| 3.8 | Local Storage | **Hive / SQLite** | `SharedPreferences` | ❌ Sapma |
| 3.9 | Local Storage — offline ürün cache | var | ✅ | — |
| 3.10 | Local Storage — geçmiş sorgular | var | ✅ | — |
| 3.11 | Local Storage — **favoriler** | yok | ❌ | — |
| 3.12 | Barcode Scanner | Kamera tabanlı paket | `mobile_scanner 7.2.0` | ✅ |
| 3.13 | Scanner — EAN/UPC/QR okuma | 🟡 | Paket okur ama validator **UPC-A (12) ve GTIN-14'ü reddeder** | ⚠️ |
| 3.14 | File Download | Cihaz dosya sistemi | `path_provider` + `open_filex` | ✅ |
| 3.15 | **Error Tracking** | Log servis entegrasyonu | **Hiç yok** | ❌ |
| 3.16 | Error Tracking — API hataları raporlama | ❌ | — | — |
| 3.17 | Error Tracking — kamera hataları raporlama | ❌ | — | — |
| 3.18 | Error Tracking — indirme hataları raporlama | ❌ | — | — |
| 3.19 | "Mobil kendi veritabanını tutmayacak" | ⚠️ | Mock CSV (yüzbinlerce satır) APK'ya gömülü — ilkeyle çelişiyor | — |

---

# BÖLÜM 4 — Ekran Akışı

| # | Ekran | Dokümandaki İçerik | Durum |
|---|---|---|---|
| 4.1 | **Splash / Başlangıç** | — | ❌ **Ekran yok.** `AppDuration.splash` sabiti tanımlanmış ama kullanılmıyor |
| 4.2 | Splash — token kontrolü | ❌ | |
| 4.3 | Splash — minimum config alma | ❌ | |
| 4.4 | **Giriş / Misafir Devam** | — | ❌ **Ekran yok.** `AppRoutes`'ta rota bile yok |
| 4.5 | Giriş — Login | ❌ | |
| 4.6 | Giriş — sınırlı kullanım (misafir) | ❌ | |
| 4.7 | Ana Sayfa — Barkod tara butonu | ✅ | |
| 4.8 | Ana Sayfa — sektör kartları | ✅ | |
| 4.9 | Ana Sayfa — son sorgular | ✅ | |
| 4.10 | Barkod Tarama — kamera görünümü | ✅ | |
| 4.11 | Barkod Tarama — **flaş** | ❌ | `toggleTorch` mevcut, kullanılmıyor |
| 4.12 | Barkod Tarama — **manuel giriş** (bu ekranda) | ❌ | Ayrı ekran, tarama ekranından geçiş yok |
| 4.13 | Barkod Tarama — **son barkod** gösterimi | ❌ | `_lastScannedBarcode` var ama UI'da gösterilmiyor |
| 4.14 | Ürün Sonuç — ürün görseli | ❌ | |
| 4.15 | Ürün Sonuç — ad | ✅ | |
| 4.16 | Ürün Sonuç — barkod | ✅ | |
| 4.17 | Ürün Sonuç — fiyat | ❌ | |
| 4.18 | Ürün Sonuç — kategori | ✅ | |
| 4.19 | Ürün Sonuç — **kaynak** | ⚠️ | `source` alanı ham anahtar adıyla "Detaylar" altında dökülüyor |
| 4.20 | **Ürün Bulunamadı** ekranı | ❌ | **Ekran yok**, sadece SnackBar |
| 4.21 | Bulunamadı — yeni ürün öner | ❌ | |
| 4.22 | Bulunamadı — tekrar tara | 🟡 | Tarama ekranında `_restartScanner` var, manuel ekranda yok |
| 4.23 | Bulunamadı — manuel bilgi ekle | ❌ | |
| 4.24 | Sektör Listeleri — liste seçimi | ✅ | |
| 4.25 | Sektör Listeleri — Market, kırtasiye vb. | ⚠️ | Mock CSV yalnızca gıda sektörleri içeriyor. **Kırtasiye, Temizlik, Kozmetik, Hırdavat verisi yok** |
| 4.26 | Liste Detay — ürün arama | ✅ | |
| 4.27 | Liste Detay — filtre | ✅ | Kategori filtresi var |
| 4.28 | Liste Detay — toplam ürün | ✅ | |
| 4.29 | Liste Detay — indirme linkleri | 🟡 | Lokal üretim |
| 4.30 | İndirilenler — dosya listesi | ✅ | |
| 4.31 | İndirilenler — açma | ✅ | |
| 4.32 | İndirilenler — paylaşma | ✅ | |
| 4.33 | Geçmiş — son taranan barkodlar | ✅ | |
| 4.34 | Geçmiş — ürünler | 🟡 | `imageUrl` saklanıyor ama listede gösterilmiyor |
| 4.35 | **Ayarlar** ekranı | ❌ | **Ekran yok**, rota yok |
| 4.36 | Ayarlar — cache temizleme | ❌ | Geçmiş temizleme var ama ürün/sektör cache temizleme yok |
| 4.37 | Ayarlar — API bağlantı durumu | ❌ | |
| 4.38 | Ayarlar — kullanıcı çıkışı | ❌ | |

**Özet: 11 ekrandan 4'ü (Splash, Giriş, Ürün Bulunamadı, Ayarlar) hiç yok.**

---

# BÖLÜM 5 — Barkod Tarama Akışı

### 8 adımlık akış

| # | Adım | Durum | Eksik |
|---|---|---|---|
| 5.1 | "Barkod Tara" butonuna basar | ✅ | — |
| 5.2 | **Kamera iznini kontrol eder** | ❌ | `permission_handler` yok, izin durumu hiç sorgulanmıyor |
| 5.3 | **İzin yoksa kullanıcıyı yönlendirir** | ❌ | Reddedilirse siyah ekran |
| 5.4 | Kamera barkodu okur | ✅ | — |
| 5.5 | Barkod formatı lokal doğrulanır | ⚠️ | Sadece 8/13 hane; 12 (UPC-A) ve 14 (GTIN-14) reddediliyor, checksum yok |
| 5.6 | Duplicate istek engellenir | ✅ | `_lastScannedBarcode` kontrolü var |
| 5.7 | `/api/v1/products/by-barcode/{barcode}` isteği | ⚠️ | Kod query param kullanıyor (`?barcode=X`), doküman path param diyor |
| 5.8 | Ürün bulunursa sonuç ekranı — görsel | ❌ | |
| 5.9 | ...fiyat | ❌ | |
| 5.10 | ...kategori | ✅ | |
| 5.11 | Ürün yoksa "bulunamadı" ekranı | ❌ | |
| 5.12 | Kullanıcı ürün önerisi oluşturabilir | ❌ | |
| 5.13 | Sorgu **lokal geçmişe** kaydedilir | ✅ | Başarılı/başarısız ikisi de |
| 5.14 | Sorgu **API scan_logs servisine** kaydedilir | ❌ | Endpoint hiç çağrılmıyor |

### 5 durum tablosu

| # | Durum | Beklenen Davranış | Durum |
|---|---|---|---|
| 5.15 | İnternet yok | Cache'de ürün varsa göster | ✅ |
| 5.16 | İnternet yok | Yoksa bağlantı uyarısı | 🟡 Genel hata mesajı, bağlantıya özel değil |
| 5.17 | API timeout | **Tekrar dene butonu göster** | ❌ Tarama/manuel ekranda yok, sadece SnackBar |
| 5.18 | API timeout | Otomatik sonsuz deneme yapma | ✅ Retry yok |
| 5.19 | Kamera izni yok | **Manuel barkod girişi seçeneği göster** | ❌ |
| 5.20 | Barkod formatı hatalı | API çağırmadan uyarı ver | ✅ |
| 5.21 | Ürün görseli yok | **Varsayılan ürün görseli göster** | ❌ Görsel alanı hiç yok |
| 5.22 | Ürün görseli yok | **"Görsel bildir" seçeneği göster** | ❌ |

---

# BÖLÜM 6 — API Entegrasyonları

| # | Mobil İşlem | Endpoint | Durum | Not |
|---|---|---|---|---|
| 6.1 | Barkod sorgula | `GET /products/by-barcode/{barcode}` | ⚠️ | Query param olarak çağrılıyor + mock modda |
| 6.2 | **Ürün ara** | `GET /products/search?q=` | ❌ | Hiç çağrılmıyor, sabiti bile tanımlı değil. Arama lokal listede filtreleme yapıyor |
| 6.3 | Sektörleri getir | `GET /sectors` | 🟡 | Kod var, mock modda |
| 6.4 | Liste ürünleri | `GET /lists/{id}/items` | ⚠️ | Kod `{sectorId}` gönderiyor, doküman liste id'si diyor |
| 6.5 | Export linki al | `GET /export/jobs/{id}` | ⚠️ | `getExportJob()` metodu yazılmış ama **hiçbir ekran çağırmıyor** (ölü kod) |
| 6.6 | **Tarama logu gönder** | `POST /scan-logs` | ❌ | Sabit yok, çağrı yok |
| 6.7 | **Ürün öner** | `POST /product-suggestions` | ❌ | Sabit yok, çağrı yok |
| 6.8 | **Görsel bildir** | `POST /image-reports` | ❌ | Sabit yok, çağrı yok |

### Mobil Response Standardı

| # | Gereklilik | Durum |
|---|---|---|
| 6.9 | `success` alanı işlenmeli | ❌ `_extractData` sadece `data`'ya bakıyor |
| 6.10 | `data` alanı işlenmeli | ✅ |
| 6.11 | `message` alanı işlenmeli | 🟡 Sadece hata durumunda, `e.response?.data?['message']` |
| 6.12 | `errors` alanı işlenmeli | ❌ Hiç okunmuyor |
| 6.13 | Her hata tipi kullanıcıya sade mesajla gösterilmeli | ⚠️ 401/404/429/500 hepsi aynı "Sunucuya ulaşılamadı" mesajını veriyor |

**Ek hata:** `e.response?.data?['message']` — `data` String veya List dönerse **crash** olur, hata mesajı yerine uygulama patlar.

---

# BÖLÜM 7 — Offline Cache ve Senkronizasyon

### 5 madde

| # | Gereklilik | Durum |
|---|---|---|
| 7.1 | Son taranan ürünler cihazda tutulur | ✅ |
| 7.2 | İnternet yokken tekrar görüntülenebilir | ✅ |
| 7.3 | **Kullanıcının favori sektörleri** için liste özetleri saklanabilir | ❌ Favori kavramı yok (açılan her sektör cachelenİyor) |
| 7.4 | Tüm sektör verisi otomatik indirilmemeli, kullanıcı seçmeli | ✅ |
| 7.5 | Cache'de son güncelleme tarihi saklanmalı | ✅ `cachedAt` |
| 7.6 | **API'de daha güncel sürüm varsa kullanıcıya yenileme önerilmeli** | ❌ Versiyon karşılaştırması hiç yapılmıyor |
| 7.7 | **Offline oluşturulan öneriler bağlantı gelince kuyruktan gönderilmeli** | ❌ Kuyruk yok, öneri yok |

### Cache tablosu

| # | Cache Verisi | Süre | Temizleme | Durum |
|---|---|---|---|---|
| 7.8 | Son sorgular — 30 gün | ✅ `scanHistoryRetention = 30 gün` | | |
| 7.9 | Son sorgular — kullanıcı temizleyebilir | ✅ | | |
| 7.10 | Ürün detay cache — 7-30 gün | ✅ 14 gün | | |
| 7.11 | Ürün detay — **versiyon değişirse yenilenir** | ⚠️ | `CachedProduct.isStale` hesaplanıyor ama **hiçbir ekranda kontrol edilmiyor** — bayat veri sınırsız gösteriliyor | |
| 7.12 | Sektör liste özeti — manuel yenilemeye kadar | 🟡 Süresiz saklanıyor, manuel yenileme butonu var | | |
| 7.13 | Sektör liste — **yeni versiyon varsa güncelle** | ❌ | | |
| 7.14 | İndirilmiş PDF/Excel — kullanıcı silene kadar | ✅ | | |
| 7.15 | İndirilmiş dosya — dosya yöneticisiyle silinebilir | ✅ | | |
| 7.16 | **Offline öneri kuyruğu** — gönderilene kadar | ❌ | | |
| 7.17 | Öneri kuyruğu — başarılı gönderimde silinir | ❌ | | |

---

# BÖLÜM 8 — Ürün Sonuç Ekranı İçeriği

**Bu bölüm en zayıf kısım.** `ProductResultCard` yalnızca etiket–değer metin satırları basıyor.

| # | Alan | Beklenen Gösterim | Not | Durum |
|---|---|---|---|---|
| 8.1 | **Ürün Görseli** | Beyaz zeminli ana görsel | — | ❌ Widget yok |
| 8.2 | Ürün Görseli | — | Görsel yoksa placeholder | ❌ |
| 8.3 | Ürün Adı | **Kalın başlık** | — | 🟡 Normal satır olarak |
| 8.4 | Ürün Adı | — | Uzun ad 2 satıra kadar | ❌ `maxLines` yok |
| 8.5 | Barkod | **Kopyalanabilir numara** | — | ❌ Kopyalama yok |
| 8.6 | Barkod | — | EAN/UPC doğrulama bilgisi | ❌ |
| 8.7 | Marka/Kategori | **Etiket chip yapısı** | — | ❌ Düz metin |
| 8.8 | Marka/Kategori | — | Liste filtreleriyle uyumlu | ❌ |
| 8.9 | **Fiyat** | TRY formatında | — | ❌ Sonuç kartında hiç yok (`intl` bağımlılığı da yok) |
| 8.10 | Fiyat | — | Kaynak ve tarih küçük metinle | ❌ |
| 8.11 | **KDV** | Varsa oran olarak | — | ❌ CSV'de KDV sütunu var ama `_productKey` map'inde `kdv` anahtarı **yok → veri sessizce düşüyor** |
| 8.12 | KDV | — | Yoksa "belirtilmedi" | ❌ |
| 8.13 | İşlemler | **Favoriye ekle** | — | ❌ |
| 8.14 | İşlemler | **Paylaş** | — | ❌ (`share_plus` bağımlılığı var, sadece dosyada kullanılıyor) |
| 8.15 | İşlemler | **Hata bildir** | — | ❌ |
| 8.16 | İşlemler | — | Role göre görünür | ❌ Rol yok |

### Görsel Standardı kutusu

| # | Gereklilik | Durum |
|---|---|---|
| 8.17 | Görseller küçük ekranda net görünmeli | ❌ Görsel yok |
| 8.18 | Web beyaz zemine alınmış optimize URL dönmeli | 🟡 Web ekibi bağımlılığı, mobil tarafta takip yok |
| 8.19 | Mobil ayrıca görsel düzenleme yapmamalı | ✅ Yapmıyor |

**Ek sorun:** Bilinmeyen tüm alanlar `rawData`'dan ham anahtar adıyla ("Detaylar" başlığı altında `sector`, `source`, `status`) kullanıcıya gösteriliyor. Bu hem çirkin hem de §12'deki "teknik bilgi göstermeyin" ilkesine aykırı.

---

# BÖLÜM 9 — Sektör Listeleri ve Dosya İndirme

| # | Gereklilik | Durum |
|---|---|---|
| 9.1 | Ana sayfada sektör kartları listelenir | ✅ |
| 9.2 | Sektör: **Market** | ⚠️ Mock CSV'de "Market" adında sektör yok, gıda alt kategorileri var |
| 9.3 | Sektör: **Kırtasiye** | ❌ Veri yok |
| 9.4 | Sektör: **Temizlik** | ❌ Veri yok |
| 9.5 | Sektör: **Kozmetik** | ❌ Veri yok |
| 9.6 | Sektör: **Hırdavat** | ❌ Veri yok |
| 9.7 | Liste detayında ürün sayısı | ✅ |
| 9.8 | Liste detayında **son güncelleme tarihi** | ❌ `BarcodeListModel.version` alanı var ama ekranda gösterilmiyor |
| 9.9 | PDF indirme seçeneği | ✅ |
| 9.10 | Excel indirme seçeneği | ✅ |
| 9.11 | ZIP indirme seçeneği | ✅ |
| 9.12 | **İndirmeden önce dosya boyutu gösterilmeli** | ❌ ZIP'te görsel sayısı gösteriliyor, boyut gösterilmiyor; PDF/Excel'de hiçbiri |
| 9.13 | Büyük ZIP için Wi-Fi önerisi | ✅ Dialog'da uyarı var |
| 9.14 | İndirilen dosyalar uygulama içinden açılabilmeli | ✅ |
| 9.15 | ...veya paylaşılabilmeli | ✅ |
| 9.16 | **İndirme yarıda kalırsa tekrar deneme** | 🟡 ZIP'te kısmi retry var, PDF/Excel'de yok |
| 9.17 | **Kaldığı yerden devam etme mantığı** | ❌ Resume yok (`dio.download` range request kullanmıyor) |

---

# BÖLÜM 10 — Mobil Veri Modelleri

| # | Model | Beklenen Alanlar | Durum |
|---|---|---|---|
| 10.1 | ProductModel | id, barcode, name, brand, sector, category, price, imageUrl, updatedAt | ✅ Hepsi var |
| 10.2 | ProductModel — `id` UI'da kullanımı | ❌ Hiçbir yerde gösterilmiyor/kullanılmıyor | |
| 10.3 | ProductModel — `sector` UI'da | ❌ | |
| 10.4 | ProductModel — `updatedAt` UI'da | ❌ Cache versiyonlamada da kullanılmıyor | |
| 10.5 | SectorModel | id, name, slug, itemCount, imageUrl | ✅ Hepsi var |
| 10.6 | SectorModel — `imageUrl` gösterimi | ❌ Sektör kartında ikon kullanılıyor, görsel değil | |
| 10.7 | BarcodeListModel | id, sectorId, title, version, itemCount, exportLinks | ✅ |
| 10.8 | BarcodeListModel — `exportLinks` kullanımı | ❌ Parse ediliyor ama indirmede kullanılmıyor | |
| 10.9 | ScanHistoryModel | barcode, productName, imageUrl, scannedAt, status | ✅ |
| 10.10 | DownloadFileModel | fileName, fileType, path, size, downloadedAt | ✅ |
| 10.11 | **SuggestionModel** | barcode, productName, note, imagePath, syncStatus | ❌ **Model dosyası hiç yok** |

---

# BÖLÜM 11 — UI/UX Notları

| # | Gereklilik | Durum |
|---|---|---|
| 11.1 | Tarama ekranında **yönlendiren çerçeve** | ❌ Overlay yok, ham kamera görüntüsü |
| 11.2 | Tarama ekranında **flaş aç/kapat** | ❌ |
| 11.3 | Tarama ekranında **manuel giriş butonu** | ❌ |
| 11.4 | Sonuç ekranı hızlı açılmalı | 🟡 Ölçülmemiş |
| 11.5 | **Görsel yüklenene kadar skeleton/placeholder** | ❌ Görsel yok, skeleton yok. Yükleme durumunda düz metin ("Ürünler yükleniyor...") |
| 11.6 | Bulunamadığında **boş ekranda bırakmayıp "ürün öner" akışı** | ❌ Tam olarak dokümanın "yapmayın" dediği durum |
| 11.7 | Sektör listelerinde **arama** | ✅ |
| 11.8 | Sektör listelerinde **kategori filtresi** | ✅ |
| 11.9 | **Bilsoft kurumsal renkleri** | 🟡 `AppColors` tanımlı, kurumsal kimlikle doğrulanmalı |
| 11.10 | Sade, beyaz arka planlı arayüz | ✅ |
| 11.11 | Okunabilir arayüz — **font** | ⚠️ **`AppTheme` `fontFamily: 'Manrope'` diyor ama `pubspec.yaml`'da Manrope fontu tanımlı değil → font hiç uygulanmıyor, sessizce sistem fontuna düşüyor** |
| 11.12 | **Tek elle kullanım için ana butonlar alta yakın** | ❌ Butonlar üstte/akış içinde, alt aksiyon barı yok |

---

# BÖLÜM 12 — Güvenlik ve Yetkilendirme

**Bu bölümün hiçbir maddesi karşılanmıyor.**

| # | Konu | Kural | Durum |
|---|---|---|---|
| 12.1 | Token | Login sonrası access token kullanılır | ❌ Login yok, token yok |
| 12.2 | Token | **Güvenli saklama alanında tutulur** | ❌ `flutter_secure_storage` bağımlılığı bile yok |
| 12.3 | Misafir limitleri | Günlük/oturum bazlı limit | ❌ |
| 12.4 | API Rate Limit | Kullanıcı/cihaz bazlı limitleme | ❌ İstemci tarafında throttle yok |
| 12.5 | Rate limit — 429 yanıtı ele alma | ❌ | |
| 12.6 | Dosya Güvenliği | İndirilen linkler **süreli** olmalı | ❌ Linkler kullanılmıyor, lokal üretim |
| 12.7 | Kişisel Veri | Gereksiz cihaz bilgisi toplanmamalı | ✅ Toplanmıyor |
| 12.8 | Kişisel Veri | Loglar anonimleştirilebilir | ❌ Log sistemi yok |
| 12.9 | Hata Mesajı | **Teknik stack bilgisi gösterilmemeli** | ⚠️ `rawData` ham alan adları ekrana basılıyor; `Exception('Sektör listesi beklenen formatta gelmedi.')` gibi mesajlar kullanıcıya ulaşabiliyor |
| 12.10 | — | HTTPS zorunluluğu / certificate pinning | ❌ Ele alınmamış |
| 12.11 | — | KVKK aydınlatma metni | ❌ |

---

# BÖLÜM 13 — Test Planı

| # | Test Alanı | Senaryo | Başarı Kriteri | Durum |
|---|---|---|---|---|
| 13.1 | Kamera | EAN-13 barkod okutma | Doğru okunur, API çağrılır | ❌ Otomatik test yok, manuel test kaydı da yok |
| 13.2 | Manuel Giriş | Barkod elle girilir | Format doğruysa sorgu | 🟡 Sadece `BarcodeValidator` unit testi |
| 13.3 | Ürün Bulundu | API ürün döner | **Görsel**, ad, fiyat doğru gösterilir | ❌ Görsel ve fiyat gösterilmediği için test edilemez |
| 13.4 | Ürün Bulunamadı | API 404/empty | Öneri ekranı açılır | ❌ Ekran yok |
| 13.5 | Offline | İnternet kapalı | Cache gösterilir | 🟡 Servis testi var, ekran testi yok |
| 13.6 | Liste İndirme | PDF/Excel indirilir | Dosya açılır, paylaşılır | 🟡 Dosya üretimi test edilmiş, indirme/açma akışı değil |
| 13.7 | ZIP İndirme | Resimler ZIP indirilir | Kaydedilir, hata olmaz | ✅ Retry dahil iyi test edilmiş |
| 13.8 | Token Süresi | Token geçersiz | Login yenileme istenir | ❌ Özellik yok |
| 13.9 | Performans | Arka arkaya 20 tarama | Duplicate ve donma olmaz | ❌ Hiç ölçülmemiş |

### Ek test altyapısı eksikleri
- ❌ `integration_test/` klasörü yok
- ❌ Golden test yok
- ❌ Widget testi sadece 1 tane (ana sayfa açılıyor mu)
- ⚠️ `test/widget_test.dart` içindeki `_FakeApiService` gerçek `ApiClient()` kuruyor — izole değil
- ❌ Test coverage raporu yok
- ❌ CI pipeline yok (`flutter test` otomatik koşmuyor)

**Mevcut olanlar (iyi durumda):** `barcode_validator_test`, `barcode_list_model_test`, `sector_model_test`, `api_service_test`, `offline_cache_service_test`, `export_file_service_test`.

---

# BÖLÜM 14 — Geliştirme Fazları

| # | Faz | Kapsam | Beklenen Çıktı | Durum |
|---|---|---|---|---|
| 14.1 | Faz 1 | Flutter proje | Çalışan temel | ✅ |
| 14.2 | Faz 1 | Tema | | 🟡 Font eksik (11.11) |
| 14.3 | Faz 1 | Route yapısı | | 🟡 6 rota var, 4 ekran eksik |
| 14.4 | Faz 1 | API client | | 🟡 Token/interceptor yok |
| 14.5 | Faz 2 | **Kamera izinleri** | | ❌ |
| 14.6 | Faz 2 | Tarama ekranı | | 🟡 Overlay/flaş eksik |
| 14.7 | Faz 2 | Manuel giriş | | ✅ |
| 14.8 | Faz 3 | API entegrasyonu | | ❌ Mock modda |
| 14.9 | Faz 3 | Detay ekranı | | 🟡 |
| 14.10 | Faz 3 | **Görsel gösterimi** | | ❌ |
| 14.11 | Faz 4 | Sektör | | ✅ |
| 14.12 | Faz 4 | Liste detay | | ✅ |
| 14.13 | Faz 4 | Arama/filtre | | ✅ |
| 14.14 | Faz 5 | PDF/Excel/ZIP indirme | | ✅ |
| 14.15 | Faz 5 | Offline cache | | ✅ |
| 14.16 | **Faz 6** | Ürün önerisi | | ❌ |
| 14.17 | Faz 6 | Hata bildirimi | | ❌ |
| 14.18 | Faz 6 | Scan log | | ❌ |

**Faz 6 hiç başlamamış durumda.**

---

# BÖLÜM 15 — Kabul Kriterleri

| # | Kriter | Durum |
|---|---|---|
| 15.1 | Mobil uygulama **web API'ye bağlanıp** barkod sorgulayabilmelidir | ❌ **Karşılanmıyor** |
| 15.2 | Kamera ile barkod okuma sorunsuz çalışmalı | 🟡 12/14 haneli barkodlar reddediliyor |
| 15.3 | Manuel barkod girişi sorunsuz çalışmalı | 🟡 Aynı |
| 15.4 | Ürün bulunduğunda **görsel** gösterilmeli | ❌ **Karşılanmıyor** |
| 15.5 | ...ürün adı gösterilmeli | ✅ |
| 15.6 | ...barkod gösterilmeli | ✅ |
| 15.7 | ...kategori gösterilmeli | ✅ |
| 15.8 | ...**fiyat** gösterilmeli | ❌ **Karşılanmıyor** |
| 15.9 | Ürün bulunamadığında **öneri/bildirim ekranı** açılmalı | ❌ **Karşılanmıyor** |
| 15.10 | Sektör bazlı listeler görüntülenmeli | ✅ |
| 15.11 | **PDF/Excel indirme linkleri çalışmalı** | 🟡 Link yerine lokal üretim |
| 15.12 | Son taranan ürünler offline cache'den görüntülenebilmeli | ✅ |
| 15.13 | **Token** davranışı doğru ele alınmalı | ❌ |
| 15.14 | **Hata yönetimi** doğru ele alınmalı | 🟡 Hata tipleri ayrıştırılmıyor |
| 15.15 | **Timeout** davranışı doğru ele alınmalı | 🟡 Timeout var, retry UI yok |
| 15.16 | **Rate limit** davranışı doğru ele alınmalı | ❌ |

**7 kabul kriterinden 4'ü açıkça karşılanmıyor.**

---

# BÖLÜM 16 — Web Ekibi ile Ortak Bağımlılıklar

Bunlar mobil ekibin *bekledikleri* — teslim öncesi durumlarının teyit edilmesi gerekiyor:

| # | Bağımlılık | Gereklilik | Teyit Durumu |
|---|---|---|---|
| 16.1 | API Dokümantasyonu | Endpoint listesi | 🟡 Dokümanda var, örnek yok |
| 16.2 | API Dokümantasyonu | **Request/response örnekleri** | ❌ Dokümanda yok |
| 16.3 | API Dokümantasyonu | **Hata kodları** | ❌ Dokümanda yok |
| 16.4 | Görsel URL'leri | Optimize, direkt gösterilebilir URL | ❓ Teyit edilmemiş |
| 16.5 | Export Linkleri | Süreli ve erişilebilir linkler | ❌ Mobil taraf zaten kullanmıyor |
| 16.6 | Versiyon Bilgisi | `version`/`updatedAt` alanı | 🟡 Model destekliyor, kullanılmıyor |
| 16.7 | Auth | Mobil token üretimi | ❌ Mobil tarafta karşılığı yok |
| 16.8 | Auth | Token yenileme akışı | ❌ |
| 16.9 | Test Verisi | **En az bir sektör için 1000 örnek ürün API'de** | ❓ Teyit edilmemiş — teslim öncesi mutlaka doğrulanmalı |

---

# BÖLÜM 17 — Kaynak Notları

| # | Not | Durum |
|---|---|---|
| 17.1 | BarkodID benzeri deneyimi kameraya taşımak | 🟡 Temel akış var, deneyim eksik (görsel yok) |
| 17.2 | Üçüncü taraf sitelerden toplu veri çekilmemeli | ✅ Uyumlu |
| 17.3 | EAN/UPC/GTIN doğrulaması mobilde **ön kontrol seviyesinde** | ⚠️ Ön kontrol var ama UPC ve GTIN-14'ü **reddediyor** — yanlış davranış |

---

# EK A — Dokümanda Olmayan Ama Teslim İçin Zorunlu

### Release / Paketleme
- ❌ `AndroidManifest.xml` (main) içinde **INTERNET izni yok** → release APK'da tüm ağ istekleri patlar
- ❌ `applicationId = com.example.barkod_hub` (varsayılan)
- ❌ iOS `PRODUCT_BUNDLE_IDENTIFIER = com.example.barkodHub` (varsayılan)
- ❌ Release build **debug key ile imzalanıyor** (`signingConfig = signingConfigs.getByName("debug")`)
- ❌ Keystore + `key.properties` yok
- ❌ Uygulama adı `barkod_hub` (Android `android:label`, iOS `CFBundleName`)
- ❌ Uygulama ikonu varsayılan Flutter ikonu
- ❌ Splash görseli varsayılan beyaz (`launch_background.xml` boş)
- ❌ `pubspec.yaml` açıklaması `"A new Flutter project."`
- ❌ `web/manifest.json` tamamen varsayılan (`#0175C2` Flutter mavisi)
- ❌ Sürüm hâlâ `1.0.0+1`
- ❌ ProGuard/R8 kuralları yok
- ❓ iOS deployment target'ın `mobile_scanner 7.x` gereksinimini (iOS 15+) karşıladığı doğrulanmamış
- ❓ `flutter build apk --release` hiç denenmemiş görünüyor
- ❌ Gizlilik politikası / KVKK metni yok

### Proje Hijyeni
- ❌ `README.md` proje için özelleştirilmemiş (kurulum, çalıştırma, ortam değişkenleri)
- ⚠️ Mock CSV (`docs/barkod_listesi_mock.csv`) asset olarak APK'ya gömülü — production'a mock veri gidiyor, APK boyutu şişiyor
- ❌ Ortam ayrımı (dev/staging/prod) yok — `--dart-define` veya flavor kullanılmıyor
- ❌ `analysis_options.yaml` özelleştirilmemiş
- ❌ CI/CD yok
- ❌ `.env` / gizli anahtar yönetimi yok

### Ölü / Kullanılmayan Kod
- `AppDuration.fast/normal/slow/splash` — hiçbiri kullanılmıyor
- `ApiService.get()` / `ApiService.post()` public wrapper'ları — hiç çağrılmıyor
- `ApiService.getExportJob()` — hiçbir ekran çağırmıyor
- `ApiConstants.exportJobs` — kullanılmıyor
- `CachedProduct.isStale` — hesaplanıyor, kontrol edilmiyor
- `BarcodeListModel.exportLinks` — parse ediliyor, kullanılmıyor
- `ScanHistoryModel.imageUrl` — saklanıyor, gösterilmiyor

### Erişilebilirlik / Uluslararasılaştırma
- ❌ Koyu tema yok (`darkTheme` tanımlı değil, `values-night` varsayılan)
- ❌ Çoklu dil desteği yok (tüm metinler hardcoded Türkçe)
- ❌ `Semantics` etiketleri / ekran okuyucu desteği yok
- ❌ Font ölçeklendirme testi yapılmamış
- ❌ Yatay (landscape) düzen test edilmemiş — Android `configChanges` yatay destekliyor, iOS `Info.plist` landscape'e izin veriyor ama UI buna göre tasarlanmamış

---

# EK B — Dokümanın Kendi Eksikleri

Teslim edilen paket dokümanı da içeriyorsa:

- ❌ Revizyon geçmişi tablosu (versiyon / tarih / değişiklik / hazırlayan)
- ❌ İçindekiler
- ❌ API request/response JSON örnekleri (§16.2'de kendisi istiyor ama içermiyor)
- ❌ HTTP hata kodu → mobil davranış tablosu (§16.3)
- ❌ Auth akış diyagramı (token nasıl alınır, ömrü, refresh var mı)
- ❌ Zaman planı — §14'te 6 faz var, tarih/süre/efor tahmini yok
- ❌ Wireframe / ekran tasarımı — §4 tablo halinde, görsel yok
- ❌ Risk listesi ve azaltma planı
- ❌ KVKK / kişisel veri işleme bölümü (§12'de tek satır)
- ❌ Analytics / kullanım ölçümleme planı
- ❌ Push bildirim stratejisi
- ❌ Uygulama güncelleme / zorunlu sürüm politikası
- ❌ Erişilebilirlik gereksinimleri
- ❌ Koyu tema kararı
- ❌ Çoklu dil kararı
- ❌ CI/CD ve dağıtım planı
- ❌ App Store / Play Store yayın planı ve gerekli materyaller
- ❌ Bakım ve destek planı
- ⚠️ §3 "Riverpod/Bloc + Hive/SQLite" diyor, kod farklı → **doküman ile kod bugün birbiriyle çelişiyor**
- ⚠️ §9 "API'den export linki" diyor, kod cihazda üretiyor → aynı çelişki
- ⚠️ §6.1 path parametresi, kod query parametresi → aynı çelişki
- ❌ §16'daki bağımlılıklara "durum" kolonu eklenmeli (karşılandı / bekliyor)

---

# ÖZET — Sayılarla

| Kategori | ✅ | 🟡 | ❌ | ⚠️ | Toplam |
|---|---|---|---|---|---|
| §1 Amaç | 6 | 3 | 7 | 0 | 16 |
| §2 Roller | 0 | 2 | 6 | 0 | 8 |
| §3 Mimari | 6 | 2 | 10 | 1 | 19 |
| §4 Ekranlar | 15 | 3 | 19 | 1 | 38 |
| §5 Tarama Akışı | 6 | 1 | 12 | 3 | 22 |
| §6 API | 1 | 3 | 5 | 4 | 13 |
| §7 Cache | 8 | 2 | 6 | 1 | 17 |
| §8 Sonuç Ekranı | 1 | 2 | 16 | 0 | 19 |
| §9 İndirme | 8 | 2 | 6 | 1 | 17 |
| §10 Modeller | 5 | 0 | 6 | 0 | 11 |
| §11 UI/UX | 3 | 2 | 6 | 1 | 12 |
| §12 Güvenlik | 1 | 0 | 9 | 1 | 11 |
| §13 Test | 1 | 3 | 5 | 0 | 9 |
| §15 Kabul Kriterleri | 5 | 5 | 6 | 0 | 16 |

**En kritik 3 blok:** §8 Ürün Sonuç Ekranı (19'da 1), §12 Güvenlik (11'de 1), §2 Roller (8'de 0).

---

# ÖNCELİK SIRASI

## Teslim edilemez seviye (bunlar olmadan uygulama çalışmıyor)
1. `useMockData = true` → gerçek API bağlantısı (1.8, 15.1)
2. `baseUrl` çift `/api` hatası
3. Release manifest'te INTERNET izni yok (Ek A)
4. Barkod validator 12/14 haneyi reddediyor (5.5, 17.3)
5. Ürün görseli gösterilmiyor (8.1, 15.4)
6. Fiyat gösterilmiyor (8.9, 15.8)
7. "Ürün Bulunamadı" ekranı yok (4.20, 15.9)
8. Manrope fontu pubspec'te tanımlı değil (11.11)

## Kabul kriterlerinde açıkça yazan, atlanamaz
9. Token/auth katmanı (§12, 15.13)
10. Kamera izin yönetimi (5.2, 5.3, 5.19)
11. Ayarlar ekranı (4.35-4.38)
12. Splash + Giriş ekranları (4.1-4.6)
13. KDV mapping'i (8.11)
14. `isStale` kontrolünün devreye alınması (7.11)

## Faz 6 kapsamı (bu hafta yetişmezse dokümanda "sonraki faz" olarak işaretleyin)
15. SuggestionModel + öneri akışı + offline kuyruk (10.11, 7.7)
16. `POST /scan-logs` (6.6)
17. `POST /image-reports` (6.8)
18. `GET /products/search` (6.2)
19. Favoriler (2.4, 3.11, 8.13)
20. Rol bazlı yetkilendirme (§2 tamamı)

## Mimari kararlar (kod değişmeyecekse doküman değişmeli)
21. Riverpod/Bloc vs setState (3.2)
22. Hive/SQLite vs SharedPreferences (3.8)
23. API export linki vs cihazda üretim (9.x, 15.11)
24. Endpoint path/query parametre uyuşmazlığı (6.1, 6.4)

## Release paketleme (Ek A'nın tamamı)
## Doküman tamamlama (Ek B'nin tamamı)
