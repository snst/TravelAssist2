import 'package:flutter/material.dart';

class VSpace extends SizedBox {
  const VSpace({super.key, double val=1}) : super(height: val*6);
}

class HSpace extends SizedBox {
  const HSpace({super.key, double val=1}) : super(width: val*8);
}
