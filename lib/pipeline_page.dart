import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'api_list.dart';
import 'database_helper.dart';
import 'database_model.dart';
import 'package:http/http.dart' as http;

import 'utility.dart';

class PipelinePage extends StatefulWidget {
  PipelinePage({Key key}) : super(key: key);

  @override
  PipelinePageState createState() => PipelinePageState();
}

class PipelinePageState extends State<PipelinePage> {
  final urlField = TextEditingController();
  final tokenField = TextEditingController();
  final projectField = TextEditingController();
  final refField = TextEditingController();
  final pipelineField = TextEditingController();
  bool hidePassword = true;

  @override
  void initState() {
    super.initState();
    read();
  }

  @override
  void dispose() {
    urlField.dispose();
    tokenField.dispose();
    projectField.dispose();
    refField.dispose();
    pipelineField.dispose();
    super.dispose();
  }

  void trimText() async {
    urlField.text = urlField.text.trim();
    tokenField.text = tokenField.text.trim();
    projectField.text = projectField.text.trim();
    refField.text = refField.text.trim();
  }

  void togglePassword() async {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  void hideKeyboard() async {
    setState(() {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    });
  }

  void read() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    List<Parameter> x = await helper.selectAll();
    for (int i = 0; i < x.length; i++) {
      // print(x[i].id.toString() +
      //     ' ' +
      //     x[i].url.toString() +
      //     ' ' +
      //     x[i].token.toString() +
      //     ' ' +
      //     x[i].project.toString() +
      //     ' ' +
      //     x[i].ref.toString());
      setState(() {
        urlField.text = x[i].url.toString();
        tokenField.text = x[i].token.toString();
        projectField.text = x[i].project.toString();
        refField.text = x[i].ref.toString();
      });
    }
  }

  void save() async {
    // if (urlField.text.isNotEmpty) {
    //   if (tokenField.text.isNotEmpty) {
    //     if (projectField.text.isNotEmpty) {
    //       if (refField.text.isNotEmpty) {
    Parameter parameter = Parameter();
    parameter.url = urlField.text;
    parameter.token = tokenField.text;
    parameter.project = projectField.text;
    parameter.ref = refField.text;
    DatabaseHelper helper = DatabaseHelper.instance;
    List<Parameter> x = await helper.selectAll();

    if (x.length == 0) {
      await helper.insert(parameter);
    } else {
      parameter.id = 1;
      parameter.url = urlField.text;
      parameter.token = tokenField.text;
      parameter.project = projectField.text;
      parameter.ref = refField.text;
      await helper.update(parameter);
    }
    //       }
    //     }
    //   }
    // }
  }

  void run() async {
    try {
      http.Response response = await http.get(
          getLatestPipeline(urlField.text, projectField.text, refField.text),
          headers: {'PRIVATE-TOKEN': tokenField.text});
      Object decoded = jsonDecode(response.body)['web_url'];

      setState(() {
        pipelineField.text = decoded;
      });
    } catch (e) {
      setState(() {
        pipelineField.text = '';
      });
      snakeBar(context, 'Failed to load data!');
    }
  }

  void copy() async {
    if (pipelineField.text.isNotEmpty) {
      ClipboardManager.copyToClipBoard(pipelineField.text).then((result) {
        snakeBar(context, 'Copied to Clipboard!');
      });
    }
  }

  void open() async {
    if (pipelineField.text.isNotEmpty) {
      if (await canLaunch(pipelineField.text)) {
        await launch(pipelineField.text);
      } else {
        snakeBar(context, 'Could not launch ' + pipelineField.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onPanDown: (_) {
        hideKeyboard();
      },
      onTap: () {
        hideKeyboard();
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            TextField(
              maxLength: 100,
              controller: urlField,
              decoration: InputDecoration(
                  labelText: 'Gitlab URL',
                  helperText: 'ex: gitlab.example.com'),
            ),
            TextField(
                obscureText: hidePassword,
                maxLength: 100,
                controller: tokenField,
                decoration: InputDecoration(
                  labelText: 'PRIVATE-TOKEN',
                  helperText: 'ex: xxxxxyyyyyzzzzz',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      togglePassword();
                    },
                    child: Icon(
                      hidePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                )),
            TextField(
              maxLength: 10,
              controller: projectField,
              decoration: InputDecoration(
                  labelText: 'Project ID', helperText: 'ex: 123'),
            ),
            TextField(
              maxLength: 50,
              controller: refField,
              decoration: InputDecoration(
                  labelText: 'Branch (ref)', helperText: 'ex: master'),
            ),
            ButtonBar(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RaisedButton.icon(
                  icon: Icon(Icons.save),
                  label: Text('Save'),
                  onPressed: () async {
                    trimText();
                    hideKeyboard();
                    save();
                    snakeBar(context, 'Saved!');
                  },
                ),
                RaisedButton.icon(
                  icon: Icon(Icons.play_arrow),
                  label: Text('Run'),
                  onPressed: () async {
                    trimText();
                    hideKeyboard();
                    save();
                    run();
                  },
                ),
              ],
            ),
            TextField(
              maxLines: 2,
              controller: pipelineField,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Pipeline',
                suffixIcon: GestureDetector(
                  onTap: () {
                    copy();
                  },
                  child: Icon(
                    Icons.copy,
                  ),
                ),
              ),
            ),
            ButtonBar(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // RaisedButton.icon(
                //   icon: Icon(Icons.copy),
                //   label: Text('Copy to Clipboard'),
                //   onPressed: () {
                //     copy();
                //   },
                // ),
                RaisedButton.icon(
                  icon: Icon(Icons.open_in_browser),
                  label: Text('Open in Browser'),
                  onPressed: () {
                    open();
                  },
                ),
              ],
            ),
            // CupertinoButton.filled(
            //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
            //   onPressed: () {
            //     snakeBar(context, 'Under Construction!');
            //   },
            //   child: Text('Jobs List'),
            // )
          ]), // This trailing comma makes auto-formatting nicer for build methods.
        ),
      ),
    ));
  }
}
