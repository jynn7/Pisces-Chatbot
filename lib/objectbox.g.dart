// GENERATED CODE - DO NOT MODIFY BY HAND
// This code was generated by ObjectBox. To update it run the generator again
// with `dart run build_runner build`.
// See also https://docs.objectbox.io/getting-started#generate-objectbox-code

// ignore_for_file: camel_case_types, depend_on_referenced_packages
// coverage:ignore-file

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'
    as obx_int; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart' as obx;
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'model/chat_list_model.dart';
import 'model/conversation_model.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <obx_int.ModelEntity>[
  obx_int.ModelEntity(
      id: const obx_int.IdUid(1, 1327392776575632057),
      name: 'ConversationModel',
      lastPropertyId: const obx_int.IdUid(6, 1382120325961867206),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 7300050278041303714),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 20910946138775606),
            name: 'conversationId',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 4911120533017341857),
            name: 'text',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 2428479331130742414),
            name: 'sendByAi',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 2679519829674796253),
            name: 'sendByUser',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 1382120325961867206),
            name: 'timestamp',
            type: 10,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(2, 7568896955686248297),
      name: 'ChatListModel',
      lastPropertyId: const obx_int.IdUid(3, 1254875334933234219),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 5933871289843928423),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 1223877129548794182),
            name: 'conversationId',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 1254875334933234219),
            name: 'addedAt',
            type: 10,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[])
];

/// Shortcut for [obx.Store.new] that passes [getObjectBoxModel] and for Flutter
/// apps by default a [directory] using `defaultStoreDirectory()` from the
/// ObjectBox Flutter library.
///
/// Note: for desktop apps it is recommended to specify a unique [directory].
///
/// See [obx.Store.new] for an explanation of all parameters.
///
/// For Flutter apps, also calls `loadObjectBoxLibraryAndroidCompat()` from
/// the ObjectBox Flutter library to fix loading the native ObjectBox library
/// on Android 6 and older.
Future<obx.Store> openStore(
    {String? directory,
    int? maxDBSizeInKB,
    int? maxDataSizeInKB,
    int? fileMode,
    int? maxReaders,
    bool queriesCaseSensitiveDefault = true,
    String? macosApplicationGroup}) async {
  await loadObjectBoxLibraryAndroidCompat();
  return obx.Store(getObjectBoxModel(),
      directory: directory ?? (await defaultStoreDirectory()).path,
      maxDBSizeInKB: maxDBSizeInKB,
      maxDataSizeInKB: maxDataSizeInKB,
      fileMode: fileMode,
      maxReaders: maxReaders,
      queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
      macosApplicationGroup: macosApplicationGroup);
}

/// Returns the ObjectBox model definition for this project for use with
/// [obx.Store.new].
obx_int.ModelDefinition getObjectBoxModel() {
  final model = obx_int.ModelInfo(
      entities: _entities,
      lastEntityId: const obx_int.IdUid(2, 7568896955686248297),
      lastIndexId: const obx_int.IdUid(0, 0),
      lastRelationId: const obx_int.IdUid(0, 0),
      lastSequenceId: const obx_int.IdUid(0, 0),
      retiredEntityUids: const [],
      retiredIndexUids: const [],
      retiredPropertyUids: const [],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, obx_int.EntityDefinition>{
    ConversationModel: obx_int.EntityDefinition<ConversationModel>(
        model: _entities[0],
        toOneRelations: (ConversationModel object) => [],
        toManyRelations: (ConversationModel object) => {},
        getId: (ConversationModel object) => object.id,
        setId: (ConversationModel object, int id) {
          object.id = id;
        },
        objectToFB: (ConversationModel object, fb.Builder fbb) {
          final conversationIdOffset = fbb.writeString(object.conversationId);
          final textOffset = fbb.writeString(object.text);
          fbb.startTable(7);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, conversationIdOffset);
          fbb.addOffset(2, textOffset);
          fbb.addBool(3, object.sendByAi);
          fbb.addBool(4, object.sendByUser);
          fbb.addInt64(5, object.timestamp.millisecondsSinceEpoch);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final conversationIdParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 6, '');
          final textParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 8, '');
          final sendByAiParam =
              const fb.BoolReader().vTableGet(buffer, rootOffset, 10, false);
          final sendByUserParam =
              const fb.BoolReader().vTableGet(buffer, rootOffset, 12, false);
          final timestampParam = DateTime.fromMillisecondsSinceEpoch(
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 14, 0));
          final object = ConversationModel(
              id: idParam,
              conversationId: conversationIdParam,
              text: textParam,
              sendByAi: sendByAiParam,
              sendByUser: sendByUserParam,
              timestamp: timestampParam);

          return object;
        }),
    ChatListModel: obx_int.EntityDefinition<ChatListModel>(
        model: _entities[1],
        toOneRelations: (ChatListModel object) => [],
        toManyRelations: (ChatListModel object) => {},
        getId: (ChatListModel object) => object.id,
        setId: (ChatListModel object, int id) {
          object.id = id;
        },
        objectToFB: (ChatListModel object, fb.Builder fbb) {
          final conversationIdOffset = fbb.writeString(object.conversationId);
          fbb.startTable(4);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, conversationIdOffset);
          fbb.addInt64(2, object.addedAt.millisecondsSinceEpoch);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final conversationIdParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 6, '');
          final addedAtParam = DateTime.fromMillisecondsSinceEpoch(
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 8, 0));
          final object = ChatListModel(
              conversationId: conversationIdParam, addedAt: addedAtParam)
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);

          return object;
        })
  };

  return obx_int.ModelDefinition(model, bindings);
}

/// [ConversationModel] entity fields to define ObjectBox queries.
class ConversationModel_ {
  /// See [ConversationModel.id].
  static final id =
      obx.QueryIntegerProperty<ConversationModel>(_entities[0].properties[0]);

  /// See [ConversationModel.conversationId].
  static final conversationId =
      obx.QueryStringProperty<ConversationModel>(_entities[0].properties[1]);

  /// See [ConversationModel.text].
  static final text =
      obx.QueryStringProperty<ConversationModel>(_entities[0].properties[2]);

  /// See [ConversationModel.sendByAi].
  static final sendByAi =
      obx.QueryBooleanProperty<ConversationModel>(_entities[0].properties[3]);

  /// See [ConversationModel.sendByUser].
  static final sendByUser =
      obx.QueryBooleanProperty<ConversationModel>(_entities[0].properties[4]);

  /// See [ConversationModel.timestamp].
  static final timestamp =
      obx.QueryDateProperty<ConversationModel>(_entities[0].properties[5]);
}

/// [ChatListModel] entity fields to define ObjectBox queries.
class ChatListModel_ {
  /// See [ChatListModel.id].
  static final id =
      obx.QueryIntegerProperty<ChatListModel>(_entities[1].properties[0]);

  /// See [ChatListModel.conversationId].
  static final conversationId =
      obx.QueryStringProperty<ChatListModel>(_entities[1].properties[1]);

  /// See [ChatListModel.addedAt].
  static final addedAt =
      obx.QueryDateProperty<ChatListModel>(_entities[1].properties[2]);
}
