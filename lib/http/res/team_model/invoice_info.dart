//开票信息
class InvoiceInfo {
  String address;
  String cardNo;
  String opened;
  String phone;
  String remark;
  String taxNum;
  int teamId;
  String title;

  InvoiceInfo(
      {this.address,
      this.cardNo,
      this.opened,
      this.phone,
      this.remark,
      this.taxNum,
      this.teamId,
      this.title});

  InvoiceInfo.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    cardNo = json['cardNo'];
    opened = json['opened'];
    phone = json['phone'];
    remark = json['remark'];
    taxNum = json['taxNum'];
    teamId = json['teamId'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['cardNo'] = this.cardNo;
    data['opened'] = this.opened;
    data['phone'] = this.phone;
    data['remark'] = this.remark;
    data['taxNum'] = this.taxNum;
    data['teamId'] = this.teamId;
    data['title'] = this.title;
    return data;
  }
}
