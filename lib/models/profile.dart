import '../data/json_read.dart';

class LinkItem {
  const LinkItem({required this.label, required this.url});

  final String label;
  final String url;

  factory LinkItem.fromJson(Map<String, dynamic> json, {required String file, String path = ''}) {
    return LinkItem(
      label: readString(json, 'label', file: file, path: path),
      url: readString(json, 'url', file: file, path: path),
    );
  }
}

class Contact {
  const Contact({required this.email, required this.phone});

  final String email;
  final String phone;

  factory Contact.fromJson(Map<String, dynamic> json, {required String file, String path = ''}) {
    return Contact(
      email: readString(json, 'email', file: file, path: path),
      phone: readOptionalString(json, 'phone', file: file, path: path),
    );
  }
}

class PdfItem {
  const PdfItem({required this.label, required this.asset});

  final String label;
  final String asset;

  factory PdfItem.fromJson(Map<String, dynamic> json, {required String file, String path = ''}) {
    return PdfItem(
      label: readString(json, 'label', file: file, path: path),
      asset: readString(json, 'asset', file: file, path: path),
    );
  }
}

class Profile {
  const Profile({
    required this.kicker,
    required this.name,
    required this.role,
    required this.location,
    required this.links,
    required this.contact,
    required this.pdfs,
    required this.tabs,
  });

  final String kicker;
  final String name;
  final String role;
  final String location;
  final List<LinkItem> links;
  final Contact contact;
  final List<PdfItem> pdfs;
  final List<String> tabs;

  factory Profile.fromJson(Map<String, dynamic> json, {required String file, String path = ''}) {
    final linkItems = readList(json, 'links', file: file, path: path);
    final pdfItems = readList(json, 'pdfs', file: file, path: path);

    return Profile(
      kicker: readString(json, 'kicker', file: file, path: path),
      name: readString(json, 'name', file: file, path: path),
      role: readString(json, 'role', file: file, path: path),
      location: readString(json, 'location', file: file, path: path),
      links: [
        for (var i = 0; i < linkItems.length; i++)
          LinkItem.fromJson(
            readMap(linkItems[i], '', file: file, path: joinPath(path, 'links[$i]')),
            file: file,
            path: joinPath(path, 'links[$i]'),
          ),
      ],
      contact: Contact.fromJson(
        readMap(json['contact'], 'contact', file: file, path: path),
        file: file,
        path: joinPath(path, 'contact'),
      ),
      pdfs: [
        for (var i = 0; i < pdfItems.length; i++)
          PdfItem.fromJson(
            readMap(pdfItems[i], '', file: file, path: joinPath(path, 'pdfs[$i]')),
            file: file,
            path: joinPath(path, 'pdfs[$i]'),
          ),
      ],
      tabs: readStringList(json, 'tabs', file: file, path: path),
    );
  }
}
