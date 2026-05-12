# B&B Desktop Admin Dashboard (Plan 1 - MVP)

This is a C++ Qt6 application for the B&B Real Estate & Home Services Platform admin panel.

## Building the Project

### Using qmake (if available)
1. Navigate to the project directory: `cd bb-admin`
2. Run: `qmake bb-admin.pro`
3. Run: `make` (or `mingw32-make` on Windows)

### Using CMake
1. Navigate to the project directory: `cd bb-admin`
2. Create a build directory: `mkdir build && cd build`
3. Run: `cmake .. -G "MinGW Makefiles"` (adjust generator as needed)
4. Run: `make` (or `mingw32-make` on Windows)

## Project Structure
- `main.cpp`: Application entry point
- `NetworkManager.h/cpp`: Singleton handling API requests with bearer token
- `LoginWindow.h/cpp`: Email/password login with admin role check
- `MainWindow.h/cpp`: Main window with sidebar and stacked widget
- `UsersTab.h/cpp`: Tab displaying admin users from `/admin/users`
- `PropertiesTab.h/cpp`: Tab displaying properties from `/properties`
- `ServicesTab.h/cpp`: Tab displaying worker services from `/worker-services`

## API Endpoints Used
- POST `/auth/login` (login)
- GET `/admin/users` (admin only)
- GET `/properties` (public)
- GET `/worker-services` (public)

## Notes
- Replace `YOUR_SERVER_IP` in NetworkManager.cpp with your actual backend URL
- Token is stored in QSettings under "BBAdmin"/"Auth"
- Minimum implementation as per Plan 1: login + 3 data tabs