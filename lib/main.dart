import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
//import 'package:path_provider/path_provider.dart';

import 'note_page.dart';

void main() async {
  // 因为异步了，所以要先确保flutter完成初始化
  WidgetsFlutterBinding.ensureInitialized();
  // 再确保windowManager完成初始化
  await windowManager.ensureInitialized();
  //窗口属性配置
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );

  //等待windows窗口准备完毕，显示窗口并聚焦
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'LXGWWenKai',
      ),
      home: const NotePage(),
      //home: const Placeholder(),
    );
  }
}
