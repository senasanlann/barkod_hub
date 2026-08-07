# Barkod Hub Mobil Uygulaması

Bilsoft Barkod Ürün Havuzu Mobil Uygulaması (Flutter).

## 🚀 Başlangıç ve Çalıştırma

Uygulamayı yerel ortamda çalıştırmak için aşağıdaki komutları kullanabilirsiniz:

### 1. Mock Modda Çalıştırma (Varsayılan & Demo)
Mock veriler ve dahili CSV veri tabanı (`docs/barkod_listesi_mock.csv`) üzerinden çevrimdışı / bağımsız çalışır:

```bash
flutter run
```

veya açıkça `--dart-define` ile:

```bash
flutter run --dart-define=USE_MOCK=true
```

### 2. Gerçek REST API ile Çalıştırma
Canlı Bilsoft REST API sunucusuna bağlanarak çalışır:

```bash
flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://api.bilsoft.com
```

---

## 🛠 Proje Özellikleri ve Mimari

- **Mobil Mimari**: Service Locator (`ServiceLocator`), `ApiClient`, `ApiService` ve `OfflineCacheService`.
- **Barkod Tarama**: Kamera ile gerçek zamanlı barkod okuma (EAN-8, EAN-13, UPC-A, GTIN-14), tarama çerçevesi overlay'i ve flaş toggle.
- **Dinamik Görsel Tamamlama**: CSV'deki görseller boş olduğunda Open Food Facts API'sinden görsel tamamlama.
- **Sektör Listeleri ve İndirme**: PDF, EXCEL ve ZIP indirme boyut ikazları ve dosya yönetimi.
- **Güvenlik ve Yetkilendirme**: `SecureStorageService` ile güvenli token yönetimi, host bazlı token sızıntısı koruması, 50 sorguluk günlük misafir limiti ve 150ms-500ms API throttling.
- **KVKK Bilgilendirme**: Ayarlar ekranında KVKK Aydınlatma Metni.

---

## 🧪 Test Paketini Çalıştırma

Tüm birim, widget ve entegrasyon testlerini çalıştırmak için:

```bash
flutter test
```
