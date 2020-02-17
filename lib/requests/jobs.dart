part of 'requests_core.dart';

class JobProfile {
  int id;
  int act_score;
  int sat_score;
  int startup_interest;

  num gpa;
  num profile_score;

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

  Map<String, dynamic> social_links;
  Map<String, dynamic> update_at_timestamps;
  Map<String, dynamic> personality;
  Map<String, dynamic> company_values;

  JobProfile(
    this.id,
    this.act_score,
    this.sat_score,
    this.startup_interest,
    this.gpa,
    this.profile_score,
    this.veteran,
    this.disability,
    this.first_gen_college,
    this.fin_aid,
    this.pell_grant,
    this.work_auth,
    this.sponsorship_required,
    this.played_sports,
    this.alt_email,
    this.state_code,
    this.regions,
    this.short_sell,
    this.career_interests,
    this.skills,
    this.gender,
    this.transcript_url,
    this.resume_url,
    this.degree_type,
    this.job_search_type,
    this.ethnicity_type,
    this.job_profile_status,
    this.wakeup_date,
    this.graduation_date,
    this.volunteer_activities,
    this.club_activities,
    this.achievement_activities,
    this.experience_activities,
    this.social_links,
    this.update_at_timestamps,
    this.personality,
    this.company_values,
  );

  Future<RequestResponse> updateProfileWithParameters(
          Map<String, dynamic> parameters) =>
      SKRequests.put('/skoller-jobs/profiles/$id', parameters, _fromJsonObj);

  Future<RequestResponse> updateProfile({
    TypeObject jobSearchType,
    DateTime gradDate,
    bool workAuth,
    bool sponsorshipRequired,
    TypeObject jobProfileStatus,
    String stateCode,
    double gpa,
    String regions,
  }) {
    final body = {
      'job_search_type_id': jobSearchType?.id,
      'graduation_date': gradDate?.toIso8601String(),
      'work_auth': workAuth,
      'sponsorship_required': sponsorshipRequired,
      'job_profile_status_id': jobProfileStatus?.id,
      'state_code': stateCode,
      'gpa': gpa,
      'regions': regions,
    };
    body.removeWhere((_, value) => value == null);

    return updateProfileWithParameters(body);
  }

  static JobProfile currentProfile;

  static JobProfile _fromJsonObj(Map content) {
    // Types
    final degreeType = content['degree_type'] == null
        ? null
        : TypeObject._fromJsonObj(content['degree_type']);

    final jobSearchType = content['job_search_type'] == null
        ? null
        : TypeObject._fromJsonObj(content['job_search_type']);

    final ethnicityType = content['ethnicity_type'] == null
        ? null
        : TypeObject._fromJsonObj(content['ethnicity_type']);

    final jobProfileStatus = content['job_profile_status'] == null
        ? null
        : TypeObject._fromJsonObj(content['job_profile_status']);

    final profile = JobProfile(
      content['id'],
      content['act_score'],
      content['sat_score'],
      content['startup_interest'],
      content['gpa'],
      content['profile_score'],
      content['veteran'],
      content['disability'],
      content['first_gen_college'],
      content['fin_aid'],
      content['pell_grant'],
      content['work_auth'],
      content['sponsorship_required'],
      content['played_sports'],
      content['alt_email'],
      content['state_code'],
      content['regions'],
      content['short_sell'],
      content['career_interests'],
      content['skills'],
      content['gender'],
      content['transcript_url'],
      content['resume_url'],
      degreeType,
      jobSearchType,
      ethnicityType,
      jobProfileStatus,
      _dateParser(content['wakeup_date']),
      _dateParser(content['graduation_date']),
      JsonListMaker.convert(
        Activity._fromJsonObj,
        content['volunteer_activities'] ?? [],
      ),
      JsonListMaker.convert(
        Activity._fromJsonObj,
        content['club_activities'] ?? [],
      ),
      JsonListMaker.convert(
        Activity._fromJsonObj,
        content['achievement_activities'] ?? [],
      ),
      JsonListMaker.convert(
        Activity._fromJsonObj,
        content['experience_activities'] ?? [],
      ),
      content['social_links'],
      content['update_at_timestamps'],
      content['personality'],
      content['company_values'],
    );

    currentProfile = profile;

    return profile;
  }

  static Future<RequestResponse> createProfile(
          {DateTime graduationDate, TypeObject jobType}) =>
      SKRequests.post(
        '/skoller-jobs/profiles',
        {
          'graduation_date': graduationDate.toIso8601String(),
          'job_search_type_id': jobType.id
        },
        JobProfile._fromJsonObj,
      );
}

class Activity {
  Activity();

  static Activity _fromJsonObj(Map content) => Activity();
}
