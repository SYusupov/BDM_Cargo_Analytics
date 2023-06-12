class Product {
  final String id;
  final String name;
  final int weight;

  Product({required this.id, required this.name, required this.weight});
}


List<Product> productList = [
  Product(id: "1", name: 'IPhone 14  pro max', weight: 500),
  Product(id: "2", name: 'MacBook Pro', weight: 1500),
  Product(id: "3", name: 'Baby Clothes', weight: 300),
  Product(id: "4", name: 'Face Cream', weight: 750),
];
