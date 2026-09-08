# Inventaire du dossier `lib`

Ce document décrit la structure actuelle du code Dart de l'application Flutter `Fofana Voyage`.

## Vue d'ensemble

```text
lib/
├── main.dart
├── navigation.dart
├── data/
│   └── local/
├── models/
├── features/
│   ├── expense/
│   └── parcel/
├── presentation/
│   └── pages/
├── widgets/
└── utils/
```

## 1. Fichiers racine

### `lib/main.dart`

Point d'entrée de l'application Flutter.

Responsabilités :

- initialise Flutter avec `WidgetsFlutterBinding` ;
- récupère la route initiale ;
- démarre `GetMaterialApp` ;
- configure les routes GetX ;
- configure les langues française et anglaise ;
- configure le thème global et la police Montserrat ;
- définit le titre de l'application : `Fofana Voyage`.

### `lib/navigation.dart`

Centralise la navigation de l'application.

Contient :

- `Nav.routes`, la liste des routes GetX ;
- les routes d'onboarding et d'authentification ;
- les routes client, percepteur et contrôleur ;
- la route des envois effectués ;
- les constantes de chemins dans la classe `Routes`.

## 2. Données locales

### `lib/data/local/auth_local_store.dart`

Gère les données d'authentification client avec `SharedPreferences`.

Fonctions principales :

- normalisation des numéros de téléphone ;
- sauvegarde des numéros clients ;
- sauvegarde des profils clients ;
- recherche du nom complet d'un client ;
- vérification de l'existence d'un numéro client ;
- sérialisation des profils en JSON.

### `lib/data/local/session_store.dart`

Stocke la session client courante en mémoire.

Données conservées :

- `currentClientPhone` ;
- `currentClientFullName`.

Permet aussi de définir et d'effacer les informations de session.

## 3. Modèles

### `lib/models/user_model.dart`

Modèle générique d'utilisateur.

Contient les propriétés d'un utilisateur et les conversions `fromJson`/`toJson`.

### `lib/models/onboarding_data_model.dart`

Modèle d'une page d'onboarding.

Contient les informations nécessaires à une slide, notamment l'image, le titre et la description.

### `lib/models/expense_model.dart`

Modèle d'une dépense.

Représente notamment :

- l'identifiant ;
- la description ;
- le coût ;
- la quantité ;
- le statut ;
- la référence ;
- les informations liées au QR code.

## 4. Utilitaires

### `lib/utils/app_colors.dart`

Définit la palette de couleurs globale de l'application dans `AppColors`.

Les écrans utilisent cette classe pour les couleurs principales, les fonds, les accents et les couleurs d'état.

## 5. Widgets réutilisables

### `lib/widgets/common/african_phone_field.dart`

Champ de téléphone réutilisable.

Fonctionnalités :

- sélection d'un pays africain ;
- affichage de l'indicatif ;
- saisie du numéro ;
- liste des pays et informations associées.

### `lib/widgets/login/login_widgets.dart`

Composants de l'interface de connexion :

- en-tête de connexion ;
- champ téléphone ;
- champ mot de passe ;
- bouton de connexion.

Réutilise `AfricanPhoneField`.

### `lib/widgets/register/register_widgets.dart`

Composants de l'interface d'inscription :

- en-tête ;
- champs nom et prénom ;
- champ téléphone ;
- champ mot de passe ;
- boîte d'information WhatsApp ;
- bouton d'envoi ou de validation.

Réutilise `AfricanPhoneField`.

### `lib/widgets/onboarding/onboarding_dot_indicator.dart`

Affiche l'indicateur de position des slides d'onboarding.

### `lib/widgets/welcome/welcome_widgets.dart`

Contient les composants visuels de la page Welcome :

- logo Fofana ;
- boutons de navigation.

### `lib/widgets/tarifs/tarifs_widgets.dart`

Contient les composants utilisés par la page des tarifs :

- petit logo Fofana ;
- champ de ville ;
- sélection des villes.

## 6. Fonctionnalité dépenses

### `lib/features/expense/data/expense_store.dart`

Singleton de gestion des dépenses, actuellement en mémoire.

Fonctionnalités :

- ajout d'une dépense ;
- ajout de plusieurs dépenses ;
- modification ;
- suppression ;
- changement de statut ;
- séparation des dépenses en cours et historiques ;
- calcul des montants totaux ;
- notification de l'interface avec `ValueNotifier`.

