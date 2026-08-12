import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/portfolio_models.dart';
import '../../core/providers/admin_providers.dart';
import '../../core/theme/admin_theme.dart';

class EducationManager extends ConsumerStatefulWidget {
  const EducationManager({super.key});

  @override
  ConsumerState<EducationManager> createState() => _EducationManagerState();
}

class _EducationManagerState extends ConsumerState<EducationManager> {
  void _showDialog([EducationModel? edu]) {
    showDialog(context: context, builder: (context) => _EducationFormDialog(edu: edu));
  }

  void _confirmDelete(EducationModel edu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.cardBg,
        title: const Text("Confirm Deletion", style: TextStyle(color: AdminTheme.textPrimary)),
        content: Text("Delete '${edu.degree}'?", style: const TextStyle(color: AdminTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(adminRepositoryProvider).deleteEducation(edu.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.danger),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eduAsync = ref.watch(adminEducationProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Education Management", style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                onPressed: () => _showDialog(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text("Add Education"),
                style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: AdminTheme.darkBg),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: eduAsync.when(
              data: (eduList) {
                if (eduList.isEmpty) return const Center(child: Text("No education documents found.", style: TextStyle(color: AdminTheme.textMuted)));

                return ListView.separated(
                  itemCount: eduList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final edu = eduList[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AdminTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminTheme.border)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(edu.degree, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textPrimary)),
                                Text("${edu.institution} • Grade: ${edu.grade}", style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.edit_rounded, color: AdminTheme.primary), onPressed: () => _showDialog(edu)),
                          IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AdminTheme.danger), onPressed: () => _confirmDelete(edu)),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AdminTheme.primary)),
              error: (err, stack) => Text("Error: $err", style: const TextStyle(color: AdminTheme.danger)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EducationFormDialog extends ConsumerStatefulWidget {
  final EducationModel? edu;
  const _EducationFormDialog({this.edu});

  @override
  ConsumerState<_EducationFormDialog> createState() => _EducationFormDialogState();
}

class _EducationFormDialogState extends ConsumerState<_EducationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _instController;
  late TextEditingController _degreeController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _gradeController;
  late TextEditingController _descController;
  late TextEditingController _orderController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.edu;
    _instController = TextEditingController(text: e?.institution ?? '');
    _degreeController = TextEditingController(text: e?.degree ?? '');
    _startDateController = TextEditingController(text: e?.startDate ?? '');
    _endDateController = TextEditingController(text: e?.endDate ?? '');
    _gradeController = TextEditingController(text: e?.grade ?? '');
    _descController = TextEditingController(text: e?.description ?? '');
    _orderController = TextEditingController(text: (e?.displayOrder ?? 1).toString());
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final repo = ref.read(adminRepositoryProvider);
        final order = int.tryParse(_orderController.text) ?? 1;

        if (widget.edu == null) {
          final newEdu = EducationModel(
            id: '',
            institution: _instController.text.trim(),
            degree: _degreeController.text.trim(),
            field: 'Computer Science',
            startDate: _startDateController.text.trim(),
            endDate: _endDateController.text.trim(),
            grade: _gradeController.text.trim(),
            description: _descController.text.trim(),
            displayOrder: order,
          );
          await repo.addEducation(newEdu);
        } else {
          final updated = EducationModel(
            id: widget.edu!.id,
            institution: _instController.text.trim(),
            degree: _degreeController.text.trim(),
            field: widget.edu!.field,
            startDate: _startDateController.text.trim(),
            endDate: _endDateController.text.trim(),
            grade: _gradeController.text.trim(),
            description: _descController.text.trim(),
            displayOrder: order,
          );
          await repo.updateEducation(updated);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: AdminTheme.danger));
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AdminTheme.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.edu == null ? "Add Education" : "Edit Education", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(controller: _instController, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: "Institution", filled: true, fillColor: AdminTheme.darkBg), validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 12),
              TextFormField(controller: _degreeController, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: "Degree", filled: true, fillColor: AdminTheme.darkBg), validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _startDateController, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: "Start Date", filled: true, fillColor: AdminTheme.darkBg))),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _endDateController, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: "End Date", filled: true, fillColor: AdminTheme.darkBg))),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _gradeController, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: "Grade / CGPA", filled: true, fillColor: AdminTheme.darkBg)),
              const SizedBox(height: 12),
              TextFormField(controller: _descController, maxLines: 2, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: "Honors / Description", filled: true, fillColor: AdminTheme.darkBg)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: _isSaving ? null : _save, style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: AdminTheme.darkBg), child: Text(_isSaving ? "Saving..." : "Save")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
