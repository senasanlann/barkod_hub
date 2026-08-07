# barkod_hub — Güncel Repo İncelemesi

**Kaynak:** github.com/senasanlann/barkod_hub @ main (7b28a49)
**Karşılaştırma:** İlk eksiklik listesindeki 168 maddeye göre

---

## Kapanan Maddeler

Kod tarafında yapılan iş ciddi. Aşağıdakiler artık tamam:

**P0'ın tamamı (kod tarafı):**
- `useMockData` → `bool.fromEnvironment('USE_MOCK', defaultValue: false)` ✅
- `baseUrl` çift `/api` hatası düzeltilmiş (`https://example.com`, sondaki `/api` yok) ✅
- Main manifest'e `INTERNET` **ve** `CAMERA` izni eklenmiş ✅
- Validator artık 8/12/13/14 hane + mod-10 checksum kontrol ediyor ✅
- `ProductResultCard`'a `Image.network` + `loadingBuilder` + `errorBuilder` + placeholder eklenmiş ✅
- Fiyat bloğu eklenmiş, null durumunda "Fiyat belirtilmedi" gösteriliyor ✅

**Yeni ekranlar:** Splash, WelcomeAuth, Login, Settings, Favorites, ProductNotFound, SuggestionForm, AdminLog, AdminReports

**Yeni servisler:** AuthService, SecureStorageService, AuthInterceptor, ErrorTracker, LogService, SuggestionQueueService, FavoritesService, LocalStorageService

**Ürün sonuç ekranı:** görsel, fiyat, kopyalanabilir barkod, marka/kategori chip'leri, favori, paylaş, hata bildir — hepsi var

**Tarama ekranı:** flaş toggle, manuel girişe geçiş, Stack tabanlı overlay

**API:** scan-logs / product-suggestions / image-reports endpoint'leri + çağrıları; OFF entegrasyonu CSV-birincil / API-yedek mimarisiyle; User-Agent header'ı; 401/403/429/500 ayrıştırması

**Test:** 6 → 31 dosya, `integration_test/` eklenmiş, bölüm bazlı test dosyaları (section5–section12) yazılmış

---

# 🔴 KRİTİK — Veri Katmanı

Kod bu sorunları çözemez, veriyi düzeltmek gerekiyor.

## 1. CSV bozuk: 4.838 satırda sütun kayması (%20,5)

CSV'de iki sektör adı **tırnaksız virgül** içeriyor:

```
Meyve, Sebze ve Kuruyemiş,8697436558391,Dried Figs,Ciloglu,...
Sos, Baharat ve Çeşni,8690635300815,Mayonez,Tat,...
```

Başlık 8 sütun tanımlıyor, bu satırlar 9 alan üretiyor. Sonuç: **tüm sütunlar bir kayıyor.**

| Beklenen | Bu satırlarda gelen |
|---|---|
| `sector` = "Meyve, Sebze ve Kuruyemiş" | "Meyve" |
| `barcode` = "8697436558391" | " Sebze ve Kuruyemiş" |
| `name` = "Dried Figs" | "8697436558391" |
| `brand` = "Ciloglu" | "Dried Figs" |

Barkod alanına metin düştüğü için bu 4.838 ürün **hiçbir zaman sorgulanamaz**. Uygulamada "Meyve" ve "Sos" adında iki hayalet sektör görünür.

**Çözüm:** CSV'yi yeniden üretin, virgül içeren alanları çift tırnağa alın (`"Meyve, Sebze ve Kuruyemiş"`). Excel/pandas ile kaydederken bu otomatik olur.

## 2. Barkodların %21,6'sı validator'dan geçemiyor

23.551 barkodun 5.082'si reddediliyor:

| Sebep | Adet |
|---|---|
| Sayısal değil (sütun kayması kaynaklı) | 4.838 |
| Geçersiz uzunluk (3, 6, 7, 9, 10, 11 hane) | 49 |
| Checksum hatalı | 195 |

Checksum kontrolünü eklemek doğru bir düzeltmeydi, ama artık **veri bu kurala uymuyor.** Checksum'dan geçemeyen 195 barkodun içinde `2000000024941` gibi mağaza içi (in-store) barkodlar var — bunlar zaten standart dışı.

