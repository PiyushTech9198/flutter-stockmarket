import 'dart:convert';

class StockData {
   double rate;
  final double volume;
  final String orderType;
  final String timestamp;

  StockData({
    required this.rate,
    required this.volume,
    required this.orderType,
    required this.timestamp,
  });

  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      rate: json['rate'] ?? 0.0,
      volume: json['volume'] ?? 0.0,
      orderType: json['order_type'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

List<StockData> parseStockDataList(String json) {
  final parsed = jsonDecode(json).cast<Map<String, dynamic>>();
  return parsed.map<StockData>((json) => StockData.fromJson(json)).toList();
}
