import 'dart:isolate';

class JsonConverterUtil {
  /// Helper method to convert the result from native code to the expected Dart type
  static Future<Map<String, dynamic>> convertToStringDynamicMap(
      Map<Object?, Object?>? result) async {
    if (result == null) {
      final error = result?['error'];
      throw Exception(error);
    }

    return await Isolate.run(() {
      final Map<String, dynamic> convertedMap = {};

      result.forEach((key, value) {
        if (key is String) {
          if (value is Map) {
            // Recursively convert nested maps
            convertedMap[key] = convertNestedMap(value);
          } else if (value is List) {
            // Convert lists
            convertedMap[key] = convertList(value);
          } else {
            // Direct assignment for primitive types
            convertedMap[key] = value;
          }
        }
      });

      return convertedMap;
    });
  }

  /// Helper method to convert nested maps
  static dynamic convertNestedMap(Map<dynamic, dynamic> map) {
    final convertedMap = <String, dynamic>{};

    map.forEach((key, value) {
      if (key is String) {
        if (value is Map) {
          convertedMap[key] = convertNestedMap(value);
        } else if (value is List) {
          convertedMap[key] = convertList(value);
        } else {
          convertedMap[key] = value;
        }
      }
    });

    return convertedMap;
  }

  /// Helper method to convert lists
  static List<dynamic> convertList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) {
        return convertNestedMap(item);
      } else if (item is List) {
        return convertList(item);
      } else {
        return item;
      }
    }).toList();
  }
}
