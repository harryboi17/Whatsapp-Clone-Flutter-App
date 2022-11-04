import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/features/chat/controller/chat_controller.dart';
import '../../../common/utils/colors.dart';
import '../../../common/widgets/loader.dart';
import '../../../model/chat_contact.dart';
import '../screens/mobile_chat_screen.dart';

class ContactsList extends ConsumerStatefulWidget{
  const ContactsList({Key? key}) : super(key: key);

  @override
  ConsumerState<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends ConsumerState<ContactsList> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          children: [
            StreamBuilder<List<ChatContact>>(
              stream: ref.watch(chatControllerProvider).chatGroups(),
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Loader();
                }
                return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index){
                      var groupData = snapshot.data![index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, MobileChatScreen.routeName, arguments: {
                                'name' : groupData.name,
                                'uid' : groupData.contactId,
                                'isGroupChat' : true,
                                'numberOfMembers' : groupData.membersUid.length,
                                'profilePic' : groupData.profilePic,
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text(
                                  groupData.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    groupData.isTyping
                                        ? groupData.userTyping.length > 15
                                          ? '${groupData.userTyping.substring(0,15)} is typing...'
                                          : '${groupData.userTyping} is typing...'
                                        : groupData.lastMessage,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: groupData.isTyping ? unSeenMessageColor : null
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      groupData.profilePic
                                  ),
                                  radius: 30,
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const SizedBox(),
                                    Text(
                                      groupData.timeSent.isAfter(DateTime.now().subtract(const Duration(hours: 24)))
                                          ? DateFormat.jm().format(groupData.timeSent)
                                          : DateFormat('d/MM/yy').format(groupData.timeSent),
                                      style: TextStyle(
                                        color: groupData.unSeenMessageCount == 0 ?  Colors.grey : unSeenMessageColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    groupData.unSeenMessageCount != 0 ? Container(
                                      width: 25,
                                      height: 25,
                                      decoration: const BoxDecoration(
                                        color: unSeenMessageColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(groupData.unSeenMessageCount.toString(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                                      ),
                                    ) : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Divider(color: dividerColor, indent: 85),
                        ],
                      );
                    }
                );
              },
            ),
            StreamBuilder<List<ChatContact>>(
              stream: ref.watch(chatControllerProvider).chatContacts(),
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Loader();
                }
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index){
                      var chatContactData = snapshot.data![index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, MobileChatScreen.routeName, arguments: {
                                'name' : chatContactData.name,
                                'uid' : chatContactData.contactId,
                                'isGroupChat' : false,
                                'numberOfMembers' : 0,
                                'profilePic' : chatContactData.profilePic,
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text(
                                  chatContactData.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    chatContactData.isTyping
                                        ? 'Typing...'
                                        : chatContactData.lastMessage,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: chatContactData.isTyping ? unSeenMessageColor : null
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    chatContactData.profilePic
                                  ),
                                  radius: 30,
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const SizedBox(),
                                    Text(
                                      chatContactData.timeSent.isAfter(DateTime.now().subtract(const Duration(hours: 24)))
                                        ? DateFormat.jm().format(chatContactData.timeSent)
                                        : DateFormat('d/MM/yy').format(chatContactData.timeSent),
                                      style: TextStyle(
                                        color: chatContactData.unSeenMessageCount == 0 ?  Colors.grey : unSeenMessageColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    chatContactData.unSeenMessageCount != 0 ? Container(
                                      width: 25,
                                      height: 25,
                                      decoration: const BoxDecoration(
                                        color: unSeenMessageColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(chatContactData.unSeenMessageCount.toString(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                                      ),
                                    ) : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Divider(color: dividerColor, indent: 85),
                        ],
                      );
                    }
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}