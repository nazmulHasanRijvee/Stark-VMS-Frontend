/// The app's named routes for Stark VMS.
///
/// [path] is the URL segment handed to `GoRoute.path`;
/// [name] is what `GoRoute.name` and named navigation use.
enum Routes {
  // Startup Gates
  splash('/splash'),
  onboarding('/onboarding'),

  // Public Auth Routes
  login('/login'),
  signup('/signup'),

  // Signed-in VMS Shell Routes
  dashboard('/dashboard'),
  vehicles('/vehicles'),
  vehicleRegister('/vehicles/register'),
  vehicleEdit('/vehicles/edit/:vehicleNumber');

  const Routes(this.path);

  final String path;
}
