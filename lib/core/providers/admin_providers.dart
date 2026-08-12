import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/portfolio_models.dart';
import '../repositories/admin_repository.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final adminProfileProvider = StreamProvider<ProfileModel>((ref) {
  return ref.watch(adminRepositoryProvider).watchProfile();
});

final adminProjectsProvider = StreamProvider<List<ProjectModel>>((ref) {
  return ref.watch(adminRepositoryProvider).watchProjects();
});

final adminSkillsProvider = StreamProvider<List<SkillModel>>((ref) {
  return ref.watch(adminRepositoryProvider).watchSkills();
});

final adminExperienceProvider = StreamProvider<List<ExperienceModel>>((ref) {
  return ref.watch(adminRepositoryProvider).watchExperiences();
});

final adminEducationProvider = StreamProvider<List<EducationModel>>((ref) {
  return ref.watch(adminRepositoryProvider).watchEducation();
});

final adminCertificationsProvider = StreamProvider<List<CertificationModel>>((ref) {
  return ref.watch(adminRepositoryProvider).watchCertifications();
});

final adminAchievementsProvider = StreamProvider<List<AchievementModel>>((ref) {
  return ref.watch(adminRepositoryProvider).watchAchievements();
});
