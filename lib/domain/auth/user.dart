


abstract class IUserRepository {
  Future<String> login({required String email, required String password});

  Future<String> register({
    required String email,
    required String password,
    required String fullName,
    required String iban,
  });
}
