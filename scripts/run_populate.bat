@echo off
echo 🔥 Script de remplissage Firebase
echo ====================================
echo.
echo 📦 Installation des dépendances...
cd ..
flutter pub get
echo.
echo 🚀 Exécution du script...
dart scripts/populate_firestore.dart
echo.
echo ✅ Terminé! Appuyez sur une touche pour fermer...
pause >nul
