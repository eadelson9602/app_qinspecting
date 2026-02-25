# Configuración Android en Codemagic

## Versión (versionCode / versionName)

La versión se obtiene en este orden:

1. **Flutter** (desde `pubspec.yaml`, campo `version: X.Y.Z+BUILD`) → el plugin de Flutter expone `flutter.versionCode` y `flutter.versionName`.
2. **Fallback** → si no están disponibles, se leen de `android/local.properties`:
   - `flutter.versionCode=11`
   - `flutter.versionName=1.1.8`

**En Codemagic** normalmente no hace falta nada: Flutter rellena la versión desde `pubspec.yaml` al ejecutar `flutter build appbundle`.  
Si en algún momento el build fallara por “unknown property flutter.versionCode”, puedes **escribir** esas claves en `local.properties` en un script previo al build:

```yaml
# En codemagic.yaml, en el script de build (antes de flutter build appbundle):
scripts:
  - name: Set Android version in local.properties
    script: |
      echo "flutter.versionCode=$BUILD_NUMBER" >> android/local.properties
      echo "flutter.versionName=$PUBLISH_VERSION" >> android/local.properties
```

Usa variables de Codemagic (`BUILD_NUMBER`, `PUBLISH_VERSION`) o valores fijos si lo prefieres.

---

## Firma de release (key.properties y keystore)

`key.properties` **no** debe subirse al repo (contiene contraseñas). En Codemagic hay que generarlo en cada build.

### 1. Subir el keystore como secreto

- En Codemagic: **Settings** → tu app → **Secure storage** (o **Environment variables**).
- Añade un archivo: nombre p. ej. **`upload-keystore.jks`** y sube el contenido de `upload-keystore.jks`.

### 2. Variables de entorno para las claves

Crea variables **secretas** (no las muestres en logs):

- `CM_KEY_STORE_PASSWORD` → contraseña del store (ej. la de `storePassword`)
- `CM_KEY_ALIAS` → alias (ej. `upload`)
- `CM_KEY_PASSWORD` → contraseña de la clave (ej. la de `keyPassword`)

### 3. Script que crea key.properties y coloca el keystore

En **codemagic.yaml** (o en el script de build de la interfaz), antes de `flutter build appbundle`:

```yaml
scripts:
  - name: Configurar firma Android
    script: |
      echo "storePassword=$CM_KEY_STORE_PASSWORD" > android/key.properties
      echo "keyPassword=$CM_KEY_PASSWORD" >> android/key.properties
      echo "keyAlias=$CM_KEY_ALIAS" >> android/key.properties
      echo "storeFile=$CM_KEY_STORE_PATH" >> android/key.properties
```

Si guardaste el keystore como archivo en Secure storage, Codemagic lo expone con una ruta; esa ruta es la que debes poner en `CM_KEY_STORE_PATH` (o escribirla directamente en el script).  
Ejemplo si el keystore se descarga a `$CM_KEY_STORE_PATH`:

```yaml
  - name: Configurar firma Android
    script: |
      echo "storePassword=$CM_KEY_STORE_PASSWORD" > android/key.properties
      echo "keyPassword=$CM_KEY_PASSWORD" >> android/key.properties
      echo "keyAlias=$CM_KEY_ALIAS" >> android/key.properties
      echo "storeFile=$CM_KEY_STORE_PATH" >> android/key.properties
```

(En la interfaz de Codemagic, “Secure storage” suele dar una ruta tipo `/tmp/...` al archivo subido; usa esa ruta en `storeFile`.)

### 4. Ruta relativa del keystore (opcional)

Si en lugar de la ruta absoluta de Codemagic prefieres una ruta relativa al proyecto, copia el keystore a `android/` en el script y usa:

```bash
echo "storeFile=upload-keystore.jks" >> android/key.properties
```

En `build.gradle` ya se usa `file(keystoreProperties['storeFile'])`, que resuelve rutas relativas respecto al módulo `android` (o al root del proyecto, según cómo esté definido); una ruta `upload-keystore.jks` suele resolverse si el archivo está en `android/upload-keystore.jks`.

---

## Publicar en Google Play: errores con "changesNotSentForReview"

Hay dos errores posibles según lo que exija Google para tu track.

