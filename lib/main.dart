import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/storage_service.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/marketplace_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'core/l10n/locale_provider.dart';
import 'core/navigation/app_navigator.dart';
import 'core/navigation/auth_wrapper.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/l10n/so_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Log to crash reporting service here
  };

  try {
    await SupabaseService.init();
    await StorageService.init();
    runApp(const MyApp());
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize app: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const EmaraApp(),
    );
  }
}

class EmaraApp extends StatelessWidget {
  const EmaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    return MaterialApp(
      navigatorKey: AppNavigator.key,
      title: 'EMARA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      builder: EasyLoading.init(),
      locale: Locale(locale.language.name),
      supportedLocales: const [
        Locale('en'),
        Locale('so'),
        Locale('ar'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        SomaliMaterialLocalizations.delegate,
        SomaliCupertinoLocalizations.delegate,
      ],
      home: Directionality(
        textDirection: locale.isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: const AuthWrapper(),
      ),
    );
  }
}
