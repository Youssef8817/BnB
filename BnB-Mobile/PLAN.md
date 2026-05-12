B&B — Flutter Mobile App
Senior Implementation Plans — All 3 Phases

Stack: Flutter (Dart) · REST API (Laravel backend)
App: B&B Real Estate & Home Services Platform
Target: Android + iOS


Locked Specifications
#DecisionChoiceLanguageEnglish onlyNo RTL, no localizationLocationText only — city + address stringNo map widget, no GPSWorker registrationInstant — no approval screenJust a role dropdown on registerContact methodShow phone number — tap to callUse url_launcher with tel:PaymentNoneNo payment screensPush notificationsNone — removedNo FCMProperty imagesRequired — max 3 per propertyimage_picker + multipart uploadSell flowStatus change onlyNo offer/bid flowAuth storageshared_preferences for token

Shared Data Contract
API Response Envelope (all responses)
json{
  "success": true,
  "data": {},
  "message": "OK",
  "errors": null
}
Core Models
dartUser      { id, name, email, phone, role, avatarUrl }
Property  { id, ownerId, title, description, price, location, city,
            areaMq, rooms, status, images: List<PropertyImage> }
PropertyImage { id, propertyId, path, displayOrder }
WorkerService { id, workerId, type, description, pricePerUnit, unit,
                isAvailable, worker: User }
ServiceRequest { id, userId, workerServiceId, note, address, status }
Role Values
role = 'user'    → normal user
role = 'worker'  → worker (can offer services)
role = 'admin'   → admin (desktop only, never in mobile)
Property Status Values
status = 'available' | 'pending' | 'sold'
Service Request Status Values
status = 'pending' | 'accepted' | 'completed' | 'cancelled'
Worker Service Types
type = 'plumbing' | 'painting' | 'tiling' | 'electrical' | 'carpentry' | 'finishing'


PLAN 1 — MVP

Goal: 8 screens, fully working, minimal code. One file per screen.
Rule: setState only. No Provider. No packages except essentials.
LLM Hint: One task = one LLM prompt. Keep each screen file under 200 lines.


Screen List — Plan 1 (8 screens)
#ScreenRouteRoleKey Elements1SplashScreen/AllLogo, check token → redirect2LoginScreen/loginAllEmail, password, login, go to register3RegisterScreen/registerAllName, email, password, phone, role dropdown4HomeScreen/homeAllTabBar: Properties tab + Services tab5PropertyDetailScreen/property/:idAllImage PageView, details, call owner button6AddPropertyScreen/property/addAllForm + image picker (max 3)7WorkerServicesScreen/servicesAllService cards with worker phone8ProfileScreen/profileAllName, role badge, phone, logout

Folder Structure — Plan 1
lib/
  main.dart
  constants.dart
  models/
    user.dart
    property.dart
    property_image.dart
    worker_service.dart
    service_request.dart
  services/
    api_service.dart
  screens/
    splash_screen.dart
    login_screen.dart
    register_screen.dart
    home_screen.dart
    property_detail_screen.dart
    add_property_screen.dart
    worker_services_screen.dart
    profile_screen.dart
  widgets/
    property_card.dart
    service_card.dart

Dependencies — Plan 1
yamldependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  shared_preferences: ^2.2.2
  image_picker: ^1.0.7
  cached_network_image: ^3.3.1
  url_launcher: ^6.2.5

Task List — Flutter MVP
Project Setup

 flutter create b_and_b — create project
 Add all Plan 1 dependencies to pubspec.yaml, run flutter pub get
 Create lib/constants.dart:

dart  class Constants {
    static const String baseUrl = 'http://YOUR_SERVER_IP/api';
    static const String tokenKey = 'auth_token';
    static const String userKey = 'auth_user';
  }

 Add url_launcher permissions to AndroidManifest.xml: <queries> block with tel intent

