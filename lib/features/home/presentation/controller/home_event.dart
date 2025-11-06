abstract class HomeEvent {}

class HomeInitializeRequested extends HomeEvent {}

class HomeRefreshRequested extends HomeEvent {}

class HomeNavigateRequested extends HomeEvent {
  final String route;

  HomeNavigateRequested({required this.route});
}
