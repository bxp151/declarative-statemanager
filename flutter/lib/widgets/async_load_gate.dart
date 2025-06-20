import 'package:flutter/material.dart';

class AsyncLoadGate<T> extends StatefulWidget {
  // Future<T> function - the async task to perform
  final Future<T> Function() future;
  // widget to display while loading
  final Widget loading;
  // widget to display if error
  final Widget Function(Object error)? error;
  // function that receives the result (T) and returns a widget.
  final Widget Function(T result) onResult;

  const AsyncLoadGate({
    super.key,
    required this.future,
    required this.loading,
    required this.onResult,
    this.error,
  });

  // Creates the state class, parameterized by the same type T.
  @override
  State<AsyncLoadGate<T>> createState() => _AsyncLoadGateState<T>();
}

class _AsyncLoadGateState<T> extends State<AsyncLoadGate<T>> {
  // stores future so it's created only once
  late final Future<T> _future;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _future = widget.future();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.loading;
        }

        if (snapshot.hasError) {
          if (widget.error != null) {
            return widget.error!(snapshot.error!);
          }
          return const SizedBox(); // fallback if no error widget is supplied
        }

        if (!_handled) {
          _handled = true;
          // This contains a route, Problem, or any type
          final result = snapshot.data as T;
          return widget.onResult(result);
        }

        // If we've already handled the result, show loading or nothing
        return widget.loading;
      },
    );
  }
}
