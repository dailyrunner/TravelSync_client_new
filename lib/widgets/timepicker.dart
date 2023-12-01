import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TimePicker {
  static Future<String?> showTimePicker(BuildContext context) async {
    DateTime? pickedTime;
    String? selectedTime;

    await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedTime = DateTime.now();
        return SizedBox(
          height: 200,
          child: Column(
            children: [
              CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: selectedTime,
                onDateTimeChanged: (DateTime newDateTime) {
                  selectedTime = newDateTime;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  pickedTime = selectedTime;
                  Navigator.pop(context); // 닫기
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      },
    );

    if (pickedTime != null) {
      selectedTime = '${pickedTime?.hour}:${pickedTime?.minute}';
    }

    return selectedTime;
  }
}


// ElevatedButton(
//   onPressed: () async {
//     String? selectedTime = await TimePicker.showTimePicker(context);
//     if (selectedTime != null) {
//       print('Selected Time: $selectedTime');
//       // 여기에서 선택한 시간을 화면에 표시하거나 다른 작업을 수행할 수 있습니다.
//     }
//   },
//   child: Text('확인'),
// )