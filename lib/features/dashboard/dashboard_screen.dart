import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/admin_providers.dart';
import '../../core/theme/admin_theme.dart';
import '../profile/profile_manager.dart';
import '../projects/projects_manager.dart';
import '../skills/skills_manager.dart';
import '../experience/experience_manager.dart';
import '../education/education_manager.dart';
import '../certifications/certs_manager.dart';
import '../achievements/achievements_manager.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _menuTitles = [
    "Overview",
    "Profile",
    "Projects",
    "Skills",
    "Experience",
    "Education",
    "Certifications",
    "Achievements",
  ];

  final List<IconData> _menuIcons = [
    Icons.dashboard_rounded,
    Icons.person_rounded,
    Icons.folder_special_rounded,
    Icons.psychology_rounded,
    Icons.work_rounded,
    Icons.school_rounded,
    Icons.verified_user_rounded,
    Icons.emoji_events_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(_menuTitles[_selectedIndex]),
              backgroundColor: AdminTheme.sidebarBg,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AdminTheme.danger),
                  onPressed: () => ref.read(authServiceProvider).signOut(),
                ),
              ],
            ),
      drawer: isDesktop ? null : _buildDrawer(),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Container(
              color: AdminTheme.darkBg,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Material(
      color: AdminTheme.sidebarBg,
      child: SizedBox(
        width: 250,
        child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AdminTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded, color: AdminTheme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Portfolio CMS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textPrimary)),
                    Text("Admin Panel", style: TextStyle(fontSize: 12, color: AdminTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: AdminTheme.border, height: 1),

          Expanded(
            child: ListView.builder(
              itemCount: _menuTitles.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: Icon(_menuIcons[index], color: isSelected ? AdminTheme.primary : AdminTheme.textSecondary),
                    title: Text(
                      _menuTitles[index],
                      style: TextStyle(
                        color: isSelected ? AdminTheme.primary : AdminTheme.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: AdminTheme.primary.withValues(alpha: 0.1),
                    onTap: () => setState(() => _selectedIndex = index),
                  ),
                );
              },
            ),
          ),

          const Divider(color: AdminTheme.border, height: 1),
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AdminTheme.danger),
              title: const Text("Sign Out", style: TextStyle(color: AdminTheme.danger, fontWeight: FontWeight.bold)),
              onTap: () => ref.read(authServiceProvider).signOut(),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AdminTheme.sidebarBg,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: const Row(
                children: [
                  Icon(Icons.admin_panel_settings_rounded, color: AdminTheme.primary, size: 28),
                  SizedBox(width: 12),
                  Text("Portfolio CMS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AdminTheme.textPrimary)),
                ],
              ),
            ),
            const Divider(color: AdminTheme.border),
            Expanded(
              child: ListView.builder(
                itemCount: _menuTitles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(_menuIcons[index], color: AdminTheme.primary),
                    title: Text(_menuTitles[index], style: const TextStyle(color: AdminTheme.textPrimary)),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _selectedIndex = index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewPanel();
      case 1:
        return const ProfileManager();
      case 2:
        return const ProjectsManager();
      case 3:
        return const SkillsManager();
      case 4:
        return const ExperienceManager();
      case 5:
        return const EducationManager();
      case 6:
        return const CertsManager();
      case 7:
        return const AchievementsManager();
      default:
        return _buildOverviewPanel();
    }
  }

  Widget _buildOverviewPanel() {
    final projectsAsync = ref.watch(adminProjectsProvider);
    final skillsAsync = ref.watch(adminSkillsProvider);
    final expAsync = ref.watch(adminExperienceProvider);
    final certsAsync = ref.watch(adminCertificationsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Dashboard Overview", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text("Manage your personal portfolio content dynamically synced to Firebase Cloud Firestore.", style: TextStyle(color: AdminTheme.textSecondary)),
          const SizedBox(height: 32),

          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width > 900 ? 4 : width > 600 ? 2 : 1;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _statCard(
                    title: "Total Projects",
                    value: projectsAsync.when(data: (l) => l.length.toString(), loading: () => '...', error: (err, st) => '0'),
                    icon: Icons.folder_special_rounded,
                    color: AdminTheme.primary,
                  ),
                  _statCard(
                    title: "Work Experience",
                    value: expAsync.when(data: (l) => l.length.toString(), loading: () => '...', error: (err, st) => '0'),
                    icon: Icons.work_rounded,
                    color: AdminTheme.success,
                  ),
                  _statCard(
                    title: "Technical Skills",
                    value: skillsAsync.when(data: (l) => l.length.toString(), loading: () => '...', error: (err, st) => '0'),
                    icon: Icons.psychology_rounded,
                    color: AdminTheme.secondary,
                  ),
                  _statCard(
                    title: "Certifications",
                    value: certsAsync.when(data: (l) => l.length.toString(), loading: () => '...', error: (err, st) => '0'),
                    icon: Icons.verified_user_rounded,
                    color: Colors.amber,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 24),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
