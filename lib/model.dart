class KeuanganModel {
   final String id;
   final String name;
   final String description;
   final String amount;
   final String type;
   final String category;
   final String date;
   final String picture;

   KeuanganModel({
      required this.id,
      required this.name,
      required this.description,
      required this.amount,
      required this.type,
      required this.category,
      required this.date,
      required this.picture
   });

   factory KeuanganModel.fromJson(Map data) {
      return KeuanganModel(
         id: data['_id'],
         name: data['name'],
         description: data['description'],
         amount: data['amount'],
         type: data['type'],
         category: data['category'],
         date: data['date'],
         picture: data['picture']
      );
   }
}