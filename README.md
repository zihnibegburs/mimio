# Mimio

Tiimo tarzı görsel günlük planlayıcı — Flutter + Spring Boot + PostgreSQL + Redis.

## Hızlı Başlangıç

```bash
# 1. Veritabanlarını başlat
docker compose up -d

# 2. Backend
cd backend && ./gradlew bootRun

# 3. Flutter
cd mobile && flutter run
```

## Proje Yapısı

```
Mimio/
├── docs/PLAN.md          # Tiimo analizi + 10 fazlı geliştirme planı
├── docker-compose.yml    # PostgreSQL + Redis
├── backend/              # Spring Boot API
└── mobile/               # Flutter uygulaması
```

## Phase 9 — Widget & Web

```bash
# Web
cd mobile && flutter run -d chrome

# iOS widget (Xcode target kurulumu gerekir)
open ios/Runner.xcworkspace
# Detay: mobile/ios/WIDGET_SETUP.md
```

| Platform | Özellik |
|----------|---------|
| Web | Haftalık görünüm + responsive shell |
| Android | Ana ekran widget + bildirim Live Activity |
| iOS | Widget + Live Activity / Dynamic Island (Xcode setup) |

## AI (Ollama — Phase 6)

```bash
# Ollama kur (macOS: brew install ollama)
ollama serve
ollama pull llama3.2:3b

# veya Docker ile
docker compose up -d ollama
docker exec mimio-ollama ollama pull llama3.2:3b
```

| Method | Endpoint | Açıklama |
|--------|----------|----------|
| POST | `/api/v1/ai/breakdown` | Görevi adımlara böl |
| POST | `/api/v1/ai/plan` | Doğal dilden günlük plan |

## API (Phase 1–2)

| Method | Endpoint | Açıklama |
|--------|----------|----------|
| POST | `/api/v1/auth/register` | Kayıt |
| POST | `/api/v1/auth/login` | Giriş |
| GET | `/api/v1/timeline?date=` | Günlük timeline |
| GET | `/api/v1/focus/session` | Aktif odak oturumu |
| POST | `/api/v1/tasks` | Görev oluştur |
| POST | `/api/v1/tasks/{id}/start` | Görevi başlat |
| POST | `/api/v1/tasks/{id}/complete` | Görevi tamamla |

Detaylı faz planı için: [docs/PLAN.md](docs/PLAN.md)
