import 'package:flutter/material.dart';
import 'package:kelanaapp/theme.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:kelanaapp/data_list.dart'; // Import data_list.dart

class SignUpForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController noHpController;
  final Function(String) onSelectJurusan;
  final Function(String) onSelectProgramStudi;
  final Function(String) onSelectKelas;

  const SignUpForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.noHpController,
    required this.onSelectJurusan,
    required this.onSelectProgramStudi,
    required this.onSelectKelas,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool _isObscure = true;
  String? _selectedJurusan;
  String? _selectedProgramStudi;
  String? _selectedKelas;

  @override
  Widget build(BuildContext context) {
    List<String> filteredProgramStudiList =
        _selectedJurusan != null ? programStudiMap[_selectedJurusan] ?? [] : [];

    return Column(
      children: [
        buildInputForm('Nama', false, widget.nameController),
        buildInputForm('Email', false, widget.emailController),
        buildSearchableDropdownForm(
          'Jurusan',
          jurusanList,
          _selectedJurusan,
          (value) {
            setState(() {
              _selectedJurusan = value;
              widget.onSelectJurusan(value!);
            });
          },
        ),
        buildSearchableDropdownForm(
          'Program Studi',
          filteredProgramStudiList,
          _selectedProgramStudi,
          (value) {
            setState(() {
              _selectedProgramStudi = value;
              widget.onSelectProgramStudi(value!);
            });
          },
        ),
        buildSearchableDropdownForm(
          'Kelas',
          kelasList,
          _selectedKelas,
          (value) {
            setState(() {
              _selectedKelas = value;
              widget.onSelectKelas(value!);
            });
          },
        ),
        buildInputForm('Password', true, widget.passwordController),
        buildInputForm('No HP', false, widget.noHpController),
      ],
    );
  }

  Padding buildInputForm(
      String hint, bool pass, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        obscureText: pass ? _isObscure : false,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kTextFieldColor),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: kPrimaryColor),
          ),
          suffixIcon: pass
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                  icon: _isObscure
                      ? const Icon(
                          Icons.visibility_off,
                          color: kTextFieldColor,
                        )
                      : const Icon(
                          Icons.visibility,
                          color: kPrimaryColor,
                        ),
                )
              : null,
        ),
      ),
    );
  }

  Padding buildSearchableDropdownForm(
    String hint,
    List<String> items,
    String? selectedItem,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownSearch<String>(
        items: items,
        selectedItem: selectedItem,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: hint,
            hintStyle: const TextStyle(
              color: kTextFieldColor,
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: kPrimaryColor,
              ),
            ),
          ),
        ),
        onChanged: onChanged,
        popupProps: PopupProps.menu(
          showSearchBox: true,
          emptyBuilder: (context, searchEntry) {
            return Center(
              child: Text(
                "Tidak ditemukan pencarian untuk $searchEntry",
              ),
            );
          },
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: "Ketikkan disini...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
