part of 'requests_core.dart';

class Chat {
  int id;
  String post;
  bool isStarred;
  bool isLiked;
  int classId;
  DateTime postDate;
  PublicStudent student;

  int likes;
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

  Future<RequestResponse> refetch() {
    return Chat.getChatById(classId: classId, chatId: id);
  }

  Future<RequestResponse> createChatComment(String comment) {
    return SKRequests.post(
      '/classes/$classId/posts/$id/comments',
      {'comment': comment},
      Comment._fromJsonObj,
    ).then((response) {
      if (response.wasSuccessful()) {
        Chat.currentChats[id].comments.add(response.obj);
      }
      return response;
    });
  }

  Future<bool> toggleLike() {
    bool newState = isLiked == null ? true : !isLiked;

    if (newState) {
      return SKRequests.post(
        '/classes/$classId/posts/$id/like',
        null,
        Comment._fromJsonObj,
      ).then((response) {
        bool status = response.wasSuccessful();

        if (status) {
          this.likes++;
        }

        this.isLiked = status;
        return status;
      });
    } else {
      return SKRequests.delete(
        '/classes/$classId/posts/$id/unlike',
        null,
      ).then((responseCode) {
        final bool status = [200, 204].contains(responseCode);

        if (status) {
          this.likes--;
        }

        this.isLiked = !status;
        return status;
      });
    }
  }

  Future<bool> toggleStar() {
    bool newState = isStarred == null ? true : !isStarred;

    if (newState) {
      return SKRequests.post(
        '/classes/$classId/posts/$id/star',
        null,
        Comment._fromJsonObj,
      ).then((response) {
        bool status = response.wasSuccessful();

        if (status) {
          this.likes++;
        }

        this.isStarred = status;
        return status;
      });
    } else {
      return SKRequests.delete(
        '/classes/$classId/posts/$id/unstar',
        null,
      ).then((responseCode) {
        final bool status = [200, 204].contains(responseCode);

        this.isStarred = !status;
        return status;
      });
    }
  }

  static Map<int, Chat> currentChats = {};

  static Chat _fromJsonObj(Map content) => Chat(
        content['id'],
        content['post'],
        content['is_starred'],
        content['is_liked'],
        content['class']['id'],
        DateTime.parse(content['inserted_at']),
        PublicStudent._fromJsonObj(content['student']),
        (content['likes'] ?? []).length,
        JsonListMaker.convert(Comment._fromJsonObj, content['comments'] ?? []),
      );

  static Future<RequestResponse> getStudentChats() {
    return SKRequests.get(
      '/students/${SKUser.current.student.id}/chat?sort=200',
      _fromJsonObj,
    ).then((response) {
      if (response.wasSuccessful()) {
        (response.obj as List).forEach((chat) => currentChats[chat.id] = chat);
      }
      return response;
    });
  }

  static Future<RequestResponse> getChatById({
    @required int classId,
    @required int chatId,
  }) {
    return SKRequests.get(
      '/classes/$classId/posts/$chatId',
      _fromJsonObj,
    ).then((response) {
      if (response.wasSuccessful()) {
        Chat.currentChats[chatId] = response.obj;
      }
      return response;
    });
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
  int likes;

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

  Future<RequestResponse> createReply(int classId, String reply) {
    return SKRequests.post(
      '/classes/$classId/comments/$id/replies',
      {'reply': reply},
      Reply._fromJsonObj,
    );
  }

  Future<bool> toggleLike(int classId) {
    bool newState = isLiked == null ? true : !isLiked;

    if (newState) {
      return SKRequests.post(
        '/classes/$classId/comments/$id/like',
        null,
        Comment._fromJsonObj,
      ).then((response) {
        bool status = response.wasSuccessful();

        if (status) {
          this.likes++;
        }

        this.isLiked = status;
        return status;
      });
    } else {
      return SKRequests.delete(
        '/classes/$classId/comments/$id/unlike',
        null,
      ).then((responseCode) {
        final bool status = [200, 204].contains(responseCode);

        if (status) {
          this.likes--;
        }

        this.isLiked = !status;
        return status;
      });
    }
  }

  Future<bool> toggleStar(int classId) {
    bool newState = isStarred == null ? true : !isStarred;

    if (newState) {
      return SKRequests.post(
        '/classes/$classId/comments/$id/star',
        null,
        Comment._fromJsonObj,
      ).then((response) {
        bool status = response.wasSuccessful();

        if (status) {
          this.likes++;
        }

        this.isStarred = status;
        return status;
      });
    } else {
      return SKRequests.delete(
        '/classes/$classId/comments/$id/unstar',
        null,
      ).then((responseCode) {
        final bool status = [200, 204].contains(responseCode);

        this.isStarred = !status;
        return status;
      });
    }
  }

  static Comment _fromJsonObj(Map content) => Comment(
        content['id'],
        JsonListMaker.convert(Reply._fromJsonObj, content['replies'] ?? []),
        PublicStudent._fromJsonObj(content['student']),
        content['comment'],
        DateTime.parse(content['inserted_at']),
        content['is_liked'],
        content['is_starred'],
        (content['likes'] ?? []).length,
      );
}

class Reply {
  int id;
  PublicStudent student;
  String reply;
  DateTime insertedAt;
  bool isLiked;
  int likes;

  Reply(
    this.id,
    this.student,
    this.reply,
    this.insertedAt,
    this.isLiked,
    this.likes,
  );

  Future<bool> toggleLike(int classId) {
    bool newState = isLiked == null ? true : !isLiked;

    if (newState) {
      return SKRequests.post(
        '/classes/$classId/replies/$id/like',
        null,
        Comment._fromJsonObj,
      ).then((response) {
        bool status = response.wasSuccessful();

        if (status) {
          this.likes++;
        }

        this.isLiked = status;
        return status;
      });
    } else {
      return SKRequests.delete(
        '/classes/$classId/replies/$id/unlike',
        null,
      ).then((responseCode) {
        final bool status = [200, 204].contains(responseCode);

        if (status) {
          this.likes--;
        }

        this.isLiked = !status;
        return status;
      });
    }
  }

  static Reply _fromJsonObj(Map content) => Reply(
        content['id'],
        PublicStudent._fromJsonObj(content['student']),
        content['reply'],
        DateTime.parse(content['inserted_at']),
        content['is_liked'],
        (content['likes'] ?? []).length,
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

  static List<InboxNotification> currentInbox = [];

  static InboxNotification _fromJsonObj(Map content) => InboxNotification(
        InboxPost._fromJsonObj(content['chat_post']),
        InboxReply._fromJsonObj(content['response']),
        content['is_read'],
        content['color'],
      );

  static Future<RequestResponse> getChatInbox() {
    return SKRequests.get(
      '/students/${SKUser.current.student.id}/inbox',
      _fromJsonObj,
    ).then(
      (response) {
        if (response.wasSuccessful()) {
          currentInbox = response.obj;
        }
        return response;
      },
    );
  }
}

class InboxPost {
  int id;
  int classId;
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
