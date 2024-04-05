import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

class PaginatedDataResult<T> {
  final Paginated<T> page;
  final bool hasNext;
  final bool hasPrevious;

  const PaginatedDataResult(this.page, this.hasNext, this.hasPrevious);
}

class PaginatedWrapper<T> extends StatefulWidget {
  final Future<Paginated<T>> Function(bool) initialPageFunction;
  final Widget Function(BuildContext, AsyncSnapshot<PaginatedDataResult<T>>) onSuccess;
  final Widget Function(BuildContext, AsyncSnapshot<PaginatedDataResult<T>>) onLoading;

  const PaginatedWrapper({super.key, required this.initialPageFunction, required this.onSuccess, required this.onLoading});

  @override
  State<PaginatedWrapper<T>> createState() => PaginatedWrapperState<T>();
}

class PaginatedWrapperState<T> extends State<PaginatedWrapper<T>> {
  final Map<int, Paginated<T>> _pages = {};

  int? _currentPage;

  @override
  void initState() {
    super.initState();
    widget.initialPageFunction.call(false).then((page) {
      _pages[page.pageNumber] = page;
      setState(() => _currentPage = page.pageNumber);
    });
  }

  Future<void> _loadInitialPage({bool forceRetrieve = false}) async {
    final Paginated<T> page = await widget.initialPageFunction.call(forceRetrieve);
    _pages[page.pageNumber] = page;
    setState(() => _currentPage = page.pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    return _currentPage == null
        ? widget.onLoading.call(context, AsyncSnapshot<PaginatedDataResult<T>>.waiting())
        : widget.onSuccess.call(
            context,
            AsyncSnapshot<PaginatedDataResult<T>>.withData(
                ConnectionState.done,
                PaginatedDataResult(_pages[_currentPage] ?? const Paginated(pageNumber: 0, limit: 0, total: 0, items: []),
                    hasNext, hasPrevious)));
  }

  bool get hasNext => _pages[_currentPage]?.hasNext ?? false;

  bool get hasPrevious => _pages[_currentPage]?.hasPrevious ?? false;

  Future<void> reset() {
    _pages.clear();
    return _loadInitialPage(forceRetrieve: true);
  }

  Future<void>? nextPage(Restrr api) async {
    final Paginated<T>? currentPage = _pages[_currentPage];
    if (currentPage == null || !currentPage.hasNext) {
      return;
    }
    if (!_pages.containsKey(currentPage.pageNumber + 1)) {
      final Paginated<T> nextPage = await currentPage.nextPage!(api);
      _pages[nextPage.pageNumber] = nextPage;
    }
    setState(() => _currentPage = currentPage.pageNumber + 1);
  }

  Future<void>? previousPage(Restrr api) async {
    final Paginated<T>? currentPage = _pages[_currentPage];
    if (currentPage == null || !currentPage.hasPrevious) {
      return;
    }
    if (!_pages.containsKey(currentPage.pageNumber - 1)) {
      final Paginated<T> previousPage = await currentPage.previousPage!(api);
      _pages[previousPage.pageNumber] = previousPage;
    }
    setState(() => _currentPage = currentPage.pageNumber - 1);
  }
}
