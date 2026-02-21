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

## Publicar en Google Play: "Changes cannot be sent for review automatically"

Si el build sube el AAB pero falla con:

```text
Setting release for Google Play track internal failed.
Changes cannot be sent for review automatically. Please set the query parameter changesNotSentForReview to true.
```

significa que Google Play **no** permite enviar esta publicación a revisión de forma automática. Hay que indicar que los cambios **no** se envíen a revisión y luego enviarlos manualmente desde Play Console.

### Opción A: Codemagic con **Workflow Editor** (interfaz web)

1. Entra en **Codemagic** → tu app → **Publish** (o el paso de publicación a Google Play).
2. En la sección **Google Play**, busca una opción tipo **"Submit as draft"** o **"Changes not sent for review"**.
3. Activa **"Changes not sent for review"** (o el equivalente que ofrezca la UI).
4. Guarda y vuelve a lanzar el build.

Si no ves esa opción, usa **codemagic.yaml** (Opción B).

### Opción B: Codemagic con **codemagic.yaml**

En la sección de publicación a Google Play añade `changes_not_sent_for_review: true`:

```yaml
publishing:
  google_play:
    credentials: $GOOGLE_PLAY_SERVICE_ACCOUNT_CREDENTIALS
    track: internal
    changes_not_sent_for_review: true   # Los cambios se envían a revisión desde Play Console
```

### Después del build

1. El AAB se sube y el release queda **guardado** en la pestaña correspondiente (p. ej. Internal testing).
2. Entra en **Google Play Console** → tu app → **Testing** → **Internal testing** (o el track que uses).
3. Verás el release en estado "Ready to send for review" o similar.
4. Haz clic en **"Send for review"** (o "Enviar para revisión") cuando quieras que Google lo revise.

Referencia: [Codemagic - Google Play publishing](https://docs.codemagic.io/yaml-publishing/google-play/), [Common Google Play errors](https://docs.codemagic.io/troubleshooting/common-google-play-errors).

---

## Resumen

| Dónde           | Qué hace |
|-----------------|----------|
| **pubspec.yaml**| `version: X.Y.Z+BUILD` → versión por defecto en el build. |
| **local.properties** | Opcional: `flutter.versionCode` y `flutter.versionName` como fallback (útil si en CI no se leen del plugin). |
| **Codemagic**   | Crear `key.properties` en el script con variables secretas y tener el `.jks` en Secure storage (o copiado a `android/`). |
| **Codemagic (publicar)** | Si falla "Changes cannot be sent for review automatically", activar **Changes not sent for review** en el paso de Google Play o en codemagic.yaml: `changes_not_sent_for_review: true`. Luego enviar a revisión desde Google Play Console. |

No subas `local.properties` ni `key.properties` al repositorio; en Codemagic se generan en cada build.
