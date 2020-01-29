package de.berlin.htw.hiking4nerds

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

import android.os.Bundle

import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri


class MainActivity: FlutterActivity() {
  private val CHANNEL = "app.channel.hikingfornerds.data"

  var sharedData: Uri? = null

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    sharedData = intent?.data

    MethodChannel(flutterView, CHANNEL).setMethodCallHandler{ call, result ->
      if (call.method!!.contentEquals("getSharedData")){
        result.success(sharedData?.toString() ?: "")
        sharedData = null
      }
    }
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    setIntent(intent)
    sharedData = intent?.data
  }
}
