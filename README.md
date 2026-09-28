# كليلة ودمنة — لعبة أندرويد (Godot 4.3)

## التشغيل محلياً
1. افتح المجلد في Godot 4.3 واضغط F5.
2. الاختبارات: `godot --headless -s tests/validate_stories.gd` و `godot --headless -s tests/smoke_test.gd`

## إضافة الأصوات (لاحقاً)
سجّل كل مقطع بصيغة `.ogg` وسمّه: `<id القصة>_<رقم المقطع بخانتين>.ogg`
ضعه في `assets/audio/voice/` — مثال: `lion_bull_01.ogg` ثم `lion_bull_02.ogg` …
لا حاجة لتعديل الكود: النص يتزامن تلقائياً مع طول الصوت، وبدون صوت يظهر بسرعة قراءة ثابتة.

## إضافة قصة
أنشئ ملفاً في `data/stories/` بنفس بنية الملفات الموجودة (id، order، title، moral، segments).

## GitHub Actions (`.github/workflows/android.yml`)
- كل push/PR: فحص القصص + اختبار دخان.
- كل push على main: APK تجريبي يظهر في Actions ← Artifacts.
- عند وسم `v1.0.0` مثلاً: AAB موقّع، ويُرفع إلى Google Play (Internal) إن وُجد السر.

### الأسرار (Settings ← Secrets and variables ← Actions)
| السر | المحتوى |
|---|---|
| `KEYSTORE_BASE64` | مفتاح النشر بصيغة base64: `base64 -w0 release.keystore` |
| `KEYSTORE_ALIAS` / `KEYSTORE_PASSWORD` | اسم المفتاح وكلمة المرور |
| `PLAY_SERVICE_ACCOUNT_JSON` | (اختياري) ملف JSON لحساب الخدمة من Play Console |

إنشاء مفتاح النشر (مرة واحدة، واحتفظ به في مكان آمن):
`keytool -genkey -v -keystore release.keystore -alias kalila -keyalg RSA -keysize 2048 -validity 10000`

## قبل النشر
- غيّر معرّف الحزمة `com.example.kaliladimna` في `export_presets.cfg` وفي `android.yml` (PACKAGE_NAME).
- استبدل `icon.svg` بأيقونتك (512×512).
- أول رفع إلى Play يكون يدوياً (إنشاء التطبيق ورفع أول AAB من Play Console)، وبعدها يعمل الرفع الآلي.
