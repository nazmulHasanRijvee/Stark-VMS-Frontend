import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

import 'dio_client.dart';
import 'endpoints.dart';

part 'rest_client.g.dart';

@RestApi(baseUrl: Endpoints.base)
abstract class RestClient {
  factory RestClient(Dio dio, {String? baseUrl, ParseErrorLogger errorLogger}) =
      _RestClient;

  /// Authentication
  @POST(Endpoints.register)
  Future<HttpResponse<dynamic>> register(@Body() Map<String, dynamic> request);

  @POST(Endpoints.login)
  Future<HttpResponse<dynamic>> login(@Body() Map<String, dynamic> request);

  /// Vehicles
  @GET(Endpoints.vehicles)
  Future<HttpResponse<dynamic>> getVehicles({
    @Query('search') String? search,
    @Query('status') String? status,
    @Query('page') int? page,
    @Query('size') int? size,
  });

  @POST(Endpoints.vehicles)
  Future<HttpResponse<dynamic>> createVehicle(
    @Body() Map<String, dynamic> request,
  );

  @GET('${Endpoints.vehicles}/{vehicleNumber}')
  Future<HttpResponse<dynamic>> getVehicleByNumber(
    @Path('vehicleNumber') String vehicleNumber,
  );

  @PUT('${Endpoints.vehicles}/{vehicleNumber}')
  Future<HttpResponse<dynamic>> updateVehicle(
    @Path('vehicleNumber') String vehicleNumber,
    @Body() Map<String, dynamic> request,
  );

  @DELETE('${Endpoints.vehicles}/{vehicleNumber}')
  Future<HttpResponse<dynamic>> deleteVehicle(
    @Path('vehicleNumber') String vehicleNumber,
  );

  /// Dashboard
  @GET(Endpoints.dashboardStats)
  Future<HttpResponse<dynamic>> getDashboardStats();
}

final restClientProvider = Provider<RestClient>((ref) {
  final dio = ref.watch(dioProvider);
  return RestClient(dio);
});
