import 'package:postgres/postgres.dart';

/// Creates a [ResultRow] from a plain map for use in unit tests.
ResultRow makeRow(Map<String, dynamic> data) {
  final columns = data.keys
      .map(
        (k) => ResultSchemaColumn(
          typeOid: 0,
          type: Type.text,
          columnName: k,
        ),
      )
      .toList();
  return ResultRow(
    values: data.values.toList(),
    schema: ResultSchema(columns),
  );
}

/// Creates a [Result] from a list of plain maps for use in unit tests.
Result makeResult(List<Map<String, dynamic>> rows) {
  if (rows.isEmpty) {
    return Result(rows: [], affectedRows: 0, schema: ResultSchema([]));
  }
  final schema = ResultSchema(
    rows.first.keys
        .map(
          (k) => ResultSchemaColumn(
            typeOid: 0,
            type: Type.text,
            columnName: k,
          ),
        )
        .toList(),
  );
  return Result(
    rows: rows.map(makeRow).toList(),
    affectedRows: rows.length,
    schema: schema,
  );
}
