class DropDownItem {
  static DropDownItem objState;
  static DropDownItem objTitle;
  static DropDownItem objDialCode = DropDownItem(name: '+60', id: 1);
  String name;
  int id;

  DropDownItem({this.name, this.id});

  static List<DropDownItem> get listState => [
        DropDownItem(name: 'Johor', id: 1),
        DropDownItem(name: 'Kedah', id: 2),
        DropDownItem(name: 'Kelantan', id: 3),
        DropDownItem(name: 'Melaka', id: 4),
        DropDownItem(name: 'Negeri Sembilan', id: 5),
        DropDownItem(name: 'Pahang', id: 6),
        DropDownItem(name: 'Penang', id: 7),
        DropDownItem(name: 'Perak', id: 8),
        DropDownItem(name: 'Sabah', id: 9),
        DropDownItem(name: 'Sarawak', id: 10),
        DropDownItem(name: 'Selangor', id: 11),
        DropDownItem(name: 'Terengganu', id: 12),
      ];

  static List<DropDownItem> get listTitle => [
        DropDownItem(name: 'Mr.', id: 1),
        DropDownItem(name: 'Mrs.', id: 2),
        DropDownItem(name: 'Ms.', id: 3),
        DropDownItem(name: 'Miss', id: 4),
      ];

  static List<DropDownItem> get listDialCode => [
        DropDownItem(name: '+60', id: 1),
      ];
}
