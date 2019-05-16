part of 'requests_core.dart';

enum ModType { name, weight, due, newAssignment, delete }

class Mod {
  int id;
  int acceptedCount;
  int _parentAssignmentId;
  int _parentClassId;

  String shortMsg;
  DateTime createdOn;

  ModType modType;

  bool isAccepted;

  /**
   * Different data type depending on [ModType].
   * 
   * name: String
   * weight: int
   * due: DateTime
   * newAssignment: Assignment
   * delete: null
   */
  dynamic data;

  Mod(
    this.id,
    this._parentAssignmentId,
    this._parentClassId,
    this.acceptedCount,
    this.shortMsg,
    this.createdOn,
    this.modType,
    this.isAccepted,
    this.data,
  );

  StudentClass get parentClass => StudentClass.currentClasses[_parentClassId];

  Assignment get parentAssigment =>
      Assignment.currentAssignments[_parentAssignmentId];

  Future<RequestResponse> declineMod() {
    return _submitModResponse(false);
  }

  Future<RequestResponse> acceptMod() {
    return _submitModResponse(true);
  }

  Future<RequestResponse> _submitModResponse(bool withStatus) {
    return SKRequests.post(
      '/students/${SKUser.current.student.id}/mods/${id}',
      {'is_accepted': withStatus},
      Assignment._fromJsonObj,
    );
  }

  //--------------//
  //Static members//
  //--------------//

  static List<Mod> currentMods = [];

  static Mod _fromJsonObj(Map content) {
    if (content == null) {
      return null;
    }

    DateTime createdOn = content['mod_created_at'] == null
        ? null
        : DateTime.parse(content['mod_created_at']);

    ModType modType;
    dynamic data;

    if (content['mod_type'] != null && content['data'] != null) {
      switch (content['mod_type']) {
        case 'Name':
          modType = ModType.name;
          data = content['data']['name'];
          break;
        case 'Weight Category':
          modType = ModType.weight;
          data = content['data']['weight_id'];
          break;
        case 'Due Date':
          modType = ModType.due;
          data = DateTime.parse(content['data']['due']);
          break;
        case 'New Assignment':
          modType = ModType.newAssignment;
          data = Assignment._fromJsonObj(content['data']['assignment']);
          break;
        case 'Delete Assignment':
          modType = ModType.delete;
          break;
        default:
          break;
      }
    }

    return Mod(
      content['id'],
      content['student_assignment_id'],
      content['class']['id'],
      content['students_accepted_count'],
      content['short_msg'],
      createdOn,
      modType,
      content['is_accepted'],
      data,
    );
  }

  static Future<RequestResponse> fetchMods() {
    return SKRequests.get(
      '/students/${SKUser.current.student.id}/mods/',
      Mod._fromJsonObj,
    ).then((response) {
      if (response.wasSuccessful()) {
        currentMods = response.obj;
      }
      return response;
    });
  }
}
