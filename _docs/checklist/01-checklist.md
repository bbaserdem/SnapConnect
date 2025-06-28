# Phase 01 Checklist

This document contains the checklists for tasks completed during Phase 1.

---

## 1.2 Main App Navigation & Structure

### Overview
This checklist covers testing the main app navigation structure with four primary tabs and their respective placeholder screens.

### 🎯 Testing Environment Setup

#### Prerequisites
- [x] App successfully builds and runs on mobile device/emulator
- [x] User is logged in and has completed profile setup
- [x] App launches to the Camera tab by default

---

### 📱 Navigation Structure Testing

#### Bottom Navigation Bar
- [x] **Navigation bar is visible** at the bottom of the screen
- [x] **Four tabs are present**: Camera, Friends, Messages, Stories
- [x] **Proper icons displayed**:
  - [x] Camera: camera_alt icon
  - [x] Friends: people icon  
  - [x] Messages: chat_bubble icon
  - [x] Stories: auto_stories icon
- [x] **Icons change state** when selected (filled vs outlined)
- [x] **Touch targets are adequate** (easy to tap each tab)
- [x] **Visual feedback** when switching tabs (highlighting/selection state)

#### Tab Navigation Flow
- [x] **Camera tab** is selected by default on app launch
- [x] **Tapping each tab** successfully navigates to respective screen
- [x] **State preservation**: Switching between tabs preserves scroll position and content
- [x] **Smooth transitions** between tabs (no jarring changes)
- [x] **Back button behavior**: System back button doesn't interfere with tab navigation

---

## 1.3 Camera and Snap Creation

**Version**: 0.1.2+2  
**Last Updated**: January 2025  
**Phase**: Core Clone Development  
**Component**: Camera & Media Capture

---

### **1. 📱 Initial App Launch & Permissions**

- [x] **First launch**: App should request camera and microphone permissions
- [x] **Grant permissions**: Should see live camera preview immediately
- [x] **Deny permissions**: Should see "Grant Permission" button with retry option
- [x] **Settings navigation**: Check that permissions can be granted from device settings

### **2. 🎥 Basic Camera Functionality**

- [x] **Camera preview**: Live camera feed should be visible and smooth
- [x] **Preview quality**: Camera preview should be clear and properly oriented
- [x] **App lifecycle**: Camera should pause when app goes to background
- [x] **Resume functionality**: Camera should resume when returning to foreground

---

## Out of Scope: 1.7 Group Messaging

This file tracks progress on implementing Group Messaging (see `tasks/prd-group-messaging.md`).

### Task List

#### 0. Preparatory
- [x] 0.1 Create this task-log file and copy checklist here.

#### 1. Data Layer
- [x] 1.1 Extend Firestore security rules & indexes for group conversations. (participant limit tightened to 10 in `firestore.rules`; existing index already supports `participantIds+updatedAt`)
- [x] 1.2 Ensure `ConversationModel` already supports `isGroup`, `groupName`; add `deletedFor` array.
- [x] 1.3 Implemented `createGroupConversation()` in `MessagingRepository` (enforces 2–10 unique participants, adds creator if missing, populates usernames, writes doc with isGroup=true and empty deletedFor).
- [x] 1.4 Implemented `leaveConversation()` in `MessagingRepository` (updates deletedFor array and filters out hidden conversations in stream).

---

## Abandoned task checklist: Cross-Platform Firebase Migration

> Goal: make SnapConnect run on Linux desktop **and** mobile without duplicating code.
> Strategy: keep official FlutterFire plugins for Android/iOS, use pure-Dart `firebase_dart` on Web & Linux via conditional imports.

### 1 – Wrapper Pattern
1. Add tiny wrapper files per Firebase area
   - `lib/firebase_wrappers/firestore_stub.dart`
   - `lib/firebase_wrappers/firestore_web_linux.dart`
   - `lib/firebase_wrappers/auth_stub.dart`
   - `lib/firebase_wrappers/auth_web_linux.dart`
   - `lib/firebase_wrappers/storage_stub.dart`
   - `lib/firebase_wrappers/storage_web_linux.dart`
2. Replace every direct `cloud_firestore`, `firebase_auth`, `firebase_storage` import with the conditional form:

```dart
import 'package:snapconnect/firebase_wrappers/firestore_stub.dart'
    if (dart.library.html) 'package:snapconnect/firebase_wrappers/firestore_web_linux.dart'
    if (dart.library.io)  'package:snapconnect/firebase_wrappers/firestore_stub.dart' as ff;
```
3. Prefix all Firestore/Auth/Storage API calls with the alias `ff.` (or corresponding alias).
4. Keep mobile initialisation unchanged; Linux/Web already uses `DefaultFirebaseOptions.web`. 