Models

 lib/models/user.dart: class User with fields id, name, email, phone, role, avatarUrl, factory User.fromJson(Map<String, dynamic> json), Map<String, dynamic> toJson()
 lib/models/property_image.dart: id, propertyId, path, displayOrder, fromJson, add getter String get fullUrl => '${Constants.baseUrl.replaceAll('/api','')}${path.startsWith('/') ? '' : '/'}$path' using storage URL returned from API
 lib/models/property.dart: all fields, List<PropertyImage> images = [], fromJson — parse images list, add getter String get formattedPrice => '\$${price.toStringAsFixed(0)}'
 lib/models/worker_service.dart: all fields, nested User? worker, fromJson
 lib/models/service_request.dart: all fields, fromJson

ApiService (lib/services/api_service.dart)

 static Future<String?> _getToken() — reads from SharedPreferences
 static Future<Map<String,String>> _headers() — returns {'Authorization': 'Bearer $token', 'Accept': 'application/json', 'Content-Type': 'application/json'}
 static Future<Map<String,dynamic>> _handleResponse(http.Response r) — parses JSON, throws Exception if success == false using errors or message field
 static Future<Map<String,dynamic>> login(String email, String password) — POST /auth/login, returns {user, token}
 static Future<Map<String,dynamic>> register(String name, String email, String password, String phone, String role) — POST /auth/register
 static Future<void> logout() — POST /auth/logout
 static Future<User> getMe() — GET /me
 static Future<List<Property>> getProperties() — GET /properties, parse data array
 static Future<Property> getProperty(int id) — GET /properties/$id
 static Future<Property> createProperty(Map<String,dynamic> data, List<File> images) — POST /properties as MultipartRequest, add all fields + loop images as MultipartFile.fromPath('images[]', file.path)
 static Future<void> updatePropertyStatus(int id, String status) — PUT /properties/$id/status
 static Future<List<WorkerService>> getWorkerServices() — GET /worker-services
 static Future<void> createWorkerService(Map<String,dynamic> data) — POST /worker-services
 static Future<void> createServiceRequest(int workerServiceId, String note, String address) — POST /service-requests
 static Future<User> getUser(int id) — GET /users/$id

SplashScreen

 initState: Future.delayed(Duration(seconds: 2)) → read token from SharedPreferences
 If token exists → Navigator.pushReplacementNamed(context, '/home')
 If no token → Navigator.pushReplacementNamed(context, '/login')
 UI: centered Column with logo (Text 'B&B' in large bold) + app tagline

LoginScreen

 _formKey = GlobalKey<FormState>()
 Two TextFormField: email (validator: not empty + contains @) + password (obscureText, validator: min 6 chars)
 ElevatedButton('Login'): validate form → setState(_isLoading = true) → call ApiService.login() → save token + user to SharedPreferences → navigate home → catch: show SnackBar with error
 TextButton('Don\'t have an account? Register') → navigate RegisterScreen
 Show CircularProgressIndicator when _isLoading

RegisterScreen

 Fields: name, email, password, phone, role DropdownButtonFormField with items User + Worker
 Validation on all fields
 On submit: ApiService.register() → save token → navigate HomeScreen
 Show loading, handle error SnackBar

HomeScreen

 DefaultTabController(length: 2)
 AppBar with title 'B&B', profile IconButton → navigate ProfileScreen
 TabBar with tabs: Properties, Services
 TabBarView child 1 — _PropertiesTab widget (StatefulWidget):

 initState calls ApiService.getProperties() → setState(_properties = result)
 ListView.builder of PropertyCard
 Pull-to-refresh RefreshIndicator


 TabBarView child 2 — _ServicesTab widget (StatefulWidget):

 initState calls ApiService.getWorkerServices() → setState(_services = result)
 ListView.builder of ServiceCard


 FloatingActionButton with '+' icon → navigate AddPropertyScreen

PropertyCard widget (lib/widgets/property_card.dart)

 Card with InkWell wrapping
 Top: CachedNetworkImage of property.images.first.fullUrl (height 160, BoxFit.cover) with placeholder Container(color: Colors.grey[200])
 Bottom padding: title (bold), price (green), Row with city chip + rooms + area
 onTap → navigate PropertyDetailScreen passing property object

