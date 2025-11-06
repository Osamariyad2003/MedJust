import 'dart:async';
import 'home_event.dart';
import 'home_state.dart';
import '../../../../core/constants/app_constants.dart';

class HomeBloc {
  final StreamController<HomeState> _stateController =
      StreamController<HomeState>.broadcast();
  Stream<HomeState> get stream => _stateController.stream;

  HomeState _currentState = HomeInitial();
  HomeState get state => _currentState;

  HomeBloc() {
    _initializeHome();
  }

  void add(HomeEvent event) {
    if (event is HomeInitializeRequested) {
      _initializeHome();
    } else if (event is HomeRefreshRequested) {
      _refreshHome();
    }
  }

  void _emit(HomeState state) {
    _currentState = state;
    _stateController.add(state);
  }

  void _initializeHome() {
    _emit(HomeLoading());

    final menuItems = [
      {
        'title': 'Years',
        'icon': 'school',
        'route': AppConstants.yearsRoute,
        'color': 0xFF2196F3,
      },
      {
        'title': 'Professors',
        'icon': 'person',
        'route': AppConstants.professorsRoute,
        'color': 0xFF4CAF50,
      },
      {
        'title': 'News',
        'icon': 'article',
        'route': AppConstants.newsRoute,
        'color': 0xFFFF9800,
      },
      {
        'title': 'Store',
        'icon': 'store',
        'route': AppConstants.storeRoute,
        'color': 0xFF9C27B0,
      },
      {
        'title': 'GPA Calculator',
        'icon': 'calculate',
        'route': AppConstants.gpaCalculatorRoute,
        'color': 0xFFE91E63,
      },
      {
        'title': 'University Map',
        'icon': 'map',
        'route': AppConstants.universityMapRoute,
        'color': 0xFF607D8B,
      },
    ];

    _emit(HomeLoaded(menuItems: menuItems));
  }

  void _refreshHome() {
    _initializeHome();
  }

  void dispose() {
    _stateController.close();
  }
}
