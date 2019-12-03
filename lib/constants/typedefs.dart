part of 'constants.dart';

/// Callback that presents a view
typedef void PresentationCallback(Widget widget);

typedef ContextCallback(BuildContext context);

typedef DateTime DateFetch();
typedef void DateCallback(DateTime date) ;
typedef Future<void> DateContextCallback(DateTime date, BuildContext context) ;

typedef void ColorCallback(Color color);

typedef void AppStateCallback(AppState newValue);

typedef void IntCallback(int index);

typedef void ProfessorCallback(Professor professor);

typedef dynamic DynamicCallback();

typedef void StringCallback(String string);

typedef void DoubleStringCallback(String str1, String str2);

typedef List<Assignment> AssignmentsForDateCallback(DateTime time);
typedef void AssignmentCallback(Assignment assignment);
