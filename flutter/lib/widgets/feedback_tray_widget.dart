// FILE: feedback_tray_widget.dart

import 'package:flutter/material.dart';
import 'progress_widget.dart';
import 'package:automath/managers/step_manager.dart';
import 'package:automath/managers/feedback_manager.dart';

class FeedbackTrayWidget extends StatefulWidget {
  const FeedbackTrayWidget({super.key});

  @override
  State<FeedbackTrayWidget> createState() => FeedbackTrayWidgetState();
}

class FeedbackTrayWidgetState extends State<FeedbackTrayWidget> {
  String? evalStatus;

  final StepManager stepManager = StepManager();

  void updateEvalStatus(String newStatus) {
    setState(() {
      evalStatus = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (evalStatus == null) return const SizedBox();

    final stepFeedback = stepManager.stepFeedback;
    final finalFeedbackMessage = FeedbackManager().getFeedbackMessage(
      evalStatus: evalStatus!,
      stepFeedback: stepFeedback,
    );

    return Container(
      color: evalStatus == 'step_incorrect'
          ? const Color.fromARGB(255, 246, 224, 211)
          : const Color(0xFFA6CAEC),
      height: 225,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: ProgressWidget(),
          ),
          const SizedBox(height: 16.0),
          Text(
            finalFeedbackMessage,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: evalStatus == 'step_incorrect'
                  ? const Color(0xFFE97132)
                  : const Color(0xFF002060),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


// import 'package:automath/managers/step_manager.dart';
// import 'package:flutter/material.dart';
// import 'progress_widget.dart';
// import 'package:provider/provider.dart';
// import 'package:automath/managers/feedback_manager.dart';

// class FeedbackTrayWidget extends StatelessWidget {
//   const FeedbackTrayWidget({super.key});

//   StepManager get stepManager => StepManager();

//   @override
//   Widget build(BuildContext context) {
//     final evalStatus = context.watch<StepManager>().evalStatus;
//     print("evalStatus: $evalStatus");
//     final stepFeedback = stepManager.stepFeedback;

//     final finalFeedbackMessage = FeedbackManager()
//         .getFeedbackMessage(evalStatus: evalStatus, stepFeedback: stepFeedback);

//     return Container(
//       color: evalStatus == 'step_incorrect'
//           ? const Color.fromARGB(255, 246, 224, 211)
//           : const Color(0xFFA6CAEC),
//       height: 225,
//       width: double.infinity,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(top: 16.0),
//             child: ProgressWidget(),
//           ),
//           const SizedBox(height: 16.0),
//           Text(
//             finalFeedbackMessage,
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: evalStatus == 'step_incorrect'
//                   ? Color(0xFFE97132)
//                   : Color(0xFF002060),
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }
