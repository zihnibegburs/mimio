import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/models/ai_models.dart';
import 'package:mimio/core/network/dio_provider.dart';

class AiRepository {
  AiRepository(this._dio);

  final Dio _dio;

  Future<AiBreakdownModel> breakdown(String task) async {
    final response = await _dio.post('/assist/breakdown', data: {'task': task});
    return AiBreakdownModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AiPlanModel> plan(String input, {DateTime? date}) async {
    final dateStr = date != null
        ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
        : null;
    final response = await _dio.post('/assist/plan', data: {
      'input': input,
      if (dateStr != null) 'date': dateStr,
    });
    return AiPlanModel.fromJson(response.data as Map<String, dynamic>);
  }
}

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ref.watch(dioProvider));
});