### `lib/presentation/pages/expense/expense_store.dart`

Fichier de réexport du store situé dans `features/expense/data`.

Il ne contient pas de logique propre.

### `lib/presentation/pages/expense/manual_expense_page.dart`

Formulaire de création ou de modification manuelle d'une dépense.

Après validation, la dépense est ajoutée à `ExpenseStore`.

### `lib/presentation/pages/expense/qr_scanner_page.dart`

Écran de scan d'une dépense par QR code.

Utilise `mobile_scanner`, analyse le contenu du QR code et ouvre ensuite le formulaire de dépense.

## 7. Fonctionnalité colis

### `lib/features/parcel/data/parcel_store.dart`

Définit le modèle `ParcelRecord` et le store `ParcelStore`.

Le store conserve en mémoire :

- les colis en attente ;
- les colis enregistrés ;
- les notifications ;
- les notifications non lues.

### `lib/features/parcel/presentation/pages/parcel_constants.dart`

Regroupe les constantes de la fonctionnalité colis :

- couleurs ;
- villes ;
- types de colis ;
- modèle temporaire du formulaire.

### `lib/features/parcel/presentation/pages/parcel_form_widgets.dart`

Contient les widgets du formulaire colis :

- sélection de ville ;
- sélection de nature du colis ;
- quantité ;
- pièce jointe ;
- cartes et boutons du formulaire.

### `lib/features/parcel/presentation/pages/send_parcel_page.dart`

Formulaire d'envoi d'un colis.

Gère :

- les informations du destinataire ;
- le trajet ;
- la nature du colis ;
- la quantité ;
- la photo ou pièce jointe ;
- l'ouverture du billet colis.

### `lib/features/parcel/presentation/pages/parcel_pages.dart`

Fichier hôte utilisant le mécanisme Dart `part` pour assembler plusieurs fichiers de la fonctionnalité colis.

### `lib/features/parcel/presentation/pages/parcel_menu_content.dart`

Menu colis côté client.

Permet d'accéder à l'envoi, au suivi et à la consultation des colis.

### `lib/features/parcel/presentation/pages/billet_page.dart`

Affiche le billet ou récapitulatif d'un colis.

Fonctionnalités :

- affichage des informations du colis ;
- génération d'un QR code ;
- génération d'un PDF ;
- impression et partage ;
- paiement en agence ;
- création d'un `ParcelRecord`.

Utilise les packages `qr_flutter`, `pdf` et `printing`.

### `lib/features/parcel/presentation/pages/colis_attente_page.dart`

Affiche les colis en attente et les colis enregistrés.

Fonctionnalités :

- filtrage par client ;
- consultation des détails ;
- paiement ;
- changement de statut ;
- enregistrement du colis dans `ParcelStore`.

### `lib/features/parcel/presentation/pages/envois_effectues_page.dart`

Affiche un récapitulatif des envois effectués.

Propose notamment la création d'un nouvel envoi et l'accès au suivi.

## 8. Façades colis

Les fichiers suivants réexportent la fonctionnalité située dans `features/parcel`. Ils servent de compatibilité avec d'anciens chemins d'import et ne contiennent pas de logique métier.

- `lib/presentation/pages/parcel/parcel_store.dart` : réexport de `ParcelStore` ;
- `lib/presentation/pages/parcel/parcel_pages.dart` : réexport du fichier hôte colis ;
- `lib/presentation/pages/parcel/billet_page.dart` : réexport de `BilletPage` ;
- `lib/presentation/pages/parcel/colis_attente_page.dart` : réexport de `ColisAttentePage` ;
- `lib/presentation/pages/parcel/envois_effectues_page.dart` : réexport de `EnvoisEffectuesPage`.

## 9. Onboarding et authentification

### `lib/presentation/pages/onboarding/onboarding_page.dart`

Affiche les slides d'introduction avec un `PageView`.

Gère le défilement, l'indicateur de position et la navigation vers Welcome.

### `lib/presentation/pages/onboarding/onboarding_slide.dart`

Affiche une slide à partir d'un objet `OnboardingData`.

### `lib/presentation/pages/onboarding/onboarding_placeholder.dart`

Affiche un visuel de remplacement lorsqu'une image d'onboarding est absente ou indisponible.

### `lib/presentation/pages/welcome/welcome_page.dart`

Page d'accueil affichée après l'onboarding.

Contient :

- l'image et le logo Fofana ;
- les boutons d'inscription et de connexion ;
- une demande d'activation de la localisation ;
- la présentation des services de voyage et de colis.

