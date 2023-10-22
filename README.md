# AVM Health App
Dieses Projekt ist im Zuge meiner Bachelorarbeit entstanden. 

## Android
Nach Starten eines Android-Emulators kann die main-Methode unter `lib/main.dart` gestartet werden.

Alternativ kann USB-Debugging auf einem physikalischen Gerät aktiviert und das Gerät mit dem PC verbunden werden.

### Release APK bauen
Für das Bauen eines Releases ist ein Zertifikat nötig. Dies kann entweder selbst erstellt werden, oder von Google beantragt werden, falls das APK in den Playstore hochgeladen werden soll. 

Zum Bauen eines Releases muss das Projekt in Android Studio geöffnet werden. Unter `Tools > Flutter > Open for Editing Android Studio` auswählen. Anschließend dem Dialog im neue geöffneten Fenster unter `Build > Generate Signed Bundle or APK` anstoßen und durchlaufen. 

## iOS
Für das Kompilieren der App ist ein MAC-Book nötig. 
