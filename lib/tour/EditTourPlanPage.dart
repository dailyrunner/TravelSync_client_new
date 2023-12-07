// import 'package:flutter/material.dart';
// import 'package:travelsync_client_new/models/plan.dart';

// class EditTourPlanPage extends StatefulWidget {
//   final int tourId;
//   final int planId;

//   const EditTourPlanPage({required this.tourId, required this.planId, Key? key})
//       : super(key: key);

//   @override
//   _EditTourPlanPageState createState() => _EditTourPlanPageState();
// }

// class _EditTourPlanPageState extends State<EditTourPlanPage> {
//   TextEditingController titleController = TextEditingController();
//   TextEditingController contentController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('계획 편집'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: titleController,
//               decoration: const InputDecoration(labelText: '계획 제목'),
//             ),
//             TextField(
//               controller: contentController,
//               decoration: const InputDecoration(labelText: '계획 내용'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // 편집된 내용을 저장하고 이전 화면으로 돌아갑니다.
//                 saveEditedPlan();
//               },
//               child: const Text('저장'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void saveEditedPlan() {
//     // titleController.text와 contentController.text를 사용하여 계획을 업데이트합니다.
//     String editedTitle = titleController.text;
//     String editedContent = contentController.text;

//     // 여기서 저장 로직을 추가하십시오.
//     // 예를 들어, API를 호출하여 서버에 업데이트 요청을 보낼 수 있습니다.
//     // 이 예시에서는 편의상 로컬 변수로 업데이트를 표시하고 있습니다.
//     Plan updatedPlan = Plan(
//       planId: widget.planId, // 편집 중인 계획의 ID
//       tourId: widget.tourId, // 해당 투어의 ID
//       planTitle: editedTitle,
//       planContent: editedContent,
//       day: 1, // 예시로 day를 1로 고정
//       time: '12:00', // 예시로 time을 12:00으로 고정
//     );

//     // 업데이트가 완료되면 Navigator를 사용하여 이전 화면으로 이동합니다.
//     // 업데이트가 성공적으로 이루어졌다고 가정하고 pop을 호출하고 있습니다.
//     // 실제로는 업데이트 결과에 따라 적절한 처리를 해야 합니다.
//     Navigator.pop(context);
//   }
// }
