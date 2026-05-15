import 'package:flutter/material.dart';

class AfricanCountry {
  final String name;
  final String code;
  final String flag;

  const AfricanCountry({
    required this.name,
    required this.code,
    required this.flag,
  });
}

const List<AfricanCountry> africanCountries = [
  AfricanCountry(name: 'Bénin', code: '+229', flag: '🇧🇯'),
  AfricanCountry(name: 'Afrique du Sud', code: '+27', flag: '🇿🇦'),
  AfricanCountry(name: 'Algérie', code: '+213', flag: '🇩🇿'),
  AfricanCountry(name: 'Angola', code: '+244', flag: '🇦🇴'),
  AfricanCountry(name: 'Botswana', code: '+267', flag: '🇧🇼'),
  AfricanCountry(name: 'Burkina Faso', code: '+226', flag: '🇧🇫'),
  AfricanCountry(name: 'Burundi', code: '+257', flag: '🇧🇮'),
  AfricanCountry(name: 'Cameroun', code: '+237', flag: '🇨🇲'),
  AfricanCountry(name: 'Cap-Vert', code: '+238', flag: '🇨🇻'),
  AfricanCountry(name: 'Comores', code: '+269', flag: '🇰🇲'),
  AfricanCountry(name: 'Congo', code: '+242', flag: '🇨🇬'),
  AfricanCountry(name: 'Côte d\'Ivoire', code: '+225', flag: '🇨🇮'),
  AfricanCountry(name: 'Djibouti', code: '+253', flag: '🇩🇯'),
  AfricanCountry(name: 'Égypte', code: '+20', flag: '🇪🇬'),
  AfricanCountry(name: 'Érythrée', code: '+291', flag: '🇪🇷'),
  AfricanCountry(name: 'Éthiopie', code: '+251', flag: '🇪🇹'),
  AfricanCountry(name: 'Gabon', code: '+241', flag: '🇬🇦'),
  AfricanCountry(name: 'Gambie', code: '+220', flag: '🇬🇲'),
  AfricanCountry(name: 'Ghana', code: '+233', flag: '🇬🇭'),
  AfricanCountry(name: 'Guinée', code: '+224', flag: '🇬🇳'),
  AfricanCountry(name: 'Guinée-Bissau', code: '+245', flag: '🇬🇼'),
  AfricanCountry(name: 'Guinée équatoriale', code: '+240', flag: '🇬🇶'),
  AfricanCountry(name: 'Kenya', code: '+254', flag: '🇰🇪'),
  AfricanCountry(name: 'Lesotho', code: '+266', flag: '🇱🇸'),
  AfricanCountry(name: 'Liberia', code: '+231', flag: '🇱🇷'),
  AfricanCountry(name: 'Libye', code: '+218', flag: '🇱🇾'),
  AfricanCountry(name: 'Madagascar', code: '+261', flag: '🇲🇬'),
  AfricanCountry(name: 'Malawi', code: '+265', flag: '🇲🇼'),
  AfricanCountry(name: 'Mali', code: '+223', flag: '🇲🇱'),
  AfricanCountry(name: 'Maroc', code: '+212', flag: '🇲🇦'),
  AfricanCountry(name: 'Maurice', code: '+230', flag: '🇲🇺'),
  AfricanCountry(name: 'Mauritanie', code: '+222', flag: '🇲🇷'),
  AfricanCountry(name: 'Mozambique', code: '+258', flag: '🇲🇿'),
  AfricanCountry(name: 'Namibie', code: '+264', flag: '🇳🇦'),
  AfricanCountry(name: 'Niger', code: '+227', flag: '🇳🇪'),
  AfricanCountry(name: 'Nigeria', code: '+234', flag: '🇳🇬'),
  AfricanCountry(name: 'Ouganda', code: '+256', flag: '🇺🇬'),
  AfricanCountry(name: 'R. centrafricaine', code: '+236', flag: '🇨🇫'),
  AfricanCountry(name: 'R.D. Congo', code: '+243', flag: '🇨🇩'),
  AfricanCountry(name: 'Rwanda', code: '+250', flag: '🇷🇼'),
  AfricanCountry(name: 'Sao Tomé-et-Principe', code: '+239', flag: '🇸🇹'),
  AfricanCountry(name: 'Sénégal', code: '+221', flag: '🇸🇳'),
  AfricanCountry(name: 'Seychelles', code: '+248', flag: '🇸🇨'),
  AfricanCountry(name: 'Sierra Leone', code: '+232', flag: '🇸🇱'),
  AfricanCountry(name: 'Somalie', code: '+252', flag: '🇸🇴'),
  AfricanCountry(name: 'Soudan', code: '+249', flag: '🇸🇩'),
  AfricanCountry(name: 'Soudan du Sud', code: '+211', flag: '🇸🇸'),
  AfricanCountry(name: 'Tanzanie', code: '+255', flag: '🇹🇿'),
  AfricanCountry(name: 'Tchad', code: '+235', flag: '🇹🇩'),
  AfricanCountry(name: 'Togo', code: '+228', flag: '🇹🇬'),
  AfricanCountry(name: 'Tunisie', code: '+216', flag: '🇹🇳'),
  AfricanCountry(name: 'Zambie', code: '+260', flag: '🇿🇲'),
  AfricanCountry(name: 'Zimbabwe', code: '+263', flag: '🇿🇼'),
];

class AfricanPhoneField extends StatefulWidget {
  final TextEditingController? controller;

  const AfricanPhoneField({super.key, this.controller});

  @override
  State<AfricanPhoneField> createState() => _AfricanPhoneFieldState();
}

class _AfricanPhoneFieldState extends State<AfricanPhoneField> {
  AfricanCountry selectedCountry = africanCountries.first;

  Future<void> _openCountryPicker() async {
    final country = await showModalBottomSheet<AfricanCountry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.68,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Choisir un pays',
                  style: TextStyle(
                    color: Color(0xFF060663),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: africanCountries.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: const Color(0xFF060663).withValues(alpha: 0.08),
                    ),
                    itemBuilder: (context, index) {
                      final country = africanCountries[index];
                      final isSelected = country.name == selectedCountry.name;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        leading: Text(
                          country.flag,
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(
                          country.name,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              country.code,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFFF80C0D),
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                        onTap: () => Navigator.pop(context, country),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (country != null) {
      setState(() {
        selectedCountry = country;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openCountryPicker,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF060663).withValues(alpha: 0.24),
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCountry.flag,
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(width: 6),
                Text(
                  selectedCountry.code,
                  style: const TextStyle(
                    color: Color(0xFF060663),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Color(0xFF060663)),
              ],
            ),
            const SizedBox(width: 10),
            Container(
              height: 30,
              width: 1,
              color: const Color(0xFF060663).withValues(alpha: 0.24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: TextField(
                controller: widget.controller,
                keyboardType: TextInputType.phone,
                onTap: () {},
                decoration: const InputDecoration(
                  hintText: '',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Color(0xFF7B849B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
