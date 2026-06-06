package com.example.movswgr22026a

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.Arguments
import androidx.core.content.ContextCompat

class ResourceModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    override fun getName() = "ResourceModule"

    @ReactMethod
    fun getNativeResources(promise: Promise) {
        try {
            val context = reactApplicationContext
            val resources = Arguments.createMap()

            // Estos nombres deben existir en tus XML
            resources.putString("texto", context.getString(R.string.mi_texto))

            val textColor = ContextCompat.getColor(context, R.color.mi_color_fuente)
            val bgColor = ContextCompat.getColor(context, R.color.mi_color_fondo)

            resources.putString("colorFuente", String.format("#%06X", 0xFFFFFF and textColor))
            resources.putString("colorFondo", String.format("#%06X", 0xFFFFFF and bgColor))

            promise.resolve(resources)
        } catch (e: Exception) {
            promise.reject("ERROR", "No se pudo leer el recurso")
        }
    }
}