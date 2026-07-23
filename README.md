# 🏢 SAP RAP & Fiori Elements - Tesis ve Toplu Konut Yönetim Sistemi

<p align="center">
  <b>Modern, Kurumsal ve Bulut Tabanlı Tesis Yönetim Çözümü</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP%20Cloud-blue?style=for-the-badge&logo=sap" alt="SAP ABAP Cloud">
  <img src="https://img.shields.io/badge/SAP-RAP-orange?style=for-the-badge" alt="SAP RAP">
  <img src="https://img.shields.io/badge/SAP-Fiori%20Elements-green?style=for-the-badge" alt="SAP Fiori Elements">
  <img src="https://img.shields.io/badge/Status-Production%20Ready-success?style=for-the-badge" alt="Status">
</p>

---

# 📌 Proje Hakkında

Bu proje, **SAP ABAP RESTful Application Programming Model (RAP)** ve **SAP Fiori Elements** kullanılarak geliştirilmiş modern bir **Tesis ve Toplu Konut (Site) Yönetim Sistemi** uygulamasıdır.

Uygulama, **ABAP Cloud** geliştirme standartlarına uygun olarak sıfırdan tasarlanmış olup, RAP Managed Scenario mimarisi, CDS veri modeli, Behavior Definition/Implementation yapıları ve Fiori Elements kullanıcı arayüzünü kullanmaktadır.

Sistem sayesinde site sakinleri kayıt altına alınabilir, doğrulama kuralları uygulanabilir, portal durumları yönetilebilir ve kullanıcı dostu Fiori ekranları üzerinden tüm işlemler gerçekleştirilebilir.

---

# 🚀 Kullanılan Teknolojiler

- SAP ABAP Cloud
- SAP RAP (RESTful Application Programming Model)
- SAP Fiori Elements
- Core Data Services (CDS)
- Behavior Definition
- Behavior Implementation
- OData V4 Service Binding
- Eclipse ADT
- SAP BTP ABAP Environment

---

# 🏗️ Proje Mimarisi

```
Database Table
      │
      ▼
 CDS Root View Entity
      │
      ▼
 Projection View
      │
      ▼
 Behavior Definition
      │
      ▼
 Behavior Implementation
      │
      ▼
 Service Definition
      │
      ▼
 Service Binding (OData V4)
      │
      ▼
 SAP Fiori Elements
```

---

# 📂 Veri Modeli

Ana tablo: **ZTS_RESIDENT**

| Alan | Açıklama |
|------|----------|
| RESIDENT_ID | UUID |
| BLOCK_ID | Blok Bilgisi |
| APARTMENT_NO | Daire Numarası |
| FIRST_NAME | Ad |
| LAST_NAME | Soyad |
| PHONE_NUMBER | Telefon |
| IS_OWNER | Ev Sahibi Bilgisi |
| PORTAL_STATUS | Portal Durumu |

---

# ⚙️ Gerçekleştirilen İş Kuralları

## ✅ 1. Apartment Conflict Validation

Aynı blok ve aynı daire numarasına ikinci kez kayıt oluşturulması engellenmektedir.

- Duplicate kayıt kontrolü
- Güncelleme senaryolarında kendi kaydı hariç tutulur
- RAP Validation mekanizması kullanılmıştır

```abap
IF sy-subrc = 0
   AND ls_existing-resident_id <> ls_resident-ResidentId.

  APPEND VALUE #(
      %tky = ls_resident-%tky
  ) TO failed-resident.

ENDIF.
```

---

## ✅ 2. Initial Status Determination

Yeni oluşturulan kayıtların portal durumu otomatik olarak **BEKLEMEDE** olarak atanır.

```abap
LOOP AT lt_residents INTO DATA(ls_resident)
     WHERE PortalStatus IS INITIAL.

  APPEND VALUE #(
      %tky = ls_resident-%tky
      PortalStatus = 'BEKLEMEDE'
      %control-PortalStatus = if_abap_behv=>mk-on
  ) TO lt_update.

ENDLOOP.
```

---

## ✅ 3. Custom RAP Action

Fiori ekranındaki **Aktif Yap** butonu ile seçilen kullanıcının portal durumu tek tıklamayla **AKTİF** yapılmaktadır.

Özellikler:

- RAP Action
- Fiori Action Button
- Anlık durum güncellemesi
- Managed Behavior

---

## ✅ 4. Alan Doğrulamaları

Kayıt oluşturulurken aşağıdaki alanlar boş bırakılamaz:

- Ad
- Soyad
- Blok
- Daire Numarası

Eksik bilgi girildiğinde kullanıcıya Fiori üzerinden hata mesajı gösterilir.

---

# 🎨 Fiori Elements Özellikleri

Uygulama aşağıdaki standart Fiori ekranlarını kullanmaktadır:

- List Report
- Object Page
- Responsive Tasarım
- Smart Filter Bar
- Arama
- Sıralama
- Filtreleme
- CRUD İşlemleri
- Action Button
- Otomatik Validasyon Mesajları

---

# 📈 Projede Kullanılan RAP Özellikleri

- Managed Scenario
- CDS View Entity
- Projection View
- Behavior Definition
- Behavior Implementation
- Validation
- Determination
- Custom Action
- EML
- OData V4
- Fiori Elements

---

# 💡 Projenin Kazandırdıkları

Bu proje kapsamında aşağıdaki SAP teknolojileri aktif olarak kullanılmıştır:

- Modern ABAP Cloud geliştirme
- RAP mimarisi
- CDS modelleme
- Behavior geliştirme
- Validation yazımı
- Determination geliştirme
- RAP Action geliştirme
- OData V4 servisleri
- Fiori Elements geliştirme
- Kurumsal uygulama mimarisi

---

# 👨‍💻 Geliştirici

**Muhammed Enes Çimen**

Full-Stack Yazılım Mühendisliği Öğrencisi

SAP ABAP & RAP Developer

GitHub:
> https://github.com/enescimensoftwareeng



# 📄 Lisans

Bu proje **MIT License** kapsamında paylaşılmıştır.

Eğitim, portföy ve referans amaçlı özgürce incelenebilir ve kullanılabilir.

---

⭐ Eğer projeyi beğendiyseniz yıldız vermeyi unutmayın.
