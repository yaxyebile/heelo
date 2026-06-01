import 'package:flutter/material.dart';
import 'departments_view.dart';

/// Legacy route — redirects to new departments design.
class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) => const DepartmentsView();
}