### `lib/presentation/pages/register/register_page.dart`

Formulaire d'inscription client.

Enregistre le téléphone et le profil avec `AuthLocalStore`, puis redirige vers la vérification du code.

### `lib/presentation/pages/login/login_page.dart`

Première étape de connexion.

Le numéro saisi est comparé à `AuthLocalStore` :

- un client connu est envoyé vers la vérification OTP ;
- un autre numéro est envoyé vers l'écran de mot de passe équipe.

### `lib/presentation/pages/login/collector_password_page.dart`

Écran de mot de passe destiné à l'accès du percepteur ou de l'équipe interne.

### `lib/presentation/pages/controller/controller_password_page.dart`

Écran de mot de passe spécifique au contrôleur.

### `lib/presentation/pages/verify_code/verify_code_page.dart`

Écran de vérification du code à six chiffres.

Gère :

- la saisie du code ;
- le délai avant renvoi ;
- la création de la session client ;
- la redirection vers l'espace client.

### `lib/presentation/pages/forgot_password/forgot_password_page.dart`

Permet de saisir un numéro de téléphone et simule l'envoi d'un code de récupération.

## 10. Tarifs

### `lib/presentation/pages/tarifs/tarifs_page.dart`

Permet de sélectionner une ville de départ et une destination, puis d'afficher les tarifs.

Peut aussi transmettre une sélection au parcours de réservation.

## 11. Espace client

### `lib/presentation/pages/home/home_page.dart`

Écran principal du client connecté.

Assemble plusieurs sections avec le mécanisme Dart `part` et gère les onglets de l'espace client.

### `lib/presentation/pages/home/parts/location_section.dart`

Gère :

- la sélection des villes ;
- la localisation ;
- la recherche des agences proches ;
- l'affichage des cartes d'agence.

### `lib/presentation/pages/home/parts/news_section.dart`

Gère les actualités locales :

- données d'actualités ;
- carrousel automatique ;
- filtrage par catégorie ;
- affichage du détail.

### `lib/presentation/pages/home/parts/reservation_flow.dart`

Gère le parcours complet de réservation côté client.

Le parcours accessible depuis l'onglet Voyage est :

```text
Voyage
	-> Réservation ou Tarifs
	-> départ et destination
	-> date, heure et nombre de passagers
	-> confirmation
	-> paiement
	-> billet généré
	-> historique
```

Fonctionnalités :

- trajet ;
- date et heure ;
- nombre de passagers ;
- choix du siège ;
- paiement ;
- génération du billet ;
- ajout à l'historique local ;
- modification de la réservation ;
- reprogrammation ;
- annulation.

Ce fichier contient notamment la page de réservation, la page du billet généré
et le paiement. La réservation est ensuite ajoutée à `_HistoryRepository` dans
`home_page.dart`.

### `lib/presentation/pages/home/parts/history_section.dart`

Affiche l'historique des réservations et des billets.

Permet notamment la consultation, l'ouverture du billet, la modification, la
reprogrammation et l'annulation.

### `lib/presentation/pages/home/parts/menu_account_section.dart`

Gère le menu du compte client :

- profil ;
- avatar ;
- déconnexion ;
- notifications colis ;
- consultation des colis finalisés.

Utilise `SessionStore` et `ParcelStore`.

## 12. Espace percepteur

### `lib/presentation/pages/collector/collector_home_page.dart`

Écran principal du percepteur.

Contient les espaces :

- voyages ;
- colis ;
- dépenses ;
- profil.

Sert également de fichier hôte pour plusieurs fichiers `part`.

### `lib/presentation/pages/collector/parts/models_and_stores.dart`

Contient les modèles et stores internes du percepteur :

- notifications ;
- profil ;
- réservations ;
- colis affectés.

### `lib/presentation/pages/collector/parts/tab_content.dart`

Sélectionne le contenu à afficher selon l'onglet actif du percepteur.

### `lib/presentation/pages/collector/parts/voyage_menu_section.dart`

Menu des actions liées aux voyages, affectations et validations.

### `lib/presentation/pages/collector/parts/reservation_flow.dart`

Gère les réservations côté percepteur :

- création d'une réservation pour un client ;
- calcul de distance ;
- choix du trajet et du véhicule ;
- paiement par différents moyens ;
- confirmation de la réservation ;
- enregistrement dans `_CollectorReservationStore` ;
- affichage de l'historique des réservations du percepteur.

