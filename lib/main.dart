import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

//providers
import './providers/api_provider.dart';
import './providers/authentication_provider.dart';
import './providers/data_provider.dart';
import './providers/location_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MultiProvider(
      providers: [
        Provider(
          create: (ctx) => ApiProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => LocationProvider(),
        ),
        ChangeNotifierProxyProvider<ApiProvider, AuthenticationProvider>(
            create: null,
            update: (ctx, apiObject, _) =>
                AuthenticationProvider(apiObject.baseUrl)),
        ChangeNotifierProxyProvider2<ApiProvider, AuthenticationProvider,
            DataProvider>(
          create: null,
          update: (ctx, apiObject, _) => DataProvider(apiObject.baseUrl),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Text('Home'),
      ),
    );
  }
}
