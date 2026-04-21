# My Events

Flutter-приложение для просмотра и поиска событий с карточками, деталями, избранным, картой, профилем и базовыми настройками.

## Что есть в проекте

- Современный Flutter (null-safety, Material 3).
- Экран авторизации (Google Sign-In через Firebase Auth, плюс анонимный режим).
- Главный экран с карточками событий в фирменном стиле.
- Детальная страница события.
- Страница всех событий.
- Поиск по событиям.
- Избранное (сохранение в Firestore для пользователя).
- Геймификация удержания: серия (streak) и бейджи в профиле.
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
- `lib/services` — интеграции (Auth, Analytics/Notifications, Place, Theme customization).

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

## Подключение Firebase

1. В Firebase Console включите `Authentication` (Google Sign-In) и `Firestore Database`.
2. Добавьте Android-конфиг:
   - файл `android/app/google-services.json` из Firebase → Project settings.
3. Добавьте iOS-конфиг:
   - файл `ios/Runner/GoogleService-Info.plist` из Firebase → Project settings (или Add app → iOS);
   - проверьте, что он добавлен в target `Runner` в Xcode.
4. Сгенерируйте Flutter-конфиг:
   - `flutterfire configure` (создаст `lib/firebase_options.dart`);
   - убедитесь, что в `lib/main.dart` используется `DefaultFirebaseOptions.currentPlatform`.

## Проверка качества

```bash
flutter analyze --no-fatal-infos
flutter test
```

## MVP и критерии готовности

- Definition of Done и acceptance criteria: `MVP_CHECKLIST.md`
- Firestore security rules: `firestore.rules`
- Firestore indexes: `firestore.indexes.json`
- CI pipeline: `.github/workflows/flutter_ci.yml`
- Геймификация (streak/бейджи): `lib/data/user_stats_repository.dart`, поля в `users/{uid}` (`favoritesCount`, `eventsCreatedCount`, `streakLength`, `lastActivityDayKey`, `earnedBadges`).

## Планы развития

- Подключить реальное создание/редактирование событий через Firestore.
- Добавить фильтры по дате/категориям.
- Реализовать персональный профиль пользователя.
