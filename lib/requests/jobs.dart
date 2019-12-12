part of 'requests_core.dart';

class JobProfile {
  int id;
  int act_score;
  int sat_score;
  int startup_interest;

  num gpa;

  bool veteran;
  bool disability;
  bool first_gen_college;
  bool fin_aid;
  bool pell_grant;
  bool work_auth;
  bool sponsorship_required;
  bool played_sports;

  String alt_email;
  String state_code;
  String regions;
  String short_sell;
  String career_interests;
  String skills;
  String gender;
  String transcript_url;
  String resume_url;

  TypeObject degree_type;
  TypeObject job_search_type;
  TypeObject ethnicity_type;
  TypeObject job_profile_status;

  DateTime wakeup_date;
  DateTime graduation_date;

  List<Activity> volunteer_activities;
  List<Activity> club_activities;
  List<Activity> achievement_activities;
  List<Activity> experience_activities;

  Map<String, String> social_links;
  Map<String, String> update_at_timestamps;
  Map<String, String> personality;
  Map<String, int> company_values;

  JobProfile(
    this.id,
// this.act_score,
// this.sat_score,
// this.startup_interest,
// this.gpa,
// this.veteran,
// this.disability,
// this.first_gen_college,
// this.fin_aid,
// this.pell_grant,
// this.work_auth,
// this.sponsorship_required,
// this.played_sports,
// this.alt_email,
// this.state_code,
// this.regions,
// this.short_sell,
// this.career_interests,
// this.skills,
// this.gender,
// this.transcript_url,
// this.resume_url,
// this.degree_type,
// this.job_search_type,
// this.ethnicity_type,
// this.job_profile_status,
// this.wakeup_date,
// this.graduation_date,
// this.volunteer_activities,
// this.club_activities,
// this.achievement_activities,
// this.experience_activities,
// this.social_links,
// this.update_at_timestamps,
// this.personality,
// this.company_values,
  );

  static JobProfile currentProfile;

  static JobProfile _fromJsonObj(Map content) {
    final profile = JobProfile(content['id']);

    currentProfile = profile;

    return profile;
  }
}

class Activity {}
