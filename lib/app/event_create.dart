import 'package:flutter/material.dart';
import 'package:my_events/app/landing_page.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/services/place.dart';
import 'package:my_events/common_widgets/animated_background.dart';
import 'package:my_events/common_widgets/custom_input.dart';
import 'package:my_events/common_widgets/custom_datepicker.dart';
import 'package:my_events/common_widgets/custom_raised_button.dart';

class EventCreate extends StatefulWidget {
  EventCreate({
    @required this.auth,
    @required this.place
  });

  final AuthBase auth;
  final place;

  @override
  _EventCreateState createState() => new _EventCreateState(auth: auth, place: place);
}

class _EventCreateState extends State<EventCreate> {

  _EventCreateState({
      @required this.auth,
      @required this.place,
  });

  final AuthBase auth;
  final place;
  Map formData = {};

  TextEditingController textControllerStart = new TextEditingController();
  TextEditingController textControllerEnd = new TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void prepareFormData() {
    print(formData);
    PlaceMark().createRecord(
      formData,
      place
    );
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidate: false,
            child: formUi(),
          ),
        ),
      ),
    );
  }

  Widget formUi(){
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
              left: 12.0, right: 12.0, top: 30.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).textSelectionColor,
                  size: 30.0,
                ),
                onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => LandingPage(auth: Auth(), choosenIndex: 2,),
                    )
                  );
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: 12.0, right: 12.0, top: 30.0, bottom: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Новое событие:",
                  style: TextStyle(
                    color: Theme.of(context).textSelectionColor,
                    fontSize: 26.0,
                    fontFamily: "Calibre-Semibold",
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  )),
              CustomInput(
                labelText: "Название",
                height: 100,
                width: MediaQuery.of(context).size.width - 24,
                maxLines: null,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Название не должно быть пустым';
                  }
                  return null;
                },
                onSaved: (String value) {
                  formData.addAll({'eventName': value});
                }
              ),
              CustomInput(
                labelText: "Описание",
                height: 150,
                width: MediaQuery.of(context).size.width - 24,
                maxLines: 1000,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Описание не должно быть пустым';
                  }
                  return null;
                },
                onSaved: (String value) {
                  formData.addAll({'eventDescription': value});
                }
              ),
              Text("Начало:",
                style: TextStyle(
                  color: Theme.of(context).textSelectionColor,
                  fontSize: 20.0,
                  fontFamily: "Calibre-Semibold",
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                )),
              dateSelector('start'),
              Text("Закончится:",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Theme.of(context).textSelectionColor,
                  fontSize: 20.0,
                  fontFamily: "Calibre-Semibold",
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                )),
              dateSelector('end'),
              CustomRaisedButton(
                color: Theme.of(context).primaryColor,
                onPressed: () => prepareFormData(),
                child: Text("Готово"),
              )
            ]
          ),
        ),
      ],
    );
  }

  Widget dateSelector(type) {

    Future<DateTime> selectDate() async {
      return await showDatePicker(
        initialDatePickerMode: DatePickerMode.day,
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2018),
        lastDate:  DateTime.now().add(Duration(days: 365)),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark(),
            child: child,
          );
        },
      );
    }

    TextEditingController textController;

    if(type == 'end')
    {
      textController = textControllerEnd;
    } else
    {
      textController = textControllerStart;
    }

    return Padding(
      padding: const EdgeInsets.only(
          left: 0, right: 12.0, top: 30.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomDatepicker(
            textController: textController,
            labelText: "Выберите дату",
            height: 100,
            width: (MediaQuery.of(context).size.width - 24 ) / 1.85,
            onTap: () async {
              DateTime date = DateTime(1900);
              FocusScope.of(context).requestFocus(new FocusNode());
              date = await selectDate();

              String dateString = "${date.day}, ${date.month}";

              if(type == 'end')
              {
                formData.addAll({'eventEndDay': "${date.day}"});
                formData.addAll({'eventEndMonth': "${date.month}"});
              } else
              {
                formData.addAll({'eventDay': "${date.day}"});
                formData.addAll({'eventMonth': "${date.month}"});
              }

              setState(() {
                textController.text = "$dateString";
              });
            },
          ),
          CustomInput(
            labelText: "Часы",
            height: 100,
            paddingHorizontal: 2,
            width: MediaQuery.of(context).size.width / 4 - 24,
            maxLines: null,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isEmpty) {
                return null;
              }
              return null;
            },
            onSaved: (String value) {
              if(type == 'end')
              {
                formData.addAll({'eventEndHours': value});
              } else
              {
                formData.addAll({'eventHours': value});
              }
            },
          ),
          CustomInput(
            labelText: "Минуты",
            height: 100,
            paddingHorizontal: 2,
            width: MediaQuery.of(context).size.width / 4 - 24,
            maxLines: null,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isEmpty) {
                return null;
              }
              return null;
            },
            onSaved: (String value) {
              if(type == 'end')
              {
                formData.addAll({'eventEndMinutes': value});
              } else
              {
                formData.addAll({'eventMinutes': value});
              }
            },
          ),
        ],
      ),
    );
  }
}