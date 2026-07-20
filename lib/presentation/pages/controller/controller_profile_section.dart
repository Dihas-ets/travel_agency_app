import 'package:flutter/material.dart';
import 'package:code_initial/presentation/pages/controller/controller_models.dart';
import 'package:code_initial/presentation/pages/collector/parts/menu_profile_section.dart';
// Profil controleur: edition locale des informations de compte.

class ControllerProfileTabContent extends StatelessWidget {
  const ControllerProfileTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 18),
      children: const [
        Center(
          child: CircleAvatar(
            radius: 52,
            backgroundColor: Color(0xFF58648D),
            child: Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 64,
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Profil controleur',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF0B4F2A),
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 18),
        ControllerProfilePanel(),
      ],
    );
  }
}

class ControllerProfilePanel extends StatelessWidget {
  const ControllerProfilePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ControllerProfileData>(
      valueListenable: ControllerProfileStore.profile,
      builder: (context, profile, _) {
        return ControllerProfileEditor(profile: profile);
      },
    );
  }
}

class ControllerProfileEditor extends StatefulWidget {
  final ControllerProfileData profile;

  const ControllerProfileEditor({super.key, required this.profile});

  @override
  State<ControllerProfileEditor> createState() =>
      ControllerProfileEditorState();
}

class ControllerProfileEditorState extends State<ControllerProfileEditor> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _agencyController;
  late final TextEditingController _roleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _agencyController = TextEditingController(text: widget.profile.agency);
    _roleController = TextEditingController(text: widget.profile.role);
  }

  @override
  void didUpdateWidget(covariant ControllerProfileEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _nameController.text = widget.profile.fullName;
      _phoneController.text = widget.profile.phone;
      _agencyController.text = widget.profile.agency;
      _roleController.text = widget.profile.role;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _agencyController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final nextProfile = widget.profile.copyWith(
      fullName: _nameController.text.trim().isEmpty
          ? widget.profile.fullName
          : _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? widget.profile.phone
          : _phoneController.text.trim(),
      agency: _agencyController.text.trim().isEmpty
          ? widget.profile.agency
          : _agencyController.text.trim(),
      role: _roleController.text.trim().isEmpty
          ? widget.profile.role
          : _roleController.text.trim(),
    );

    ControllerProfileStore.update(nextProfile);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil controleur mis a jour.'),
        backgroundColor: Color(0xFF0B4F2A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          CollectorProfileEditField(
            icon: Icons.badge_rounded,
            label: 'Nom et prenom',
            controller: _nameController,
          ),
          CollectorProfileEditField(
            icon: Icons.phone_rounded,
            label: 'Telephone',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          CollectorProfileEditField(
            icon: Icons.location_city_rounded,
            label: 'Agence',
            controller: _agencyController,
          ),
          CollectorProfileEditField(
            icon: Icons.work_rounded,
            label: 'Fonction',
            controller: _roleController,
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Enregistrer le profil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