**Karar verin:** ya bu satırları temizleyin, ya da validator'da checksum'ı uyarı seviyesine indirip yine de sorguya izin verin.

## 3. Görsel doluluk oranı %0,3

Sağlam 18.713 satırın **yalnızca 53'ünde** görsel URL'i var.

Yani §8.1 ve §15.4 için yazdığınız görsel gösterimi kodu **her 100 sorgudan 99,7'sinde placeholder gösterecek.** Mentörünüzün özellikle vurguladığı konu da buydu.

İyi haber: OFF entegrasyonu devrede olduğu için CSV'de bulunmayan barkodlar OFF'a gidecek ve orada görsel gelme ihtimali yüksek. Ama CSV'de **bulunan** ürünlerde OFF'a hiç gidilmiyor — görselsiz sonuç dönüyor.

**Öneri:** `getProductByBarcode`'da CSV eşleşmesi bulunduğunda `imageUrl` boşsa OFF'tan sadece görseli tamamlayın. Küçük bir değişiklik, demodaki etkisi çok büyük.

## 4. Fiyat ve KDV pratikte yok — %0,03

18.713 satırın **5'inde** fiyat var. O 5 satır da aşağıdaki uydurma demo kayıtları.

## 5. Dokümanın 5 sektörü birer sahte ürün

```
Market      8690000990001  Unkur Un 5KG
Kırtasiye   8690000990002  Faber-Castell Kurşun Kalem 12li
Temizlik    8690000990003  Ariel Sıvı Deterjan 3L
Kozmetik    8690000990004  Nivea Nemlendirici Krem 150ml
Hırdavat    8690000990005  Bosch Matkap Ucu Seti 10lu
```

Üç ayrı sorun:
- **Barkodlar uydurma** ve checksum'dan geçmiyor → taranamaz, sorgulanamaz
- **Görsel URL'leri ölü** → üçünü test ettim, hepsi **HTTP 403**
- Sektör başına 1 ürün → liste ekranı tek satır gösterir

Demoda "hırdavat listesini aç" denirse tek satır ve kırık görsel çıkar. Bu, hiç veri olmamasından daha kötü görünür.

**Öneri:** ya bu 5 satırı kaldırıp doküman §9'u gıda sektörleriyle güncelleyin, ya da her birine gerçek barkodlu 20-30 ürün ekleyin.

---

# 🟠 KOD — Kalan Sorunlar

## 6. Token üçüncü tarafa sızıyor

`AuthInterceptor.onRequest` **her** isteğe Bearer token ekliyor — Open Food Facts'e gidenler dahil.

```dart
if (user.token != null && user.token!.isNotEmpty) {
  options.headers['Authorization'] = 'Bearer ${user.token}';
}
```

Kullanıcının Bilsoft token'ı üçüncü taraf sunucuya gönderiliyor. §12.1'in ihlali.

**Düzeltme:** host kontrolü ekleyin.
```dart
final isOwnApi = options.uri.toString().startsWith(ApiConstants.baseUrl);
if (isOwnApi && user.token != null && user.token!.isNotEmpty) { ... }
```

## 7. `SecureStorageService` aslında güvenli değil

Dosya adı ve sınıf adı "secure" diyor, içeride `SharedPreferences` var. Android'de bu düz XML dosyası; root'lu cihazda okunabilir.

Doküman §12.2: *"token güvenli saklama alanında tutulur"* — karşılanmıyor. `flutter_secure_storage` bağımlılığı hâlâ yok.

