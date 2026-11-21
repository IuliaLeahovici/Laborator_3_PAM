
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_screen.dart';
import 'cubit/product_cubit.dart';
import 'repositories/product_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GemStoreApp());
}

class GemStoreApp extends StatelessWidget {
  const GemStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      ProductCubit(ProductRepository())..loadProducts(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GemStore',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
