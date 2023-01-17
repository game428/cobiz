class BurnModel {
  int burn;
  BurnModel(this.burn);

  BurnModel.fromJsonMap(Map<String, dynamic> map) : burn = map['burn'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['burn'] = burn;
    return data;
  }
}
