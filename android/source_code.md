# Source Code Summary

## Directory Structure
```
./
  .gitignore
  build.gradle
  gradle.properties
  gradlew
  gradlew.bat
  local.properties
  settings.gradle
  tictactoe_gameapp_android.iml
  .gradle/
    file-system.probe
    8.8/
      gc.properties
      checksums/
        checksums.lock
        md5-checksums.bin
        sha1-checksums.bin
      dependencies-accessors/
        gc.properties
      executionHistory/
        executionHistory.bin
        executionHistory.lock
      expanded/
      fileChanges/
        last-build.bin
      fileHashes/
        fileHashes.bin
        fileHashes.lock
        resourceHashesCache.bin
      vcsMetadata/
    buildOutputCleanup/
      buildOutputCleanup.lock
      cache.properties
      outputFiles.bin
    kotlin/
      errors/
        errors-1730130139217.log
        errors-1730130139228.log
        errors-1730131193072.log
        errors-1730131193079.log
    noVersion/
      buildLogic.lock
    vcs-1/
      gc.properties
  .kotlin/
    errors/
      errors-1730130139217.log
      errors-1730130139228.log
      errors-1730131193072.log
      errors-1730131193079.log
  app/
    build.gradle
    google-services.json
    src/
      debug/
        AndroidManifest.xml
      main/
        AndroidManifest.xml
        java/
          io/
            flutter/
              plugins/
                GeneratedPluginRegistrant.java
        kotlin/
          com/
            example/
              tictactoe_gameapp/
                MainActivity.kt
                ThumbnailPlugin.kt
        res/
          drawable/
            app_logo.png
            app_logo_dark.png
            background.png
            background_dark.png
            branding.png
            branding_dark.png
            launch_background.xml
          drawable-night-v21/
            launch_background.xml
          drawable-v21/
            launch_background.xml
          mipmap-hdpi/
            ic_launcher.png
            launcher_icon.png
          mipmap-mdpi/
            ic_launcher.png
            launcher_icon.png
          mipmap-xhdpi/
            ic_launcher.png
            launcher_icon.png
          mipmap-xxhdpi/
            ic_launcher.png
            launcher_icon.png
          mipmap-xxxhdpi/
            ic_launcher.png
            launcher_icon.png
          raw/
            call_sound.mp3
            notification_sound.mp3
          values/
            styles.xml
          values-night/
            styles.xml
      profile/
        AndroidManifest.xml
  gradle/
    wrapper/
      gradle-wrapper.jar
      gradle-wrapper.properties
```


## File Contents


### app\src\main\java\io\flutter\plugins\GeneratedPluginRegistrant.java

```java
package io.flutter.plugins;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import io.flutter.Log;

import io.flutter.embedding.engine.FlutterEngine;

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Android platform.
 */
@Keep
public final class GeneratedPluginRegistrant {
  private static final String TAG = "GeneratedPluginRegistrant";
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    try {
      flutterEngine.getPlugins().add(new io.agora.agora_rtc_ng.AgoraRtcNgPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin agora_rtc_engine, io.agora.agora_rtc_ng.AgoraRtcNgPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.ryanheise.audio_session.AudioSessionPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin audio_session, com.ryanheise.audio_session.AudioSessionPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin cloud_firestore, io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new dev.fluttercommunity.plus.connectivity.ConnectivityPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin connectivity_plus, dev.fluttercommunity.plus.connectivity.ConnectivityPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.fintasys.emoji_picker_flutter.EmojiPickerFlutterPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin emoji_picker_flutter, com.fintasys.emoji_picker_flutter.EmojiPickerFlutterPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.appcheck.FlutterFirebaseAppCheckPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin firebase_app_check, io.flutter.plugins.firebase.appcheck.FlutterFirebaseAppCheckPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.auth.FlutterFirebaseAuthPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin firebase_auth, io.flutter.plugins.firebase.auth.FlutterFirebaseAuthPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin firebase_core, io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.storage.FlutterFirebaseStoragePlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin firebase_storage, io.flutter.plugins.firebase.storage.FlutterFirebaseStoragePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.pichillilorenzo.flutter_inappwebview_android.InAppWebViewFlutterPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin flutter_inappwebview_android, com.pichillilorenzo.flutter_inappwebview_android.InAppWebViewFlutterPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin flutter_local_notifications, com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin flutter_plugin_android_lifecycle, io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.tundralabs.fluttertts.FlutterTtsPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin flutter_tts, com.tundralabs.fluttertts.FlutterTtsPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.baseflow.geolocator.GeolocatorPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin geolocator_android, com.baseflow.geolocator.GeolocatorPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.googlesignin.GoogleSignInPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin google_sign_in_android, io.flutter.plugins.googlesignin.GoogleSignInPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.imagepicker.ImagePickerPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin image_picker_android, io.flutter.plugins.imagepicker.ImagePickerPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.agora.iris_method_channel.IrisMethodChannelPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin iris_method_channel, com.agora.iris_method_channel.IrisMethodChannelPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.ryanheise.just_audio.JustAudioPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin just_audio, com.ryanheise.just_audio.JustAudioPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.pathprovider.PathProviderPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin path_provider_android, io.flutter.plugins.pathprovider.PathProviderPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.baseflow.permissionhandler.PermissionHandlerPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin permission_handler_android, com.baseflow.permissionhandler.PermissionHandlerPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new dev.fluttercommunity.plus.share.SharePlusPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin share_plus, dev.fluttercommunity.plus.share.SharePlusPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin shared_preferences_android, io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.csdcorp.speech_to_text.SpeechToTextPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin speech_to_text, com.csdcorp.speech_to_text.SpeechToTextPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.tekartik.sqflite.SqflitePlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin sqflite, com.tekartik.sqflite.SqflitePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.urllauncher.UrlLauncherPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin url_launcher_android, io.flutter.plugins.urllauncher.UrlLauncherPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.videoplayer.VideoPlayerPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin video_player_android, io.flutter.plugins.videoplayer.VideoPlayerPlugin", e);
    }
  }
}

```

---
