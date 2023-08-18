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

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  late Future _readFile;
  String _filePath = "loading...";

  late Future<File> _file;

//读取文档内容
  _loadFile() async {
    try {
      //await Future.delayed(const Duration(seconds: 3));

      File file = File(_filePath);
      if (await file.exists()) {
        var text = await file.readAsString();
        debugPrint("file.readAsString");
        return text;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

//获取路径
  getSingleFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        lockParentWindow: true,
        type: FileType.custom,
        allowedExtensions: ['txt']);
    return result!.files.single;
  }

  @override
  void initState() {
    super.initState();
    () async {
      var prefs = await _prefs;
      PlatformFile temp = getSingleFile();
      setState(() {
        _filePath = prefs.getString("filePath") ?? temp.path!;
      });
    };
    _readFile = _loadFile();
    _readFile.then((value) {
      setState(() {
        controller.text = value;
      });
    });
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
                future: _readFile,
                builder: (context, snapshot) {
                  //controller.text = _readFile.toString();
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
                    return const Center(
                      child: Text('loading...'),
                    );
                  }
                }),
          ),
          MouseRegion(
            onEnter: (_) => setState(() => _visible = true),
            //onExit: (_) => setState(() => _visible = false),
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(_filePath),
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
                  onPressed: () {},
                  tooltip: "新建",
                  child: const Icon(Icons.note_add),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    _loadFile();
                  },
                  tooltip: "打开",
                  child: const Icon(Icons.file_open),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {},
                  tooltip: "保存",
                  child: const Icon(Icons.save),
                ),
              ],
            ),
    );
  }
}
