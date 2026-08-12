import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/portfolio_models.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Profile CRUD
  Stream<ProfileModel> watchProfile() {
    return _firestore.collection('profile').doc('main').snapshots().map((doc) {
      if (!doc.exists) {
        return const ProfileModel(
          id: 'main',
          name: 'Ayyan Shahid',
          title: 'AI Engineer',
          headline: 'Building intelligent systems with Computer Vision, Deep Learning, Generative AI and Agentic AI.',
          shortBio: 'AI Engineer with ~3 years of experience specializing in Generative AI, RAG, and Computer Vision.',
          longBio: 'Designs multi-agent pipelines with LangGraph and MCP, builds RAG systems over vector databases, and ships end-to-end services.',
          location: 'Lahore, Pakistan',
          email: 'ayyanshahid640@gmail.com',
          profileImageUrl: '',
          resumeUrl: '',
        );
      }
      return ProfileModel.fromFirestore(doc);
    });
  }

  Future<void> updateProfile(ProfileModel profile) async {
    await _firestore
        .collection('profile')
        .doc('main')
        .set(profile.toFirestore(), SetOptions(merge: true))
        .timeout(const Duration(seconds: 5));
  }

  // Projects CRUD
  Stream<List<ProjectModel>> watchProjects() {
    return _firestore.collection('projects').orderBy('displayOrder').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProjectModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addProject(ProjectModel project) async {
    await _firestore
        .collection('projects')
        .add(project.toFirestore())
        .timeout(const Duration(seconds: 5));
  }

  Future<void> updateProject(ProjectModel project) async {
    await _firestore
        .collection('projects')
        .doc(project.id)
        .update(project.toFirestore())
        .timeout(const Duration(seconds: 5));
  }

  Future<void> deleteProject(String id) async {
    await _firestore
        .collection('projects')
        .doc(id)
        .delete()
        .timeout(const Duration(seconds: 5));
  }

  // Skills CRUD
  Stream<List<SkillModel>> watchSkills() {
    return _firestore.collection('skills').orderBy('displayOrder').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SkillModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addSkill(SkillModel skill) async {
    await _firestore
        .collection('skills')
        .add(skill.toFirestore())
        .timeout(const Duration(seconds: 5));
  }

  Future<void> updateSkill(SkillModel skill) async {
    await _firestore
        .collection('skills')
        .doc(skill.id)
        .update(skill.toFirestore())
        .timeout(const Duration(seconds: 5));
  }

  Future<void> deleteSkill(String id) async {
    await _firestore
        .collection('skills')
        .doc(id)
        .delete()
        .timeout(const Duration(seconds: 5));
  }

  // Experience CRUD
  Stream<List<ExperienceModel>> watchExperiences() {
    return _firestore.collection('experience').orderBy('displayOrder').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ExperienceModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addExperience(ExperienceModel exp) async {
    await _firestore
        .collection('experience')
        .add(exp.toFirestore())
        .timeout(const Duration(seconds: 5));
  }

  Future<void> updateExperience(ExperienceModel exp) async {
    await _firestore
        .collection('experience')
        .doc(exp.id)
        .update(exp.toFirestore())
        .timeout(const Duration(seconds: 5));
  }

  Future<void> deleteExperience(String id) async {
    await _firestore
        .collection('experience')
        .doc(id)
        .delete()
        .timeout(const Duration(seconds: 5));
  }

  // Education CRUD
  Stream<List<EducationModel>> watchEducation() {
    return _firestore.collection('education').orderBy('displayOrder').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => EducationModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addEducation(EducationModel edu) async {
    await _firestore
        .collection('education')
        .add(edu.toFirestore())
        .timeout(const Duration(seconds: 5));
  }

  Future<void> updateEducation(EducationModel edu) async {
    await _firestore
        .collection('education')
        .doc(edu.id)
        .update(edu.toFirestore())
        .timeout(const Duration(seconds: 5));
  }

  Future<void> deleteEducation(String id) async {
    await _firestore
        .collection('education')
        .doc(id)
        .delete()
        .timeout(const Duration(seconds: 5));
  }

  // Certifications CRUD
  Stream<List<CertificationModel>> watchCertifications() {
    return _firestore.collection('certifications').orderBy('displayOrder').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CertificationModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addCertification(CertificationModel cert) async {
    await _firestore
        .collection('certifications')
        .add(cert.toFirestore())
        .timeout(const Duration(seconds: 5));
  }

  Future<void> updateCertification(CertificationModel cert) async {
    await _firestore
        .collection('certifications')
        .doc(cert.id)
        .update(cert.toFirestore())
        .timeout(const Duration(seconds: 5));
  }

  Future<void> deleteCertification(String id) async {
    await _firestore
        .collection('certifications')
        .doc(id)
        .delete()
        .timeout(const Duration(seconds: 5));
  }

  // Achievements CRUD
  Stream<List<AchievementModel>> watchAchievements() {
    return _firestore.collection('achievements').orderBy('displayOrder').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AchievementModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addAchievement(AchievementModel ach) async {
    await _firestore
        .collection('achievements')
        .add(ach.toFirestore())
        .timeout(const Duration(seconds: 5));
  }

  Future<void> updateAchievement(AchievementModel ach) async {
    await _firestore
        .collection('achievements')
        .doc(ach.id)
        .update(ach.toFirestore())
        .timeout(const Duration(seconds: 5));
  }

  Future<void> deleteAchievement(String id) async {
    await _firestore
        .collection('achievements')
        .doc(id)
        .delete()
        .timeout(const Duration(seconds: 5));
  }
}
