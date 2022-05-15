import 'package:colour/colour.dart';
import 'package:flutter/material.dart';
import 'package:inet/classes/date_select.dart';

Widget DropDownChart(String title, List<String> listOptions, String currentValue, Function onChangedFunction){
  return Container(
    padding: EdgeInsets.only(left: 25, right: 25),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          child: Text(title, style: TextStyle(),)
        ),
        DropdownButton(
          value: currentValue,
          isExpanded: true,
          items: listOptions.map(
                (val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val),
              );
            },
          ).toList(),
          onChanged: (val) {
            onChangedFunction(val);
          },
        )
      ],
    )
  );
}

Widget DatePicker(BuildContext context, String title, String currentDate, DateTime datePicker, Function datePickerFunction) {
  return Container(
    padding: EdgeInsets.only(left: 25, right: 25),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        GestureDetector(
            onTap: (){
              selectDate(context, datePicker).then((datePicked){
                if(datePicked != null) {
                  datePickerFunction(datePicked);
                }
              });
            },
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Container(
                    child: Text(currentDate, style: TextStyle(fontWeight: FontWeight.bold),),
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    margin: EdgeInsets.only(top: 5),
                  ),),
                  Icon(Icons.date_range_rounded, color: Colour("#666666"),)
                ],
              ),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colour("#d6d6d6"), width: 0.5))
              ),
            )
        )
      ],
    ),
  );
}

List<Widget> SearchResult(List<String> list, String searchText, Function selectChannelFunction) {
  List<Widget> listResult = new List<Widget>();
  list.forEach((element) {
    if(element.toUpperCase().contains(searchText.toUpperCase())) {
      listResult.add(
        new GestureDetector(
          onTap: (){
            selectChannelFunction(element);
          },
          child: Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            child: Text(element),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(
                    color: Colour('#D1DBEE'),
                    width: 1
                ))
            ),
          )
        )
      );
    }
  });
  return listResult;
}

Widget MyDropDown({String title, List<String> listOptions, String currentValue, Function onChangedFunction, bool isExpand, double customMargin}){
  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        title != null && title.isNotEmpty ? Container(
            child: Text(title,)
        ) : Container(),
        DropdownButton(
          underline: SizedBox(),
          value: currentValue,
          isExpanded: isExpand,
          items: listOptions.map(
                (val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Container(
                  margin: EdgeInsets.only(left: customMargin ?? 5),
                  child: Text(val)
                ),
              );
            },
          ).toList(),
          onChanged: (val) {
            if(onChangedFunction != null) {
              onChangedFunction(val);
            }
          },

        )
      ],
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      border: Border.all(color: Colors.grey, width: 1)
    ),
  );
}
