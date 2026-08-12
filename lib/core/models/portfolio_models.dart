import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String id;
  final String name;
  final String title;
  final String headline;
  final String shortBio;
  final String longBio;
  final String location;
  final String email;
  final String profileImageUrl;
  final String resumeUrl;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.title,
    required this.headline,
    required this.shortBio,
    required this.longBio,
    required this.location,
    required this.email,
    required this.profileImageUrl,
    required this.resumeUrl,
  });

  factory ProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return ProfileModel(
      id: doc.id,
      name: data['name'] ?? 'Ayyan Shahid',
      title: data['title'] ?? 'AI Engineer',
      headline: data['headline'] ?? 'Building intelligent systems with Computer Vision, Deep Learning, Generative AI and Agentic AI.',
      shortBio: data['shortBio'] ?? 'AI Engineer with ~3 years of experience specializing in Generative AI, RAG, and Computer Vision.',
      longBio: data['longBio'] ?? 'Passionate AI Engineer delivering production AI services, agentic pipelines with LangGraph, and full-stack Flutter applications.',
      location: data['location'] ?? 'Lahore, Pakistan',
      email: data['email'] ?? 'ayyanshahid640@gmail.com',
      profileImageUrl: data['profileImageUrl'] ?? '',
      resumeUrl: data['resumeUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'title': title,
      'headline': headline,
      'shortBio': shortBio,
      'longBio': longBio,
      'location': location,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'resumeUrl': resumeUrl,
    };
  }
}

class ProjectModel {
  final String id;
  final String title;
  final String shortDescription;
  final String detailedDescription;
  final List<String> technologies;
  final String category;
  final String imageUrl;
  final String githubUrl;
  final String liveUrl;
  final bool featured;
  final int displayOrder;
  final DateTime? createdAt;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.detailedDescription,
    required this.technologies,
    required this.category,
    required this.imageUrl,
    required this.githubUrl,
    required this.liveUrl,
    required this.featured,
    required this.displayOrder,
    this.createdAt,
  });

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return ProjectModel(
      id: doc.id,
      title: data['title'] ?? '',
      shortDescription: data['shortDescription'] ?? '',
      detailedDescription: data['detailedDescription'] ?? '',
      technologies: List<String>.from(data['technologies'] ?? []),
      category: data['category'] ?? 'GenAI & RAG',
      imageUrl: data['imageUrl'] ?? '',
      githubUrl: data['githubUrl'] ?? '',
      liveUrl: data['liveUrl'] ?? '',
      featured: data['featured'] ?? false,
      displayOrder: data['displayOrder'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'shortDescription': shortDescription,
      'detailedDescription': detailedDescription,
      'technologies': technologies,
      'category': category,
      'imageUrl': imageUrl,
      'githubUrl': githubUrl,
      'liveUrl': liveUrl,
      'featured': featured,
      'displayOrder': displayOrder,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}

class SkillModel {
  final String id;
  final String name;
  final String category;
  final String icon;
  final double proficiency;
  final int displayOrder;

  const SkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.proficiency,
    required this.displayOrder,
  });

  factory SkillModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return SkillModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'Generative AI',
      icon: data['icon'] ?? 'psychology',
      proficiency: (data['proficiency'] as num?)?.toDouble() ?? 0.9,
      displayOrder: data['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'icon': icon,
      'proficiency': proficiency,
      'displayOrder': displayOrder,
    };
  }
}

class ExperienceModel {
  final String id;
  final String company;
  final String position;
  final String location;
  final String employmentType;
  final String startDate;
  final String endDate;
  final bool current;
  final String description;
  final List<String> responsibilities;
  final List<String> technologies;
  final int displayOrder;

  const ExperienceModel({
    required this.id,
    required this.company,
    required this.position,
    required this.location,
    required this.employmentType,
    required this.startDate,
    required this.endDate,
    required this.current,
    required this.description,
    required this.responsibilities,
    required this.technologies,
    required this.displayOrder,
  });

  factory ExperienceModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return ExperienceModel(
      id: doc.id,
      company: data['company'] ?? '',
      position: data['position'] ?? '',
      location: data['location'] ?? '',
      employmentType: data['employmentType'] ?? 'Full-time',
      startDate: data['startDate'] ?? '',
      endDate: data['endDate'] ?? '',
      current: data['current'] ?? false,
      description: data['description'] ?? '',
      responsibilities: List<String>.from(data['responsibilities'] ?? []),
      technologies: List<String>.from(data['technologies'] ?? []),
      displayOrder: data['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'company': company,
      'position': position,
      'location': location,
      'employmentType': employmentType,
      'startDate': startDate,
      'endDate': endDate,
      'current': current,
      'description': description,
      'responsibilities': responsibilities,
      'technologies': technologies,
      'displayOrder': displayOrder,
    };
  }
}

class EducationModel {
  final String id;
  final String institution;
  final String degree;
  final String field;
  final String startDate;
  final String endDate;
  final String grade;
  final String description;
  final int displayOrder;

  const EducationModel({
    required this.id,
    required this.institution,
    required this.degree,
    required this.field,
    required this.startDate,
    required this.endDate,
    required this.grade,
    required this.description,
    required this.displayOrder,
  });

  factory EducationModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return EducationModel(
      id: doc.id,
      institution: data['institution'] ?? '',
      degree: data['degree'] ?? '',
      field: data['field'] ?? '',
      startDate: data['startDate'] ?? '',
      endDate: data['endDate'] ?? '',
      grade: data['grade'] ?? '',
      description: data['description'] ?? '',
      displayOrder: data['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'institution': institution,
      'degree': degree,
      'field': field,
      'startDate': startDate,
      'endDate': endDate,
      'grade': grade,
      'description': description,
      'displayOrder': displayOrder,
    };
  }
}

class CertificationModel {
  final String id;
  final String name;
  final String issuingOrganization;
  final String issueDate;
  final String credentialId;
  final String credentialUrl;
  final String imageUrl;
  final int displayOrder;

  const CertificationModel({
    required this.id,
    required this.name,
    required this.issuingOrganization,
    required this.issueDate,
    required this.credentialId,
    required this.credentialUrl,
    required this.imageUrl,
    required this.displayOrder,
  });

  factory CertificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return CertificationModel(
      id: doc.id,
      name: data['name'] ?? '',
      issuingOrganization: data['issuingOrganization'] ?? '',
      issueDate: data['issueDate'] ?? '',
      credentialId: data['credentialId'] ?? '',
      credentialUrl: data['credentialUrl'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      displayOrder: data['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'issuingOrganization': issuingOrganization,
      'issueDate': issueDate,
      'credentialId': credentialId,
      'credentialUrl': credentialUrl,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
    };
  }
}

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String date;
  final String organization;
  final String imageUrl;
  final int displayOrder;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.organization,
    required this.imageUrl,
    required this.displayOrder,
  });

  factory AchievementModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return AchievementModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: data['date'] ?? '',
      organization: data['organization'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      displayOrder: data['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'organization': organization,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
    };
  }
}

class SocialLinkModel {
  final String id;
  final String platform;
  final String url;
  final String icon;
  final int displayOrder;

  const SocialLinkModel({
    required this.id,
    required this.platform,
    required this.url,
    required this.icon,
    required this.displayOrder,
  });

  factory SocialLinkModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return SocialLinkModel(
      id: doc.id,
      platform: data['platform'] ?? '',
      url: data['url'] ?? '',
      icon: data['icon'] ?? 'link',
      displayOrder: data['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'platform': platform,
      'url': url,
      'icon': icon,
      'displayOrder': displayOrder,
    };
  }
}
