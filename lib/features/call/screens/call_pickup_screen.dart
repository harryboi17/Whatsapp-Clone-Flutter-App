import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/call/controller/call_controller.dart';

import '../../../model/call.dart';
class CallPickupScreen extends ConsumerWidget {
  final Widget scaffold;
  const CallPickupScreen({super.key,
    required this.scaffold,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<DocumentSnapshot>(
      stream: ref.watch(callControllerProvider).callStream,
      builder: (context, snapshot){
        if(snapshot.hasData && snapshot.data!.data() != null){
          Call call = Call.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          if(!call.hasDialled){
            return Scaffold(
              body: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Incoming Call',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 50),
                    CircleAvatar(
                      backgroundImage: NetworkImage(call.callerPic),
                      radius: 60,
                    ),
                    const SizedBox(height: 50),
                    Text(
                      call.callerName,
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 100),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.call_end,
                            color: Colors.redAccent,
                            size: 50,
                          ),
                        ),
                        const SizedBox(width: 25),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.call,
                            color: Colors.green,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        }
        return scaffold;
      },
    );
  }

}
