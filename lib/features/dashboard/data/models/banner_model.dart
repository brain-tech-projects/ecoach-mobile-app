/// One item of `GET /banners`.
class BannerModel {
  const BannerModel({
    required this.id,
    required this.contentType,
    this.title,
    this.banner,
    this.video,
    this.link,
    this.text,
    this.status,
  });

  final int id;
  final String contentType;
  final String? title;
  final String? banner;
  final String? video;
  final String? link;
  final String? text;
  final String? status;

  bool get isActive => (status ?? 'Active').toLowerCase() == 'active';
  bool get isVideo => _has(video);
  bool get isImage => _has(banner);
  bool get hasContent => isVideo || isImage || _has(text);

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
    id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
    contentType: (json['content_type'] ?? '').toString(),
    title: json['title'] as String?,
    banner: json['banner'] as String?,
    video: json['video'] as String?,
    link: json['link'] as String?,
    text: json['text'] as String?,
    status: json['status'] as String?,
  );

  static bool _has(String? v) => v != null && v.trim().isNotEmpty;
}
