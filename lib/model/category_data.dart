class CategoryModel {
  String? categoryName
  CategoryModel({this.categoryName});
}

List<CategoryModel> getCategories() {
  List<CategoryModel> categories = [];

  // Adding each category
  CategoryModel category = CategoryModel(categoryName: "Science");
  categories.add(category);

  category = CategoryModel(categoryName: "Sports");
  categories.add(category);

  category = CategoryModel(categoryName: "Business");
  categories.add(category);

  category = CategoryModel(categoryName: "General");
  categories.add(category);

  category = CategoryModel(categoryName: "Health");
  categories.add(category);

  category = CategoryModel(categoryName: "Entertainment");
  categories.add(category);

  return categories;
}
