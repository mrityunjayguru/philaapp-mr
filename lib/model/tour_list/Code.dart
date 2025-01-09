/// ticket_number : "123"

class Code {
  Code({
      this.ticketNumber,});

  Code.fromJson(dynamic json) {
    ticketNumber = json['ticket_number'];
  }
  String? ticketNumber;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ticket_number'] = ticketNumber;
    return map;
  }

}