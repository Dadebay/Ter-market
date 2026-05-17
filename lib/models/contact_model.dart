class ContactModel {
  final int id;
  final String? addressUk;
  final String? addressRu;
  final String? phone1;
  final String? phone2;
  final String? phone3;
  final String? email;
  final String? tiktok;
  final String? facebook;
  final String? youtube;
  final String? telegram;

  const ContactModel({
    required this.id,
    this.addressUk,
    this.addressRu,
    this.phone1,
    this.phone2,
    this.phone3,
    this.email,
    this.tiktok,
    this.facebook,
    this.youtube,
    this.telegram,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] ?? 0,
      addressUk: json['address_uk'],
      addressRu: json['address_ru'],
      phone1: json['phone1'],
      phone2: json['phone2'],
      phone3: json['phone3'],
      email: json['email'],
      tiktok: json['tiktok'],
      facebook: json['facebook'],
      youtube: json['youtube'],
      telegram: json['telegram'],
    );
  }
}
