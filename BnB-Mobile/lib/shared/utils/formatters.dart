class Formatters {
  static String price(double p) => '\$${p.toStringAsFixed(0)}';
  static String date(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
