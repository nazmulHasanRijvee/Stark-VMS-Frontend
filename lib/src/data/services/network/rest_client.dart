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
    @Query('sortBy') String? sortBy,
    @Query('sortDirection') String? sortDirection,
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

  /// Driver Assignment
  @PUT(Endpoints.vehicleDriver)
  Future<HttpResponse<dynamic>> assignDriver(
    @Path('vehicleNumber') String vehicleNumber,
    @Body() Map<String, dynamic> request,
  );

  @DELETE(Endpoints.vehicleDriver)
  Future<HttpResponse<dynamic>> unassignDriver(
    @Path('vehicleNumber') String vehicleNumber,
  );

  /// Drivers
  @GET(Endpoints.drivers)
  Future<HttpResponse<dynamic>> getDrivers({
    @Query('search') String? search,
    @Query('status') String? status,
    @Query('page') int? page,
    @Query('size') int? size,
    @Query('sortBy') String? sortBy,
    @Query('sortDirection') String? sortDirection,
  });

  @POST(Endpoints.drivers)
  Future<HttpResponse<dynamic>> createDriver(
    @Body() Map<String, dynamic> request,
  );

  @GET('${Endpoints.drivers}/{driverId}')
  Future<HttpResponse<dynamic>> getDriverById(@Path('driverId') int driverId);

  @PUT('${Endpoints.drivers}/{driverId}')
  Future<HttpResponse<dynamic>> updateDriver(
    @Path('driverId') int driverId,
    @Body() Map<String, dynamic> request,
  );

  @DELETE('${Endpoints.drivers}/{driverId}')
  Future<HttpResponse<dynamic>> deleteDriver(@Path('driverId') int driverId);

  /// Documents
  @POST(Endpoints.vehicleDocuments)
  @MultiPart()
  Future<HttpResponse<dynamic>> uploadDocument(
    @Path('vehicleNumber') String vehicleNumber,
    @Part(name: 'file') MultipartFile file,
    @Part(name: 'documentType') String documentType,
    @Part(name: 'expiryDate') String? expiryDate,
  );

  @GET(Endpoints.vehicleDocuments)
  Future<HttpResponse<dynamic>> getDocuments(
    @Path('vehicleNumber') String vehicleNumber, {
    @Query('documentType') String? documentType,
    @Query('expiryState') String? expiryState,
    @Query('page') int? page,
    @Query('size') int? size,
  });

  @GET(Endpoints.documentDownload)
  Future<HttpResponse<dynamic>> getDocumentDownloadUrl(
    @Path('vehicleNumber') String vehicleNumber,
    @Path('documentId') int documentId,
  );

  /// Maintenance
  @POST(Endpoints.vehicleMaintenance)
  Future<HttpResponse<dynamic>> createMaintenanceRecord(
    @Path('vehicleNumber') String vehicleNumber,
    @Body() Map<String, dynamic> request,
  );

  @GET(Endpoints.vehicleMaintenance)
  Future<HttpResponse<dynamic>> getMaintenanceRecords(
    @Path('vehicleNumber') String vehicleNumber, {
    @Query('page') int? page,
    @Query('size') int? size,
  });

  /// Dashboard
  @GET(Endpoints.dashboardStats)
  Future<HttpResponse<dynamic>> getDashboardStats();
}

final restClientProvider = Provider<RestClient>((ref) {
  final dio = ref.watch(dioProvider);
  return RestClient(dio);
});
