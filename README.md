# My Events

Flutter-приложение для просмотра и поиска событий с карточками, деталями, избранным, картой, профилем и базовыми настройками.

## Что есть в проекте

- Современный Flutter (null-safety, Material 3).
- Экран авторизации (анонимный вход через Firebase Auth).
- Главный экран с карточками событий в фирменном стиле.
- Детальная страница события.
- Страница всех событий.
- Поиск по событиям.
- Избранное (сохранение в Firestore для пользователя).
- Карта (`google_maps_flutter` + `location`).
- Профиль (загрузка и редактирование).
- Настройки (переключение темы).
- Экран создания события (форма + сохранение в Firestore).
- Базовый контур аналитики (`firebase_analytics`).
- Базовый контур уведомлений (`firebase_messaging` + `flutter_local_notifications`).

## Архитектура

Проект разделен на базовые слои:

- `lib/models` — доменные модели (`Event`).
- `lib/data` — источники данных (`EventRepository`).
- `lib/state` — состояние (`EventsController`, `FavoritesController` и scope).
- `lib/app` — страницы приложения.
- `lib/common_widgets` — переиспользуемые UI-компоненты.
- `lib/services` — интеграции (Auth, Place, Theme customization).

## Навигация (нижнее меню)

- `Главная`
- `События`
- `Избранное`
- `Поиск`
- `Карта`
- `Профиль`
- `Настройки`

## Запуск

```bash
flutter pub get
flutter run
```

## Проверка качества

```bash
flutter analyze
flutter test
```

## MVP и критерии готовности

- Definition of Done и acceptance criteria: `MVP_CHECKLIST.md`
- Firestore security rules: `firestore.rules`
- Firestore indexes: `firestore.indexes.json`
- CI pipeline: `.github/workflows/flutter_ci.yml`

## Планы развития

- Подключить реальное создание/редактирование событий через Firestore.
- Добавить фильтры по дате/категориям.
- Реализовать персональный профиль пользователя.
