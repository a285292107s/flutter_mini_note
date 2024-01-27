import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:core';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController controller = TextEditingController();

  bool _visible = false;
  FocusNode focusNode = FocusNode();
  //读取本地储存的配置数据 SharedPreferences
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  late Future<bool> isOpenDoc;
  String? path;

  //读取文档内容
  _readAsString(String path) async {
    File file = File(path);
    if (await file.exists()) {
      controller.text = await file.readAsString();
      debugPrint("file.readAsString=> $path");
    }
    setState(() {});
  }

// 保存文档内容
  _saveAsString(String path) async {
    if (controller.text.isEmpty) {
      return;
    }
    File file = File(path);
    await file.writeAsString(controller.text);
    debugPrint("file.writeAsString=> $path");
    setState(() {});
  }

  //获取选择器返回结果
  Future<FilePickerResult?> pickTextFile() async {
    FilePickerResult? filePickerResult = await FilePicker.platform.pickFiles(
        lockParentWindow: true,
        type: FileType.custom,
        allowedExtensions: ['txt']);

    if (filePickerResult != null) {
      //及时写入本地存储
      saveFilePath(filePickerResult.files.single.path!);
    }

    return filePickerResult;
  }

  //保存txt文档路径
  saveFilePath(String path) async {
    var prefs = await _prefs;
    prefs.setString("filePath", path);
    setState(() {
      debugPrint("重绘，更新底部文字");
      this.path = path;
    });
  }

  @override
  void initState() {
    super.initState();

    //读取上次打开的文档
    isOpenDoc = () async {
      SharedPreferences prefs = await _prefs;
      path = prefs.getString('filePath');
      //path = null;
      if (path == null) {
        setState(() {
          _visible = true;
        });
        return false;
      } else {
        _readAsString(path!);
        return true;
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kWindowCaptionHeight),
        child: WindowCaption(
          brightness: Theme.of(context).brightness,
          title: Text('大白兔笔记 (${controller.text.length}字)'),
        ),
      ),
      body: Column(
        children: <Widget>[
          //const Text('标题'),
          Expanded(
            child: FutureBuilder(
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return TextField(
                      maxLines: null,
                      expands: true,
                      focusNode: focusNode,
                      controller: controller,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(20, 12, 20, 12),
                      ),
                      onChanged: (text) {
                        setState(() {});
                      },
                      onTap: () {
                        debugPrint("隐藏按钮");
                        setState(() => _visible = false);
                      },
                    );
                  } else {
                    return const Text("暂无打开文档……");
                  }
                },
                future: isOpenDoc),
          ),
          MouseRegion(
            onEnter: (_) => setState(() => _visible = true),
            //onExit: (_) => setState(() => _visible = false),
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: path == null
                    ? const Text(
                        "TXT文档路径：",
                        style: TextStyle(color: Colors.grey),
                      )
                    : Text(
                        path!,
                        style: const TextStyle(color: Colors.grey),
                      ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: !_visible
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    debugPrint("新建");
                    () async {
                      path = null;
                      controller.text = "";
                      setState(() {});
                    }();
                  },
                  tooltip: "新建",
                  child: const Icon(Icons.note_add),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    debugPrint("打开");
                    () async {
                      path = await pickTextFile()
                          .then((value) => value?.files.single.path);
                      _readAsString(path!);
                      setState(() {});
                    }();
                  },
                  tooltip: "打开",
                  child: const Icon(Icons.file_open),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    debugPrint("保存文档内容");
                    () async {
                      path == null
                          ? debugPrint("没有文档路径")
                          : _saveAsString(path as String);
                      setState(() {});
                    }();
                  },
                  tooltip: "保存",
                  child: const Icon(Icons.save),
                ),
              ],
            ),
    );
  }
}
