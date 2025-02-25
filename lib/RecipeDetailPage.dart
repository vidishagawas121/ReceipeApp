import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeDetailPage extends StatefulWidget {
  final String name;
  final String image;

  RecipeDetailPage({required this.name, required this.image});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  TextEditingController ingredientController = TextEditingController();
  TextEditingController procedureController = TextEditingController();
  List<String> ingredients = [];
  String procedure = "";

  // 🔹 Default Recipes (Can Be Modified by User)
  final Map<String, Map<String, dynamic>> defaultRecipes = {
    "Puran Poli": {
      "ingredients": ["Wheat Flour", "Chana Dal", "Jaggery", "Cardamom Powder", "Ghee"],
      "procedure": "1. Prepare the dough.\n2. Cook the chana dal and mix with jaggery.\n3. Stuff and roll into poli.\n4. Cook on tawa with ghee.",
    },
    "Pasta": {
      "ingredients": ["Pasta", "Tomato Sauce", "Garlic", "Cheese", "Olive Oil"],
      "procedure": "1. Boil pasta.\n2. Prepare sauce with garlic & tomatoes.\n3. Mix pasta with sauce and serve with cheese.",
    },
  };

  @override
  void initState() {
    super.initState();
    _loadRecipeData();
  }

  // 🔹 Load Recipe Data (From Firebase or Default)
  void _loadRecipeData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('recipes').doc(widget.name).get();

    if (doc.exists) {
      setState(() {
        ingredients = List<String>.from(doc['ingredients'] ?? []);
        procedure = doc['procedure'] ?? '';
        procedureController.text = procedure;
      });
    } else {
      // If no Firebase data, load defaults
      if (defaultRecipes.containsKey(widget.name)) {
        setState(() {
          ingredients = List<String>.from(defaultRecipes[widget.name]!['ingredients']);
          procedure = defaultRecipes[widget.name]!['procedure'];
          procedureController.text = procedure;
        });
      }
    }
  }

  // 🔹 Add New Ingredient & Save to Firebase
  void _addIngredient() async {
    if (ingredientController.text.isNotEmpty) {
      setState(() {
        ingredients.add(ingredientController.text);
      });

      await FirebaseFirestore.instance.collection('recipes').doc(widget.name).set({
        'ingredients': ingredients,
      }, SetOptions(merge: true));

      ingredientController.clear();
    }
  }

  // 🔹 Save Procedure to Firebase
  void _saveProcedure() async {
    await FirebaseFirestore.instance.collection('recipes').doc(widget.name).set({
      'procedure': procedureController.text,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Recipe Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(widget.image, width: double.infinity, height: 200, fit: BoxFit.cover),
            ),
            SizedBox(height: 16),

            // 🔹 Ingredients List
            Text("Ingredients:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ingredients.map((ingredient) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text("• $ingredient", style: TextStyle(fontSize: 16)),
              )).toList(),
            ),
            SizedBox(height: 10),

            // 🔹 Add Custom Ingredients
            TextField(
              controller: ingredientController,
              decoration: InputDecoration(
                hintText: "Add an ingredient...",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addIngredient,
                ),
              ),
            ),
            SizedBox(height: 16),

            // 🔹 Procedure Section
            Text("Procedure:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: procedureController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Enter the procedure...",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  procedure = value;
                });
              },
            ),
            SizedBox(height: 10),

            // 🔹 Save Procedure Button
            ElevatedButton(
              onPressed: _saveProcedure,
              child: Text("Save Procedure"),
            ),
          ],
        ),
      ),
    );
  }
}
