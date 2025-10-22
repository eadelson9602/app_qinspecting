# CustomStyleButton - Guía de Uso

Este widget replica el estilo de los botones de `SafeCrashlyticsTest` pero usando los colores del tema de tu aplicación.

## Componentes Disponibles

### 1. CustomStyleButton
Botón individual con el estilo personalizado.

```dart
CustomStyleButton(
  text: 'Guardar',
  icon: Icons.save,
  backgroundColor: Colors.green,
  onPressed: () {
    // Tu acción aquí
  },
)
```

### 2. CustomStyleButtonRow
Fila de botones que se expanden automáticamente.

```dart
CustomStyleButtonRow(
  buttons: [
    CustomStyleButton(
      text: 'Guardar',
      backgroundColor: Colors.green,
      onPressed: () {},
    ),
    CustomStyleButton(
      text: 'Cancelar',
      backgroundColor: Colors.red,
      onPressed: () {},
    ),
  ],
)
```

### 3. CustomStyleButtonCard
Tarjeta con título y botones, similar al estilo de SafeCrashlyticsTest.

```dart
CustomStyleButtonCard(
  title: '🚀 Acciones',
  buttons: [
    CustomStyleButton(
      text: 'Acción 1',
      backgroundColor: Colors.blue,
      onPressed: () {},
    ),
    CustomStyleButton(
      text: 'Acción 2',
      backgroundColor: Colors.orange,
      onPressed: () {},
    ),
  ],
)
```

## Propiedades Principales

### CustomStyleButton
- `text`: Texto del botón
- `onPressed`: Función a ejecutar
- `backgroundColor`: Color de fondo (usa el tema por defecto si no se especifica)
- `foregroundColor`: Color del texto (blanco por defecto)
- `icon`: Icono opcional
- `isExpanded`: Si el botón debe expandirse
- `width`: Ancho específico
- `padding`: Padding personalizado
- `fontSize`: Tamaño de fuente

### CustomStyleButtonRow
- `buttons`: Lista de botones
- `spacing`: Espaciado entre botones (4px por defecto)

### CustomStyleButtonCard
- `title`: Título de la tarjeta
- `buttons`: Lista de botones
- `cardColor`: Color de fondo de la tarjeta
- `borderColor`: Color del borde
- `margin`: Margen de la tarjeta
- `padding`: Padding interno de la tarjeta

## Ejemplos de Uso en tu App

### Botones de Acción Principal
```dart
CustomStyleButtonCard(
  title: '📋 Inspección',
  buttons: [
    CustomStyleButton(
      text: 'Iniciar',
      icon: Icons.play_arrow,
      backgroundColor: Colors.green,
      onPressed: () => _iniciarInspeccion(),
    ),
    CustomStyleButton(
      text: 'Pausar',
      icon: Icons.pause,
      backgroundColor: Colors.orange,
      onPressed: () => _pausarInspeccion(),
    ),
  ],
)
```

### Botones de Navegación
```dart
CustomStyleButtonRow(
  buttons: [
    CustomStyleButton(
      text: 'Anterior',
      icon: Icons.arrow_back,
      backgroundColor: Colors.grey,
      onPressed: () => _anterior(),
    ),
    CustomStyleButton(
      text: 'Siguiente',
      icon: Icons.arrow_forward,
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: () => _siguiente(),
    ),
  ],
)
```

### Botón Individual
```dart
CustomStyleButton(
  text: 'Subir Foto',
  icon: Icons.camera_alt,
  backgroundColor: Colors.blue,
  fontSize: 14,
  padding: EdgeInsets.symmetric(vertical: 8),
  onPressed: () => _tomarFoto(),
)
```

## Integración con tu Tema

Los botones automáticamente usan los colores de tu tema:
- `backgroundColor`: Usa `Theme.of(context).primaryColor` por defecto
- `cardColor`: Usa `primaryColor.withOpacity(0.05)` por defecto
- `borderColor`: Usa `primaryColor.withOpacity(0.2)` por defecto

Puedes sobrescribir cualquier color pasando el parámetro correspondiente.
