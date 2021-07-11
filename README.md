See individual project readme files.

## Using with you own firebase instances.

Setup cloud messaging in app: https://firebase.flutter.dev/docs/messaging/overview/

Setup cloud messaging in server: https://firebase.google.com/docs/cloud-messaging/js/client

## Usage

Overall installation and usage of the system from a user perspective is quite simple. The user can install the app and
plugin from the platform associated store (The app and plugin are currently not present on stores). After installation,
the user opens the app, goes to settings, enters an encryption key and mails the registration token to
themself ([screenshot](img/setup-app.png)). Next, the user opens the plugin settings and enters the encryption key and
the just received registration token ([screenshot](img/setup-plugin.png)).

The system is now set up and ready to be used. When the user wants to send a QR-code that is currently present on the
screen to the phone, they simply click on the plugin button ([screenshot](img/usage-plugin.png)). A small dialog with
basic info is presented to the user and the QR-code is sent to the phone. QR-codes are never scanned and sent to the
user without an explicit user action. The QR-code can be opened by the user by clicking on the notification received on
the phone ([screenshot](img/usage-app.png)). The QR-code is also never opened without an explicit user action. The
receiver app tries to open an app with the QR-code. If that is not successful, an error message is presented to the
user. Since there is no user account, all data can be deleted by removing the app and plugin.

## Supported QR-codes

1. [IRMA](https://irma.app/) QR-codes
2. QR-codes that are URIs.
