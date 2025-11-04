# Instrucciones para Revisión - Play Store

## Información de Acceso de Prueba

**Usuario de prueba:** [INGRESAR NÚMERO DE DOCUMENTO]
**Contraseña:** [INGRESAR CONTRASEÑA]
**Empresa:** [SELECCIONAR EMPRESA DEL LISTADO]

**Nota:** Si no tienes credenciales de prueba, contacta al equipo de desarrollo en [EMAIL DE CONTACTO] para obtener acceso.

---

## Pasos para Iniciar Sesión

1. **Abrir la aplicación** Qinspecting
2. **Ingresar credenciales:**
   - En el campo "Usuario", ingresar el número de documento
   - En el campo "Contraseña", ingresar la contraseña
3. **Seleccionar empresa:**
   - Después de ingresar las credenciales, se mostrará un listado de empresas disponibles
   - Seleccionar la empresa del listado
4. **Acceder al sistema:**
   - Al seleccionar la empresa, la aplicación cargará los datos iniciales y mostrará el dashboard principal

---

## Funcionalidades Principales para Revisar

### 1. Dashboard Principal
- **Ubicación:** Pestaña "Escritorio" (primera pestaña del menú inferior)
- **Qué revisar:** 
  - Dashboard con estadísticas de inspecciones
  - Cards deslizables con inspecciones recientes
  - Funcionalidad offline (si no hay conexión, muestra inspecciones guardadas localmente)

### 2. Realizar Inspección
- **Ubicación:** Pestaña "Inspección" (segunda pestaña del menú inferior)
- **Pasos:**
  1. Seleccionar placa del vehículo del dropdown
  2. Seleccionar departamento de inspección
  3. Usar GPS automático o seleccionar ciudad manualmente
  4. Ingresar kilometraje
  5. Capturar foto del kilometraje (cámara o galería)
  6. Capturar foto del cabezote (opcional)
  7. Activar/desactivar switches según corresponda:
     - ¿Realizó tanqueo?
     - ¿Tiene remolque?
     - ¿Tiene guía de transporte?
  8. Presionar botón "Realizar inspección"
  9. Completar formulario paso a paso con los items de inspección
  10. Usar botón "Todo ok" para marcar todos los items como cumplidos
  11. Finalizar y guardar la inspección

### 3. Gestión de Inspecciones Pendientes
- **Ubicación:** Menú lateral (hamburguesa) → "Enviar inspecciones pendientes"
- **Qué revisar:**
  - Lista de inspecciones guardadas offline
  - Proceso de envío en segundo plano
  - Notificaciones de progreso durante la subida

### 4. Perfil de Usuario
- **Ubicación:** Menú lateral → "Perfil"
- **Qué revisar:**
  - Visualización de datos personales
  - Actualización de foto de perfil
  - Cambio de datos personales

### 5. Firma Digital
- **Ubicación:** Menú lateral → "Firma"
- **Qué revisar:**
  - Visualización de firma guardada
  - Crear nueva firma (dibujo en pantalla)
  - Términos y condiciones

### 6. Generación de PDFs
- **Ubicación:** Desde el dashboard, al tocar una inspección
- **Qué revisar:**
  - PDF con información completa de la inspección
  - Fotos incluidas en el PDF
  - Compartir PDF

### 7. Configuración
- **Ubicación:** Menú lateral → "Configuración"
- **Qué revisar:**
  - Toggle de tema claro/oscuro
  - Solicitud de permisos GPS
  - Gestión de cache

---

## Permisos Requeridos

La aplicación solicita los siguientes permisos durante el uso:

- **Cámara:** Para capturar fotos de kilometraje, cabezote, remolque y guías
- **Almacenamiento:** Para guardar fotos y generar PDFs
- **Ubicación (GPS):** Para detectar automáticamente la ciudad donde se realiza la inspección
- **Notificaciones:** Para mostrar el progreso de subida de inspecciones en segundo plano

**Nota:** Todos los permisos se solicitan de forma contextual cuando el usuario los necesita, no al inicio de la aplicación.

---

## Funcionalidades Offline

La aplicación funciona completamente sin conexión a internet:
- Se pueden realizar inspecciones sin conexión
- Las inspecciones se guardan localmente en SQLite
- Cuando se recupera la conexión, las inspecciones se sincronizan automáticamente
- Los PDFs se pueden generar y visualizar offline

---

## Características Adicionales

- **Tema oscuro/claro:** Disponible en el menú de configuración
- **Sincronización automática:** Las inspecciones pendientes se suben automáticamente cuando hay conexión
- **Notificaciones en segundo plano:** Muestra el progreso de subida de inspecciones
- **Geolocalización automática:** Detecta la ciudad usando GPS

---

## Notas Importantes para el Revisor

1. **Datos de prueba:** Si los datos de prueba no funcionan, la aplicación requiere conexión a un servidor backend específico. Contactar al desarrollador si es necesario.

2. **Funcionalidad offline:** Para probar la funcionalidad offline, se puede activar el modo avión después de iniciar sesión.

3. **Subida de archivos:** Las fotos e inspecciones se suben al servidor, por lo que requiere conexión a internet para completar el proceso.

4. **Multiempresa:** Un usuario puede tener acceso a múltiples empresas, por lo que debe seleccionar una al iniciar sesión.

---

## Contacto

Para problemas o preguntas durante la revisión:
- **Email:** [INGRESAR EMAIL DE CONTACTO]
- **Teléfono:** [INGRESAR TELÉFONO OPCIONAL]

---

**Versión de la app:** 2.1.0
**Package name:** com.qinspecting.mobile
**Fecha de envío:** [FECHA ACTUAL]