**En azından** sınıf yorumuna mevcut durumu yazın, ya da paketi ekleyin (Keychain/Keystore kullanır, API'si neredeyse aynı).

## 8. Kamera izni yönetimi hâlâ yok

`home_screen.dart`'taki `_checkPermissionAndNavigate` kamera izni değil, **kullanıcı rol kontrolü** yapıyor (kayıtlı mı, değil mi). `permission_handler` paketi projede yok.

Kullanıcı kamera iznini reddederse hâlâ siyah ekranla karşılaşacak. §5.2, §5.3, §5.19 açık.

## 9. Throttle OFF limitini korumuyor

`ApiClient._throttleRequest` istekler arasına 150 ms koyuyor → dakikada ~400 istek. OFF'un ürün sorgu limiti **dakikada 15**. Pratikte bir kullanıcı bunu zorlamaz ama sınır aşılırsa IP banı geliyor.

Ayrıca throttle statik alan kullanmıyor, her `ApiClient` örneği kendi sayacını tutuyor.

## 10. Font meselesi çözülmedi, silindi

Önceki incelemede `fontFamily: 'Manrope'` vardı ama font tanımlı değildi. Şimdi `fontFamily` satırı tamamen kaldırılmış — yani sistem fontu kullanılıyor.

Hata giderildi ama §11.9 ("Bilsoft kurumsal renkleri ve okunabilir font") hâlâ karşılanmıyor. Font ya `pubspec.yaml`'a eklenmeli ya da doküman "sistem fontu kullanılmıştır" diye güncellenmeli.

---

# 🔵 RELEASE — Hiçbiri Yapılmamış

Bu blok ilk listeden neredeyse hiç ilerlememiş ve teslim edilecek APK varsa hepsi zorunlu:

| Madde | Mevcut | Olması gereken |
|---|---|---|
| Android `applicationId` | `com.example.barkod_hub` | `com.bilsoft.barkodhub` |
| iOS `PRODUCT_BUNDLE_IDENTIFIER` | `com.example.barkodHub` | Aynı şekilde |
| Release imzalama | `signingConfigs.getByName("debug")` | Gerçek keystore + `key.properties` |
| `android:label` | `barkod_hub` | `Barkod Hub` |
| `pubspec` description | `"A new Flutter project."` | Gerçek açıklama |
| `README.md` | 16 satır, varsayılan Flutter metni | Kurulum + `--dart-define` kullanımı |
| Uygulama ikonu | Varsayılan Flutter | Bilsoft ikonu |
| Splash görseli | Boş `launch_background.xml` | Logo |
| Sürüm | `1.0.0+1` | Teslim sürümü |
| ProGuard/R8 | Yok | — |
| KVKK / gizlilik metni | Yok | — |

**Ayrıca:** `darkTheme` yok, `localizationsDelegates` yok, `intl` yok.

---

# ⚠️ Ortam Değişkeni Tuzağı

`useMockData` artık **varsayılan `false`**, `baseUrl` varsayılan `https://example.com`.

Yani düz `flutter run` çalıştıran biri gerçek olmayan bir sunucuya gitmeye çalışır. Sektörler CSV'den geldiği için ana ekran açılır — ama bu şans eseri, `getSectors` CSV boş değilse API'ye hiç gitmiyor.

**README'ye mutlaka yazın:**
```bash
# Demo / sunum
flutter run --dart-define=USE_MOCK=true

# Gerçek API ile
flutter run --dart-define=API_BASE_URL=https://gercek-api.bilsoft.com
```

Sunum sırasında yanlış modda açmak en kolay kaybedilecek puan.

---

# Öncelik Sırası

## Bugün (veri, ~2 saat)
1. CSV'yi tırnaklı olarak yeniden üretin → 4.838 satır kurtulur
2. 5 sahte sektör satırını kaldırın veya gerçek ürünlerle doldurun
3. Checksum'dan geçemeyen 195 satırı temizleyin

## Yarın (kod, ~3 saat)
4. Token sızıntısını kapatın (host kontrolü)
5. CSV'de görsel boşsa OFF'tan görsel tamamlama → demo etkisi en yüksek madde
6. `permission_handler` + kamera izni reddi ekranı
7. README + `--dart-define` talimatları

## Teslimden önce (~2 saat)
8. Release paketleme bloğunun tamamı
9. `flutter analyze` ve `flutter test` temiz geçiyor mu kontrol
10. Release modda gerçek cihazda tarama testi

## Dokümana yazılacak (savunma)
- Bilsoft API'si mevcut olmadığı için ağ katmanı OFF'a karşı doğrulandı (mentör yazışması ek olarak konabilir)
- `SecureStorageService` mevcut durumda SharedPreferences kullanıyor
- Font sistem fontudur
- State management Riverpod yerine setState, storage Hive yerine SharedPreferences
