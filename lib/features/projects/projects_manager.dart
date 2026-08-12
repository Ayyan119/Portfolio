import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/models/portfolio_models.dart';
import '../../core/providers/admin_providers.dart';
import '../../core/theme/admin_theme.dart';

class ProjectsManager extends ConsumerStatefulWidget {
  const ProjectsManager({super.key});

  @override
  ConsumerState<ProjectsManager> createState() => _ProjectsManagerState();
}

class _ProjectsManagerState extends ConsumerState<ProjectsManager> {
  String _searchQuery = "";
  String _selectedCategory = "All";

  void _showProjectDialog([ProjectModel? project]) {
    showDialog(
      context: context,
      builder: (context) => _ProjectFormDialog(project: project),
    );
  }

  void _confirmDelete(ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.cardBg,
        title: const Text("Confirm Deletion", style: TextStyle(color: AdminTheme.textPrimary)),
        content: Text("Are you sure you want to delete '${project.title}'?", style: const TextStyle(color: AdminTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: AdminTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(adminRepositoryProvider).deleteProject(project.id);
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
    final projectsAsync = ref.watch(adminProjectsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Project Management", style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                onPressed: () => _showProjectDialog(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text("Add New Project"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.primary,
                  foregroundColor: AdminTheme.darkBg,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  decoration: const InputDecoration(
                    hintText: "Search projects by title or technology...",
                    prefixIcon: Icon(Icons.search_rounded, color: AdminTheme.textSecondary),
                    filled: true,
                    fillColor: AdminTheme.cardBg,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedCategory,
                dropdownColor: AdminTheme.cardBg,
                style: const TextStyle(color: AdminTheme.textPrimary),
                items: ["All", "GenAI & RAG", "Agentic AI", "LLMs", "Computer Vision", "Mobile"]
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: projectsAsync.when(
              data: (projectsList) {
                final filtered = projectsList.where((p) {
                  final matchesSearch = p.title.toLowerCase().contains(_searchQuery) ||
                      p.technologies.any((t) => t.toLowerCase().contains(_searchQuery));
                  final matchesCat = _selectedCategory == "All" || p.category == _selectedCategory;
                  return matchesSearch && matchesCat;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text("No projects found matching filter criteria.", style: TextStyle(color: AdminTheme.textMuted)),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final project = filtered[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AdminTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AdminTheme.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AdminTheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.folder_special_rounded, color: AdminTheme.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(project.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textPrimary)),
                                    if (project.featured) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text("Featured", style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(project.shortDescription, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                          Text("Order: ${project.displayOrder}", style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12)),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: AdminTheme.primary),
                            onPressed: () => _showProjectDialog(project),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AdminTheme.danger),
                            onPressed: () => _confirmDelete(project),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AdminTheme.primary)),
              error: (err, stack) => Text("Error loading projects: $err", style: const TextStyle(color: AdminTheme.danger)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectFormDialog extends ConsumerStatefulWidget {
  final ProjectModel? project;

  const _ProjectFormDialog({this.project});

  @override
  ConsumerState<_ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends ConsumerState<_ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _shortDescController;
  late TextEditingController _detailedDescController;
  late TextEditingController _techController;
  late TextEditingController _githubController;
  late TextEditingController _liveUrlController;
  late TextEditingController _displayOrderController;

  String _category = "GenAI & RAG";
  bool _featured = false;
  bool _isSaving = false;
  String _imageUrl = "";

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _titleController = TextEditingController(text: p?.title ?? '');
    _shortDescController = TextEditingController(text: p?.shortDescription ?? '');
    _detailedDescController = TextEditingController(text: p?.detailedDescription ?? '');
    _techController = TextEditingController(text: p?.technologies.join(', ') ?? '');
    _githubController = TextEditingController(text: p?.githubUrl ?? '');
    _liveUrlController = TextEditingController(text: p?.liveUrl ?? '');
    _displayOrderController = TextEditingController(text: (p?.displayOrder ?? 1).toString());
    _category = p?.category ?? "GenAI & RAG";
    _featured = p?.featured ?? false;
    _imageUrl = p?.imageUrl ?? '';
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        setState(() => _isSaving = true);
        try {
          final storageService = ref.read(storageServiceProvider);
          final url = await storageService.uploadFile(
            bytes: file.bytes!,
            path: 'portfolio/projects',
            fileName: '${DateTime.now().millisecondsSinceEpoch}_${file.name}',
          );
          setState(() => _imageUrl = url);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Image upload error: $e"), backgroundColor: AdminTheme.danger),
            );
          }
        } finally {
          if (mounted) setState(() => _isSaving = false);
        }
      }
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final repo = ref.read(adminRepositoryProvider);
        final techList = _techController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
        final order = int.tryParse(_displayOrderController.text) ?? 1;

        if (widget.project == null) {
          final newProject = ProjectModel(
            id: '',
            title: _titleController.text.trim(),
            shortDescription: _shortDescController.text.trim(),
            detailedDescription: _detailedDescController.text.trim(),
            technologies: techList,
            category: _category,
            imageUrl: _imageUrl,
            githubUrl: _githubController.text.trim(),
            liveUrl: _liveUrlController.text.trim(),
            featured: _featured,
            displayOrder: order,
            createdAt: DateTime.now(),
          );
          await repo.addProject(newProject);
        } else {
          final updated = ProjectModel(
            id: widget.project!.id,
            title: _titleController.text.trim(),
            shortDescription: _shortDescController.text.trim(),
            detailedDescription: _detailedDescController.text.trim(),
            technologies: techList,
            category: _category,
            imageUrl: _imageUrl,
            githubUrl: _githubController.text.trim(),
            liveUrl: _liveUrlController.text.trim(),
            featured: _featured,
            displayOrder: order,
            createdAt: widget.project!.createdAt,
          );
          await repo.updateProject(updated);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error saving project: $e"), backgroundColor: AdminTheme.danger),
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
        width: 600,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.project == null ? "Add New Project" : "Edit Project", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  decoration: const InputDecoration(labelText: "Project Title", filled: true, fillColor: AdminTheme.darkBg),
                  validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _shortDescController,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  decoration: const InputDecoration(labelText: "Short Tagline Description", filled: true, fillColor: AdminTheme.darkBg),
                  validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _detailedDescController,
                  maxLines: 3,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  decoration: const InputDecoration(labelText: "Detailed Description & Architecture", filled: true, fillColor: AdminTheme.darkBg),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _techController,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  decoration: const InputDecoration(labelText: "Technologies (comma-separated, e.g. LangChain, Gemini, FastAPI)", filled: true, fillColor: AdminTheme.darkBg),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _category,
                        dropdownColor: AdminTheme.cardBg,
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        decoration: const InputDecoration(labelText: "Category", filled: true, fillColor: AdminTheme.darkBg),
                        items: ["GenAI & RAG", "Agentic AI", "LLMs", "Computer Vision", "Mobile"]
                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (val) => setState(() => _category = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _displayOrderController,
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Display Order", filled: true, fillColor: AdminTheme.darkBg),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _githubController,
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        decoration: const InputDecoration(labelText: "GitHub Repository URL", filled: true, fillColor: AdminTheme.darkBg),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _liveUrlController,
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        decoration: const InputDecoration(labelText: "Live Demo URL", filled: true, fillColor: AdminTheme.darkBg),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Checkbox(
                      value: _featured,
                      activeColor: AdminTheme.primary,
                      onChanged: (val) => setState(() => _featured = val ?? false),
                    ),
                    const Text("Mark as Featured Project", style: TextStyle(color: AdminTheme.textPrimary)),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.upload_file_rounded, size: 16),
                      label: Text(_imageUrl.isEmpty ? "Upload Image" : "Change Image"),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel", style: TextStyle(color: AdminTheme.textMuted)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: AdminTheme.darkBg),
                      child: Text(_isSaving ? "Saving..." : "Save Project"),
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
