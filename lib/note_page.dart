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

  FilePickerResult? _filePickerResult;
  File? _file;
  String? _filePath;

//读取文档内容
  _loadFile() async {
    try {
      //debugPrint("$_filePath");
      if (_filePath == null) {
        await getSingleFile();
        _filePath = _filePickerResult!.files.single.path;
        debugPrint("_filePickerResult.files.single.path");
      }
      _file = File(_filePath!);
      if (await _file!.exists()) {
        controller.text = await _file!.readAsString();
        debugPrint("file.readAsString");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

//获取路径
  getSingleFile() async {
    _filePickerResult = await FilePicker.platform.pickFiles(
        lockParentWindow: true,
        type: FileType.custom,
        allowedExtensions: ['txt']);
    _filePath = _filePickerResult!.files.single.path;
    var prefs = await _prefs;
    prefs.setString("filePath", _filePath!);
    debugPrint("${_filePickerResult!.files.single.path}");
  }

  @override
  void initState() {
    super.initState();
    () async {
      //读取上次打开的文档
      var prefs = await _prefs;
      if (_filePath == null) {
        await _loadFile();
        _filePath = _filePickerResult!.files.single.path;
        prefs.setString("filePath", _filePath!);
      } else {
        _filePath = prefs.getString("filePath");
      }
      setState(() {});
    };
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
            child: _file == null
                ? const Text("loading……")
                : TextField(
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
                  ),
          ),
          MouseRegion(
            onEnter: (_) => setState(() => _visible = true),
            //onExit: (_) => setState(() => _visible = false),
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(_filePath == null ? "loading" : _filePath!),
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
                    debugPrint("保存");
                    () async {
                      debugPrint("保存2");
                      await getSingleFile();
                      _loadFile();
                    }();
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
