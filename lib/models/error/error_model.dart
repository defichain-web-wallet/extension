class ErrorModel {
  final String? file;
  final String? method;
  final String? exception;

  ErrorModel({
    this.file,
    this.method,
    this.exception,
  });

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['file'] = this.file ?? 'none';
    data['method'] = this.method ?? 'none';
    data['exception'] = this.exception ?? 'none';
    return data;
  }

  factory ErrorModel.fromJSON(Map<String, dynamic> json) {
    return ErrorModel(
      file: json['file'] ?? '',
      method: json['method'] ?? '',
      exception: json['exception'] ?? '',
    );
  }
}