PropertyDetailScreen

 Receives Property property as constructor arg
 Top: PageView.builder for images (height 250), with DotsIndicator below (manual dots using Row of Containers)
 Body: ListView with: title, price, city, location, area, rooms, description
 "Call Owner" ElevatedButton → launchUrl(Uri.parse('tel:${property.owner?.phone ?? ''}')) — fetch owner separately if not in property object
 If AuthService.currentUserId == property.ownerId: show DropdownButton for status (available/pending/sold) → call ApiService.updatePropertyStatus()

AddPropertyScreen

 Form fields: title, description, price (numberKeyboard), location, city, area (numberKeyboard), rooms (numberKeyboard)
 Image picker: ElevatedButton('Pick Images') → ImagePicker().pickMultiImage() → limit to 3 total → setState(_selectedImages = picked.take(3).toList())
 Show selected images in SizedBox(height:80) → ListView.builder horizontal of Image.file thumbnails
 Submit: validate form + at least 1 image selected → ApiService.createProperty() → pop with success SnackBar

WorkerServicesScreen

 FutureBuilder around ApiService.getWorkerServices() → ListView.builder of ServiceCard

ServiceCard widget (lib/widgets/service_card.dart)

 Card with type icon (use switch on type string to return Icon), worker name, type label, price_per_unit + unit
 TextButton('Request') → shows showModalBottomSheet with:

 TextField for note
 TextField for address
 ElevatedButton('Submit Request') → ApiService.createServiceRequest() → close sheet → show SnackBar



ProfileScreen

 FutureBuilder(ApiService.getMe()) → show name, email, phone
 Role badge: Chip with color — blue for user, orange for worker
 ElevatedButton('Logout') → ApiService.logout() → clear SharedPreferences → navigate LoginScreen
 Note: if user is worker — show TextButton('Add Service') → dialog with form for new service type/description/price/unit

main.dart

 MaterialApp with named routes: / → SplashScreen, /login → LoginScreen, /register → RegisterScreen, /home → HomeScreen, /profile → ProfileScreen
 PropertyDetailScreen and AddPropertyScreen opened via Navigator.push (not named routes — need to pass data)
 Theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true)

Global error handling

 Create void showError(BuildContext context, String message) helper: ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red))
 Use in every catch block



PLAN 2 — Structured

Goal: 11 screens, role-based UI, setState for state management. Clean and maintainable.
Rule: setState for state management. No Provider or state management libraries. Repository wraps ApiService.
LLM Hint: Migrate from Plan 1. Each screen implementation = one LLM prompt.


Screen List — Plan 2 (11 screens)
#ScreenRoleAdditions vs Plan 11SplashScreenAllCalls AuthProvider.tryAutoLogin()2LoginScreenAllUses AuthProvider instead of direct ApiService3RegisterScreenAllSame4HomeScreenAllWorker sees 3rd tab: Dashboard5PropertyListScreenAllSearch bar + city filter chips6PropertyDetailScreenAllOwner sees edit/delete buttons7AddPropertyScreenAllImage drag-reorder8MyPropertiesScreenAllOwn listings + status change + delete9WorkerServicesScreenAllFilter by type chips10WorkerDashboardScreenWorker onlyMy services tab + incoming requests tab11ProfileScreenAllEdit phone field inline

Folder Structure — Plan 2
lib/
  main.dart
  constants.dart
  models/              (same as Plan 1)
  services/
    api_service.dart   (expanded with new endpoints)
  repositories/
    property_repository.dart
    service_repository.dart
  providers/
    auth_provider.dart
    property_provider.dart
    service_provider.dart
  screens/             (11 screens)
  widgets/
    property_card.dart
    service_card.dart
    role_badge.dart
    loading_overlay.dart
    empty_state.dart
    filter_chips_row.dart

Dependencies — Plan 2
yamldependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  shared_preferences: ^2.2.2
  image_picker: ^1.0.7
  cached_network_image: ^3.3.1
  url_launcher: ^6.2.5

