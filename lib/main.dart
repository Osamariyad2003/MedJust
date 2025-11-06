import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:med_just/core/di/di.dart';
import 'package:med_just/core/local/app_locle.dart';
import 'package:med_just/core/local/bloc_observer.dart';
import 'package:med_just/core/routes/app_router.dart';
import 'package:med_just/core/routes/routers.dart';
import 'package:med_just/core/shared/themes/app_theme.dart';
import 'package:med_just/features/auth/presentation/controller/auth_bloc.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_bloc.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_event.dart';
import 'package:med_just/features/sidebar/presentation/bloc/sidebar_bloc.dart';
import 'package:med_just/features/sidebar/presentation/bloc/sidebar_event.dart';
import 'package:med_just/features/store/presentation/bloc/store_bloc.dart';
import 'package:med_just/firebase_options.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Bloc.observer = MyBlocObserver();
  await setupLocator();
  await Hive.openBox('userBox');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalization _localization = FlutterLocalization.instance;

  @override
  void initState() {
    super.initState();
    _configureLocalization();
  }

  void _configureLocalization() {
    _localization.init(
      mapLocales: [
        const MapLocale('ar', AppLocale.AR),
        const MapLocale('en', AppLocale.EN),
      ],
      initLanguageCode: 'en',
    );
    _localization.onTranslatedLanguage = _onTranslatedLanguage;
  }

  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di<AuthBloc>(),
          lazy: false,
        ),
        BlocProvider<SideBarBloc>(
          create: (context) => di<SideBarBloc>()..add(LoadUserData("", "")),
        ),
        BlocProvider<StoreBloc>(create: (context) => di<StoreBloc>()),
        BlocProvider<ResourcesBloc>(
          create: (context) => di<ResourcesBloc>()..add(LoadYears()),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppLocale.title.getString(context),

            // Flutter Localization configuration
            supportedLocales: _localization.supportedLocales,
            localizationsDelegates: _localization.localizationsDelegates,
            locale: _localization.currentLocale,

            theme: AppTheme.lightTheme,

            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: Routers.splashRoute,
          );
        },
      ),
    );
  }
}
