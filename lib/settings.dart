import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_icon_button.dart';

class SettingsVariables {
  static SharedPreferences prefs;
  static Future<void> setSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Directory downloadDirectory;
  static Future<Directory> getDownloadDirectory() async {
    Directory dirDefault;
    if (!Platform.isIOS) dirDefault = await getExternalStorageDirectory();
    Directory dirPrefs;
    if (prefs != null) {
      if (prefs.getString("downloadDirectoryPath") != null) dirPrefs = Directory(prefs.getString("downloadDirectoryPath"));
    }
    if (dirPrefs != null) return dirPrefs;
    return dirDefault;
  }

  static Future<void> setDownloadDirectory(String path) async {
    downloadDirectory = Directory(path);
    await prefs.setString("downloadDirectoryPath", path);
  }

  static String view = "list";
  static String getView() {
    String viewPrefs;
    if (prefs != null) viewPrefs = prefs.getString("view");
    if (viewPrefs != null) return viewPrefs;
    return view;
  }

  static Future<void> setView(String value) async {
    view = value;
    await prefs.setString("view", value);
  }

  static String sort = "name";
  static String getSort() {
    String sortPrefs;
    if (prefs != null) sortPrefs = prefs.getString("sort");
    if (sortPrefs != null) return sortPrefs;
    return sort;
  }

  static Future<void> setSort(String value) async {
    sort = value;
    await prefs.setString("sort", value);
  }

  static bool sortIsDescending = false;
  static bool getSortIsDescending() {
    bool sortIsDescendingPrefs;
    if (prefs != null) sortIsDescendingPrefs = prefs.getBool("sortIsDescending");
    if (sortIsDescendingPrefs != null) return sortIsDescendingPrefs;
    return sortIsDescending;
  }

  static Future<void> setSortIsDescending(bool value) async {
    sortIsDescending = value;
    await prefs.setBool("sortIsDescending", value);
  }

  static bool showHiddenFiles = true;
  static bool getShowHiddenFiles() {
    bool showHiddenFilesPrefs;
    if (prefs != null) showHiddenFilesPrefs = prefs.getBool("showHiddenFiles");
    if (showHiddenFilesPrefs != null) return showHiddenFilesPrefs;
    return showHiddenFiles;
  }

  static Future<void> setShowHiddenFiles(bool value) async {
    showHiddenFiles = value;
    await prefs.setBool("showHiddenFiles", value);
  }

  static bool showAddressInAppBar = true;
  static bool getShowAddressInAppBar() {
    bool showAddressInAppBarPrefs;
    if (prefs != null) showAddressInAppBarPrefs = prefs.getBool("showAddressInAppBar");
    if (showAddressInAppBarPrefs != null) return showAddressInAppBarPrefs;
    return showAddressInAppBar;
  }

  static Future<void> setShowAddressInAppBar(bool value) async {
    showAddressInAppBar = value;
    await prefs.setBool("showAddressInAppBar", value);
  }
}

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[],
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget _buildHeadline(String title, {bool hasSwitch = false, Function onChanged}) {
    return Padding(
      padding: EdgeInsets.only(top: hasSwitch ? 8.0 : 19.0, bottom: hasSwitch ? .0 : 11.0, left: 18.0, right: hasSwitch ? 22.0 : 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0, color: Colors.grey[700]),
          ),
          hasSwitch
              ? Switch(
                  activeThumbImage: AssetImage("assets/arrow_drop_down.png"),
                  activeColor: Colors.grey[50],
                  activeTrackColor: Colors.grey[300],
                  inactiveThumbImage: AssetImage("assets/arrow_drop_up.png"),
                  inactiveTrackColor: Colors.grey[300],
                  inactiveThumbColor: Colors.grey[50],
                  value: SettingsVariables.sortIsDescending,
                  onChanged: onChanged,
                )
              : Container(),
        ],
      ),
    );
  }

  var _downloadPathTextController = TextEditingController(text: SettingsVariables.downloadDirectory.path);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 55.0,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                "Settings",
                style: TextStyle(fontFamily: "GoogleSans", fontSize: 17.0, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Scrollbar(
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              SizedBox(height: 20.0),
              !Platform.isIOS
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildHeadline("Save files to:"),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 19.0, vertical: 4.0),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return Row(
                              children: <Widget>[
                                Container(
                                  width: constraints.maxWidth - 60.0,
                                  child: TextField(
                                    controller: _downloadPathTextController,
                                    decoration: InputDecoration(
                                      labelText: "Path",
                                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0)),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 14.0),
                                  child: CustomIconButton(
                                    icon: Icon(Icons.settings_backup_restore),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                        Divider(),
                      ],
                    )
                  : Container(),
              _buildHeadline("View"),
              RadioListTile(
                title: Text("List"),
                groupValue: SettingsVariables.view,
                value: "list",
                onChanged: (String value) async {
                  await SettingsVariables.setView("list");
                  setState(() {});
                },
              ),
              RadioListTile(
                title: Text("Detailed"),
                groupValue: SettingsVariables.view,
                value: "detailed",
                onChanged: (String value) async {
                  await SettingsVariables.setView("detailed");
                  setState(() {});
                },
              ),
              RadioListTile(
                title: Text("Grid"),
                groupValue: SettingsVariables.view,
                value: "grid",
                onChanged: (String value) async {
                  SettingsVariables.setView("grid");
                  setState(() {});
                },
              ),
              Divider(),
              _buildHeadline("Sort", hasSwitch: true, onChanged: (bool value) async {
                await SettingsVariables.setSortIsDescending(value);
                setState(() {});
              }),
              RadioListTile(
                title: Text("Name"),
                groupValue: SettingsVariables.sort,
                value: "name",
                onChanged: (String value) async {
                  await SettingsVariables.setSort("name");
                  setState(() {});
                },
              ),
              RadioListTile(
                title: Text("Modification Date"),
                groupValue: SettingsVariables.sort,
                value: "modificationDate",
                onChanged: (String value) async {
                  await SettingsVariables.setSort("modificationDate");
                  setState(() {});
                },
              ),
              RadioListTile(
                title: Text("Last Access"),
                groupValue: SettingsVariables.sort,
                value: "lastAccess",
                onChanged: (String value) async {
                  await SettingsVariables.setSort("lastAccess");
                  setState(() {});
                },
              ),
              Divider(),
              _buildHeadline("Other"),
              CheckboxListTile(
                title: Padding(
                  padding: EdgeInsets.only(left: 3.0),
                  child: Text("Show hidden files"),
                ),
                value: SettingsVariables.showHiddenFiles,
                onChanged: (bool value) async {
                  await SettingsVariables.setShowHiddenFiles(value);
                  setState(() {});
                },
              ),
              CheckboxListTile(
                title: Padding(
                  padding: EdgeInsets.only(left: 3.0),
                  child: Text("Show connection address in app bar"),
                ),
                value: SettingsVariables.showAddressInAppBar,
                onChanged: (bool value) async {
                  await SettingsVariables.setShowAddressInAppBar(value);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}