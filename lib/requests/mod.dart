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

  static Mod _fromJsonObj(Map content) {
    DateTime createdOn = content['mod_created_at'] == null
        ? null
        : DateTime.parse(content['mod_created_at']);

    StudentClass studentClass = StudentClass._fromJsonObj(content['class']);

    ModType modType;
    dynamic data;

    if (content['mod_type'] != null) {
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
      studentClass.id,
      content['students_accepted_count'],
      content['short_msg'],
      createdOn,
      modType,
      content['is_accepted'],
      data,
    );
  }
}