Task List — Flutter Structured
New ApiService Methods

 static Future<List<Property>> getMyProperties() — GET /my-properties
 static Future<void> deleteProperty(int id) — DELETE /properties/$id
 static Future<List<ServiceRequest>> getMyRequests() — GET /service-requests/mine
 static Future<List<ServiceRequest>> getIncomingRequests() — GET /service-requests/incoming
 static Future<void> updateRequestStatus(int id, String status) — PUT /service-requests/$id/status
 static Future<void> updateWorkerService(int id, Map data) — PUT /worker-services/$id
 static Future<void> deleteWorkerService(int id) — DELETE /worker-services/$id
 static Future<Map<String,dynamic>> getAdminStats() — GET /admin/stats (for worker mock stats)

AuthProvider (providers/auth_provider.dart)

Removed - using setState only for state management

PropertyProvider (providers/property_provider.dart)

Removed - using setState only for state management

ServiceProvider (providers/service_provider.dart)

Removed - using setState only for state management

PropertyRepository (repositories/property_repository.dart)

 Future<List<Property>> getAll({String? city, String? status, double? minPrice, double? maxPrice}): builds query string → calls ApiService.getProperties() with params → returns list
 Future<List<Property>> getMine(): calls ApiService.getMyProperties() → returns list

ServiceRepository (repositories/service_repository.dart)

 Future<List<WorkerService>> getAll({String? type}): calls ApiService.getWorkerServices() → optional client-side filter by type → returns list
 Future<List<ServiceRequest>> getMyRequests(): calls ApiService.getMyRequests()
 Future<List<ServiceRequest>> getIncoming(): calls ApiService.getIncomingRequests()

main.dart update

No MultiProvider needed - using setState only in each screen

SplashScreen.initState: read token from SharedPreferences → if exists, call ApiService.getMe() → navigate home if token valid, else login

New Widgets

 RoleBadge(String role): Chip — blue for 'user', orange for 'worker', purple for 'admin', text is role.toUpperCase()
 LoadingOverlay({required bool isLoading, required Widget child}): Stack — child + if isLoading: Container(color: Colors.black26) + centered CircularProgressIndicator
 EmptyState({required String message, required IconData icon}): centered Column with icon (size 64, grey) + Text(message, grey)
 FilterChipsRow({required List<String> options, String? selected, required Function(String?) onSelected}): horizontal SingleChildScrollView → Row of FilterChip

New Screens

PropertyListScreen: StatefulWidget with setState → show FilterChipsRow with Egyptian cities (Cairo, Giza, Alexandria, etc.) above ListView of PropertyCard. On chip select: setState(() => fetchAll(city: city)). Show EmptyState when list empty.
MyPropertiesScreen: StatefulWidget with setState → initState calls fetchMine() → ListView.builder where each PropertyCard has trailing PopupMenuButton with: "Change Status" → dropdown dialog, "Delete" → confirm dialog → deleteProperty(id) then setState(() => fetchMine()).
WorkerDashboardScreen: DefaultTabController(length: 2) with tabs: "My Services" + "Requests". My Services: StatefulWidget with setState → list of own services with edit/delete. Requests: StatefulWidget with setState → initState fetches incoming → list with status update buttons.

HomeScreen update

Read Auth state using setState only (no Provider)
If worker: DefaultTabController(length: 3) with extra "Dashboard" tab → navigate WorkerDashboardScreen on tap
If not worker: DefaultTabController(length: 2)



PLAN 3 — Production

Goal: 14 screens, setState for state management, Dio interceptors, feature-based folders.
Rule: One feature = one folder. Dio handles all HTTP. GoRouter handles all navigation.
LLM Hint: Implement one feature folder at a time — each is fully isolated.


Screen List — Plan 3 (14 screens)
#ScreenRoleAdditions vs Plan 21SplashScreenAllAnimated logo with AnimationController2LoginScreenAllInline validation (shows errors under fields)3RegisterScreenAllSame4HomeScreenAllFeatured properties section + services section5PropertyListScreenAllFull filter bottom sheet: city, price range, rooms6PropertyDetailScreenAllFullscreen image tap (Hero animation)7AddPropertyScreenAllReorderableListView for image order8MyPropertiesScreenAllSame9WorkerServicesScreenAllFilter chips + avg star rating displayed10ServiceDetailScreenAllNEW: full service page + reviews list + request form11WorkerDashboardScreenWorkerCount cards: total requests, pending, completed12MyRequestsScreenUserNEW: all my requests + status Chip per item13ReviewScreenUserNEW: star rating + comment form → submit review14ProfileScreenAllEdit all fields inline

