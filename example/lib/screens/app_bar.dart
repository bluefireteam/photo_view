import 'package:flutter/material.dart';


class ExampleAppBar extends StatelessWidget{
  final String title;
  final bool showGoBack;

  const ExampleAppBar({
    this.title,
    this.showGoBack = false
  }) : super();

  @override
  Widget build(BuildContext context) {
    return new SafeArea(
      child: new Container(
        padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: const Radius.circular(10.0),
              bottomRight: const Radius.circular(10.0)
            ),
            boxShadow: <BoxShadow>[
              const BoxShadow(
                color: Colors.black12,
                spreadRadius: 10.0,
                blurRadius: 20.0
              )
            ]
        ),
        child: new Row(
          children: <Widget>[
            new Container(
              child: showGoBack ? new IconButton(
                icon: new Icon(Icons.chevron_left),
                onPressed: () { Navigator.pop(context); },
                padding: EdgeInsets.zero,

              ) : new Container( height: 50.0,),
            ),
            new Expanded(
              child: new Text(
                title,
                style: new TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w700
                ),
              ),
            )
          ],
        )
      )
    );
  }

}