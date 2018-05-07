import 'dart:async';

void main() {
  print("start...");
  new Timer(const Duration(seconds: 3), () {
    print("hello world");
  });
}