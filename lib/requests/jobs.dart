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

  Map<String, String> social_links;
  Map<String, String> update_at_timestamps;
  Map<String, String> personality;
  Map<String, int> company_values;

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

  static JobProfile currentProfile;

  static JobProfile _fromJsonObj(Map content) {
    // Dates
    final wakeupDate = content['wakeup_date'] == null
        ? null
        : DateTime.parse(content['wakeup_date']);

    final graduationDate = content['graduation_date'] == null
        ? null
        : DateTime.parse(content['graduation_date']);

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
      wakeupDate,
      graduationDate,
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
      ).then((response) {
        if (response.wasSuccessful()) {
          JobProfile.currentProfile = response.obj;
        }

        return response;
      });
}

class Activity {
  Activity();

  static Activity _fromJsonObj(Map content) => Activity();
}
