import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../model/status_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../repository/status_repository.dart';

final statusControllerProvider = Provider((ref) {
  final statusRepository = ref.read(statusRepositoryProvider);
  return StatusController(
    statusRepository: statusRepository,
    ref: ref,
  );
});

class StatusController {
  final StatusRepository statusRepository;
  final ProviderRef ref;
  StatusController({
    required this.statusRepository,
    required this.ref,
  });

  void addStatus(File file, BuildContext context) {
    ref.watch(userDataAuthProvider).whenData((value) {
      statusRepository.uploadStatus(
        userName: value!.name,
        profilePic: value.profilePic,
        phoneNumber: value.phoneNumber,
        statusImage: file,
        context: context,
      );
    });
  }

  Stream<List<UserStatus>> getStatus(BuildContext context, bool isSeenStatusColumn){
    return statusRepository.getStatus(context, isSeenStatusColumn);
  }

  Stream<UserStatus> getMyStatus(BuildContext context){
    return statusRepository.getMyStatus(context);
  }

  void updateIsSeen(String uid, String statusId){
    statusRepository.updateIsSeen(uid, statusId);
  }
}