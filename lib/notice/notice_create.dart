import 'package:flutter/material.dart';
import 'package:travelsync_client_new/widgets/header.dart';

class NoticeCreatePage extends StatefulWidget {
  const NoticeCreatePage({super.key});

  @override
  State<NoticeCreatePage> createState() => _NoticeCreatePageState();
}

class _NoticeCreatePageState extends State<NoticeCreatePage> {
  final TextEditingController groupNameController = TextEditingController();
  void searchLocation() {}
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Header(textHeader: "Create NOTICE"),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(
                      flex: 3,
                      child: Text(
                        "위치",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: TextField(
                        controller: groupNameController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                    Flexible(
                        child: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: searchLocation,
                    ))
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(
                      flex: 3,
                      child: Text(
                        "시간",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Flexible(
                      flex: 5,
                      child: Text(""),
                    ),
                    Flexible(
                        child: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: searchLocation,
                    ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
