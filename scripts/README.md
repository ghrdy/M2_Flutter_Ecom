# 🔥 Scripts Firebase

Ce dossier contient les scripts pour automatiser la gestion de votre base de données Firebase.

## 📦 Remplir la base de données

### Windows
```bash
cd scripts
run_populate.bat
```

### Mac/Linux
```bash
cd scripts
chmod +x run_populate.sh
./run_populate.sh
```

### Manuellement
```bash
dart scripts/populate_firestore.dart
```

## 🛍️ Produits ajoutés

Le script ajoute automatiquement **10 produits premium** :

1. **iPhone 15 Pro Max** - 1299,99€
2. **MacBook Pro 16" M3 Max** - 2899,99€ 
3. **AirPods Pro 2ème génération** - 279,99€
4. **iPad Pro 12,9" M2** - 1199,99€
5. **Apple Watch Ultra 2** - 849,99€
6. **Studio Display** - 1699,99€
7. **Magic Keyboard avec Touch ID** - 199,99€
8. **AirTag Pack de 4** - 119,99€
9. **Mac Studio M2 Ultra** - 4399,99€
10. **HomePod 2ème génération** - 349,99€

## ⚙️ Configuration

Assurez-vous que :
- Firebase est configuré dans votre projet
- `firebase_options.dart` est à jour
- Vous avez les droits d'écriture sur Firestore

## 🔧 Résolution de problèmes

**Erreur de permissions** : Vérifiez les règles Firestore
**Erreur de connexion** : Vérifiez votre configuration Firebase
**Produits dupliqués** : Le script supprime automatiquement les anciens produits
