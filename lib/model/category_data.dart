// Define the CategoryModel class
class CategoryModel {
  String? categoryName;

  // Constructor to initialize the category name
  CategoryModel({this.categoryName});
}

// Function to get a list of news categories
List<CategoryModel> getCategories() {
  // List to hold categories
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
