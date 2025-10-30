import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Tag {
  static const gps = "gps";
  static const map = "map";
  static const star = "star";
  static const note = "note";
  static const link = "link";
}

class MyIcon {
  static const gps = Icon(Icons.gps_fixed);
  static const map = Icon(Icons.map);
  static const link = Icon(Icons.link);
  static const copy = Icon(Icons.copy);
  static const star = Icon(Icons.star);
  static const note = Icon(Icons.note);
}

class TagIcon2 {
  final String tag;
  final Icon icon;
  const TagIcon2({required this.tag, required this.icon});
}

class TagIcon {
  static const gps = TagIcon2(tag: Tag.gps, icon: MyIcon.gps);
  static const map = TagIcon2(tag: Tag.map, icon: MyIcon.map);
  static const link = TagIcon2(tag: Tag.link, icon: MyIcon.link);
  static const star = TagIcon2(tag: Tag.star, icon: MyIcon.star);
  static const note = TagIcon2(tag: Tag.note, icon: MyIcon.note);
}

class Txt {
  static const links = "Links";
  static const note = "Note";
  static const allNotes = "Notes";
  static const locations = "Locations";
  static const expenses = "Expenses";
  static const todos = "To-Dos";
  static const calculator = "Calculator";
  static const appTitle = "Travel Assist";
  static const currencyRates = "Currency rates";
  static const storageDir = "Storage Dir";
  static const importExport = "Import/Export";
}

class AppColors {
  static const expense = Colors.orangeAccent;
  static const withdrawal = Colors.greenAccent;
  static const deposit = Colors.lightGreenAccent;
  static const balance = Colors.lightBlueAccent;
  static const cash = Colors.yellowAccent;
}

class AppIcons {
  static const expense = FaIcon(
    FontAwesomeIcons.cartShopping,
    color: AppColors.expense,
  );
  static const withdrawal = FaIcon(
    FontAwesomeIcons.moneyBills,
    color: AppColors.withdrawal,
  );
  static const deposit = FaIcon(
    FontAwesomeIcons.sackDollar,
    color: AppColors.deposit,
  );
  static const cashCount = FaIcon(
    FontAwesomeIcons.scaleBalanced,
    color: AppColors.balance,
  );
}

class AppFonstSize {
  static const double balanceMainHeader = 18;
  static const double balanceHeader = 16;
  static const double balanceEntry = 16;
}

class AppBalanceStyle {
  static const TextStyle subheader = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle method = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.normal,
  );
  static const TextStyle normal = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.italic,
  );
}

class BorderStyles {
  static final OutlineInputBorder input = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
  );
  static final BoxDecoration box = BoxDecoration(
    //border: Border.all(color: Colors.blue, width: 2.0), // Border color and width
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(10.0), // Optional: rounded corners
  );
}
