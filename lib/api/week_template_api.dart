import 'package:api_client/http/http.dart';
import 'package:api_client/models/week_template_model.dart';
import 'package:api_client/models/week_template_name_model.dart';
import 'package:api_client/offline_database/offline_db_handler.dart';

/// Week template endpoints
class WeekTemplateApi {
  /// Default constructor
  WeekTemplateApi(this._http, this.dbHandler);

  final Http _http;
  final OfflineDbHandler dbHandler;

  /// Gets all schedule templates for the currently authenticated user.
  /// Available to all users.
  Stream<List<WeekTemplateNameModel>> getNames() {
    return _http.get('/').map((Response res) {
      if (res.json['data'] is List) {
        return List<Map<String, dynamic>>.from(res.json['data'])
            .map((Map<String, dynamic> val) =>
                WeekTemplateNameModel.fromJson(val))
            .toList();
      } else {
        return null;
      }
    });
  }

  /// Creates new week template in the department of the given user.
  /// Available to Supers, Departments and Guardians.
  ///
  /// [template] After successful execution, a new week template will be created
  /// with the same values as this DTO.
  Stream<WeekTemplateModel> create(WeekTemplateModel template) {
    return _http.post('/', template.toJson()).asyncMap((Response res) {
      if (res.success()) {
        dbHandler.createTemplate(template);
        return WeekTemplateModel.fromJson(res.json['data']);
      } else {
        return dbHandler.createTemplate(template);
      }
    });
  }

  /// Gets the week template with the specified id. Available to all users.
  ///
  /// [id] ID of the week to get
  Stream<WeekTemplateModel> get(int id) {
    return _http.get('/$id').map((Response res) {
      return WeekTemplateModel.fromJson(res.json['data']);
    });
  }

  /// Overwrite the information of a week template. Available to all Supers, and
  /// to Departments and Guardians of the same department as the template.
  ///
  /// [template] The new template value
  Stream<WeekTemplateModel> update(WeekTemplateModel template) {
    return _http
        .put('/${template.id}', template.toJson())
        .asyncMap((Response res) {
      if (res.success()) {
        dbHandler.updateTemplate(template);
        return WeekTemplateModel.fromJson(res.json['data']);
      } else {
        return dbHandler.updateTemplate(template);
      }
    });
  }

  /// Deletes the template of the given ID. Available to all Supers, and to
  /// Departments and Guardians of the same department as the template.
  ///
  /// [id] ID of the template to delete
  Stream<bool> delete(int id) {
    return _http.delete('/$id').asyncMap((Response res) {
      if (res.success()) {
        dbHandler.deleteTemplate(id);
        return res.success();
      } else {
        return dbHandler.deleteTemplate(id);
      }
    });
  }
}
