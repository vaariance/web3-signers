#!/bin/bash

# Configuration
PACKAGE_NAME="space.variance.web3_signers"
KOTLIN_PATH="android/src/main/kotlin/space/variance/web3_signers"
SWIFT_PATH="darwin/web3_signers/Sources/web3_signers"
CPP_PATH="windows/runner"
DART_GEN_PATH="lib/src/api"

echo "📦 Generating Pigeon bindings for platform authenticators..."

# 1. GENERATE ANDROID (Kotlin + Dart)
echo "---------- Android..."
dart run pigeon \
  --input pigeons/schema_android.dart \
  --dart_out "$DART_GEN_PATH/android_auth.g.dart" \
  --kotlin_out "$KOTLIN_PATH/PlatformAuthenticator.g.kt" \
  --kotlin_package "$PACKAGE_NAME"

# 2. GENERATE DARWIN (Swift + Dart)
echo "---------- Darwin (iOS/macOS)..."
dart run pigeon \
  --input pigeons/schema_darwin.dart \
  --dart_out "$DART_GEN_PATH/darwin_auth.g.dart" \
  --swift_out "$SWIFT_PATH/PlatformAuthenticator.g.swift"

# 3. GENERATE WINDOWS (C++ + Dart)
echo "---------- Windows..."
dart run pigeon \
  --input pigeons/schema_windows.dart \
  --dart_out "$DART_GEN_PATH/windows_auth.g.dart" \
  --cpp_header_out "$CPP_PATH/platform_authenticator.g.h" \
  --cpp_source_out "$CPP_PATH/platform_authenticator.g.cpp" \
  --cpp_namespace "web3_signers"

echo "✅ Generation complete."
