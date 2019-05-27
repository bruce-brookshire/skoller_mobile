part of 'requests_core.dart';

class Chat {
  int id;
  String post;
  bool isStarred;
  bool isLiked;
  int classId; //TODO this is nested content['class']['id']
  DateTime postDate;
  PublicStudent student;

  List<Like> likes;
  List<Comment> comments;

  Chat(
    this.id,
    this.post,
    this.isStarred,
    this.isLiked,
    this.classId,
    this.postDate,
    this.student,
    this.likes,
    this.comments,
  );

  StudentClass get parentClass => StudentClass.currentClasses[classId ?? 0];

  static Chat _fromJsonObj(Map content) => Chat(
        content['id'],
        content['post'],
        content['is_starred'],
        content['is_liked'],
        content['class']['id'],
        DateTime.parse(content['inserted_at']),
        PublicStudent._fromJsonObj(content['student']),
        JsonListMaker.convert(Like._fromJsonObj, content['likes'] ?? []),
        JsonListMaker.convert(Comment._fromJsonObj, content['comment'] ?? []),
      );

  static Future<RequestResponse> getStudentChats() {
    return SKRequests.get(
      '/students/${SKUser.current.student.id}/chat?sort=200',
      Chat._fromJsonObj,
    );
  }
}

class Comment {
  int id;
  List<Reply> replies;
  PublicStudent student;
  String comment;
  DateTime insertedAt;
  bool isLiked;
  bool isStarred;
  List<Like> likes;

  Comment(
    this.id,
    this.replies,
    this.student,
    this.comment,
    this.insertedAt,
    this.isLiked,
    this.isStarred,
    this.likes,
  );

  static Comment _fromJsonObj(Map content) => Comment(
        content['id'],
        JsonListMaker.convert(Reply._fromJsonObj, content['replies'] ?? []),
        PublicStudent._fromJsonObj(content['student']),
        content['comment'],
        DateTime.parse(content['inserted_at']),
        content['is_liked'],
        content['is_starred'],
        JsonListMaker.convert(Like._fromJsonObj, content['likes'] ?? []),
      );
}

class Reply {
  int id;
  PublicStudent student;
  String reply;
  DateTime insertedAt;
  bool isLiked;
  List<Like> likes;

  Reply(
    this.id,
    this.student,
    this.reply,
    this.insertedAt,
    this.isLiked,
    this.likes,
  );

  static Reply _fromJsonObj(Map content) => Reply(
        content['id'],
        PublicStudent._fromJsonObj(content['student']),
        content['reply'],
        DateTime.parse(content['inserted_at']),
        content['is_liked'],
        JsonListMaker.convert(Like._fromJsonObj, content['likes'] ?? []),
      );
}

class Like {
  int id;
  int studentId;

  Like(this.id, this.studentId);

  static Like _fromJsonObj(Map content) => Like(
        content['id'],
        content['student_id'],
      );
}

class InboxNotification {
  InboxPost chatPost;
  InboxReply response;
  bool isRead;
  String color;

  InboxNotification(this.chatPost, this.response, this.isRead, this.color);

  static InboxNotification _fromJsonObj(Map content) => InboxNotification(
        InboxPost._fromJsonObj(content['chat_post']),
        InboxReply._fromJsonObj(content['response']),
        content['is_read'],
        content['color'],
      );
}

class InboxPost {
  int id;
  int classId; //TODO this is nested content['class']['id']
  String post;

  InboxPost(this.id, this.classId, this.post);

  static InboxPost _fromJsonObj(Map content) => InboxPost(
        content['id'],
        content['class']['id'],
        content['post'],
      );
}

class InboxReply {
  bool isReply;
  String response;
  DateTime insertedAt;
  PublicStudent student;

  InboxReply(this.isReply, this.response, this.insertedAt, this.student);

  static InboxReply _fromJsonObj(Map content) => InboxReply(
        content['is_reply'],
        content['response'],
        DateTime.parse(content['inserted_at']),
        PublicStudent._fromJsonObj(content['student']),
      );
}
