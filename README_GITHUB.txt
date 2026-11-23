MÜHAFİZƏÇİ — iPhone / GitHub Actions / eSign

1. iPhone Safari-də github.com aç, hesab yarat və daxil ol.
2. New repository yarat (məs: Muhafizeci-iOS), public/private seç, Create repository.
3. Repository-də Add file > Upload files seç. Bu ZIP-i əvvəl açmaq (extract) lazımdır; içindəki fayl və qovluqları, o cümlədən .github qovluğunu, repository-yə yüklə. project.yml və README_GITHUB.txt kök səviyyədə olmalıdır.
4. Commit changes et.
5. Actions bölməsinə keç. “Build unsigned iOS IPA for eSign” workflow görünməlidir.
6. Workflow səhifəsində Run workflow > Run workflow bas.
7. Build tamamlananda run nəticəsinin aşağısında Artifacts bölməsindən Muhafizeci-unsigned-IPA ZIP/artifact-ını yüklə.
8. Artifact ZIP-in içində Muhafizeci-unsigned.ipa olacaq. eSign-də IPA import et və öz sertifikat/profile-inlə imzalama.

Qeyd: Bu workflow imzasız IPA paketini hazırlayır. eSign üçün sertifikat və provisioning profile uyğunluğu, bundle ID, cihaz/sertifikat qaydaları tələb oluna bilər. Kod cihazda test edilməyib; build xətası ola bilər. GitHub Actions bulud yığımı iPhone brauzerindən idarə oluna bilər.
