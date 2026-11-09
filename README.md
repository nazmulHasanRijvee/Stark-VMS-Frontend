# Stark VMS

Stark VMS is a responsive Flutter Web vehicle-management app built for the Stark Group fleet workflow. It connects to a Java Spring Boot REST API backed by SQL so vehicle records are managed as real application data.

**Live app:** [stark-vms.netlify.app](https://stark-vms.netlify.app) · **Backend:** [Stark VMS Backend](https://github.com/nazmulHasanRijvee/Stark-VMS-Backend) · **Design:** [Google Stitch project](https://stitch.withgoogle.com/projects/18195970468133141741)

## Features

- Login and registration with a JWT access-token session managed by `flutter_secure_storage`; authenticated API requests send it as a Bearer token.
- Vehicle list, search, status filtering, registration, editing, and confirmed deletion.
- Duplicate vehicle-number validation and form validation.
- Dashboard with fleet summary metrics and recently added vehicles.
- Responsive layouts, English and Bangla localization, and persistent light/dark theme selection.
- State-driven navigation with GoRouter and Riverpod.

The project follows Clean Architecture, with presentation, domain, and data layers. Networking uses Dio and Retrofit.

## Run locally

Install Flutter with Dart **3.13.7 or newer** and a browser such as Chrome. From the project root:

```bash
flutter pub get
flutter run -d chrome
```

By default, the app uses `https://stark-vms-backend-yxhg.onrender.com/api/v1`. To use another backend, set `BASE_URL` to its API root (ending in `/api/v1`):

```bash
flutter run -d chrome --dart-define=BASE_URL=https://your-backend.example/api/v1
```

To run the backend locally, follow the setup instructions in the [backend repository](https://github.com/nazmulHasanRijvee/Stark-VMS-Backend) and point `BASE_URL` at it. The backend and its SQL database must be available for login and vehicle data workflows.

## Deployment

The frontend is deployed on [Netlify](https://stark-vms.netlify.app). The root `netlify.toml` installs Flutter in the build environment, prepares the web artifacts, and builds the release web app with WebAssembly.

## Design and development tools

- **Frontend:** Antigravity with Gemini
- **Backend:** Codex
- **UI design:** Google Stitch — [open the project](https://stitch.withgoogle.com/projects/18195970468133141741)
- **MCP tooling:** Dart MCP for Flutter/Dart-aware development and Stitch MCP for design access. Add and authorize these servers in your AI client’s MCP settings, then restart the client. MCP setup is local to the development tools and is not required to build or run the app.

## Assignment 1 scope

Implements the core VMS workflow: login, vehicle list, add, edit, delete, duplicate-number validation, and Flutter Web integration with a REST API and database-backed backend.
