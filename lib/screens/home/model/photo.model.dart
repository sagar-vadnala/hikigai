import 'dart:convert';

class PhotosData {
  final int id;
  final String author;
  final String url;
  final String downloadUrl;

  PhotosData({
    required this.id,
    required this.author,
    required this.url,
    required this.downloadUrl,
  });

  PhotosData copyWith({
    int? id,
    String? author,
    String? url,
    String? downloadUrl,
  }) {
    return PhotosData(
      id: id ?? this.id,
      author: author ?? this.author,
      url: url ?? this.url,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author': author,
      'url': url,
      'download_url': downloadUrl,
    };
  }

  factory PhotosData.fromMap(Map<String, dynamic> map) {
    return PhotosData(
      id: map['id'] is String ? int.parse(map['id']) : map['id'],
      author: map['author'] ?? '',
      url: map['url'] ?? '',
      downloadUrl: map['download_url'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PhotosData.fromJson(String source) => PhotosData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PhotosData(id: $id, author: $author, url: $url, downloadUrl: $downloadUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PhotosData &&
        other.id == id &&
        other.author == author &&
        other.url == url &&
        other.downloadUrl == downloadUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^ author.hashCode ^ url.hashCode ^ downloadUrl.hashCode;
  }
}
