# 📱 Projet Flutter — Notifications Locales

## 📋 Table des Matières
1. [Introduction](#introduction)
2. [Architecture du Projet](#architecture-du-projet)
3. [Technologies Utilisées](#technologies-utilisées)
4. [Fonctionnalités Implémentées](#fonctionnalités-implémentées)
5. [Explication du Code](#explication-du-code)
6. [Défis et Solutions](#défis-et-solutions)
7. [Permissions Android](#permissions-android)
8. [Comment Exécuter le Projet](#comment-exécuter-le-projet)

---

## Introduction

Ce projet est une application Flutter démontrant l'implémentation des **notifications locales** sur Android (et iOS). L'application permet à l'utilisateur de déclencher 4 types de notifications différentes depuis une interface simple et intuitive.

L'objectif est de comprendre le cycle de vie des notifications sur mobile, la gestion des permissions, et les défis liés aux restrictions des versions récentes d'Android (API 33+).

---

## Architecture du Projet

```
lib/
├── main.dart                          # Point d'entrée, UI, gestion des permissions
└── services/
    └── notification_service.dart      # Service singleton pour toutes les notifications
android/
└── app/src/main/
    └── AndroidManifest.xml            # Permissions Android déclarées
```

### Pattern Singleton

Le `NotificationService` utilise le **pattern Singleton** pour garantir qu'une seule instance du service existe dans toute l'application :

```dart
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
}
```

**Pourquoi un Singleton ?** Les notifications doivent être gérées par un point central unique. Si plusieurs instances existaient, elles pourraient créer des conflits (IDs dupliqués, timers multiples, etc.).

---

## Technologies Utilisées

| Technologie | Version | Rôle |
|---|---|---|
| Flutter | SDK ^3.10.1 | Framework mobile cross-platform |
| `flutter_local_notifications` | ^21.0.0-dev.1 | Plugin pour notifications locales Android/iOS |
| `permission_handler` | ^11.3.1 | Gestion des permissions runtime |
| Dart `Timer` / `Future.delayed` | Built-in | Planification des notifications différées |

---

## Fonctionnalités Implémentées

### 1. 🔔 Notification Instantanée
Affiche une notification **immédiatement** quand l'utilisateur appuie sur le bouton.

- **Méthode** : `flutterLocalNotificationsPlugin.show()`
- **Canal** : `instant_channel_id`
- **Priorité** : `Importance.max`, `Priority.high`

### 2. ⏱️ Notification Programmée (5 secondes)
Affiche une notification **après un délai de 5 secondes**.

- **Méthode** : `Future.delayed()` + `show()`
- **Canal** : `scheduled_channel_id`
- **Mécanisme** : Un timer Dart déclenche l'affichage après le délai

### 3. 🔁 Notification Répétée (Chaque minute)
Affiche une notification **toutes les minutes** jusqu'à annulation.

- **Méthode** : `Timer.periodic()` + `show()`
- **Canal** : `repeating_channel_id`
- **Compteur** : Affiche le numéro de la notification (ex: "Notification #3")

### 4. 📝 Notification Gros Texte (Big Text)
Affiche une notification avec un **contenu textuel étendu** que l'utilisateur peut développer.

- **Méthode** : `show()` avec `BigTextStyleInformation`
- **Canal** : `big_text_channel_id`
- **Format** : Support HTML pour le formatage du texte

### 5. ❌ Annuler Toutes les Notifications
Annule toutes les notifications actives et arrête les timers de répétition.

---

## Explication du Code

### `main.dart` — Point d'Entrée

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Requis pour les appels async avant runApp
  await NotificationService().init();          // Initialise le plugin de notifications
  await _requestNotificationPermission();      // Demande les permissions Android 13+
  runApp(const MyApp());
}
```

**Points clés :**
- `WidgetsFlutterBinding.ensureInitialized()` est **obligatoire** quand on utilise `await` avant `runApp()`
- Les permissions sont demandées **avant** le lancement de l'UI pour éviter les erreurs

### `notification_service.dart` — Service de Notifications

#### Initialisation
```dart
await flutterLocalNotificationsPlugin.initialize(
  settings: initializationSettings,
  onDidReceiveNotificationResponse: (response) async {
    // Gérer le tap sur la notification
  },
);
```

L'initialisation configure :
- **Android** : Icône de notification (`@mipmap/ic_launcher`)
- **iOS** : Permissions pour son, badge et alerte

#### Canaux de Notification (Android)
Chaque type de notification utilise un **canal** (channel) séparé. Les canaux permettent à l'utilisateur de contrôler chaque type individuellement dans les paramètres Android.

```dart
AndroidNotificationDetails(
  'instant_channel_id',         // ID unique du canal
  'Instant Notifications',      // Nom affiché dans les paramètres
  channelDescription: '...',    // Description
  importance: Importance.max,   // Niveau d'importance
  priority: Priority.high,      // Priorité d'affichage
)
```

### `_buildNotificationButton()` — Widget Réutilisable

L'UI utilise un widget builder personnalisé pour créer des **cartes cliquables** cohérentes :

```dart
Widget _buildNotificationButton(BuildContext context, {
  required String title,
  required String description,
  required IconData icon,
  required VoidCallback onPressed,
})
```

Ce pattern évite la duplication de code et garantit une UI uniforme.

---

## Défis et Solutions

### Défi 1 : Permissions sur Android 13+ (API 33)
**Problème** : Depuis Android 13, les applications doivent demander explicitement la permission `POST_NOTIFICATIONS` pour afficher des notifications.

**Solution** : 
- Ajout de `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` dans le manifest
- Utilisation de `permission_handler` pour demander la permission au runtime

### Défi 2 : `AlarmManager` ne fonctionne pas sur Android 14+ Samsung
**Problème** : Les méthodes `zonedSchedule()` et `periodicallyShow()` du plugin utilisent l'`AlarmManager` d'Android en arrière-plan. Sur les appareils Samsung avec Android 14+, ces alarmes sont silencieusement bloquées, même avec la permission `SCHEDULE_EXACT_ALARM` et le mode `inexactAllowWhileIdle`.

**Solution** : Utilisation de **timers Dart natifs** (`Future.delayed` et `Timer.periodic`) combinés avec la méthode `show()` qui fonctionne parfaitement. Cette approche contourne les restrictions de l'API AlarmManager d'Android.

```dart
// Au lieu de zonedSchedule (qui échoue silencieusement) :
Future.delayed(const Duration(seconds: 5), () async {
  await plugin.show(id: 1, title: '...', body: '...', notificationDetails: details);
});
```

**Limitation** : Les timers Dart fonctionnent uniquement quand l'application est active en mémoire.

### Défi 3 : Overflow de l'UI (RenderFlex)
**Problème** : Le widget `Row` contenant l'icône et le titre débordait de 34 pixels sur les écrans plus étroits.

**Solution** : Envelopper le `Text` du titre dans un widget `Flexible` pour qu'il s'adapte à l'espace disponible.

```dart
Row(children: [
  Icon(icon),
  Flexible(        // ← Empêche le débordement
    child: Text(title),
  ),
])
```

---

## Permissions Android

Le fichier `AndroidManifest.xml` déclare les permissions suivantes :

| Permission | Rôle |
|---|---|
| `RECEIVE_BOOT_COMPLETED` | Restaurer les notifications après redémarrage |
| `VIBRATE` | Vibration lors d'une notification |
| `SCHEDULE_EXACT_ALARM` | Alarmes exactes (Android 12+) |
| `USE_EXACT_ALARM` | Alarmes exactes (Android 14+) |
| `POST_NOTIFICATIONS` | Afficher des notifications (Android 13+) |

---

## Comment Exécuter le Projet

### Prérequis
- Flutter SDK (^3.10.1)
- Un appareil Android physique ou émulateur (API 21+)
- Android Studio ou VS Code avec l'extension Flutter

### Commandes

```bash
# 1. Installer les dépendances
flutter pub get

# 2. Lancer en mode debug
flutter run

# 3. Build APK de release (optionnel)
flutter build apk
```

### Tester les Notifications
1. Lancer l'application
2. **Accepter la permission** de notification quand le popup apparaît
3. Appuyer sur chaque bouton pour tester les différents types
4. Vérifier que les notifications apparaissent dans la barre de statut

---

> **Auteur** : Projet ESIH — Flutter Notifications Demo  
> **Date** : Février 2026  
> **Version** : 1.0.0+1
