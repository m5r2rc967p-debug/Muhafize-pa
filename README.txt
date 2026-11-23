MÜHAFİZƏÇİ — iOS başlanğıc layihəsi

Bu ZIP SwiftUI/Xcode mənbə layihəsi üçün kod və Android paketindən çıxarılmış plates.txt bazasını ehtiva edir.

Quraşdırma/yığma:
1) Mac-da Xcode açın və yeni iOS App (SwiftUI) layihəsi yaradın (adı Muhafizeci).
2) ZIP-dəki Swift fayllarını layihəyə əlavə edin.
3) plates.txt faylını Xcode layihəsinə əlavə edin və Copy Bundle Resources-a daxil olduğuna əmin olun.
4) Target > Info bölməsinə NSCameraUsageDescription əlavə edin: "Maşın nömrələrini oxumaq üçün kameradan istifadə olunur."
5) Signing & Capabilities-də öz Apple signing hesabınızı seçin, cihazı qoşub build edin.
6) IPA çıxarma/distribution üçün Xcode Archive workflow istifadə edin; eSign imzalama yalnız uyğun sertifikat/profile və tətbiq paketinə əsasən mümkündür.

Məhdudiyyət: Bu kod ilkin prototipdir. OCR kamera axınında heuristik nömrə formatı ilə 3 ardıcıl oxuma tələb edir; yanlış oxumalar ola bilər. Tam yığılma və IPA bu mühitdə Xcode olmadan yoxlanmayıb.
