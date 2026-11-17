# Saludapp Mobile

Aplicación móvil de Saludap construida con Flutter. Permite administrar perfiles
de salud y registrar lecturas de glucosa y presión arterial.

## Requisitos

- Flutter compatible con Dart 3.14 o posterior.
- Backend de Saludap disponible en `http://localhost:3001` por defecto.

## Ejecución

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3001
```

En un emulador Android, utiliza `http://10.0.2.2:3001`. Para un dispositivo
físico conectado por USB puedes ejecutar:

```bash
adb reverse tcp:3001 tcp:3001
flutter run
```

## Google Sign-In

El flujo requiere los Client IDs OAuth correspondientes:

```bash
flutter run \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=WEB_CLIENT_ID \
  --dart-define=GOOGLE_IOS_CLIENT_ID=IOS_CLIENT_ID
```

Los secretos OAuth nunca deben almacenarse en la aplicación ni incluirse en el
repositorio.
