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

  bool? isAccepted=null;

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

  StudentClass get parentClass => StudentClass.currentClasses[_parentClassId]!;

  Assignment get parentAssignment {
    return Assignment.currentAssignments[_parentAssignmentId]!;
  }

  Future<RequestResponse> declineMod() {
    return _submitModResponse(false);
  }

  Future<RequestResponse> acceptMod() async {
    final response = await _submitModResponse(true);

    if (response.wasSuccessful() &&
        modType == ModType.due &&
        (parentAssignment.isCompleted ?? false))
      await parentAssignment.toggleComplete();

    return response;
  }

  Future<RequestResponse> _submitModResponse(bool withStatus) {
    return SKRequests.post(
      '/students/${SKUser.current!.student.id}/mods/${id}',
      {'is_accepted': withStatus},
      Assignment._fromJsonObj,
    );
  }

  //--------------//
  //Static members//
  //--------------//

  static Map<int, Mod> currentMods = {};
  static Map<int, List<Mod>> modsByAssignmentId = {};

  static Mod? _fromJsonObj(Map content) {
    if (content == null) {
      return null;
    }

    ModType? modType;
    dynamic data;

    if (content['mod_type'] != null && content['data'] != null) {
      switch (content['mod_type']) {
        case 'Name':
          modType = ModType.name;
          data = content['data']['name'];
          break;
        case 'Weight Category':
          modType = ModType.weight;

          final weightId = content['data']['weight_id'];
          final parentClass =
              StudentClass.currentClasses[content['class']['id']];

          for (final weight in parentClass!.weights!) {
            if (weight.id == weightId) {
              data = weight;
            }
          }
          break;
        case 'Due Date':
          modType = ModType.due;
          data = _dateParser(content['data']['due']);
          break;
        case 'New Assignment':
          modType = ModType.newAssignment;
          data = Assignment._fromJsonObj(
            content['data']['assignment'],
            shouldPersist: false,
          );
          (data as Assignment).configureDateTimeOffset();
          break;
        case 'Delete Assignment':
          modType = ModType.delete;
          break;
        default:
          break;
      }
    }

    final mod = Mod(
      content['id'],
      content['student_assignment_id'],
      content['class']['id'],
      content['students_accepted_count'],
      content['short_msg'],
      _dateParser(content['mod_created_at'])!,
      modType!,
      content['is_accepted'],
      data,
    );

    currentMods[mod.id] = mod;

    if (mod._parentAssignmentId != null && mod.isAccepted == null) {
      if (modsByAssignmentId.containsKey(mod._parentAssignmentId))
        modsByAssignmentId[mod._parentAssignmentId]!.add(mod);
      else
        modsByAssignmentId[mod._parentAssignmentId] = [mod];
    }

    return mod;
  }

  static Future<RequestResponse> fetchMods() {
    return SKRequests.get(
        '/students/${SKUser.current!.student.id}/mods/', Mod._fromJsonObj,
        postRequestAction: () {
      modsByAssignmentId = {};
      currentMods = {};
    });
  }

  static Future<RequestResponse> fetchNewAssignmentMods() {
    return SKRequests.get(
      '/students/${SKUser.current!.student.id}/mods?is_new_assignments=true',
      Mod._fromJsonObj,
    ).then((response) {
      if (response.wasSuccessful()) {
        for (final Mod mod in response.obj) {
          currentMods[mod.id] = mod;
        }
      }
      return response;
    });
  }
}