### Error 1: "The query parameter changesNotSentForReview must not be set"

Si falla con:

```text
Changes are sent for review automatically. The query parameter changesNotSentForReview must not be set.
```

significa que para este track (p. ej. **internal**) Google **sí** envía los cambios a revisión automáticamente, y **no** debe enviarse el parámetro `changesNotSentForReview`.

**Solución:**

- **Workflow Editor (UI):** En Codemagic → tu app → **Publish** → Google Play, **desactiva** la opción **"Changes not sent for review"** / **"Submit as draft"** (o equivalente).
- **codemagic.yaml:** En la sección `publishing.google_play` **no** pongas `changes_not_sent_for_review: true`, o bórralo si está. Debe quedar solo algo como:

```yaml
publishing:
  google_play:
    credentials: $GOOGLE_PLAY_SERVICE_ACCOUNT_CREDENTIALS
    track: internal
```

Vuelve a lanzar el build.

---

### Error 2: "Changes cannot be sent for review automatically"

Si en cambio falla con:

```text
Setting release for Google Play track internal failed.
Changes cannot be sent for review automatically. Please set the query parameter changesNotSentForReview to true.
```

significa que Google Play **no** permite enviar esta publicación a revisión de forma automática. Hay que indicar que los cambios **no** se envíen a revisión y luego enviarlos manualmente desde Play Console.

**Opción A: Workflow Editor**

1. En Codemagic → **Publish** → Google Play, activa **"Changes not sent for review"**.
2. Guarda y vuelve a lanzar el build.

**Opción B: codemagic.yaml**

Añade `changes_not_sent_for_review: true`:

```yaml
publishing:
  google_play:
    credentials: $GOOGLE_PLAY_SERVICE_ACCOUNT_CREDENTIALS
    track: internal
    changes_not_sent_for_review: true
```

**Después del build:** entra en Google Play Console → Internal testing y envía el release a revisión manualmente cuando quieras.

Referencia: [Codemagic - Google Play publishing](https://docs.codemagic.io/yaml-publishing/google-play/), [Common Google Play errors](https://docs.codemagic.io/troubleshooting/common-google-play-errors).

---

## Resumen

| Dónde           | Qué hace |
|-----------------|----------|
| **pubspec.yaml**| `version: X.Y.Z+BUILD` → versión por defecto en el build. |
| **local.properties** | Opcional: `flutter.versionCode` y `flutter.versionName` como fallback (útil si en CI no se leen del plugin). |
| **Codemagic**   | Crear `key.properties` en el script con variables secretas y tener el `.jks` en Secure storage (o copiado a `android/`). |
| **Codemagic (publicar)** | Si falla "**changesNotSentForReview must not be set**", **desactivar** "Changes not sent for review" en Google Play (o quitar `changes_not_sent_for_review` del yaml). Si falla "**Changes cannot be sent for review automatically**", activar "Changes not sent for review" o añadir `changes_not_sent_for_review: true` y enviar a revisión desde Play Console. |

No subas `local.properties` ni `key.properties` al repositorio; en Codemagic se generan en cada build.

---

## ANR en arranque (nativeSurfaceCreated)

Si aparecen ANR en `FlutterJNI.nativeSurfaceCreated` (sobre todo en dispositivos Google/Pixel):

- **Causa:** demasiado trabajo en el hilo principal antes de que Flutter dibuje el primer frame (inicialización síncrona en `main()` o en `MainActivity`).
- **Qué se hizo en la app:**
  - **Inicialización diferida:** en `lib/main.dart` solo se ejecutan antes de `runApp()` Firebase, Crashlytics y los handlers de error. El resto (notificaciones, subida en segundo plano, listener de conectividad, `ErrorHandler`) se ejecuta en `addPostFrameCallback` tras el primer frame.
  - **Splash Screen API (Android 12+):** en `MainActivity` se llama a `SplashScreen.installSplashScreen(this)` antes de `super.onCreate()` para que el sistema muestre el splash hasta que Flutter pinte.
- **Recomendaciones:** no añadir más `await` pesados en `main()` antes de `runApp()`; mantener Flutter y plugins actualizados; perfilar el arranque en dispositivos afectados con Android Studio CPU Profiler.
