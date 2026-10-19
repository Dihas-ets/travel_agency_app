import 'package:flutter_test/flutter_test.dart';
import 'package:fofanavoyage/services/staff_ticket_service.dart';

void main() {
  test('extracts a regular ticket reference from its QR payload', () {
    expect(
      ticketReferenceFromQr('FV-TKT-20261016-AB12'),
      'FV-TKT-20261016-AB12',
    );
  });

  test('extracts a regular ticket reference embedded in a URL', () {
    expect(
      ticketReferenceFromQr(
        'https://fofanavoyage.bj/ticket/FV-TKT-20261016-AB12',
      ),
      'FV-TKT-20261016-AB12',
    );
  });

  test('keeps MECeF QR data separate from regular ticket references', () {
    const qr = 'F;NIM123;ABCD1234EFGH5678;IFU789;2026-10-16';

    expect(ticketReferenceFromQr(qr), isNull);
    expect(mecefTicketDataFromQr(qr)?.nim, 'NIM123');
    expect(mecefTicketDataFromQr(qr)?.code, 'ABCD-1234-EFGH-5678');
  });

  test('normalizes MECeF NIM casing and surrounding whitespace', () {
    expect(normalizeMecefNim(' nim123 '), 'NIM123');
  });
}
