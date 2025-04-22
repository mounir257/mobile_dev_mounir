import 'package:isar/isar.dart';

part 'story.g.dart';

@collection
class Story {
  Id id = Isar.autoIncrement;
  late String title;
  late String description;
  late String imageURL;

  Story copyWith({
    String? title,
    String? description,
    String? imageURL,
  }) {
    return Story()..id = id
      ..title = title ?? this.title
      ..description = description ?? this.description
      ..imageURL = imageURL ?? this.imageURL;
  }
}
