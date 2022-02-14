part of spine_flutter;

class SkeletonAnimation extends core.Skeleton {
  SkeletonAnimation(core.SkeletonData data)
      : state = core.AnimationState(core.AnimationStateData(data)),
        super(data);

  final core.AnimationState state;

  void applyState() {
    state.apply(this);
  }

  void updateState(double delta) {
    state.update(delta);
  }

  static Future<SkeletonAnimation> create(Builder builder) async {
    final Map<String, dynamic> assets = <String, dynamic>{};
    final List<Future<MapEntry<String, dynamic>>> futures =
        <Future<MapEntry<String, dynamic>>>[
      builder.buildJson(),
      builder.buildAtlas(),
    ];

    final List<String> textureDataFiles =
        await textureFilesFromAtlas(builder.pathToAtlasDataFile);
    for (final String textureDataFile in textureDataFiles) {
      final Future<MapEntry<String, dynamic>> entry =
          builder.buildTexture(textureDataFile);
      futures.add(entry);
    }

    await Future.wait(futures).then(assets.addEntries).catchError((Object e) {
      if (kDebugMode) {
        print("Couldn't add entries. $e");
      }
    });

    final core.TextureAtlas atlas = core.TextureAtlas(
      assets[builder.pathToAtlasDataFile],
      (String? p) => p == null ? '' : assets['${builder.path}/$p'],
    );
    final core.AtlasAttachmentLoader atlasLoader =
        core.AtlasAttachmentLoader(atlas);
    final core.SkeletonJson skeletonJson = core.SkeletonJson(atlasLoader);
    final core.SkeletonData skeletonData =
        skeletonJson.readSkeletonData(assets[builder.pathToSkeletonDataFile]);

    return SkeletonAnimation(skeletonData);
  }

  static List<String> textureFiles(String name, int count) =>
      List<String>.generate(count, (int i) => textureFile(name, i + 1));

  static String textureFile(String name, int i) =>
      i <= 1 ? '$name.png' : '${name}_$i.png';

  static Future<List<String>> textureFilesFromAtlas(String pathToAtlas) async {
    final String data = await rootBundle.loadString(pathToAtlas);
    final core.TextureAtlasReader reader = core.TextureAtlasReader(data);
    final List<String> r = <String>[];
    for (;;) {
      String? line = reader.readLine();
      if (line == null) {
        break;
      }

      line = line.trim();
      if (line.isEmpty) {
        continue;
      }

      if (isAllowedImageFileName(line)) {
        r.add(line);
      }
    }

    return r;
  }

  static const List<String> allowedImageExtensions = <String>[
    'jpg',
    'png',
    'webp',
  ];

  static bool isAllowedImageFileName(String file) => allowedImageExtensions
      .firstWhere((String ext) => file.endsWith('.$ext'), orElse: () => '')
      .isNotEmpty;
}
