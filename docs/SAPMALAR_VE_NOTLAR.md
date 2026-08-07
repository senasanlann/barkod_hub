# Uygulama Notları ve Mimari Sapmalar (Bilsoft Barkod Hub)

Bu doküman, teknik şartname (PDF) ile mobil uygulama kod tabanı arasındaki bilinçli mimari sapmaları, teknik gerekçeleri ve bağımlılık matrisini açıklar.

---

## 1. Mimari Kararlar ve Bilinçli Sapmalar

### §3.2 State Management (setState + FutureBuilder)
- **Dokümanda İstenen**: Riverpod / BLoC
- **Mevcut Durum**: `setState` + `FutureBuilder` + Service Locator (`ServiceLocator`)
- **Teknik Gerekçe**: Uygulamanın reaktif bağımlılık ağının nispeten yalın olması ve ekstra boilerplate kod oluşturmadan bellek verimliliğini korumak adına setState / ServiceLocator mimarisi tercih edilmiştir.

### §3.8 Depolama Katmanı (SharedPreferences)
- **Dokümanda İstenen**: Hive / SQLite / Room
- **Mevcut Durum**: `SharedPreferences` + `LocalStorageService` / `OfflineCacheService`
- **Teknik Gerekçe**: Çevrimdışı ürün ve tarama geçmişi veri modellerinin JSON serileştirme ile saklanmasının yeterli olması, SQLite veritabanı şema göçü karmaşıklığını önlemiştir.

### §6.1 REST Barkod Endpoint'i (`GET /products/by-barcode/{barcode}`)
- **Dokümanda İstenen**: Bilsoft REST API backend servisi
- **Mevcut Durum**: Çevrimdışı CSV veritabanı birincil kaynak, Open Food Facts API yedek kaynak
- **Teknik Gerekçe**: Bilsoft canlı REST API sunucusu henüz devrede olmadığı için (Mentör ile mutabık kalınmıştır), çevrimdışı 23.550+ ürünlük CSV ve küresel Open Food Facts API'si hibrit olarak kullanılmıştır.

### §12.6 İndirme Bağlantıları (Süreli URL)
- **Dokümanda İstenen**: Sunucudan süreli S3/CDN indirme bağlantıları
- **Mevcut Durum**: PDF, EXCEL ve ZIP arşivlerinin doğrudan mobil cihaz üzerinde anlık oluşturulması (`ExportFileService`)
- **Teknik Gerekçe**: Kullanıcı verisinin internet bağlantısı olmadan da dışa aktarılabilmesini sağlamak.

---

## 2. §16 Bağımlılık ve Servis Durum Matrisi

| Servis / Bağımlılık | Dokümandaki Durum | Kod Tabanındaki Durum | Notlar |
|---|---|---|---|
| Bilsoft Barkod API | Bekleniyor | Mock / CSV + OFF Hibrit | Backend API hazır olmadığından hibrit yapı devrede |
| Kullanıcı / Auth API | Bekleniyor | `AuthService` + `SecureStorageService` | Token saklama ve misafir sorgu limiti aktif |
| Sektör / İndirme API | Bekleniyor | `ExportFileService` | PDF/XLSX/ZIP cihazda üretiliyor |
| Open Food Facts | Yedek | Aktif Entegrasyon | Görsel tamamlama ve ürün arama tamamlandı |

---

## 3. Sürüm ve Release Bilgileri

- **Yayın Sürümü**: `1.1.0+1`
- **Android Application ID**: `com.bilsoft.barkodhub`
- **iOS Bundle Identifier**: `com.bilsoft.barkodhub`
- **İzinler**: `CAMERA`, `INTERNET` ve `permission_handler` ile kullanıcı dostu izin yönetimi.
