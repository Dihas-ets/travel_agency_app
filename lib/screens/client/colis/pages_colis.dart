import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fofanavoyage/config/app_config.dart';
import 'package:fofanavoyage/screens/client/colis/billet_page.dart';
import 'package:fofanavoyage/screens/client/colis/colis_attente_page.dart';
import 'package:fofanavoyage/screens/global/widgets/common/african_phone_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fofanavoyage/models/agence_model.dart';
import 'package:fofanavoyage/models/colis_model.dart';
import 'package:fofanavoyage/models/store/colis_store.dart';
import 'package:fofanavoyage/models/tax_group_model.dart';
import 'package:fofanavoyage/services/agence_service.dart';
import 'package:fofanavoyage/services/colis_service.dart';
import 'package:fofanavoyage/services/tax_service.dart';
import 'package:fofanavoyage/services/payment_service.dart';
import 'package:fofanavoyage/services/feexpay_service.dart';
import 'package:fofanavoyage/services/kkiapay_service.dart';
import 'package:fofanavoyage/models/payment_provider_model.dart';
import 'package:fofanavoyage/data/local/session_store.dart';
import 'package:url_launcher/url_launcher.dart';

part 'constantes_colis.dart';
part 'menu_colis.dart';
part 'envoyer_colis_page.dart';
part 'formulaire_colis.dart';