### `lib/presentation/pages/collector/parts/assignments_section.dart`

Affiche les affectations de véhicules, chauffeurs et percepteurs.

Gère notamment :

- les missions actuelles ;
- les missions programmées ;
- l'historique ;
- les filtres de statut ;
- les détails du chauffeur ;
- le véhicule et le trajet.

Le chauffeur est présent ici comme information d'affectation, mais il ne possède pas encore d'espace de connexion autonome.

### `lib/presentation/pages/collector/parts/parcel_section.dart`

Gestion des colis côté percepteur :

- consultation ;
- sélection ;
- acceptation ;
- changement de statut ;
- affichage des détails.

### `lib/presentation/pages/collector/parts/expense_section.dart`

Tableau de gestion des dépenses du percepteur.

Contient :

- dépenses en cours ;
- dépenses historiques ;
- solde ;
- ajout manuel ;
- scan QR ;
- validation ou rejet.

Utilise `ExpenseStore`.

### `lib/presentation/pages/collector/parts/notifications_section.dart`

Affiche les notifications du percepteur avec badge, liste et détail.

### `lib/presentation/pages/collector/parts/menu_profile_section.dart`

Menu du profil percepteur :

- profil ;
- affectations ;
- colis ;
- conditions ;
- déconnexion.

### `lib/presentation/pages/collector/parts/ticket_validation_section.dart`

Permet de scanner un ticket ou de saisir manuellement ses informations afin de le valider.

### `lib/presentation/pages/collector/parts/history_news_section.dart`

Affiche l'historique des opérations du percepteur et les actualités locales.

## 13. Espace contrôleur

### `lib/presentation/pages/controller/controller_home_page.dart`

Écran principal du contrôleur.

Contient les onglets :

- voyage ;
- historique ;
- profil.

Une partie de la structure est partagée avec le percepteur.

### `lib/presentation/pages/controller/controller_models.dart`

Contient les stores internes du contrôleur :

- tickets scannés ;
- profil contrôleur.

### `lib/presentation/pages/controller/controller_history_section.dart`

Affiche les tickets validés par le contrôleur.

### `lib/presentation/pages/controller/controller_profile_section.dart`

Affiche et permet de modifier le profil du contrôleur.

### `lib/presentation/pages/controller/controller_password_page.dart`

Écran de connexion du contrôleur.

## 14. Points d'architecture importants

### Données persistées

Les téléphones et profils clients sont sauvegardés localement avec `SharedPreferences`.

### Données en mémoire

Les éléments suivants sont actuellement principalement conservés en mémoire :

- session courante ;
- colis ;
- dépenses ;
- réservations ;
- tickets ;
- notifications ;
- profils percepteur et contrôleur.

Les réservations client sont conservées dans `_HistoryRepository` et les
réservations percepteur dans `_CollectorReservationStore`. Une fermeture
complète de l'application peut donc faire perdre ces données temporaires.

### Réservation

La réservation existe donc bien dans le projet, avec deux parcours :

- **client** : réservation depuis l'onglet Voyage, paiement, billet généré et
	historique ;
- **percepteur** : réservation pour un client, paiement, confirmation et suivi
	local.

La fonctionnalité est actuellement locale et simulée. Il n'y a pas encore de
connexion à une API de disponibilités, de paiement ou de billetterie. Les
places, tarifs, paiements et billets ne sont donc pas synchronisés avec un
serveur distant.

### Absence de backend visible

Aucun service API ou repository distant n'est actuellement visible dans `lib`. Les opérations sont principalement simulées localement.

### Fichiers `part`

`home_page.dart` et `collector_home_page.dart` partagent leur contexte avec plusieurs fichiers grâce à `part` et `part of`. Cela permet de partager des classes privées, mais crée un couplage important entre les fichiers.

### Espace chauffeur

Le projet ne contient pas encore d'espace chauffeur autonome.

Le chauffeur est seulement référencé dans `assignments_section.dart` avec :

- son nom ;
- son téléphone ;
- le véhicule affecté ;
- le trajet ;
- les horaires.

Il n'existe pas encore de page, route, modèle ou authentification spécifique au chauffeur.

### Données répétées

Certaines villes, couleurs et données locales sont définies directement dans plusieurs fichiers. Une centralisation future pourrait réduire cette duplication.

## 15. Vérification

Le projet passe actuellement la commande suivante sans erreur :

```text
flutter analyze
```
