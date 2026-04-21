import 'package:my_events/services/auth.dart';
import 'package:my_events/services/place.dart';
import 'package:my_events/app/event_details_page.dart';
import 'package:my_events/data/event_repository.dart';
import 'package:my_events/models/event.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

const double _cameraZoom = 16;
const Point _fallbackLocation = Point(
  latitude: 55.751244,
  longitude: 37.618423,
);

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.auth});

  final AuthBase auth;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final PlaceMark _placeMark = PlaceMark();
  final EventRepository _eventRepository = const EventRepository();
  YandexMapController? _mapController;
  bool _isSatellite = false;
  bool _isCentering = false;
  Point? _selectedPoint;

  static const CameraPosition _initialPosition = CameraPosition(
    target: _fallbackLocation,
    zoom: _cameraZoom,
  );

  Widget _placeMarkButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'locate',
          onPressed: _centerOnUserLocation,
          child: const Icon(Icons.location_searching),
        )
      ],
    );
  }

  Future<void> _centerOnUserLocation() async {
    if (_isCentering) return;
    setState(() => _isCentering = true);
    try {
      final LocationData? location = await _placeMark.findLocation();
      if (!mounted || _mapController == null || location == null) return;
      await _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(
              latitude: location.latitude ?? _fallbackLocation.latitude,
              longitude: location.longitude ?? _fallbackLocation.longitude,
            ),
            zoom: _cameraZoom,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCentering = false);
      }
    }
  }

  void _toggleMapType() {
    setState(() => _isSatellite = !_isSatellite);
  }

  void _onMapTap(Point point) {
    setState(() => _selectedPoint = point);
    _openCreateEventSheet(point);
  }

  Future<void> _openCreateEventSheet(Point point) async {
    await Navigator.of(context).push(
      ModalSheetRoute<void>(
        swipeDismissible: true,
        builder: (context) {
          return Sheet(
            snapGrid: const SheetSnapGrid(
              snaps: [SheetOffset(0.45), SheetOffset(0.9)],
            ),
            decoration: MaterialSheetDecoration(
              size: SheetSize.fit,
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
            ),
            child: _CreateEventSheet(
              initialPoint: point,
              auth: widget.auth,
              eventRepository: _eventRepository,
            ),
          );
        },
      ),
    );
  }

  List<MapObject> _buildEventMapObjects(List<Event> events) {
    return events.asMap().entries.map((entry) {
      final index = entry.key;
      final event = entry.value;
      final point = _eventPoint(event, index);
      return PlacemarkMapObject(
        mapId: MapObjectId('event_${event.id}'),
        point: point,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            scale: 0.10,
            image: BitmapDescriptor.fromAssetImage('images/logo.png'),
          ),
        ),
        opacity: 0.95,
        onTap: (_, __) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EventDetailsPage(event: event),
            ),
          );
        },
      );
    }).toList(growable: false);
  }

  Point _eventPoint(Event event, int index) {
    if (event.latitude != null && event.longitude != null) {
      return Point(latitude: event.latitude!, longitude: event.longitude!);
    }
    final ring = (index ~/ 8) + 1;
    final slot = index % 8;
    final latOffset = (slot - 3.5) * 0.0045 * ring;
    final lonOffset = (slot.isEven ? 1 : -1) * 0.005 * ring;
    return Point(
      latitude: _fallbackLocation.latitude + latOffset,
      longitude: _fallbackLocation.longitude + lonOffset,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Event>>(
      stream: _eventRepository.watchEvents(),
      initialData: _eventRepository.getPopularEvents(),
      builder: (context, snapshot) {
        final events = snapshot.data ?? const <Event>[];
        return Scaffold(
          body: YandexMap(
            onMapCreated: (controller) {
              _mapController = controller;
              controller.moveCamera(
                CameraUpdate.newCameraPosition(_initialPosition),
              );
            },
            mapType: _isSatellite ? MapType.satellite : MapType.map,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            logoAlignment: const MapAlignment(
              horizontal: HorizontalAlignment.left,
              vertical: VerticalAlignment.bottom,
            ),
            onMapTap: _onMapTap,
            mapObjects: _buildEventMapObjects(events),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          floatingActionButton: _placeMarkButton(),
        );
      },
    );
  }
}

class _CreateEventSheet extends StatefulWidget {
  const _CreateEventSheet({
    required this.initialPoint,
    required this.auth,
    required this.eventRepository,
  });

  final Point initialPoint;
  final AuthBase auth;
  final EventRepository eventRepository;

  @override
  State<_CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends State<_CreateEventSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();
  late final TextEditingController _addressController;
  String _category = 'Общее';
  DateTime? _startsAt;
  bool _isSaving = false;
  static const _categories = [
    'Общее',
    'Город',
    'Маркет',
    'Нетворкинг',
    'Лаунж'
  ];

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text:
          '${widget.initialPoint.latitude.toStringAsFixed(6)}, ${widget.initialPoint.longitude.toStringAsFixed(6)}',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _isSaving = true);
    try {
      final user = await widget.auth.currentUser();
      if (user == null) {
        throw StateError('Пользователь не авторизован');
      }
      await widget.eventRepository.createEvent(
        title: _titleController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        latitude: widget.initialPoint.latitude,
        longitude: widget.initialPoint.longitude,
        category: _category,
        imageUrl: _imageController.text,
        startsAt: _startsAt,
        createdBy: user.uid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Событие создано и добавлено на карту')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось создать событие: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Создать событие по точке',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _field('Название', _titleController),
                const SizedBox(height: 10),
                _field('Описание', _descriptionController, maxLines: 3),
                const SizedBox(height: 10),
                _field(
                  'Адрес (из карты)',
                  _addressController,
                  enabled: false,
                ),
                const SizedBox(height: 10),
                _field(
                  'Картинка (URL или путь до asset)',
                  _imageController,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Категория',
                    filled: true,
                  ),
                  items: _categories
                      .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _category = value ?? _category),
                ),
                const SizedBox(height: 10),
                FilledButton.tonal(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDate: _startsAt ?? DateTime.now(),
                    );
                    if (date == null || !context.mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 19, minute: 0),
                    );
                    if (time == null || !context.mounted) return;
                    setState(() {
                      _startsAt = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  },
                  child: Text(
                    _startsAt == null
                        ? 'Дата и время'
                        : 'Старт: ${_startsAt!.day}.${_startsAt!.month}.${_startsAt!.year} ${_startsAt!.hour.toString().padLeft(2, '0')}:${_startsAt!.minute.toString().padLeft(2, '0')}',
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: Text(_isSaving ? 'Сохраняем...' : 'Создать событие'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      validator: enabled
          ? (value) => (value == null || value.trim().isEmpty)
              ? 'Поле обязательно'
              : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
      ),
    );
  }
}
