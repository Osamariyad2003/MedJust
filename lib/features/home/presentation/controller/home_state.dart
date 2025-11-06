abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Map<String, dynamic>> menuItems;

  HomeLoaded({required this.menuItems});
}

class HomeError extends HomeState {
  final String message;

  HomeError({required this.message});
}
