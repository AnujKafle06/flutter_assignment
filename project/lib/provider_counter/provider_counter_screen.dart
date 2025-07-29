import 'package:flutter/material.dart';
import 'package:project/provider_counter/counter_provider.dart';
import 'package:provider/provider.dart';

class ProviderCounterScreen extends StatelessWidget {
  const ProviderCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CounterProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Conter Provider")),
        body: Center(
          child: Consumer<CounterProvider>(
            builder: (_, provider, __) => Text(
              'Count: ${provider.count}',
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
        floatingActionButton: Consumer<CounterProvider>(
          builder: (_, provider, __) => FloatingActionButton(
            onPressed: provider.increment,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
