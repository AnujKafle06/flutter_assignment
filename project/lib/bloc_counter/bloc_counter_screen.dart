import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'counter_bloc.dart';
import 'counter_event.dart';
import 'counter_state.dart';

class BlocCounterScreen extends StatelessWidget {
  const BlocCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterBloc(),
      child: const BlocCounterView(),
    );
  }
}

class BlocCounterView extends StatelessWidget {
  const BlocCounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: BlocBuilder<CounterBloc, CounterState>(
                    builder: (context, state) {
                      return TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 400),
                        tween: Tween(begin: 0.8, end: 1.0),
                        curve: Curves.elasticOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Counter",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) {
                                      return SlideTransition(
                                        position:
                                            Tween<Offset>(
                                              begin: const Offset(0, 0.3),
                                              end: Offset.zero,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutBack,
                                              ),
                                            ),
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      key: ValueKey(state.counter),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        '${state.counter}',
                                        style: TextStyle(
                                          fontSize: 72,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildStatsRow(context, state),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: const _CounterActions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, CounterState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          context,
          icon: Icons.trending_up,
          label: 'Positive',
          value: state.counter > 0,
          color: Colors.green,
        ),
        _buildStatItem(
          context,
          icon: Icons.radio_button_checked,
          label: 'Zero',
          value: state.counter == 0,
          color: Colors.blue,
        ),
        _buildStatItem(
          context,
          icon: Icons.trending_down,
          label: 'Negative',
          value: state.counter < 0,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool value,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: value ? color.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? color : Colors.grey.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Icon(icon, size: 20, color: value ? color : Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: value ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterActions extends StatelessWidget {
  const _CounterActions();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, CounterState>(
      builder: (context, state) {
        final bloc = context.read<CounterBloc>();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                icon: Icons.remove,
                onPressed: () => bloc.add(DecrementEvent()),
                tooltip: 'Decrement',
                color: Colors.red,
                isEnabled: true,
              ),
              _buildActionButton(
                context,
                icon: Icons.refresh,
                onPressed: () => bloc.add(ResetEvent()),
                tooltip: 'Reset',
                color: Colors.blue,
                isEnabled: state.counter != 0,
              ),
              _buildActionButton(
                context,
                icon: Icons.add,
                onPressed: () => bloc.add(IncrementEvent()),
                tooltip: 'Increment',
                color: Colors.green,
                isEnabled: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    required Color color,
    required bool isEnabled,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isEnabled
                  ? color.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isEnabled
                    ? color.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(icon, size: 28, color: isEnabled ? color : Colors.grey),
          ),
        ),
      ),
    );
  }
}
