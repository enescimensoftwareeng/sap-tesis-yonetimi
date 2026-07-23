# 🏢 SAP RAP & Fiori Elements - Tesis ve Toplu Konut Yönetim Sistemi

<p align="center">
  <b>Modern, Kurumsal ve Bulut Tabanlı Tesis Yönetim Çözümü</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP%20Cloud-blue?style=for-the-badge&logo=sap" alt="SAP ABAP Cloud">
  <img src="https://img.shields.io/badge/SAP-RAP-orange?style=for-the-badge" alt="SAP RAP">
  <img src="https://img.shields.io/badge/SAP-Fiori%20Elements-green?style=for-the-badge" alt="Fiori Elements">
  <img src="https://img.shields.io/badge/Status-Production%20Ready-success?style=for-the-badge" alt="Status">
</p>

---

## 📌 Proje Hakkında

Bu proje; **SAP ABAP RESTful Application Programming Model (RAP)** ve **Fiori Elements** mimarisi kullanılarak sıfırdan geliştirilmiş, modern bir **Tesis ve Toplu Konut (Site) Yönetim Sistemidir**. 

Geleneksel ABAP geliştirme yaklaşımlarının ötesine geçerek, bulut tabanlı **ABAP Cloud** standartlarına uygun, davranış tanımları (Behavior Definitions), veritabanı düzeyinde otomatik durum yönetimleri, akıllı validasyonlar ve kullanıcı dostu Fiori arayüzüyle donatılmıştır.

---

## 🚀 Öne Çıkan Teknik Özellikler ve Mimari Yapı

* **🧠 SAP RAP (ABAP RESTful Programming Model):** Managed senaryo üzerine kurulu, katmanlı ve ölçeklenebilir modern mimari.
* **💻 Core Data Services (CDS):** Veri modelleme, projection view'lar, association ve UI annotation entegrasyonları.
* **🛡️ Gelişmiş Validasyonlar (Validations):**
  * Boş alan kontrolleri (Ad, Soyad, Daire Numarası vb.).
  * **Daire Çakışma Kontrolü (Apartment Conflict Validation):** Aynı blok ve daire numarasına mükerrer kayıt açılmasını engelleyen dinamik veritabanı taraması.
* **⚡ Otomatik İşlemler (Determinations & Actions):**
  * Kayıt anında otomatik başlangıç durumu ataması (`Determination`: `BEKLEMEDE`).
  * Özelleştirilmiş Fiori Action butonu ile anlık statü güncelleme (`Action`: Sakin durumunu tek tıkla `AKTİF` yapma).
* **🎨 Fiori Elements List Report & Object Page:** Duyarlı (responsive), kurumsal ve modern kullanıcı deneyimi.

---

## 🏗️ Veri Modeli ve Mimarisi

Proje çekirdeğinde yer alan ana veritabanı tablosu (`ZTS_RESIDENT`) şu alanları barındırmaktadır:

| Alan Adı | Veri Tipi | Açıklama |
| :--- | :--- | :--- |
| `CLIENT` | CLNT | Sistem İstemcisi |
| `RESIDENT_ID` | RAW(16) | Benzersiz Sakin Kimliği (UUID) |
| `BLOCK_ID` | CHAR(10) | Blok Bilgisi (Örn: A, B, C) |
| `APARTMENT_NO` | CHAR/NUMC | Daire Numarası |
| `FIRST_NAME` | CHAR(40) | Sakin Adı |
| `LAST_NAME` | CHAR(40) | Sakin Soyadı |
| `PHONE_NUMBER` | CHAR(30) | İletişim Numarası |
| `IS_OWNER` | ABAP_BOOLEAN | Ev Sahibi mi? (True/False) |
| `PORTAL_STATUS` | CHAR(20) | Portal Durumu (`BEKLEMEDE` / `AKTİF`) |

---

## 🛠️ İş Mantığı (Behavior Implementation) Özetleri

### 1. Daire Çakışma Validasyonu (`validateApartmentConflict`)
Aynı blok ve daire numarasına mükerrer kayıt yapılmasını önler. Güncelleme senaryolarında kendi kaydını istisna tutarak güvenli bir kontrol sağlar:
```abap
IF sy-subrc = 0 AND ls_existing-resident_id <> ls_resident-ResidentId.
  " Çakışma tespit edildi! Hata fırlat ve kaydı engelle.
  APPEND VALUE #( %tky = ls_resident-%tky ) TO failed-resident.
  ...
ENDIF.

2. Otomatik Durum Atama (setInitialStatus)
Yeni oluşturulan kayıtlar için sistem arka planda varsayılan statüyü belirler:

ABAP
LOOP AT lt_residents INTO DATA(ls_resident) WHERE PortalStatus IS INITIAL.
  APPEND VALUE #(
    %tky                  = ls_resident-%tky
    PortalStatus          = 'BEKLEMEDE'
    %control-PortalStatus = if_abap_behv=>mk-on
  ) TO lt_update.
ENDLOOP.
📷 Ekran Görüntüleri & Kullanım Akışı
List Report & Filtreleme: Blok ve daire bazlı arama, sıralama ve sayfalama yönetimi.

Object Page & Validasyonlar: Hatalı veya mükerrer girişlerde anlık Fiori hata mesajları.

Aksiyon Yönetimi: "Aktif Yap" butonu ile sakin onay süreçlerinin yönetilmesi.

👨‍💻 Geliştirici
Muhammed Enes Çimen

Full-Stack Yazılım Mühendisliği Öğrencisi | SAP ABAP & RAP Geliştiricisi

GitHub Profilim

📄 Lisans
Bu proje MIT lisansı altında korunmaktadır. Eğitim ve portföy amaçlı özgürce incelenebilir.
