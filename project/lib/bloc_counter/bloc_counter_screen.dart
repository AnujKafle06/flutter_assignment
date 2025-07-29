import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/bloc_counter/counter_event.dart';

import 'counter_bloc.dart';
import 'counter_state.dart';

class BlocCounterScreen extends StatelessWidget {
  const BlocCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Bloc Counter')),
        body: BlocBuilder<CounterBloc, CounterState>(
          builder: (_, state) => Center(
            child: Text(
              'Counter ${state.counter}',
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            // Now this context can see the BlocProvider above
            return context.read<CounterBloc>().addButton();
          },
        ),
      ),
    );
  }
}

extension on CounterBloc {
  FloatingActionButton addButton() {
    return FloatingActionButton(
      onPressed: () => add(IncrementEvent()),
      child: const Icon(Icons.add),
    );
  }
}
