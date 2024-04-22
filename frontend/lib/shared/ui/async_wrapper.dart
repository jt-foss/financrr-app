import 'package:flutter/cupertino.dart';

class FutureWrapper<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext, AsyncSnapshot<T>) onSuccess;
  final Widget Function(BuildContext, AsyncSnapshot<T>) onLoading;
  final Widget Function(BuildContext, AsyncSnapshot<T>) onError;

  const FutureWrapper(
      {super.key, required this.future, required this.onSuccess, required this.onLoading, required this.onError});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return onLoading.call(context, snapshot);
            default:
              if (snapshot.hasError) {
                return onError.call(context, snapshot);
              } else {
                return onSuccess.call(context, snapshot);
              }
          }
        });
  }
}

class StreamWrapper<T> extends StatelessWidget {
  final Stream<T> stream;
  final Widget Function(BuildContext, AsyncSnapshot<T>) onSuccess;
  final Widget Function(BuildContext, AsyncSnapshot<T>) onLoading;
  final Widget Function(BuildContext, AsyncSnapshot<T>) onError;
  final T? initialData;

  const StreamWrapper(
      {super.key,
      required this.stream,
      required this.onSuccess,
      required this.onLoading,
      required this.onError,
      this.initialData});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
        stream: stream,
        initialData: initialData,
        builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return onLoading.call(context, snapshot);
            default:
              if (snapshot.hasError) {
                return onError.call(context, snapshot);
              } else {
                return onSuccess.call(context, snapshot);
              }
          }
        });
  }
}
