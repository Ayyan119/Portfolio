import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/portfolio_models.dart';
import '../../core/providers/admin_providers.dart';
import '../../core/theme/admin_theme.dart';

class SkillsManager extends ConsumerStatefulWidget {
  const SkillsManager({super.key});

  @override
  ConsumerState<SkillsManager> createState() => _SkillsManagerState();
}

class _SkillsManagerState extends ConsumerState<SkillsManager> {
  void _showSkillDialog([SkillModel? skill]) {
    showDialog(
      context: context,
      builder: (context) => _SkillFormDialog(skill: skill),
    );
  }

  void _confirmDelete(SkillModel skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.cardBg,
        title: const Text("Confirm Deletion", style: TextStyle(color: AdminTheme.textPrimary)),
        content: Text("Are you sure you want to delete '${skill.name}'?", style: const TextStyle(color: AdminTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(adminRepositoryProvider).deleteSkill(skill.id);
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
    final skillsAsync = ref.watch(adminSkillsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Skills Management", style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                onPressed: () => _showSkillDialog(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text("Add Skill"),
                style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: AdminTheme.darkBg),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: skillsAsync.when(
              data: (skills) {
                if (skills.isEmpty) {
                  return const Center(child: Text("No skills found.", style: TextStyle(color: AdminTheme.textMuted)));
                }

                return ListView.separated(
                  itemCount: skills.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final skill = skills[index];
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
                                Text(skill.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textPrimary)),
                                Text("${skill.category} • Order: ${skill.displayOrder}", style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: AdminTheme.primary),
                            onPressed: () => _showSkillDialog(skill),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AdminTheme.danger),
                            onPressed: () => _confirmDelete(skill),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AdminTheme.primary)),
              error: (err, stack) => Text("Error loading skills: $err", style: const TextStyle(color: AdminTheme.danger)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillFormDialog extends ConsumerStatefulWidget {
  final SkillModel? skill;

  const _SkillFormDialog({this.skill});

  @override
  ConsumerState<_SkillFormDialog> createState() => _SkillFormDialogState();
}

class _SkillFormDialogState extends ConsumerState<_SkillFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _displayOrderController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.skill;
    _nameController = TextEditingController(text: s?.name ?? '');
    _categoryController = TextEditingController(text: s?.category ?? 'Generative AI');
    _displayOrderController = TextEditingController(text: (s?.displayOrder ?? 1).toString());
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final repo = ref.read(adminRepositoryProvider);
        final order = int.tryParse(_displayOrderController.text) ?? 1;

        if (widget.skill == null) {
          final newSkill = SkillModel(
            id: '',
            name: _nameController.text.trim(),
            category: _categoryController.text.trim(),
            icon: 'psychology',
            proficiency: 0.9,
            displayOrder: order,
          );
          await repo.addSkill(newSkill);
        } else {
          final updated = SkillModel(
            id: widget.skill!.id,
            name: _nameController.text.trim(),
            category: _categoryController.text.trim(),
            icon: widget.skill!.icon,
            proficiency: widget.skill!.proficiency,
            displayOrder: order,
          );
          await repo.updateSkill(updated);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error saving skill: $e"), backgroundColor: AdminTheme.danger),
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
        width: 450,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.skill == null ? "Add Skill" : "Edit Skill", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AdminTheme.textPrimary),
                decoration: const InputDecoration(labelText: "Skill Name", filled: true, fillColor: AdminTheme.darkBg),
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _categoryController,
                style: const TextStyle(color: AdminTheme.textPrimary),
                decoration: const InputDecoration(labelText: "Category (e.g. Generative AI, Computer Vision)", filled: true, fillColor: AdminTheme.darkBg),
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
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
                    child: Text(_isSaving ? "Saving..." : "Save Skill"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
