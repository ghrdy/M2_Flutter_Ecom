// Test de connexion Firebase simple
// Ce script teste la connexion à votre base de données

const projectId = 'm2flutter-1d466';
const apiKey = 'AIzaSyD8KjxzAov98WXnSYxFgd-IkRRMdjiSdrM';

console.log('🔥 Test de connexion Firebase...');
console.log('📁 Projet ID:', projectId);

// Test avec l'API REST de Firestore
const testUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/products`;

console.log('🌐 URL de test:', testUrl);
console.log('📡 Tentative de connexion...');

fetch(testUrl)
  .then(response => {
    console.log('📊 Status:', response.status);
    if (response.ok) {
      return response.json();
    } else {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
  })
  .then(data => {
    console.log('✅ Connexion réussie !');
    console.log('📦 Documents trouvés:', data.documents ? data.documents.length : 0);
    
    if (data.documents && data.documents.length > 0) {
      console.log('🛍️ Premier produit:');
      const firstDoc = data.documents[0];
      const fields = firstDoc.fields;
      console.log('   - Nom:', fields.name?.stringValue || 'N/A');
      console.log('   - Prix:', fields.price?.doubleValue || 'N/A');
      console.log('   - Featured:', fields.isFeatured?.booleanValue || 'N/A');
    }
  })
  .catch(error => {
    console.error('❌ Erreur de connexion:', error.message);
    console.log('🔧 Vérifiez:');
    console.log('   - Règles Firestore (lecture autorisée ?)');
    console.log('   - Configuration du projet');
    console.log('   - Connexion internet');
  });
