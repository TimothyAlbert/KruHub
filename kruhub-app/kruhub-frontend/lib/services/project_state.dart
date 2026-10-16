import 'package:flutter/material.dart';
import 'api_service.dart';

class ProjectState {
  static final ValueNotifier<String?> activeProjectIdNotifier = ValueNotifier<String?>(null);

  static void setActiveProject(String? projectId) {
    ApiService.activeProjectId = projectId;
    activeProjectIdNotifier.value = projectId;
  }
}