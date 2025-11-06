import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/features/auth/data/repo/auth_repository.dart';
import 'package:med_just/features/azkar/presentation/screens/azkar_page.dart';
import 'package:med_just/features/gpa_calculator/presentation/gpa_selector.dart';
import 'package:med_just/features/guidies/presentation/controller/guide_bloc.dart';
import 'package:med_just/features/guidies/presentation/screens/chat_screen.dart';
import 'package:med_just/features/home/presentation/views/home_page.dart';
import 'package:med_just/features/news/presentation/bloc/news_event.dart';
import 'package:med_just/features/pomodoro/presentation/controller/poromdo_bloc.dart';
import 'package:med_just/features/pomodoro/presentation/pages/pomodoro_page.dart';
import 'package:med_just/features/professors/presentation/screens/professor_list_screen.dart';
import 'package:med_just/features/profile/presentation/screens/profile_screen.dart';
import 'package:med_just/features/sidebar/presentation/bloc/sidebar_bloc.dart';
import 'package:med_just/features/sidebar/presentation/screens/sidebar_screen.dart';
import 'package:med_just/features/store/presentation/bloc/store_bloc.dart';
import 'package:med_just/features/university_map/presentation/bloc/maps_bloc.dart';
import 'package:med_just/features/university_map/presentation/bloc/maps_event.dart';
import 'package:provider/provider.dart';
import 'package:med_just/core/di/di.dart';
import 'package:med_just/features/auth/presentation/controller/auth_bloc.dart';
import 'package:med_just/features/home/presentation/controller/home_bloc.dart';
import 'package:med_just/features/news/presentation/bloc/news_bloc.dart';

import 'package:med_just/features/news/presentation/screens/news_list_screen.dart';
import 'package:med_just/features/professors/presentation/bloc/professor_bloc.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_bloc.dart';
import 'package:med_just/features/splash_boarding/preseentation/screnns/splash_screen.dart';
import '../../features/auth/presentation/views/login_page.dart';
import '../../features/auth/presentation/views/register_page.dart';
import '../../features/gpa_calculator/presentation/gpa_calculator_page.dart';
import '../../features/university_map/presentation/screens/university_map_page.dart';
import 'routers.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routers.initialRoute:
        return MaterialPageRoute(builder: (_) => SplashScreen());

      case Routers.homeRoute:
        return MaterialPageRoute(
          builder:
              (_) => MultiBlocProvider(
                providers: [
                  BlocProvider<ResourcesBloc>(
                    create: (_) => di<ResourcesBloc>(),
                  ),

                  BlocProvider<StoreBloc>(create: (_) => di<StoreBloc>()),
                ],
                child: HomePage(),
              ),
        );
      case Routers.loginRoute:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider<AuthBloc>(
                // Directly create the AuthBloc without using GetIt, as a temporary solution
                create: (_) => AuthBloc(authRepository: AuthRepository()),
                child: LoginPage(),
              ),
        );

      case Routers.registerRoute:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                // Directly create the AuthBloc without using GetIt, as a temporary solution
                create: (_) => AuthBloc(authRepository: AuthRepository()),
                child: RegisterPage(),
              ),
        );
      case Routers.guide:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (_) => di<GuideBloc>(),
                child: ChatScreen(),
              ),
        );

      case Routers.professorsRoute:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (_) => di<ProfessorsBloc>(),
                child: ProfessorsListScreen(),
              ),
        );
      case Routers.universityMapRoute:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (_) => di<MapsBloc>()..add(LoadAllLocations()),
                child: const UniversityMapScreen(),
              ),
        );

      case Routers.newsRoute:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (_) => di<NewsBloc>(),
                child: NewsListScreen(),
              ),
        );

      case Routers.sidebarRoute:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (_) => di<SideBarBloc>(),
                child: SideMenu(),
              ),
        );
      case Routers.profileRoute:
        return MaterialPageRoute(builder: (context) => ProfileScreen());

      case Routers.gpaCalculatorRoute:
        return MaterialPageRoute(builder: (_) => GpaSelectorPage());
      case Routers.azkarRoute:
        return MaterialPageRoute(builder: (_) => AzkarPage());
      case Routers.pomodoro:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (_) => di<PomodoroBloc>(),
                child: PomodoroPage(),
              ),
        );

      // case Routers.gpaCalculatorRoute:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (_) => di<GpaBloc>(),
      //       child: GpaCalculatorPage(),
      //     ),
      //   );

      // case Routers.universityMapRoute:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (_) => di<MapBloc>(),
      //       child: UniversityMapPage(),
      //     ),
      //   );

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
