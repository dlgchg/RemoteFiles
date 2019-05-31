import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../shared/shared.dart';
import 'pages.dart';

class ConnectionPage extends StatefulWidget {
  static Connection connection;
  ConnectionPage(Connection connection) {
    ConnectionPage.connection = connection;
  }

  static var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _ConnectionPageState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> with TickerProviderStateMixin {
  var _refreshKey = GlobalKey<RefreshIndicatorState>();

  List<Widget> _getCurrentPathWidgets() {
    List<Widget> widgets = [
      InkWell(
        borderRadius: BorderRadius.circular(100.0),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
          child: Text("/", style: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.w500, fontSize: 16.0)),
        ),
        onTap: () => ConnectionMethods.goToDirectory(context, "/"),
      ),
      Container(
        width: .0,
        constraints: BoxConstraints.loose(Size.fromHeight(18.0)),
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            Positioned(
              left: -9.0,
              child: Icon(
                Icons.chevron_right,
                size: 18.0,
              ),
            ),
          ],
        ),
      )
    ];
    String temp = "";
    String path = "";
    if (connectionModel.currentConnection != null) path = connectionModel.currentConnection.path != null ? connectionModel.currentConnection.path + "/" : "";
    if (path.length > 1) {
      if (path[0] == "/" && path[1] == "/") path = path.substring(1, path.length);
    }
    for (int i = 1; i < path.length; i++) {
      if (path[i] == "/") {
        widgets.add(InkWell(
          borderRadius: BorderRadius.circular(100.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 11.0, vertical: 7.0),
            child: Text(temp, style: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.w500, fontSize: 16.0)),
          ),
          onTap: () {
            ConnectionMethods.goToDirectory(context, path.substring(0, i));
          },
        ));
        if (path.substring(i + 1, path.length).contains("/")) {
          widgets.add(Container(
            width: .0,
            constraints: BoxConstraints.loose(Size.fromHeight(18.0)),
            child: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Positioned(
                  left: -9.0,
                  child: Icon(
                    Icons.chevron_right,
                    size: 18.0,
                  ),
                ),
              ],
            ),
          ));
        }
        temp = "";
      } else {
        temp += path[i];
      }
    }
    return widgets;
  }

  List<Widget> _getItemList() {
    List<Widget> list = [];
    if (connectionModel.fileInfos.length > 0) {
      for (int i = 0; i < connectionModel.connectionsNum; i++) {
        if (SettingsVariables.showHiddenFiles || connectionModel.fileInfos[i]["filename"][0] != ".") {
          list.add(ConnectionWidgetTile(
            index: i,
            fileInfos: connectionModel.fileInfos,
            isLoading: connectionModel.isLoading,
            view: SettingsVariables.view,
            itemNum: connectionModel.connectionsNum,
            onTap: () {
              if (connectionModel.fileInfos[i]["isDirectory"] == "true") {
                setState(() {
                  connectionModel.directoryBefore = connectionModel.currentConnection.path;
                });
                ConnectionMethods.goToDirectory(context, connectionModel.currentConnection.path + "/" + FileInfos.values[i]["filename"]);
              } else {
                showModalBottomSheet(context: context, builder: (context) => FileBottomSheet(i));
              }
            },
            onSecondaryTap: () {
              showModalBottomSheet(context: context, builder: (context) => FileBottomSheet(i));
            },
            onLongPress: () {
              showModalBottomSheet(context: context, builder: (context) => FileBottomSheet(i));
            },
          ));
        }
      }
    }
    list.addAll([Container(), Container(), Container()]);
    return list;
  }

  AnimationController _rotationController;

  @override
  void initState() {
    _rotationController = AnimationController(duration: Duration(milliseconds: 100), vsync: this);
    ConnectionMethods.connect(context, ConnectionPage.connection);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ConnectionPage.scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.0),
        child: AppBar(
          elevation: 1.6,
          automaticallyImplyLeading: false,
          title: SingleChildScrollView(
            reverse: true,
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            child: Container(
              margin: EdgeInsets.only(right: 10.0),
              child: Row(
                children: _getCurrentPathWidgets(),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, .08), blurRadius: 4.0, offset: Offset(.0, 2.0))],
        ),
        child: BottomAppBar(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: (connectionModel.showProgress ? 50.0 : 0) + 55.0,
            child: Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: connectionModel.showProgress ? 50.0 : 0,
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 18.0, bottom: 12.0),
                              child: Text(
                                connectionModel.progressType == "download"
                                    ? "Downloading ${connectionModel.loadFilename}"
                                    : (connectionModel.progressType == "uploading"
                                        ? "Uploading ${connectionModel.loadFilename}"
                                        : "Caching ${connectionModel.loadFilename}"),
                                style: TextStyle(fontSize: 15.8, fontWeight: FontWeight.w500, color: Colors.grey[700], fontStyle: FontStyle.italic),
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 18.0, right: 18.0, bottom: 12.0),
                            child: Text("${connectionModel.progressValue}%",
                                style: TextStyle(fontSize: 15.8, fontWeight: FontWeight.w500, color: Colors.grey[700], fontStyle: FontStyle.italic)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3.0,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey[300],
                          value: connectionModel.progressValue.toDouble() * .01,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: 55.0,
                  margin: EdgeInsets.only(top: connectionModel.showProgress ? 50.0 : 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.chevron_left),
                          onPressed: () => Navigator.pop(context),
                        ),
                        GestureDetector(
                          onTap: () {
                            HomePage.showConnectionDialog(
                              context: context,
                              page: "connection",
                              primaryButtonIconData: Icons.remove_circle_outline,
                              primaryButtonLabel: "Disconnect",
                              primaryButtonOnPressed: () {
                                if (!Platform.isIOS) connectionModel.client.disconnectSFTP();
                                connectionModel.client.disconnect();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            );
                          },
                          onLongPress: () async {
                            await SettingsVariables.setShowAddressInAppBar(!SettingsVariables.showAddressInAppBar);
                            setState(() {});
                          },
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                icon: Padding(
                                  padding: EdgeInsets.only(top: 1.0),
                                  child: Icon(OMIcons.flashOn),
                                ),
                                onPressed: () {
                                  HomePage.showConnectionDialog(
                                    context: context,
                                    page: "connection",
                                    primaryButtonIconData: Icons.remove_circle_outline,
                                    primaryButtonLabel: "Disconnect",
                                    primaryButtonOnPressed: () {
                                      if (!Platform.isIOS) connectionModel.client.disconnectSFTP();
                                      connectionModel.client.disconnect();
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                              AnimatedSize(
                                vsync: this,
                                duration: Duration(milliseconds: 200),
                                child: Padding(
                                  padding: EdgeInsets.only(right: SettingsVariables.showAddressInAppBar ? 8.0 : .0),
                                  child: SizedBox(
                                    width: !SettingsVariables.showAddressInAppBar ? .0 : null,
                                    child: Text(
                                      ConnectionPage.connection.address,
                                      style: TextStyle(fontFamily: "GoogleSans", fontSize: 16.0, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height,
                          width: 1.0,
                          color: Theme.of(context).dividerColor,
                          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                        ),
                        CustomTooltip(
                          message: "Go to parent directory",
                          child: IconButton(
                            icon: RotatedBox(quarterTurns: 2, child: Icon(Icons.subdirectory_arrow_right)),
                            onPressed: () {
                              ConnectionMethods.goToDirectoryBefore(context);
                            },
                          ),
                        ),
                        CustomTooltip(
                          message: "Go to specific directory",
                          child: IconButton(
                            icon: Icon(Icons.youtube_searched_for),
                            onPressed: () {
                              customShowDialog(
                                context: context,
                                builder: (context) {
                                  return CustomAlertDialog(
                                    title: Text("Go to directory", style: TextStyle(fontFamily: "GoogleSans", fontSize: 18.0)),
                                    content: Container(
                                      width: 260.0,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          labelText: "Path",
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0),
                                          ),
                                        ),
                                        cursorColor: Theme.of(context).accentColor,
                                        autofocus: true,
                                        autocorrect: false,
                                        onSubmitted: (String value) {
                                          if (value[0] == "/") {
                                            ConnectionMethods.goToDirectory(context, value);
                                          } else {
                                            ConnectionMethods.goToDirectory(context, connectionModel.currentConnection.path + "/" + value);
                                          }
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        CustomTooltip(
                          message: SettingsVariables.showHiddenFiles ? "Dont't show hidden files" : "Show hidden files",
                          child: IconButton(
                            icon: Icon(SettingsVariables.showHiddenFiles ? OMIcons.visibilityOff : OMIcons.visibility),
                            onPressed: () async {
                              await SettingsVariables.setShowHiddenFiles(!SettingsVariables.showHiddenFiles);
                              setState(() {});
                            },
                          ),
                        ),
                        CustomTooltip(
                          message: "Settings",
                          child: IconButton(
                            icon: Icon(OMIcons.settings),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SpeedDial(
        heroTag: "fab",
        child: RotationTransition(
          turns: Tween(begin: .0, end: 0.125).animate(_rotationController),
          child: Icon(Icons.add),
        ),
        onOpen: () {
          _rotationController.forward(from: .0);
        },
        onClose: () {
          _rotationController.animateBack(.0);
        },
        children: [
          SpeedDialChild(
            label: "Upload File",
            labelStyle: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.w500),
            child: Icon(OMIcons.cloudUpload),
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).accentColor,
            elevation: 3.0,
            onTap: () async => LoadFile.upload(context),
          ),
          SpeedDialChild(
            label: "Create Folder",
            labelStyle: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.w500),
            child: Icon(OMIcons.createNewFolder),
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).accentColor,
            elevation: 3.0,
            onTap: () async {
              customShowDialog(
                context: context,
                builder: (context) {
                  return CustomAlertDialog(
                    title: Text(
                      "Folder Name",
                      style: TextStyle(fontFamily: "GoogleSans"),
                    ),
                    content: TextField(
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0),
                        ),
                      ),
                      cursorColor: Theme.of(context).accentColor,
                      autofocus: true,
                      autocorrect: false,
                      onSubmitted: (String value) async {
                        await connectionModel.client.sftpMkdir(connectionModel.currentConnection.path + "/" + value);
                        Navigator.pop(context);
                        ConnectionMethods.connect(context, connectionModel.currentConnection);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Scrollbar(
          child: Consumer<ConnectionModel>(
            builder: (context, connection, child) {
              return RefreshIndicator(
                key: _refreshKey,
                onRefresh: () async {
                  await ConnectionMethods.connect(context, connectionModel.currentConnection, setIsLoading: true);
                },
                child: connectionModel.isLoading
                    ? Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SettingsVariables.view == "list" || SettingsVariables.view == "detailed"
                        ? ListView(
                            children: <Widget>[
                              Column(children: _getItemList()),
                              SizedBox(height: 84.0),
                            ],
                          )
                        : GridView(
                            padding: EdgeInsets.all(3.0),
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 160.0,
                            ),
                            children: _getItemList(),
                          ),
              );
            },
          ),
        ),
      ),
    );
  }
}
