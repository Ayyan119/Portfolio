import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/portfolio_models.dart';
import '../../core/providers/admin_providers.dart';
import '../../core/theme/admin_theme.dart';

class AchievementsManager extends ConsumerStatefulWidget {
  const AchievementsManager({super.key});

  @override
  ConsumerState<AchievementsManager> createState() => _AchievementsManagerState();
}

class _AchievementsManagerState extends ConsumerState<AchievementsManager> {
  void _showDialog([AchievementModel? ach]) {
    showDialog(context: context, builder: (context) => _AchFormDialog(ach: ach));
  }

  void _confirmDelete(AchievementModel ach) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.cardBg,
        title: const Text("Confirm Deletion", style: TextStyle(color: AdminTheme.textPrimary)),
        content: Text("Delete '${ach.title}'?", style: const TextStyle(color: AdminTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(adminRepositoryProvider).deleteAchievement(ach.id);
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
    final achAsync = ref.watch(adminAchievementsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Achievements Management", style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                onPressed: () => _showDialog(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text("Add Achievement"),
                style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: AdminTheme.darkBg),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: achAsync.when(
              data: (achList) {
                if (achList.isEmpty) return const Center(child: Text("No achievements found.", style: TextStyle(color: AdminTheme.textMuted)));

                return ListView.separated(
                  itemCount: achList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ach = achList[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AdminTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminTheme.border)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ach.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textPrimary)),
                                Text("${ach.organization} • ${ach.date}", style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.edit_rounded, color: AdminTheme.primary), onPressed: () => _showDialog(ach)),
                          IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AdminTheme.danger), onPressed: () => _confirmDelete(ach)),
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

class _AchFormDialog extends ConsumerStatefulWidget {
  final AchievementModel? ach;
  const _AchFormDialog({this.ach});

  @override
  ConsumerState<_AchFormDialog> createState() => _AchFormDialogState();
}

class _AchFormDialogState extends ConsumerState<_AchFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _orgController;
  late TextEditingController _dateController;
  late TextEditingController _descController;
  late TextEditingController _orderController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.ach;
    _titleController = TextEditingController(text: a?.title ?? '');
    _orgController = TextEditingController(text: a?.organization ?? '');
    _dateController = TextEditingController(text: a?.date ?? '');
    _descController = TextEditingController(text: a?.description ?? '');
    _orderController = TextEditingController(text: (a?.displayOrder ?? 1).toString());
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final repo = ref.read(adminRepositoryProvider);
        final order = int.tryParse(_orderController.text) ?? 1;

        if (widget.ach == null) {
          final newAch = AchievementModel(
            id: '',
            title: _titleController.text.trim(),
            description: _descController.text.trim(),
            date: _dateController.text.trim(),
            organization: _orgController.text.trim(),
            imageUrl: '',
            displayOrder: order,
          );
          await repo.addAchievement(newAch);
        } else {
          final updated = AchievementModel(
            id: widget.ach!.id,
            title: _titleController.text.trim(),
            description: _descController.text.trim(),
            date: _dateController.text.trim(),
            organization: _orgController.text.trim(),
            imageUrl: widget.ach!.imageUrl,
            displayOrder: order,
          );
          await repo.updateAchievement(updated);
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
              Text(widget.ach == null ? "Add Achievement" : "Edit Achievement", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(controller: _titleController, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: "Title", filled: true, fillColor: AdminTheme.darkBg), validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 12),
              TextFormField(controller: _orgController, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: "Organization / Event", filled: true, fillColor: AdminTheme.darkBg)),
              const SizedBox(height: 12),
              TextFormField(controller: _dateController, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: "Date", filled: true, fillColor: AdminTheme.darkBg)),
              const SizedBox(height: 12),
              TextFormField(controller: _descController, maxLines: 3, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: "Description", filled: true, fillColor: AdminTheme.darkBg)),
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