Folder Structure — Plan 3
lib/
  main.dart
  core/
    constants.dart
    dio_client.dart
    api_exception.dart
    router.dart
  features/
    auth/
      screens/
        login_screen.dart
        register_screen.dart
      providers/
        auth_provider.dart       (StateNotifier)
        auth_state.dart
      repository/
        auth_repository.dart
      models/
        user.dart
    properties/
      screens/
        property_list_screen.dart
        property_detail_screen.dart
        add_property_screen.dart
        my_properties_screen.dart
      providers/
        property_list_provider.dart
        my_properties_provider.dart
      repository/
        property_repository.dart
      models/
        property.dart
        property_image.dart
    services/
      screens/
        worker_services_screen.dart
        service_detail_screen.dart
        worker_dashboard_screen.dart
        my_requests_screen.dart
        review_screen.dart
      providers/
        service_list_provider.dart
        worker_dashboard_provider.dart
        my_requests_provider.dart
        incoming_requests_provider.dart
      repository/
        service_repository.dart
      models/
        worker_service.dart
        service_request.dart
        review.dart
    profile/
      screens/
        profile_screen.dart
        splash_screen.dart
      providers/
        profile_provider.dart
  shared/
    widgets/
      property_card.dart
      service_card.dart
      role_badge.dart
      loading_overlay.dart
      empty_state.dart
      filter_chips_row.dart
      star_rating.dart
    utils/
      formatters.dart

Dependencies — Plan 3
yamldependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.3
  go_router: ^14.2.0
  shared_preferences: ^2.2.3
  image_picker: ^1.1.2
  cached_network_image: ^3.3.1
  url_launcher: ^6.3.0
  flutter_rating_bar: ^4.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.9

Task List — Flutter Production
DioClient (core/dio_client.dart)

 Create DioClient class with Dio _dio instance
 BaseOptions: baseUrl = Constants.baseUrl, connectTimeout = Duration(seconds: 10), receiveTimeout = Duration(seconds: 15), headers = {'Accept': 'application/json'}
 Add InterceptorsWrapper:

onRequest: read token from SharedPreferences → if not null add 'Authorization': 'Bearer $token' to headers
onResponse: check response.data['success'] == false → throw ApiException(message: response.data['message'], errors: response.data['errors'])
onError: if DioException with status 401 → clear token from SharedPreferences → use GoRouter global key to navigate to /login


 Expose Dio get dio => _dio
 Create dioProvider = Provider<Dio>((ref) => DioClient().dio)

ApiException (core/api_exception.dart)

 class ApiException implements Exception { final String message; final Map<String,dynamic>? errors; }
 Helper: String? fieldError(String field) => errors?[field]?.first

AuthState + AuthNotifier

 AuthState: sealed class with states: AuthInitial, AuthLoading, AuthAuthenticated(User user), AuthUnauthenticated, AuthError(String message)
 AuthNotifier extends StateNotifier<AuthState>:

 Future<void> tryAutoLogin(): read token → GET /me → emit AuthAuthenticated or AuthUnauthenticated
 Future<void> login(String email, String password): emit Loading → call repo → emit Authenticated (save token) or Error
 Future<void> register(...): same pattern
 Future<void> logout(): emit Loading → call repo → clear token → emit Unauthenticated
 Getter: bool get isWorker => state is AuthAuthenticated && (state as AuthAuthenticated).user.role == 'worker'


 Create authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref.read(authRepositoryProvider)))

Property Providers

 PropertyListState: {List<Property> items, bool isLoading, String? errorMessage, String? cityFilter}
 PropertyListNotifier extends StateNotifier<PropertyListState>:

fetchAll({String? city, String? status, double? minPrice, double? maxPrice}): update state loading → call repo → update state with items
setFilter(...): update filter fields → call fetchAll


 myPropertiesProvider: StateNotifierProvider — fetchMine(), delete(int id), updateStatus(int id, String status)

