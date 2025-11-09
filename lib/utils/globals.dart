import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Tag {
  static const gps = "gps";
  static const map = "map";
  static const star = "star";
  static const note = "note";
  static const link = "link";

  static const food = "food";
  static const cafe = "cafe";
  static const breakfast = "breakfast";
  static const restaurant = "restaurant";
  static const transport = "transport";
  static const taxi = "taxi";
  static const bus = "bus";
  static const hotel = "hotel";
  static const entrance = "entrance";
  static const shop = "shop";
  static const guide = "guide";
  static const attraction = "attraction";
}

class MyIcons {
  static const gps = Icons.gps_fixed;
  static const map = Icons.location_on;
  static const link = Icons.link;
  static const copy = Icons.copy;
  static const star = Icons.star;
  static const note = Icons.note;
  static const save = Icons.save;
  static const delete = Icons.delete;
  static const cancel = Icons.arrow_back;
  static const show = Icons.zoom_in;
  static const bus = Icons.directions_bus;
  static const taxi = Icons.local_taxi;
  static const hotel = Icons.hotel;
  static const guide = Icons.directions;
  static const shop = Icons.shopping_cart;
  static const cafe = Icons.coffee_outlined;
  static const breakfast = Icons.bakery_dining;
  static const restaurant = Icons.local_dining;
  static const attraction = Icons.attractions;
}

class TagIcon {
  final List<String> tags;
  final IconData icon;

  const TagIcon({required this.tags, required this.icon});
}


class PlaceIcons {
  static const dynamic = Icons.compare_arrows;
  static const fixed = Icons.lock;
  static const booked = Icons.hotel;
  static const placeholder = Icons.question_mark;
}


class Txt {
  static const links = "Links";
  static const note = "Note";
  static const allNotes = "Notes";
  static const locations = "Locations";
  static const expenses = "Expenses";
  static const journey = "Journey";
  static const checklist = "Check List";
  static const calculator = "Calculator";
  static const appTitle = "Travel Assist";
  static const currencyRates = "Currency Rates";
  static const storageDir = "Storage Dir";
  static const importExport = "Import/Export";
  static const quickEdit = "Quick Edit";
  static const comment = "Comment";
  static const category = "Category";
  static const transaction = "Transaction";
  static const notesStorageDir = "Notes Storage Folder";
  static const hintLink = "Link...";
  static const hintComment = "Comment...";
  static const hintTag = "Tags...";
  static const cash = "cash";
  static const place = "Place";
}

const EdgeInsets pagePadding = EdgeInsets.fromLTRB(14, 8, 14, 0);

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

class AppFontSize {
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
