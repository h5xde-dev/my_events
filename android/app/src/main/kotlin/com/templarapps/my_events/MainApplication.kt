package com.templarapps.myevents

import android.app.Application

import com.yandex.mapkit.MapKitFactory

class MainApplication: Application() {
  override fun onCreate() {
    super.onCreate()
    MapKitFactory.setApiKey("bc2d3b41-bb2b-4c46-96fd-aceb431ea26c")
  }
}