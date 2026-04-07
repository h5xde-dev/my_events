import 'package:my_events/models/event.dart';

class EventRepository {
  const EventRepository();

  List<Event> getPopularEvents() {
    return const [
      Event(
        id: 'city-day',
        title: 'День города',
        description: 'Праздник в центре города',
        imageAsset: 'images/image_02.jpg',
      ),
      Event(
        id: 'fair',
        title: 'Ярмарка',
        description: 'Сезонные товары и еда',
        imageAsset: 'images/image_03.jpg',
      ),
      Event(
        id: 'coffee-evening',
        title: 'Кофе вечер',
        description: 'Нетворкинг и спикеры',
        imageAsset: 'images/image_04.jpg',
      ),
      Event(
        id: 'tobacco-tasting',
        title: 'Дегустация табака',
        description: 'Лаунж и новые миксы',
        imageAsset: 'images/image_01.png',
      ),
    ];
  }
}

