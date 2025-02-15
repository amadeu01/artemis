import 'dart:convert';

import 'package:artemis/generator/data.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';

import 'package:artemis/schema/graphql.dart';
import 'package:artemis/builder.dart';

String jsonFromSchema(GraphQLSchema schema) => json.encode({
      'data': {'__schema': schema.toJson()}
    });

void main() {
  group('On query generation', () {
    test('When not configured, nothing will be generated', () async {
      final GraphQLQueryBuilder anotherBuilder =
          graphQLQueryBuilder(BuilderOptions({}));
      final GraphQLSchema schema = GraphQLSchema(
          queryType:
              GraphQLType(name: 'SomeObject', kind: GraphQLTypeKind.OBJECT),
          types: [
            GraphQLType(name: 'String', kind: GraphQLTypeKind.SCALAR),
            GraphQLType(name: 'Int', kind: GraphQLTypeKind.SCALAR),
            GraphQLType(
                name: 'SomeObject',
                kind: GraphQLTypeKind.OBJECT,
                fields: [
                  GraphQLField(
                      name: 's',
                      type: GraphQLType(
                          name: 'String', kind: GraphQLTypeKind.SCALAR)),
                  GraphQLField(
                      name: 'i',
                      type: GraphQLType(
                          name: 'Int', kind: GraphQLTypeKind.SCALAR)),
                ]),
          ]);

      anotherBuilder.onBuild = expectAsync1((_) {}, count: 0);

      await testBuilder(anotherBuilder, {
        'a|api.schema.json': jsonFromSchema(schema),
        'a|some_query.query.graphql': 'query some_query { s, i }',
      });
    });

    test('A simple query yields simple classes', () async {
      final GraphQLQueryBuilder anotherBuilder =
          graphQLQueryBuilder(BuilderOptions({
        'generate_helpers': false,
        'schema_mapping': [
          {
            'schema': 'api.schema.json',
            'queries_glob': '**.graphql',
            'output': 'lib/some_query.dart',
          }
        ]
      }));
      final GraphQLSchema schema = GraphQLSchema(
          queryType:
              GraphQLType(name: 'SomeObject', kind: GraphQLTypeKind.OBJECT),
          types: [
            GraphQLType(name: 'String', kind: GraphQLTypeKind.SCALAR),
            GraphQLType(name: 'Int', kind: GraphQLTypeKind.SCALAR),
            GraphQLType(
                name: 'SomeObject',
                kind: GraphQLTypeKind.OBJECT,
                fields: [
                  GraphQLField(
                      name: 's',
                      type: GraphQLType(
                          name: 'String', kind: GraphQLTypeKind.SCALAR)),
                  GraphQLField(
                      name: 'i',
                      type: GraphQLType(
                          name: 'Int', kind: GraphQLTypeKind.SCALAR)),
                ]),
          ]);

      anotherBuilder.onBuild = expectAsync1((definition) {
        expect(
          definition,
          LibraryDefinition(
            'some_query',
            queries: [
              QueryDefinition(
                'SomeQuery',
                'query some_query { s, i }',
                classes: [
                  ClassDefinition('SomeQuery', [
                    ClassProperty('String', 's'),
                    ClassProperty('int', 'i'),
                  ])
                ],
              ),
            ],
          ),
        );
      }, count: 1);

      await testBuilder(anotherBuilder, {
        'a|api.schema.json': jsonFromSchema(schema),
        'a|some_query.query.graphql': 'query some_query { s, i }',
      }, outputs: {
        'a|lib/some_query.dart': '''// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
part 'some_query.g.dart';

@JsonSerializable(explicitToJson: true)
class SomeQuery with EquatableMixin {
  SomeQuery();

  factory SomeQuery.fromJson(Map<String, dynamic> json) =>
      _\$SomeQueryFromJson(json);

  String s;

  int i;

  @override
  List<Object> get props => [s, i];
  Map<String, dynamic> toJson() => _\$SomeQueryToJson(this);
}
''',
      });
    });

    test('A simple query with list input', () async {
      final GraphQLQueryBuilder anotherBuilder =
          graphQLQueryBuilder(BuilderOptions({
        'generate_helpers': false,
        'schema_mapping': [
          {
            'schema': 'api.schema.json',
            'queries_glob': '**.graphql',
            'output': 'lib/some_query.dart',
          }
        ]
      }));
      final GraphQLSchema schema = GraphQLSchema(
          queryType:
              GraphQLType(name: 'SomeObject', kind: GraphQLTypeKind.OBJECT),
          types: [
            GraphQLType(name: 'String', kind: GraphQLTypeKind.SCALAR),
            GraphQLType(name: 'Int', kind: GraphQLTypeKind.SCALAR),
            GraphQLType(
                name: 'List',
                kind: GraphQLTypeKind.LIST,
                ofType: GraphQLType(name: 'Int', kind: GraphQLTypeKind.SCALAR)),
            GraphQLType(
                name: 'SomeObject',
                kind: GraphQLTypeKind.OBJECT,
                fields: [
                  GraphQLField(
                      name: 's',
                      type: GraphQLType(
                          name: 'String', kind: GraphQLTypeKind.SCALAR)),
                  GraphQLField(
                      name: 'i',
                      type: GraphQLType(
                          name: 'Int', kind: GraphQLTypeKind.SCALAR)),
                  GraphQLField(
                      name: 'list',
                      type: GraphQLType(
                          name: 'List',
                          kind: GraphQLTypeKind.LIST,
                          ofType: GraphQLType(
                              name: 'Int', kind: GraphQLTypeKind.SCALAR)),
                      args: [
                        GraphQLInputValue(
                          name: 'ints',
                          defaultValue: null,
                          type: GraphQLType(
                              name: 'List',
                              kind: GraphQLTypeKind.LIST,
                              ofType: GraphQLType(
                                  name: 'Int', kind: GraphQLTypeKind.SCALAR)),
                        )
                      ]),
                ]),
          ]);

      anotherBuilder.onBuild = expectAsync1((definition) {
        final libraryDefinition = LibraryDefinition(
          'some_query',
          queries: [
            QueryDefinition(
              'SomeQuery',
              'query some_query(\$ints: [Int]!) { s, i, list(ints: \$ints) }',
              inputs: [QueryInput('int', 'ints')],
              classes: [
                ClassDefinition('SomeQuery', [
                  ClassProperty('String', 's'),
                  ClassProperty('int', 'i'),
                  ClassProperty('List<int>', 'list')
                ])
              ],
            ),
          ],
        );
        expect(definition, libraryDefinition);
      }, count: 1);

      await testBuilder(anotherBuilder, {
        'a|api.schema.json': jsonFromSchema(schema),
        'a|some_query.query.graphql':
            'query some_query(\$ints: [Int]!) { s, i, list(ints: \$ints) }',
      }, outputs: {
        'a|lib/some_query.dart': '''// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
part 'some_query.g.dart';

@JsonSerializable(explicitToJson: true)
class SomeQuery with EquatableMixin {
  SomeQuery();

  factory SomeQuery.fromJson(Map<String, dynamic> json) =>
      _\$SomeQueryFromJson(json);

  String s;

  int i;

  List<int> list;

  @override
  List<Object> get props => [s, i, list];
  Map<String, dynamic> toJson() => _\$SomeQueryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SomeQueryArguments extends JsonSerializable with EquatableMixin {
  SomeQueryArguments({this.ints});

  factory SomeQueryArguments.fromJson(Map<String, dynamic> json) =>
      _\$SomeQueryArgumentsFromJson(json);

  final int ints;

  @override
  List<Object> get props => [ints];
  Map<String, dynamic> toJson() => _\$SomeQueryArgumentsToJson(this);
}
''',
      });
    });

    test('The selection from query can nest', () async {
      final GraphQLQueryBuilder anotherBuilder =
          graphQLQueryBuilder(BuilderOptions({
        'generate_helpers': false,
        'schema_mapping': [
          {
            'schema': 'api.schema.json',
            'queries_glob': '**.graphql',
            'output': 'lib/some_query.dart',
          }
        ]
      }));
      final GraphQLSchema schema = GraphQLSchema(
          queryType: GraphQLType(name: 'Query', kind: GraphQLTypeKind.OBJECT),
          types: [
            GraphQLType(name: 'String', kind: GraphQLTypeKind.SCALAR),
            GraphQLType(name: 'Query', kind: GraphQLTypeKind.OBJECT, fields: [
              GraphQLField(
                  name: 's',
                  type: GraphQLType(
                      name: 'String', kind: GraphQLTypeKind.SCALAR)),
              GraphQLField(
                  name: 'o',
                  type: GraphQLType(
                      name: 'SomeObject', kind: GraphQLTypeKind.OBJECT)),
            ]),
            GraphQLType(
                name: 'SomeObject',
                kind: GraphQLTypeKind.OBJECT,
                fields: [
                  GraphQLField(
                      name: 'st',
                      type: GraphQLType(
                          name: 'String', kind: GraphQLTypeKind.SCALAR)),
                  GraphQLField(
                      name: 'ob',
                      type: GraphQLType(
                          kind: GraphQLTypeKind.LIST,
                          ofType: GraphQLType(
                              name: 'AnotherObject',
                              kind: GraphQLTypeKind.OBJECT))),
                ]),
            GraphQLType(
                name: 'AnotherObject',
                kind: GraphQLTypeKind.OBJECT,
                fields: [
                  GraphQLField(
                      name: 'str',
                      type: GraphQLType(
                          name: 'String', kind: GraphQLTypeKind.SCALAR)),
                ]),
          ]);

      final queryString = '''
        query some_query {
          s
          o {
            st
            ob {
              str
            }
          }
        }
        ''';

      anotherBuilder.onBuild = expectAsync1((definition) {
        expect(
          definition,
          LibraryDefinition(
            'some_query',
            queries: [
              QueryDefinition(
                'SomeQuery',
                queryString,
                classes: [
                  ClassDefinition('SomeQuery', [
                    ClassProperty('String', 's'),
                    ClassProperty('SomeObject', 'o'),
                  ]),
                  ClassDefinition('SomeObject', [
                    ClassProperty('String', 'st'),
                    ClassProperty('List<AnotherObject>', 'ob'),
                  ]),
                  ClassDefinition('AnotherObject', [
                    ClassProperty('String', 'str'),
                  ]),
                ],
              ),
            ],
          ),
        );
      }, count: 1);

      await testBuilder(anotherBuilder, {
        'a|api.schema.json': jsonFromSchema(schema),
        'a|some_query.graphql': queryString,
      }, outputs: {
        'a|lib/some_query.dart': '''// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
part 'some_query.g.dart';

@JsonSerializable(explicitToJson: true)
class SomeQuery with EquatableMixin {
  SomeQuery();

  factory SomeQuery.fromJson(Map<String, dynamic> json) =>
      _\$SomeQueryFromJson(json);

  String s;

  SomeObject o;

  @override
  List<Object> get props => [s, o];
  Map<String, dynamic> toJson() => _\$SomeQueryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SomeObject with EquatableMixin {
  SomeObject();

  factory SomeObject.fromJson(Map<String, dynamic> json) =>
      _\$SomeObjectFromJson(json);

  String st;

  List<AnotherObject> ob;

  @override
  List<Object> get props => [st, ob];
  Map<String, dynamic> toJson() => _\$SomeObjectToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AnotherObject with EquatableMixin {
  AnotherObject();

  factory AnotherObject.fromJson(Map<String, dynamic> json) =>
      _\$AnotherObjectFromJson(json);

  String str;

  @override
  List<Object> get props => [str];
  Map<String, dynamic> toJson() => _\$AnotherObjectToJson(this);
}
''',
      });
    });

    test('Query selections can be aliased', () async {
      final GraphQLQueryBuilder anotherBuilder =
          graphQLQueryBuilder(BuilderOptions({
        'generate_helpers': false,
        'schema_mapping': [
          {
            'schema': 'api.schema.json',
            'queries_glob': '**.graphql',
            'output': 'lib/some_query.dart',
          }
        ]
      }));
      final GraphQLSchema schema = GraphQLSchema(
          queryType: GraphQLType(name: 'Query', kind: GraphQLTypeKind.OBJECT),
          types: [
            GraphQLType(name: 'String', kind: GraphQLTypeKind.SCALAR),
            GraphQLType(name: 'Query', kind: GraphQLTypeKind.OBJECT, fields: [
              GraphQLField(
                  name: 's',
                  type: GraphQLType(
                      name: 'String', kind: GraphQLTypeKind.SCALAR)),
              GraphQLField(
                  name: 'st',
                  type: GraphQLType(
                      name: 'String', kind: GraphQLTypeKind.SCALAR)),
            ]),
          ]);

      anotherBuilder.onBuild = expectAsync1((definition) {
        expect(
          definition,
          LibraryDefinition(
            'some_query',
            queries: [
              QueryDefinition(
                'SomeQuery',
                'query some_query { firstName: s, lastName: st }',
                classes: [
                  ClassDefinition('SomeQuery', [
                    ClassProperty('String', 'firstName'),
                    ClassProperty('String', 'lastName'),
                  ]),
                ],
              ),
            ],
          ),
        );
      }, count: 1);

      await testBuilder(anotherBuilder, {
        'a|api.schema.json': jsonFromSchema(schema),
        'a|some_query.graphql':
            'query some_query { firstName: s, lastName: st }',
      }, outputs: {
        'a|lib/some_query.dart': '''// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
part 'some_query.g.dart';

@JsonSerializable(explicitToJson: true)
class SomeQuery with EquatableMixin {
  SomeQuery();

  factory SomeQuery.fromJson(Map<String, dynamic> json) =>
      _\$SomeQueryFromJson(json);

  String firstName;

  String lastName;

  @override
  List<Object> get props => [firstName, lastName];
  Map<String, dynamic> toJson() => _\$SomeQueryToJson(this);
}
''',
      });
    });

    test(
        'When multiple fields use different versions of an object, aliasing them means we\'ll alias class name as well',
        () async {
      final GraphQLQueryBuilder anotherBuilder =
          graphQLQueryBuilder(BuilderOptions({
        'generate_helpers': false,
        'schema_mapping': [
          {
            'schema': 'api.schema.json',
            'queries_glob': '**.graphql',
            'output': 'lib/some_query.dart',
          }
        ]
      }));
      final GraphQLSchema schema = GraphQLSchema(
          queryType: GraphQLType(name: 'Query', kind: GraphQLTypeKind.OBJECT),
          types: [
            GraphQLType(name: 'String', kind: GraphQLTypeKind.SCALAR),
            GraphQLType(name: 'Query', kind: GraphQLTypeKind.OBJECT, fields: [
              GraphQLField(
                  name: 's',
                  type: GraphQLType(
                      name: 'String', kind: GraphQLTypeKind.SCALAR)),
              GraphQLField(
                  name: 'o',
                  type: GraphQLType(
                      name: 'SomeObject', kind: GraphQLTypeKind.OBJECT)),
              GraphQLField(
                  name: 'ob',
                  type: GraphQLType(
                      kind: GraphQLTypeKind.LIST,
                      ofType: GraphQLType(
                          name: 'SomeObject', kind: GraphQLTypeKind.OBJECT))),
            ]),
            GraphQLType(
                name: 'SomeObject',
                kind: GraphQLTypeKind.OBJECT,
                fields: [
                  GraphQLField(
                      name: 'st',
                      type: GraphQLType(
                          name: 'String', kind: GraphQLTypeKind.SCALAR)),
                  GraphQLField(
                      name: 'str',
                      type: GraphQLType(
                          name: 'String', kind: GraphQLTypeKind.SCALAR)),
                ]),
          ]);

      final queryString = '''
        query some_query {
          s
          o {
            st
          }
          anotherObject: ob {
            str
          }
        }
        ''';

      anotherBuilder.onBuild = expectAsync1((definition) {
        expect(
          definition,
          LibraryDefinition(
            'some_query',
            queries: [
              QueryDefinition(
                'SomeQuery',
                queryString,
                classes: [
                  ClassDefinition('SomeQuery', [
                    ClassProperty('String', 's'),
                    ClassProperty('SomeObject', 'o'),
                    ClassProperty('List<AnotherObject>', 'anotherObject'),
                  ]),
                  ClassDefinition('SomeObject', [
                    ClassProperty('String', 'st'),
                  ]),
                  ClassDefinition('AnotherObject', [
                    ClassProperty('String', 'str'),
                  ]),
                ],
              ),
            ],
          ),
        );
      }, count: 1);

      await testBuilder(anotherBuilder, {
        'a|api.schema.json': jsonFromSchema(schema),
        'a|some_query.graphql': queryString,
      }, outputs: {
        'a|lib/some_query.dart': '''// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
part 'some_query.g.dart';

@JsonSerializable(explicitToJson: true)
class SomeQuery with EquatableMixin {
  SomeQuery();

  factory SomeQuery.fromJson(Map<String, dynamic> json) =>
      _\$SomeQueryFromJson(json);

  String s;

  SomeObject o;

  List<AnotherObject> anotherObject;

  @override
  List<Object> get props => [s, o, anotherObject];
  Map<String, dynamic> toJson() => _\$SomeQueryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SomeObject with EquatableMixin {
  SomeObject();

  factory SomeObject.fromJson(Map<String, dynamic> json) =>
      _\$SomeObjectFromJson(json);

  String st;

  @override
  List<Object> get props => [st];
  Map<String, dynamic> toJson() => _\$SomeObjectToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AnotherObject with EquatableMixin {
  AnotherObject();

  factory AnotherObject.fromJson(Map<String, dynamic> json) =>
      _\$AnotherObjectFromJson(json);

  String str;

  @override
  List<Object> get props => [str];
  Map<String, dynamic> toJson() => _\$AnotherObjectToJson(this);
}
''',
      });
    });

    test('On helpers generation', () async {
      final GraphQLQueryBuilder anotherBuilder =
          graphQLQueryBuilder(BuilderOptions({
        'schema_mapping': [
          {
            'schema': 'api.schema.json',
            'queries_glob': '**.graphql',
            'output': 'lib/some_query.dart',
          }
        ]
      }));
      final GraphQLSchema schema = GraphQLSchema(
          queryType: GraphQLType(name: 'Query', kind: GraphQLTypeKind.OBJECT),
          types: [
            GraphQLType(name: 'String', kind: GraphQLTypeKind.SCALAR),
            GraphQLType(name: 'Query', kind: GraphQLTypeKind.OBJECT, fields: [
              GraphQLField(
                  name: 's',
                  type: GraphQLType(
                      name: 'String', kind: GraphQLTypeKind.SCALAR)),
              GraphQLField(
                  name: 'o',
                  type: GraphQLType(
                      name: 'SomeObject', kind: GraphQLTypeKind.OBJECT)),
              GraphQLField(
                  name: 'ob',
                  type: GraphQLType(
                      kind: GraphQLTypeKind.LIST,
                      ofType: GraphQLType(
                          name: 'SomeObject', kind: GraphQLTypeKind.OBJECT))),
            ]),
            GraphQLType(
                name: 'SomeObject',
                kind: GraphQLTypeKind.OBJECT,
                fields: [
                  GraphQLField(
                      name: 'st',
                      type: GraphQLType(
                          name: 'String', kind: GraphQLTypeKind.SCALAR)),
                  GraphQLField(
                      name: 'str',
                      type: GraphQLType(
                          name: 'String', kind: GraphQLTypeKind.SCALAR)),
                ]),
          ]);

      final queryString = '''
        query some_query {
          s
          o {
            st
          }
          anotherObject: ob {
            str
          }
        }
        ''';

      anotherBuilder.onBuild = expectAsync1((definition) {
        expect(
          definition,
          LibraryDefinition(
            'some_query',
            queries: [
              QueryDefinition(
                'SomeQuery',
                queryString,
                classes: [
                  ClassDefinition('SomeQuery', [
                    ClassProperty('String', 's'),
                    ClassProperty('SomeObject', 'o'),
                    ClassProperty('List<AnotherObject>', 'anotherObject'),
                  ]),
                  ClassDefinition('SomeObject', [
                    ClassProperty('String', 'st'),
                  ]),
                  ClassDefinition('AnotherObject', [
                    ClassProperty('String', 'str'),
                  ]),
                ],
                generateHelpers: true,
              ),
            ],
          ),
        );
      }, count: 1);

      await testBuilder(anotherBuilder, {
        'a|api.schema.json': jsonFromSchema(schema),
        'a|some_query.graphql': queryString,
      }, outputs: {
        'a|lib/some_query.dart': '''// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:artemis/artemis.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
part 'some_query.g.dart';

@JsonSerializable(explicitToJson: true)
class SomeQuery with EquatableMixin {
  SomeQuery();

  factory SomeQuery.fromJson(Map<String, dynamic> json) =>
      _\$SomeQueryFromJson(json);

  String s;

  SomeObject o;

  List<AnotherObject> anotherObject;

  @override
  List<Object> get props => [s, o, anotherObject];
  Map<String, dynamic> toJson() => _\$SomeQueryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SomeObject with EquatableMixin {
  SomeObject();

  factory SomeObject.fromJson(Map<String, dynamic> json) =>
      _\$SomeObjectFromJson(json);

  String st;

  @override
  List<Object> get props => [st];
  Map<String, dynamic> toJson() => _\$SomeObjectToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AnotherObject with EquatableMixin {
  AnotherObject();

  factory AnotherObject.fromJson(Map<String, dynamic> json) =>
      _\$AnotherObjectFromJson(json);

  String str;

  @override
  List<Object> get props => [str];
  Map<String, dynamic> toJson() => _\$AnotherObjectToJson(this);
}

class SomeQueryQuery extends GraphQLQuery<SomeQuery, JsonSerializable> {
  SomeQueryQuery();

  @override
  final String query =
      'query some_query { s o { st } anotherObject: ob { str } }';

  @override
  final String operationName = 'some_query';

  @override
  List<Object> get props => [query, operationName];
  @override
  SomeQuery parse(Map<String, dynamic> json) => SomeQuery.fromJson(json);
}
''',
      });
    });

    test('Imports from the scalar mapping are included', () async {
      final builderOptions = BuilderOptions({
        'generate_helpers': false,
        'schema_mapping': [
          {
            'schema': 'api.schema.json',
            'queries_glob': '**.graphql',
            'output': 'lib/some_query.dart',
          },
        ],
        'scalar_mapping': [
          {
            'graphql_type': 'BigDecimal',
            'dart_type': {
              'name': 'Decimal',
              'imports': ['package:decimal/decimal.dart'],
            },
          },
          {
            'graphql_type': 'DateTime',
            'dart_type': 'DateTime',
          },
        ],
      });

      final GraphQLQueryBuilder anotherBuilder =
          graphQLQueryBuilder(builderOptions);

      final GraphQLSchema schema = GraphQLSchema(
          queryType: GraphQLType(
            name: 'SomeObject',
            kind: GraphQLTypeKind.OBJECT,
          ),
          types: [
            GraphQLType(
              name: 'BigDecimal',
              kind: GraphQLTypeKind.SCALAR,
            ),
            GraphQLType(
              name: 'DateTime',
              kind: GraphQLTypeKind.SCALAR,
            ),
            GraphQLType(
              name: 'SomeObject',
              kind: GraphQLTypeKind.OBJECT,
              fields: [
                GraphQLField(
                  name: 'bigDecimal',
                  type: GraphQLType(
                    name: 'BigDecimal',
                    kind: GraphQLTypeKind.SCALAR,
                  ),
                ),
                GraphQLField(
                  name: 'dateTime',
                  type: GraphQLType(
                    name: 'DateTime',
                    kind: GraphQLTypeKind.SCALAR,
                  ),
                ),
              ],
            ),
          ]);

      anotherBuilder.onBuild = expectAsync1((definition) {
        expect(
          definition,
          LibraryDefinition(
            'some_query',
            queries: [
              QueryDefinition(
                'SomeQuery',
                'query some_query { bigDecimal, dateTime }',
                classes: [
                  ClassDefinition('SomeQuery', [
                    ClassProperty('Decimal', 'bigDecimal'),
                    ClassProperty('DateTime', 'dateTime'),
                  ])
                ],
              ),
            ],
            customImports: [
              'package:decimal/decimal.dart',
            ],
          ),
        );
      }, count: 1);

      await testBuilder(anotherBuilder, {
        'a|api.schema.json': jsonFromSchema(schema),
        'a|some_query.graphql': 'query some_query { bigDecimal, dateTime }',
      }, outputs: {
        'a|lib/some_query.dart': '''// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:decimal/decimal.dart';
part 'some_query.g.dart';

@JsonSerializable(explicitToJson: true)
class SomeQuery with EquatableMixin {
  SomeQuery();

  factory SomeQuery.fromJson(Map<String, dynamic> json) =>
      _\$SomeQueryFromJson(json);

  Decimal bigDecimal;

  DateTime dateTime;

  @override
  List<Object> get props => [bigDecimal, dateTime];
  Map<String, dynamic> toJson() => _\$SomeQueryToJson(this);
}
''',
      });
    });

    test(
        'If addQueryPrefix is true, all generated classes will have queryName as prefix',
        () async {
      final GraphQLQueryBuilder anotherBuilder =
          graphQLQueryBuilder(BuilderOptions({
        'generate_helpers': false,
        'schema_mapping': [
          {
            'schema': 'api.schema.json',
            'queries_glob': '**.graphql',
            'output': 'lib/some_query.dart',
            'add_query_prefix': true,
          }
        ]
      }));
      final GraphQLSchema schema = GraphQLSchema(
          queryType: GraphQLType(name: 'Query', kind: GraphQLTypeKind.OBJECT),
          types: [
            GraphQLType(name: 'String', kind: GraphQLTypeKind.SCALAR),
            GraphQLType(name: 'Query', kind: GraphQLTypeKind.OBJECT, fields: [
              GraphQLField(
                  name: 's',
                  type: GraphQLType(
                      name: 'String', kind: GraphQLTypeKind.SCALAR)),
              GraphQLField(
                  name: 'o',
                  type: GraphQLType(
                      name: 'SomeObject', kind: GraphQLTypeKind.OBJECT)),
            ]),
            GraphQLType(
                name: 'SomeObject',
                kind: GraphQLTypeKind.OBJECT,
                fields: [
                  GraphQLField(
                      name: 'st',
                      type: GraphQLType(
                          name: 'String', kind: GraphQLTypeKind.SCALAR)),
                  GraphQLField(
                      name: 'ob',
                      type: GraphQLType(
                          kind: GraphQLTypeKind.LIST,
                          ofType: GraphQLType(
                              name: 'AnotherObject',
                              kind: GraphQLTypeKind.OBJECT))),
                ]),
            GraphQLType(
                name: 'AnotherObject',
                kind: GraphQLTypeKind.OBJECT,
                fields: [
                  GraphQLField(
                      name: 'str',
                      type: GraphQLType(
                          name: 'String', kind: GraphQLTypeKind.SCALAR)),
                ]),
          ]);

      final queryString = '''
        query some_query {
          s
          o {
            st
            ob {
              str
            }
          }
        }
        ''';

      anotherBuilder.onBuild = expectAsync1((definition) {
        expect(
          definition,
          LibraryDefinition(
            'some_query',
            queries: [
              QueryDefinition(
                'SomeQuery',
                queryString,
                classes: [
                  ClassDefinition('SomeQuery', [
                    ClassProperty('String', 's'),
                    ClassProperty('SomeQuerySomeObject', 'o'),
                  ]),
                  ClassDefinition('SomeQuerySomeObject', [
                    ClassProperty('String', 'st'),
                    ClassProperty('List<SomeQueryAnotherObject>', 'ob'),
                  ]),
                  ClassDefinition('SomeQueryAnotherObject', [
                    ClassProperty('String', 'str'),
                  ]),
                ],
              ),
            ],
          ),
        );
      }, count: 1);

      await testBuilder(
          anotherBuilder,
          {
            'a|api.schema.json': jsonFromSchema(schema),
            'a|some_query.graphql': queryString,
          },
          outputs: {
            'a|lib/some_query.dart':
                '''// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
part 'some_query.g.dart';

@JsonSerializable(explicitToJson: true)
class SomeQuery with EquatableMixin {
  SomeQuery();

  factory SomeQuery.fromJson(Map<String, dynamic> json) =>
      _\$SomeQueryFromJson(json);

  String s;

  SomeQuerySomeObject o;

  @override
  List<Object> get props => [s, o];
  Map<String, dynamic> toJson() => _\$SomeQueryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SomeQuerySomeObject with EquatableMixin {
  SomeQuerySomeObject();

  factory SomeQuerySomeObject.fromJson(Map<String, dynamic> json) =>
      _\$SomeQuerySomeObjectFromJson(json);

  String st;

  List<SomeQueryAnotherObject> ob;

  @override
  List<Object> get props => [st, ob];
  Map<String, dynamic> toJson() => _\$SomeQuerySomeObjectToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SomeQueryAnotherObject with EquatableMixin {
  SomeQueryAnotherObject();

  factory SomeQueryAnotherObject.fromJson(Map<String, dynamic> json) =>
      _\$SomeQueryAnotherObjectFromJson(json);

  String str;

  @override
  List<Object> get props => [str];
  Map<String, dynamic> toJson() => _\$SomeQueryAnotherObjectToJson(this);
}
''',
          },
          onLog: print);
    });
  });
}
