import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/portfolio_models.dart';
import '../../core/providers/admin_providers.dart';
import '../../core/theme/admin_theme.dart';

class ExperienceManager extends ConsumerStatefulWidget {
  const ExperienceManager({super.key});

  @override
  ConsumerState<ExperienceManager> createState() => _ExperienceManagerState();
}

class _ExperienceManagerState extends ConsumerState<ExperienceManager> {
  void _showExperienceDialog([ExperienceModel? exp]) {
    showDialog(
      context: context,
      builder: (context) => _ExperienceFormDialog(exp: exp),
    );
  }

  void _confirmDelete(ExperienceModel exp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.cardBg,
        title: const Text("Confirm Deletion", style: TextStyle(color: AdminTheme.textPrimary)),
        content: Text("Are you sure you want to delete '${exp.position} at ${exp.company}'?", style: const TextStyle(color: AdminTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(adminRepositoryProvider).deleteExperience(exp.id);
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
    final expAsync = ref.watch(adminExperienceProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Work Experience Management", style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                onPressed: () => _showExperienceDialog(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text("Add Experience"),
                style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: AdminTheme.darkBg),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: expAsync.when(
              data: (expList) {
                if (expList.isEmpty) {
                  return const Center(child: Text("No experience documents found.", style: TextStyle(color: AdminTheme.textMuted)));
                }

                return ListView.separated(
                  itemCount: expList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final exp = expList[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AdminTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AdminTheme.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${exp.position} @ ${exp.company}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textPrimary)),
                                Text("${exp.startDate} – ${exp.current ? 'Present' : exp.endDate} • ${exp.location}", style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: AdminTheme.primary),
                            onPressed: () => _showExperienceDialog(exp),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AdminTheme.danger),
                            onPressed: () => _confirmDelete(exp),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AdminTheme.primary)),
              error: (err, stack) => Text("Error loading experience: $err", style: const TextStyle(color: AdminTheme.danger)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceFormDialog extends ConsumerStatefulWidget {
  final ExperienceModel? exp;

  const _ExperienceFormDialog({this.exp});

  @override
  ConsumerState<_ExperienceFormDialog> createState() => _ExperienceFormDialogState();
}

class _ExperienceFormDialogState extends ConsumerState<_ExperienceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyController;
  late TextEditingController _positionController;
  late TextEditingController _locationController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _descController;
  late TextEditingController _respController;
  late TextEditingController _displayOrderController;
  bool _current = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.exp;
    _companyController = TextEditingController(text: e?.company ?? '');
    _positionController = TextEditingController(text: e?.position ?? '');
    _locationController = TextEditingController(text: e?.location ?? '');
    _startDateController = TextEditingController(text: e?.startDate ?? '');
    _endDateController = TextEditingController(text: e?.endDate ?? '');
    _descController = TextEditingController(text: e?.description ?? '');
    _respController = TextEditingController(text: e?.responsibilities.join('\n') ?? '');
    _displayOrderController = TextEditingController(text: (e?.displayOrder ?? 1).toString());
    _current = e?.current ?? false;
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final repo = ref.read(adminRepositoryProvider);
        final respList = _respController.text.split('\n').map((r) => r.trim()).where((r) => r.isNotEmpty).toList();
        final order = int.tryParse(_displayOrderController.text) ?? 1;

        if (widget.exp == null) {
          final newExp = ExperienceModel(
            id: '',
            company: _companyController.text.trim(),
            position: _positionController.text.trim(),
            location: _locationController.text.trim(),
            employmentType: 'Full-time',
            startDate: _startDateController.text.trim(),
            endDate: _endDateController.text.trim(),
            current: _current,
            description: _descController.text.trim(),
            responsibilities: respList,
            technologies: [],
            displayOrder: order,
          );
          await repo.addExperience(newExp);
        } else {
          final updated = ExperienceModel(
            id: widget.exp!.id,
            company: _companyController.text.trim(),
            position: _positionController.text.trim(),
            location: _locationController.text.trim(),
            employmentType: widget.exp!.employmentType,
            startDate: _startDateController.text.trim(),
            endDate: _endDateController.text.trim(),
            current: _current,
            description: _descController.text.trim(),
            responsibilities: respList,
            technologies: widget.exp!.technologies,
            displayOrder: order,
          );
          await repo.updateExperience(updated);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error saving experience: $e"), backgroundColor: AdminTheme.danger),
          );
        }
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
        width: 550,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.exp == null ? "Add Work Experience" : "Edit Work Experience", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _companyController,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  decoration: const InputDecoration(labelText: "Company Name", filled: true, fillColor: AdminTheme.darkBg),
                  validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _positionController,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  decoration: const InputDecoration(labelText: "Position / Title", filled: true, fillColor: AdminTheme.darkBg),
                  validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startDateController,
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        decoration: const InputDecoration(labelText: "Start Date (e.g. Dec 2025)", filled: true, fillColor: AdminTheme.darkBg),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _endDateController,
                        enabled: !_current,
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        decoration: const InputDecoration(labelText: "End Date (e.g. Dec 2026)", filled: true, fillColor: AdminTheme.darkBg),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Checkbox(
                      value: _current,
                      activeColor: AdminTheme.primary,
                      onChanged: (val) => setState(() => _current = val ?? false),
                    ),
                    const Text("Currently working here", style: TextStyle(color: AdminTheme.textPrimary)),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _locationController,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  decoration: const InputDecoration(labelText: "Location", filled: true, fillColor: AdminTheme.darkBg),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  decoration: const InputDecoration(labelText: "Summary Description", filled: true, fillColor: AdminTheme.darkBg),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _respController,
                  maxLines: 4,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  decoration: const InputDecoration(labelText: "Key Responsibilities (one bullet per line)", filled: true, fillColor: AdminTheme.darkBg),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _displayOrderController,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Display Order", filled: true, fillColor: AdminTheme.darkBg),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: AdminTheme.darkBg),
                      child: Text(_isSaving ? "Saving..." : "Save Experience"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
