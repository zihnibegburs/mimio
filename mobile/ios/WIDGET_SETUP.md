# iOS Widget & Live Activities Kurulumu

Swift dosyaları `ios/MimioWidget/` altında hazır. Xcode'da bir kez target eklemen gerekiyor:

## Adımlar

1. `open ios/Runner.xcworkspace`
2. **File → New → Target → Widget Extension**
3. Product Name: `MimioWidget`, Embed in Application: **Runner**
4. Xcode'un oluşturduğu varsayılan Swift dosyasını sil
5. `ios/MimioWidget/MimioWidget.swift` dosyasını target'a ekle
6. `ios/MimioWidget/Info.plist` ve `MimioWidget.entitlements` kullan
7. **Runner** ve **MimioWidget** target'larına **App Groups** capability ekle:
   - `group.com.mimio.mimio`
8. Runner için `ios/Runner/Runner.entitlements` dosyasını Signing & Capabilities'e bağla

## Live Activities

- Fiziksel iPhone (iOS 16.1+) gerekir
- Dynamic Island: iPhone 14 Pro+
- Görev başlatınca Live Activity otomatik açılır

## Apple Watch

Opsiyonel faz — şu an kapsam dışı. Watch complication için ayrı watchOS target gerekir.
