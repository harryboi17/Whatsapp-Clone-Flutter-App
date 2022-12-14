import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import '../repository/select_contact_repository.dart';

final getContactsProvider = FutureProvider((ref){
  final selectContactRepository = ref.watch(selectContactsRepositoryProvider);
  return selectContactRepository.getContacts();
});

final selectContactControllerProvider = Provider((ref){
  final selectContactRepository = ref.watch(selectContactsRepositoryProvider);
  return SelectContactController(ref : ref, selectContactRepository : selectContactRepository);
});

class SelectContactController{
  final ProviderRef ref;
  final SelectContactRepository selectContactRepository;
  SelectContactController({required this.ref, required this.selectContactRepository});

  void selectContact(Contact selectedContact, BuildContext context)async{
    var myData = await ref.read(authControllerProvider).getUserData();
    selectContactRepository.selectContact(selectedContact, context, myData!);
  }

  Future<List<Contact>> getContact(){
    return selectContactRepository.getContacts();
  }
}