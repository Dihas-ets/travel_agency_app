import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:code_initial/config/app_config.dart';
import 'package:code_initial/screens/client/colis/billet_page.dart';
import 'package:code_initial/screens/client/colis/colis_attente_page.dart';
import 'package:code_initial/screens/global/widgets/common/african_phone_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:code_initial/models/agence_model.dart';
import 'package:code_initial/models/colis_model.dart';
import 'package:code_initial/models/store/colis_store.dart';
import 'package:code_initial/models/tax_group_model.dart';
import 'package:code_initial/services/agence_service.dart';
import 'package:code_initial/services/colis_service.dart';
import 'package:code_initial/services/tax_service.dart';
import 'package:code_initial/services/payment_service.dart';
import 'package:code_initial/services/feexpay_service.dart';
import 'package:code_initial/services/kkiapay_service.dart';
import 'package:code_initial/models/payment_provider_model.dart';
import 'package:code_initial/data/local/session_store.dart';
import 'package:url_launcher/url_launcher.dart';

part 'constantes_colis.dart';
part 'menu_colis.dart';
part 'envoyer_colis_page.dart';
part 'formulaire_colis.dart';
