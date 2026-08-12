import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/portfolio_models.dart';
import '../../core/providers/admin_providers.dart';
import '../../core/theme/admin_theme.dart';

class CertsManager extends ConsumerStatefulWidget {
  const CertsManager({super.key});

  @override
  ConsumerState<CertsManager> createState() => _CertsManagerState();
}

class _CertsManagerState extends ConsumerState<CertsManager> {
  void _showDialog([CertificationModel? cert]) {
    showDialog(context: context, builder: (context) => _CertFormDialog(cert: cert));
  }

  void _confirmDelete(CertificationModel cert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.cardBg,
        title: const Text("Confirm Deletion", style: TextStyle(color: AdminTheme.textPrimary)),
        content: Text("Delete '${cert.name}'?", style: const TextStyle(color: AdminTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(adminRepositoryProvider).deleteCertification(cert.id);
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
    final certsAsync = ref.watch(adminCertificationsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Certifications Management", style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                onPressed: () => _showDialog(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text("Add Certification"),
                style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: AdminTheme.darkBg),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: certsAsync.when(
              data: (certs) {
                if (certs.isEmpty) return const Center(child: Text("No certifications found.", style: TextStyle(color: AdminTheme.textMuted)));

                return ListView.separated(
                  itemCount: certs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final cert = certs[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AdminTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminTheme.border)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cert.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textPrimary)),
                                Text("${cert.issuingOrganization} • ${cert.issueDate}", style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.edit_rounded, color: AdminTheme.primary), onPressed: () => _showDialog(cert)),
                          IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AdminTheme.danger), onPressed: () => _confirmDelete(cert)),
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

class _CertFormDialog extends ConsumerStatefulWidget {
  final CertificationModel? cert;
  const _CertFormDialog({this.cert});

  @override
  ConsumerState<_CertFormDialog> createState() => _CertFormDialogState();
}

class _CertFormDialogState extends ConsumerState<_CertFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _orgController;
  late TextEditingController _dateController;
  late TextEditingController _idController;
  late TextEditingController _urlController;
  late TextEditingController _orderController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.cert;
    _nameController = TextEditingController(text: c?.name ?? '');
    _orgController = TextEditingController(text: c?.issuingOrganization ?? '');
    _dateController = TextEditingController(text: c?.issueDate ?? '');
    _idController = TextEditingController(text: c?.credentialId ?? '');
    _urlController = TextEditingController(text: c?.credentialUrl ?? '');
    _orderController = TextEditingController(text: (c?.displayOrder ?? 1).toString());
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final repo = ref.read(adminRepositoryProvider);
        final order = int.tryParse(_orderController.text) ?? 1;

        if (widget.cert == null) {
          final newCert = CertificationModel(
            id: '',
            name: _nameController.text.trim(),
            issuingOrganization: _orgController.text.trim(),
            issueDate: _dateController.text.trim(),
            credentialId: _idController.text.trim(),
            credentialUrl: _urlController.text.trim(),
            imageUrl: '',
            displayOrder: order,
          );
          await repo.addCertification(newCert);
        } else {
          final updated = CertificationModel(
            id: widget.cert!.id,
            name: _nameController.text.trim(),
            issuingOrganization: _orgController.text.trim(),
            issueDate: _dateController.text.trim(),
            credentialId: _idController.text.trim(),
            credentialUrl: _urlController.text.trim(),
            imageUrl: widget.cert!.imageUrl,
            displayOrder: order,
          );
          await repo.updateCertification(updated);
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
              Text(widget.cert == null ? "Add Certification" : "Edit Certification", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(controller: _nameController, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: "Certification Name", filled: true, fillColor: AdminTheme.darkBg), validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 12),
              TextFormField(controller: _orgController, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: "Issuing Organization", filled: true, fillColor: AdminTheme.darkBg), validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _dateController, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: "Issue Date", filled: true, fillColor: AdminTheme.darkBg))),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _idController, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: "Credential ID", filled: true, fillColor: AdminTheme.darkBg))),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _urlController, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: "Credential Verification URL", filled: true, fillColor: AdminTheme.darkBg)),
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
