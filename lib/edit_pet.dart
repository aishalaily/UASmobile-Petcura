import 'package:flutter/material.dart';

class EditPetProfilePage extends StatefulWidget {
  final String name;
  final String type;
  final String age;
  final String gender;
  final String weight;
  final String birthday;

  const EditPetProfilePage({
    super.key,
    required this.name,
    required this.type,
    required this.age,
    required this.gender,
    required this.weight,
    required this.birthday,
  });

  @override
  _EditPetProfilePageState createState() => _EditPetProfilePageState();
}

class _EditPetProfilePageState extends State<EditPetProfilePage> {
  late TextEditingController nameController;
  late TextEditingController typeController;
  late TextEditingController ageController;
  late TextEditingController genderController;
  late TextEditingController weightController;
  late TextEditingController birthdayController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    typeController = TextEditingController(text: widget.type);
    ageController = TextEditingController(text: widget.age);
    genderController = TextEditingController(text: widget.gender);
    weightController = TextEditingController(text: widget.weight);
    birthdayController = TextEditingController(text: widget.birthday);
  }

  @override
  void dispose() {
    nameController.dispose();
    typeController.dispose();
    ageController.dispose();
    genderController.dispose();
    weightController.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.pop(context, {
      "name": nameController.text.trim(),
      "type": typeController.text.trim(),
      "age": ageController.text.trim(),
      "gender": genderController.text.trim(),
      "weight": weightController.text.trim(),
      "birthday": birthdayController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pet Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildTextField('Name', controller: nameController),
            _buildTextField('Breed', controller: typeController),
            _buildTextField('Age', controller: ageController, keyboardType: TextInputType.number),
            _buildTextField('Gender', controller: genderController),
            _buildTextField('Weight', controller: weightController, keyboardType: TextInputType.number),
            _buildTextField('Birthday', controller: birthdayController),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {required TextEditingController controller, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
