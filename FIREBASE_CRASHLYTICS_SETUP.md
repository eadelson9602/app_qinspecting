# 🔥 Firebase Crashlytics - Configuración

## 📋 Pasos para Configurar Firebase Crashlytics

### 1. **Crear Proyecto en Firebase Console**

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita **Crashlytics** en el proyecto

### 2. **Configurar Android**

1. Agrega tu app Android al proyecto Firebase
2. Descarga el archivo `google-services.json` desde Firebase Console
3. Reemplaza el archivo `android/app/google-services.json` con el archivo descargado
4. Actualiza el `package_name` en Firebase Console para que coincida con tu app

### 3. **Configurar iOS** (si aplica)

1. Agrega tu app iOS al proyecto Firebase
2. Descarga el archivo `GoogleService-Info.plist`
3. Colócalo en `ios/Runner/GoogleService-Info.plist`

### 4. **Actualizar Dependencias**

```bash
flutter pub get
```

### 5. **Configurar Gradle (Android)**

Asegúrate de que `android/app/build.gradle` tenga:

```gradle
apply plugin: 'com.google.gms.google-services'
apply plugin: 'com.google.firebase.crashlytics'
```

Y en `android/build.gradle`:

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
    classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9'
}
```

## 🚀 **Funcionalidades Implementadas**

### ✅ **Captura Automática de Errores**

- Crashes de Flutter
- Errores de plataforma
- Excepciones no manejadas

### ✅ **Errores Personalizados**

- Errores de cámara con contexto detallado
- Errores de red con información de endpoints
- Errores de base de datos con operaciones específicas

### ✅ **Información de Usuario**

- ID de usuario
- Email y nombre
- Información de sesión actual

### ✅ **Logs Personalizados**

- Logs de debugging
- Información de contexto
- Datos de sesión

## 📊 **Datos que se Envían a Crashlytics**

### **Información del Dispositivo**

- Modelo del dispositivo
- Versión del SO
- Memoria disponible
- Estado de la batería

### **Información de la App**

- Versión de la app
- Build number
- Estado de la sesión

### **Contexto de Errores**

- Tipo de error
- Ubicación en el código
- Stack trace completo
- Datos personalizados

## 🔍 **Cómo Ver los Reportes**

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Crashlytics** en el menú lateral
4. Verás:
   - **Issues**: Lista de errores únicos
   - **Users**: Usuarios afectados
   - **Velocity**: Frecuencia de errores
   - **Stability**: Estabilidad de la app

## 📱 **Testing**

### **Probar Crashlytics**

```dart
// Forzar un crash para testing
await CrashlyticsService.recordError(
  Exception('Test crash'),
  StackTrace.current,
  reason: 'Testing Crashlytics integration',
);
```

### **Verificar Configuración**

1. Ejecuta la app en modo debug
2. Revisa los logs para confirmar inicialización
3. Los reportes aparecen en Firebase Console en ~5 minutos

## ⚠️ **Notas Importantes**

- **Privacidad**: Crashlytics NO envía datos personales del usuario
- **Debug**: En modo debug, los crashes se envían inmediatamente
- **Release**: En modo release, los crashes se envían al reiniciar la app
- **Offline**: Los datos se almacenan localmente y se envían cuando hay conexión

## 🛠️ **Troubleshooting**

### **Error: "No Firebase App '[DEFAULT]' has been created"**

- Verifica que `google-services.json` esté en la ubicación correcta
- Asegúrate de que el package name coincida

### **Error: "Crashlytics not initialized"**

- Verifica que Firebase esté inicializado antes que Crashlytics
- Revisa los logs de inicialización

### **No aparecen reportes**

- Espera 5-10 minutos para el primer reporte
- Verifica que la app esté en modo release para testing
- Confirma que Crashlytics esté habilitado en Firebase Console
