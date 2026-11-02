import 'package:jarina/core/api/api_client.dart';
import 'package:jarina/core/api/failures.dart';
import 'package:jarina/features/kyc/domain/kyc_repository.dart';
import 'package:jarina_core/jarina_core.dart';

/// [KycRepository] against the Jarina API. The identity and liveness
/// checks go to [_pending] until the Smile ID integration lands (PLAN.md B3).
class HttpKycRepository implements KycRepository {
  HttpKycRepository(this._api, this._pending);

  final ApiClient _api;
  final KycRepository _pending;

  @override
  Future<Result<void>> submitPersonalDetails(PersonalDetails details) async {
    final dob = details.dateOfBirth;
    String two(int n) => n.toString().padLeft(2, '0');
    return mapVoid(
      await _api.send(
        'PUT',
        'me/details',
        body: {
          'firstName': details.firstName,
          if (details.middleName case final m? when m.trim().isNotEmpty) 'middleName': m,
          'lastName': details.lastName,
          'dateOfBirth': '${dob.year.toString().padLeft(4, '0')}-${two(dob.month)}-${two(dob.day)}',
          'email': details.email,
        },
      ),
    );
  }

  @override
  Future<Result<bool>> isUsernameAvailable(String handle) async =>
      mapJson(await _api.get('usernames/${Uri.encodeComponent(handle)}'), (j) => j['available']! as bool);

  @override
  Future<Result<void>> claimUsername(String handle) async =>
      mapVoid(await _api.send('PUT', 'me/username', body: {'handle': handle}));

  @override
  Future<Result<void>> submitAddress(HomeAddress address) async => mapVoid(
    await _api.send(
      'PUT',
      'me/address',
      body: {
        'countryIso': address.countryIso,
        'region': address.region,
        'city': address.city,
        'street': address.street,
        'occupation': address.occupation,
      },
    ),
  );

  @override
  Future<Result<void>> setPin(String pin) async => mapVoid(await _api.send('PUT', 'security/pin', body: {'pin': pin}));

  @override
  Future<Result<TotpSetup>> startTotpSetup() async => mapJson(
    await _api.post('security/2fa/setup', signedIn: true),
    (j) => TotpSetup(
      secret: j['secret']! as String,
      provisioningUri: Uri.parse(j['provisioningUri']! as String),
      backupCodes: List.unmodifiable([for (final c in j['backupCodes']! as List<Object?>) c! as String]),
    ),
  );

  @override
  Future<Result<void>> confirmTotp(String code) async =>
      mapVoid(await _api.post('security/2fa/confirm', body: {'code': code}, signedIn: true));

  @override
  Future<Result<void>> verifyIdentity(IdType type, String number) => _pending.verifyIdentity(type, number);

  @override
  Future<Result<void>> submitLiveness(String vendorSessionId) => _pending.submitLiveness(vendorSessionId);
}
