part of spine_flutter;

abstract class Builder {
  const Builder();

  String get path;

  String get name;

  String get atlasDataFile => '$name.atlas';

  String get pathToAtlasDataFile => '$path/$atlasDataFile';

  String get skeletonDataFile => '$name.json';

  String get pathToSkeletonDataFile => '$path/$skeletonDataFile';

  Future<MapEntry<String, dynamic>> buildJson();

  Future<MapEntry<String, String>> buildAtlas();

  /// We may have more than one texture file.
  Future<MapEntry<String, Texture>> buildTexture(String textureDataFile);
}
