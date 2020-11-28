final String tableParameter = 'parameter';
final String columnId = 'id';
final String columnUrl = 'url';
final String columnToken = 'token';
final String columnProject = 'project';
final String columnRef = 'ref';

class Parameter {
  int id;
  String url;
  String token;
  String project;
  String ref;

  Parameter({this.id, this.url, this.token, this.project, this.ref});

  Parameter.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    url = map[columnUrl];
    token = map[columnToken];
    project = map[columnProject];
    ref = map[columnRef];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnUrl: url,
      columnToken: token,
      columnProject: project,
      columnRef: ref
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}
