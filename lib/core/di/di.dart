import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:med_just/core/models/year_model.dart';
import 'package:med_just/features/auth/data/repo/auth_repository.dart';
import 'package:med_just/features/auth/presentation/controller/auth_bloc.dart';
import 'package:med_just/features/guidies/data/guide_data_sorce.dart';
import 'package:med_just/features/guidies/data/repository/guide_repository.dart';
import 'package:med_just/features/guidies/presentation/controller/guide_bloc.dart';
import 'package:med_just/features/home/presentation/controller/home_bloc.dart';
import 'package:med_just/features/news/data/news_data_source.dart';
import 'package:med_just/features/news/data/news_repository.dart';
import 'package:med_just/features/news/presentation/bloc/news_bloc.dart';
import 'package:med_just/features/news/presentation/bloc/news_event.dart';
import 'package:med_just/features/pomodoro/data/pomodoro_data_source.dart';
import 'package:med_just/features/pomodoro/data/pomodoro_repository.dart';
import 'package:med_just/features/pomodoro/presentation/controller/poromdo_bloc.dart';
import 'package:med_just/features/professors/data/professor_data_source.dart';
import 'package:med_just/features/professors/data/professor_repo.dart';
import 'package:med_just/features/professors/presentation/bloc/professor_bloc.dart';
import 'package:med_just/features/profile/data/profile_data_source.dart';
import 'package:med_just/features/profile/data/profile_repo.dart';
import 'package:med_just/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:med_just/features/resourses/data/resources_repository.dart';
import 'package:med_just/features/resourses/data/year_data_source.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_bloc.dart';
import 'package:med_just/features/sidebar/data/data_source/sidebar_data_source.dart';
import 'package:med_just/features/sidebar/data/repo/sidebar_repo.dart';
import 'package:med_just/features/sidebar/presentation/bloc/sidebar_bloc.dart';
import 'package:med_just/features/store/data/store_data_source.dart';
import 'package:med_just/features/store/data/store_repo.dart';
import 'package:med_just/features/store/presentation/bloc/store_bloc.dart';
import 'package:med_just/features/university_map/data/maps_data_source.dart';
import 'package:med_just/features/university_map/data/maps_repo.dart';
import 'package:med_just/features/university_map/presentation/bloc/maps_bloc.dart';

final di = GetIt.instance;
AuthBloc? _authBloc;

Future<void> setupLocator() async {
  await Hive.initFlutter();
  await Hive.openBox('userBox');

  // Register data sources
  di.registerLazySingleton<ResourcesDataSource>(
    () => ResourcesFirestoreDataSource(),
  );
  di.registerLazySingleton<NewsFirestoreDataSource>(
    () => NewsFirestoreDataSource(),
  );
  di.registerLazySingleton<SidebarDataSource>(() => SidebarDataSource());
  di.registerLazySingleton<ProfessorsDataSource>(
    () => ProfessorsFirestoreDataSource(),
  );
  // di.registerLazySingleton<AuthDataSource>(() => AuthFirestoreDataSource());
  di.registerLazySingleton<StoreDataSource>(() => StoreFirestoreDataSource());
  di.registerLazySingleton<MapsDataSource>(() => MapsFirestoreDataSource());
  di.registerLazySingleton<ProfileDataSource>(
    () => ProfileFirestoreDataSource(),
  );
  di.registerLazySingleton<LocalGuideDataSource>(() => LocalGuideDataSource());
  di.registerLazySingleton<PomodoroDataSource>(() => PomodoroDataSource());

  // Register repositories
  di.registerLazySingleton<NewsRepository>(
    () => NewsRepository(dataSource: di<NewsFirestoreDataSource>()),
  );
  di.registerLazySingleton<ResourcesRepository>(() => ResourcesRepository());
  di.registerLazySingleton<AuthRepository>(() => AuthRepository());
  di.registerLazySingleton<SidebarRepo>(
    () => SidebarRepo(dataSource: di<SidebarDataSource>()),
  );
  di.registerLazySingleton<ProfessorsRepository>(() => ProfessorsRepository());
  di.registerLazySingleton<StoreRepository>(
    () => StoreRepository(dataSource: di<StoreDataSource>()),
  );
  di.registerLazySingleton<MapsRepository>(
    () => MapsRepository(dataSource: di<MapsDataSource>()),
  );
  di.registerLazySingleton<ProfileRepository>(
    () => FirebaseProfileRepository(),
  );
  di.registerLazySingleton<GuideRepository>(() => GuideRepository());
  di.registerLazySingleton<PomodoroRepository>(() => PomodoroRepository());

  // Register blocs
  di.registerLazySingleton<AuthBloc>(() {
    _authBloc ??= AuthBloc(authRepository: di<AuthRepository>());
    return _authBloc!;
  });
  di.registerFactory(() => HomeBloc());
  di.registerFactory(
    () => NewsBloc(repository: di<NewsRepository>())..add(LoadAllNews()),
  );
  di.registerFactory(
    () => ResourcesBloc(repository: di<ResourcesRepository>()),
  );
  di.registerFactory(() => SideBarBloc(di<SidebarRepo>()));
  di.registerFactory<ProfessorsBloc>(
    () => ProfessorsBloc(repository: di<ProfessorsRepository>()),
  );
  di.registerFactory<StoreBloc>(
    () => StoreBloc(repository: di<StoreRepository>()),
  );
  di.registerFactory<MapsBloc>(
    () => MapsBloc(repository: di<MapsRepository>()),
  );
  di.registerFactory<ProfileBloc>(
    () => ProfileBloc(repository: di<ProfileRepository>()),
  );
  di.registerFactory<GuideBloc>(
    () => GuideBloc(repository: di<GuideRepository>()),
  );
  di.registerFactory<PomodoroBloc>(
    () => PomodoroBloc(repository: di<PomodoroRepository>()),
  );
}