Service Providers

 serviceListProvider: StateNotifierProvider — fetchAll({String? type}), setTypeFilter(String? type)
 workerDashboardProvider: FutureProvider<WorkerDashStats> — calls repo for incoming requests + own services
 myRequestsProvider: StateNotifierProvider — fetchMine(), list of my requests
 incomingRequestsProvider: StateNotifierProvider — fetchIncoming(), updateStatus(int id, String status)

GoRouter (core/router.dart)

 Create final routerProvider = Provider<GoRouter>((ref) => GoRouter(...))
 Routes: /splash, /login, /register, /home, /properties/:id, /properties/add, /my-properties, /services, /services/:id, /worker-dashboard, /my-requests, /review/:serviceId, /profile
 redirect callback: read authProvider — if AuthUnauthenticated and route not in ['/login', '/register'] → return '/login'
 Worker guard: routes /worker-dashboard → if not isWorker → return '/home'
 Pass GoRouter to MaterialApp.router

New Screens
ServiceDetailScreen

 Accept int serviceId from route param
 FutureProvider or ref.watch to get service detail
 Show: service type + icon, description, price/unit, worker name + phone call button
 FlutterRatingBarIndicator showing avg rating (read-only)
 Reviews ListView below: user name, rating stars, comment, date
 "Request Service" ElevatedButton → showModalBottomSheet with note + address fields

MyRequestsScreen

 Consumer of myRequestsProvider
 initState → ref.read(myRequestsProvider.notifier).fetchMine()
 ListView.builder — each item: service type + worker name + date + StatusChip
 StatusChip(String status) widget: Chip with color — pending=orange, accepted=blue, completed=green, cancelled=grey
 If status == 'completed': show TextButton('Leave Review') → navigate ReviewScreen

ReviewScreen

 Accept int serviceId from route param
 FlutterRatingBar (interactive, 1–5 stars)
 TextField for comment (min 10 chars)
 Submit button → call ServiceRepository.submitReview(serviceId, rating, comment) → pop → show SnackBar 'Review submitted!'

Image Handling — Plan 3

 AddPropertyScreen: use ImagePicker().pickMultiImage() capped at 3
 Display selected images in ReorderableListView.builder (horizontal, height 100) — drag to reorder changes upload order
 Upload order = display_order sent to backend
 PropertyDetailScreen: wrap PageView in GestureDetector → on tap open fullscreen Dialog with InteractiveViewer for zoom + Hero animation on image

Review Model (features/services/models/review.dart)

 class Review { int id, userId, workerServiceId, rating; String comment, userName; DateTime createdAt; factory Review.fromJson(Map<String,dynamic>); }

ServiceRepository additions

 Future<WorkerService> getServiceDetail(int id): GET /worker-services/$id with reviews
 Future<List<Review>> getReviews(int serviceId): GET /worker-services/$serviceId/reviews
 Future<void> submitReview(int serviceId, int rating, String comment): POST /worker-services/$serviceId/reviews

HomeScreen — Plan 3

 Two sections instead of tabs:

"Featured Properties" — horizontal PageView of first 5 properties (auto-scrolling using Timer.periodic)
"Available Services" — horizontal scrollable ListView of service type cards


 "See all" TextButton next to each section title → navigate to full list screen


Summary
MetricPlan 1 — MVPPlan 2 — StructuredPlan 3 — ProductionScreens81114StatesetStateOnlysetStateOnlysetStateOnlyHTTPhttp packagehttp packageDio + interceptorsNavigationNamed routesNamed routesGoRouter + guardsArchitectureFlat screensScreens + ProvidersFeature foldersAuth handlingManual in each screenManual in each screenManual in each screenRole-based UIManual if-elseManual if-elseGoRouter guardReviewsNoNoYesImage reorderNoNoYes (ReorderableListView)Fullscreen imageNoNoYes (Hero + InteractiveViewer)Widget testsNoNoYes

Rule: Each checkbox = one LLM prompt.
Always paste the relevant model + API endpoint contract with the task.
Never send more than one task per prompt to a cheap LLM model.