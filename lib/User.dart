import 'game.dart';

class User {
  String _username;
  String _email;
  String _password;
  String _phoneNumber;
  String _region;
  String _language;
  String? _profilePictureUrl;
  List<String>? _reviews;
  List<double>? _ratings;
  List<Game>? _library;  // Add this line

  User({
    required String username,
    required String email,
    required String password,
    required String phoneNumber,
    required String region,
    required String language,
    List<Game>? library,
    String? profilePictureUrl,
  })
      : _username = username,
        _email = email,
        _password = password,
        _phoneNumber = phoneNumber,
        _region = region,
        _language = language,
        _library = library,
        _profilePictureUrl = profilePictureUrl;

  set profilePictureUrl(String? url) {
    _profilePictureUrl = url;
  }

  // Getters
  String get username => _username;
  String get email => _email;
  String get password => _password;
  String get phoneNumber => _phoneNumber;
  String get region => _region;
  String get language => _language;
  String? get profilePictureUrl => _profilePictureUrl;
  List<String>? get reviews => _reviews;
  List<double>? get ratings => _ratings;
  List<Game>? get library => _library;
}