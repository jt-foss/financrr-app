import 'package:financrr_frontend/widgets/paginated_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

class PaginatedTable<T> extends StatefulWidget {
  final Restrr api;
  final Future<Paginated<T>> Function(Restrr) initialPageFunction;
  final DataRow Function(T) rowBuilder;
  final List<DataColumn> columns;
  final bool fillWithEmptyRows;
  final double? width;

  const PaginatedTable({super.key, required this.api, required this.initialPageFunction, required this.rowBuilder, required this.columns, this.width, this.fillWithEmptyRows = false});

  @override
  State<PaginatedTable<T>> createState() => PaginatedTableState<T>();
}

class PaginatedTableState<T> extends State<PaginatedTable<T>> {
  final GlobalKey<PaginatedWrapperState> _paginatedKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return PaginatedWrapper(
      key: _paginatedKey,
      initialPageFunction: () => widget.initialPageFunction.call(widget.api),
      onLoading: (context, snap) => const Center(child: CircularProgressIndicator()),
      onSuccess: (context, snap) {
        final PaginatedDataResult<T> result = snap.data as PaginatedDataResult<T>;
        return Column(
          children: [
            SizedBox(
              width: widget.width,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Symbol')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('ISO')),
                ],
                rows: [
                  for (T item in result.page.items)
                    widget.rowBuilder(item),
                  if (widget.fillWithEmptyRows && result.page.items.length < result.page.limit)
                    for (int i = 0; i < result.page.limit - result.page.items.length; i++)
                      const DataRow(
                          cells: [DataCell(Text('')), DataCell(Text('')), DataCell(Text(''))])
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: result.hasNext && !result.hasPrevious ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                children: [
                  if (result.hasPrevious)
                    TextButton.icon(
                      label: const Text('Previous'),
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => _paginatedKey.currentState?.previousPage(widget.api),
                    ),
                  if (result.hasNext)
                    TextButton.icon(
                      label: const Icon(Icons.arrow_forward),
                      icon: const Text('Next'),
                      onPressed: () => _paginatedKey.currentState?.nextPage(widget.api),
                    ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
