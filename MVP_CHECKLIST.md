# MVP Definition of Done

## Scope
- Auth + profile
- Event CRUD
- Discovery (feed/search/filters)
- Favorites
- Notifications

## Acceptance Criteria

### 1) Auth + Profile
- User can sign in and open the app shell.
- User profile loads from Firestore and can be edited.
- Profile update shows success/error feedback.

### 2) Event CRUD
- User can create event with required fields validation.
- User can edit own events.
- Validation and backend errors are shown in unified user-facing format.

### 3) Discovery
- Events list supports pagination.
- Search works by title and description.
- Filters by category and date update result set correctly.
- Empty and loading states are explicit and understandable.

### 4) Favorites
- User can add/remove event from favorites.
- Favorites are persisted in Firestore under current user.
- Favorites list handles empty state and network errors.

### 5) Notifications
- User can opt in/out to notifications.
- App requests and stores notification permissions status.
- Local reminder can be scheduled for event start time.
- Push token registration flow is implemented with graceful fallback.

## Release Readiness Checklist
- `flutter analyze` passes.
- `flutter test` passes.
- CI runs analyze + test on pull requests.
- Firestore rules and indexes are versioned in repository.
- Crash and product analytics events are tracked for critical journeys.
