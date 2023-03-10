import 'package:flutter/material.dart';

import 'package:toast/toast.dart';

showToast(BuildContext context, String msg, {int duration = 1, int gravity}) {
  if (context != null) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
