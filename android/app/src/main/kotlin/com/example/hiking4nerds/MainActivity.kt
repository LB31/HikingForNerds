package de.berlin.htw.hiking4nerds

import android.content.Intent
import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)


    val data: android.net.Uri? = intent?.data

    if (intent?.type?.equals("application/") == true){
      println("lulul")
    }
  }
}
