part of spine_flutter;

class AssetsPathBuilder extends Builder {
  const AssetsPathBuilder(this.path) : assert(path.length > 0);

  @override
  final String path;

  @override
  String get name => pp.basename(path);

  @override
  Future<MapEntry<String, dynamic>> buildJson() async {
    final String data = await rootBundle.loadString(pathToSkeletonDataFile);

    return MapEntry<String, dynamic>(pathToSkeletonDataFile, json.decode(data));
  }

  @override
  Future<MapEntry<String, String>> buildAtlas() async {
    final String data = await rootBundle.loadString(pathToAtlasDataFile);

    return MapEntry<String, String>(pathToAtlasDataFile, data);
  }

  @override
  Future<MapEntry<String, Texture>> buildTexture(String textureDataFile) async {
    assert(textureDataFile.isNotEmpty);

    final String pathToTexture = '$path/$textureDataFile';
    final ByteData byteData = await rootBundle.load(pathToTexture);
    final Uint8List data = byteData.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(data);
    final ui.FrameInfo frame = await codec.getNextFrame();

    return MapEntry<String, Texture>(pathToTexture, Texture(frame.image));
  }
}
