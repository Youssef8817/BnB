B&B — Backend API (Laravel 11)
Senior Implementation Plans — All 3 Phases

Stack: Laravel 11 · MySQL · Laravel Sanctum
Role: Single REST API — serves both Flutter Mobile and C++ Desktop
App: B&B Real Estate & Home Services Platform


Locked Specifications
#DecisionChoiceAuthLaravel Sanctum (Bearer token)Token expiry: 7 daysLocationText only — city + address stringNo GPS / no geo queriesLanguageEnglish onlyWorker registrationInstant — no admin approvalContact methodPhone number stored on user, returned in APIPaymentNone — listing platform onlyPush notificationsNone — removedProperty imagesRequired — max 3 per property, no size limitSell flowSimple status change onlyStorageLocal disk (storage/public)Run php artisan storage:linkPagination10 items per page on all list endpoints

Shared Data Contract
API Response Envelope

Every single endpoint returns this exact structure. No exceptions.

json{
  "success": true,
  "data": {},
  "message": "OK",
  "errors": null
}
On validation error:
json{
  "success": false,
  "data": null,
  "message": "Validation failed",
  "errors": {
    "email": ["The email field is required."]
  }
}
Core Database Schema
users
  id               BIGINT PK
  name             VARCHAR(100)
  email            VARCHAR(150) UNIQUE
  password         VARCHAR(255)
  phone            VARCHAR(20)
  role             ENUM(user, worker, admin)  DEFAULT user
  avatar_url       VARCHAR(500) NULLABLE
  created_at, updated_at

properties
  id               BIGINT PK
  owner_id         FK → users.id
  title            VARCHAR(200)
  description      TEXT
  price            DECIMAL(15,2)
  location         TEXT
  city             VARCHAR(100)
  area_m2          DECIMAL(8,2)
  rooms            TINYINT UNSIGNED
  status           ENUM(available, sold, pending)  DEFAULT available
  created_at, updated_at

property_images
  id               BIGINT PK
  property_id      FK → properties.id
  path             VARCHAR(500)
  display_order    TINYINT DEFAULT 0
  — MAX 3 rows per property_id enforced in controller

worker_services
  id               BIGINT PK
  worker_id        FK → users.id
  type             ENUM(plumbing, painting, tiling, electrical, carpentry, finishing)
  description      TEXT
  price_per_unit   DECIMAL(10,2)
  unit             VARCHAR(50)
  is_available     BOOLEAN DEFAULT true
  created_at, updated_at

service_requests
  id               BIGINT PK
  user_id          FK → users.id
  worker_service_id FK → worker_services.id
  note             TEXT
  address          TEXT
  status           ENUM(pending, accepted, completed, cancelled)  DEFAULT pending
  created_at, updated_at


PLAN 1 — MVP

Goal: Smallest working API — every endpoint functional, zero abstractions.
Rule: Controllers only. No services, no repositories, no form requests.
LLM Hint: One task = one LLM prompt. Each file under 150 lines.


Folder Structure
app/
  Http/
    Controllers/
      AuthController.php
      PropertyController.php
      WorkerServiceController.php
      ServiceRequestController.php
      UserController.php
  Models/
    User.php
    Property.php
    PropertyImage.php
    WorkerService.php
    ServiceRequest.php
routes/
  api.php
database/
  migrations/
    2024_01_01_000001_create_users_table.php
    2024_01_01_000002_create_properties_table.php
    2024_01_01_000003_create_property_images_table.php
    2024_01_01_000004_create_worker_services_table.php
    2024_01_01_000005_create_service_requests_table.php
database/
  seeders/
    DatabaseSeeder.php

Endpoints — Plan 1
MethodEndpointAuthDescriptionPOST/api/auth/registerPublicRegister — role: user or workerPOST/api/auth/loginPublicLogin → returns {user, token}POST/api/auth/logoutBearerRevoke current tokenGET/api/meBearerGet authenticated user profileGET/api/users/{id}PublicGet user profile (id, name, phone, role)GET/api/propertiesPublicList all available properties + imagesPOST/api/propertiesBearerCreate property with 1–3 imagesGET/api/properties/{id}PublicProperty detail + images + owner infoPUT/api/properties/{id}/statusBearer (owner)Change status: available / pending / soldGET/api/worker-servicesPublicList all active worker servicesPOST/api/worker-servicesBearer (worker)Worker creates service offeringPOST/api/service-requestsBearerCreate service requestGET/api/admin/usersAdminList all users (C++ dashboard)

Task List — Laravel MVP
Project Setup

 laravel new bb-api — create project
 composer require laravel/sanctum — install Sanctum
 Configure .env: DB_DATABASE, DB_USERNAME, DB_PASSWORD, APP_URL
 Run php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
 Run php artisan storage:link
 Set FILESYSTEM_DISK=public in .env

Migrations

 Modify default create_users_table: add phone VARCHAR(20), role ENUM('user','worker','admin') DEFAULT 'user', avatar_url VARCHAR(500) NULLABLE
 Create create_properties_table: all fields from schema above
 Create create_property_images_table: property_id FK, path VARCHAR(500), display_order TINYINT DEFAULT 0
 Create create_worker_services_table: all fields from schema above
 Create create_service_requests_table: all fields from schema above
 Run php artisan migrate

Models

 User: add HasApiTokens trait, $fillable = [name, email, password, phone, role, avatar_url], properties() hasMany, workerServices() hasMany
 Property: $fillable all fields, owner() belongsTo User, images() hasMany PropertyImage, $casts = ['price' => 'decimal:2']
 PropertyImage: $fillable = [property_id, path, display_order], property() belongsTo
 WorkerService: $fillable all fields, worker() belongsTo User (select id,name,phone only), $casts = ['is_available' => 'boolean']
 ServiceRequest: $fillable all fields, user() belongsTo User, workerService() belongsTo WorkerService

AuthController

 register(Request $r): validate name/email/password/phone/role(in:user,worker), hash password with bcrypt(), create user, $user->createToken('auth'), return {success, data:{user, token}, message}
 login(Request $r): validate email/password, Auth::attempt(), if fail return 401, issue token, return {user, token}
 logout(Request $r): $r->user()->currentAccessToken()->delete(), return success message

PropertyController

 index(): Property::where('status','available')->with('images')->latest()->get() — wrap in envelope
 show($id): Property::with(['images', 'owner:id,name,phone'])->findOrFail($id) — wrap in envelope
 store(Request $r): validate (title, description, price, location, city, area_m2, rooms, images array max:3, each image mimes:jpg,jpeg,png), create Property with owner_id = auth()->id(), loop $r->file('images') → Storage::disk('public')->put('properties', $file) → create PropertyImage record with display_order = loop index, return created property
 updateStatus($id, Request $r): find property, abort_if($property->owner_id !== auth()->id(), 403, 'Forbidden'), validate status(in:available,pending,sold), update, return updated property

WorkerServiceController

 index(): WorkerService::where('is_available',true)->with('worker:id,name,phone')->get()
 store(Request $r): abort_if(auth()->user()->role !== 'worker', 403, 'Workers only'), validate (type in enum list, description, price_per_unit numeric min:0, unit), create with worker_id = auth()->id()

ServiceRequestController

 store(Request $r): validate (worker_service_id exists:worker_services,id, note, address required), create with user_id = auth()->id(), return created request

UserController

 show($id): User::select('id','name','phone','role','avatar_url')->findOrFail($id) — return in envelope

AdminController

 users(): User::select('id','name','email','phone','role','created_at')->latest()->get() — used by C++ dashboard only
 Create IsAdmin middleware: if (auth()->user()?->role !== 'admin') abort(403);
 Register middleware alias 'admin' in bootstrap/app.php

Routes (routes/api.php)

 Public routes: GET properties, GET properties/{id}, GET worker-services, GET users/{id}, POST auth/register, POST auth/login
 Auth routes (middleware sanctum): POST auth/logout, GET me, POST properties, PUT properties/{id}/status, POST worker-services, POST service-requests
 Admin routes (middleware sanctum + admin): GET admin/users

Database Seeder

 Seed 1 admin user (role=admin)
 Seed 5 normal users (role=user)
 Seed 3 workers (role=worker)
 Seed 10 properties (owner_id from users/workers) each with 2–3 images (use placeholder paths)
 Seed 5 worker services (worker_id from workers)
 Seed 4 service requests (user_id from users, random worker_service_id)

Testing

 Import Postman collection — test every endpoint
 Verify envelope structure (success, data, message, errors) on every response
 Verify 403 when non-worker tries POST /worker-services
 Verify 403 when non-owner tries PUT /properties/{id}/status



PLAN 2 — Structured

Goal: Maintainable, validated, role-secured API. Production-safe patterns without over-engineering.
Rule: One class = one responsibility. No business logic in controllers.
LLM Hint: Migrate from Plan 1 task by task. Each refactor = one LLM prompt.


New Endpoints — Plan 2
MethodEndpointAuthDescriptionDELETE/api/properties/{id}Bearer (owner)Delete own property + images from diskGET/api/my-propertiesBearerList authenticated user's own propertiesGET/api/service-requests/mineBearerMy submitted service requestsGET/api/service-requests/incomingBearer (worker)Incoming requests for my servicesPUT/api/service-requests/{id}/statusBearer (worker)Update request statusPUT/api/worker-services/{id}Bearer (worker owner)Update own serviceDELETE/api/worker-services/{id}Bearer (worker owner)Delete own serviceGET/api/admin/statsAdminCount stats for C++ dashboardGET/api/properties?city=&status=&min_price=&max_price=&rooms=PublicFiltered + paginated list

Task List — Laravel Structured
Form Request Classes

 php artisan make:request StorePropertyRequest — rules: title min:3 max:200, description required, price numeric min:0, location required, city required max:100, area_m2 numeric min:1, rooms integer min:1 max:20, images array min:1 max:3, images.* file mimes:jpg,jpeg,png max:10240
 php artisan make:request UpdatePropertyStatusRequest — rules: status required in:available,pending,sold
 php artisan make:request StoreWorkerServiceRequest — rules: type required in:plumbing,painting,tiling,electrical,carpentry,finishing, description required, price_per_unit numeric min:0, unit required max:50
 php artisan make:request StoreServiceRequestRequest — rules: worker_service_id required exists:worker_services,id, note required, address required
 php artisan make:request UpdateServiceRequestStatusRequest — rules: status required in:accepted,completed,cancelled
 Replace all $request->validate([...]) in controllers with injected Form Request classes

API Resource Classes

 php artisan make:resource PropertyResource — format price with number_format(2), add image_urls array using Storage::url($image->path), include owner as {id, name, phone}
 php artisan make:resource PropertyCollection — wraps paginated list
 php artisan make:resource WorkerServiceResource — include nested worker {id, name, phone}, format price_per_unit
 php artisan make:resource UserResource — exclude password, include all other fields
 php artisan make:resource ServiceRequestResource — include workerService and user nested
 Replace all raw return response()->json(...) in controllers with Resource returns

Policy Classes

 php artisan make:policy PropertyPolicy --model=Property
 PropertyPolicy::update(User $user, Property $property): return $user->id === $property->owner_id
 PropertyPolicy::delete(User $user, Property $property): same check
 Register in AppServiceProvider: Gate::policy(Property::class, PropertyPolicy::class)
 In PropertyController: replace manual owner check with $this->authorize('update', $property)

Worker Middleware

 php artisan make:middleware EnsureWorker
 Logic: if (auth()->user()?->role !== 'worker') abort(403, 'Workers only');
 Register alias 'worker' in bootstrap/app.php
 Apply to: POST /worker-services, PUT /worker-services/{id}, DELETE /worker-services/{id}, GET /service-requests/incoming, PUT /service-requests/{id}/status

New Controller Methods

 PropertyController@destroy($id): authorize delete, delete all images from Storage::disk('public')->delete($image->path) in loop, delete PropertyImage records, delete Property
 PropertyController@myProperties(): Property::where('owner_id', auth()->id())->with('images')->latest()->paginate(10) → PropertyCollection
 PropertyController@index() — add filter logic: ->when($request->city, fn($q) => $q->where('city', $request->city)) + min_price, max_price, rooms, status filters, change to ->paginate(10)
 ServiceRequestController@mine(): ServiceRequest::where('user_id', auth()->id())->with(['workerService.worker:id,name,phone'])->latest()->paginate(10)
 ServiceRequestController@incoming(): get $serviceIds = auth()->user()->workerServices()->pluck('id'), ServiceRequest::whereIn('worker_service_id', $serviceIds)->with('user:id,name,phone')->latest()->paginate(10)
 ServiceRequestController@updateStatus($id, UpdateServiceRequestStatusRequest $r): find request, verify workerService->worker_id === auth()->id(), update status
 WorkerServiceController@update($id, StoreWorkerServiceRequest $r): verify ownership, update
 WorkerServiceController@destroy($id): verify ownership, check no pending requests first, delete

AdminController Upgrades

 AdminController@stats(): return { total_users: User::count(), total_workers: User::where('role','worker')->count(), total_properties: Property::count(), total_requests: ServiceRequest::count(), pending_requests: ServiceRequest::where('status','pending')->count() }
 AdminController@users(): add pagination + UserResource::collection

Routes Update

 Add all new routes in correct middleware groups
 Apply 'worker' middleware to worker-only routes
 Apply ['auth:sanctum','admin'] to all /admin/* routes

Code Quality

 Run php artisan route:list — verify all 21 routes registered correctly
 Verify all responses still use envelope structure after resource refactor
 Add Accept: application/json header handling — return JSON errors (not HTML redirects)

Add to bootstrap/app.php: withExceptions(function($e){ $e->shouldRenderJsonWhen(fn($r,$t) => $r->expectsJson()); })





PLAN 3 — Scalable

Goal: Production-ready. Onboard new developer in < 1 day. Full test coverage. Clean domain separation.
Rule: Service layer handles business logic. Repositories handle data access. Controllers handle HTTP only.
LLM Hint: Implement one feature folder at a time. Each is isolated.


New Database Tables — Plan 3
reviews
  id                 BIGINT PK
  user_id            FK → users.id
  worker_service_id  FK → worker_services.id
  rating             TINYINT (1–5)
  comment            TEXT
  created_at, updated_at

activity_logs
  id                 BIGINT PK
  user_id            FK → users.id NULLABLE
  action             VARCHAR(100)   e.g. 'property.status_changed'
  model              VARCHAR(100)   e.g. 'Property'
  model_id           BIGINT
  ip_address         VARCHAR(45)
  created_at
New Endpoints — Plan 3
MethodEndpointAuthDescriptionPOST/api/worker-services/{id}/reviewsBearerSubmit review (only after completed request)GET/api/worker-services/{id}/reviewsPublicGet reviews + avg rating for a serviceGET/api/admin/requestsAdminAll service requests paginatedDELETE/api/admin/reviews/{id}AdminDelete inappropriate reviewPUT/api/admin/properties/{id}AdminForce-update any property statusDELETE/api/admin/users/{id}AdminDelete user accountGET/api/admin/logsAdminActivity audit log with date filter

Task List — Laravel Production
Migrations — Plan 3

 Create create_reviews_table: user_id FK, worker_service_id FK, rating TINYINT, comment TEXT, timestamps
 Create create_activity_logs_table: user_id FK NULLABLE, action VARCHAR(100), model VARCHAR(100), model_id BIGINT, ip_address VARCHAR(45), created_at only (no updated_at)
 Run php artisan migrate

Feature-Based Controller Structure

 Create folder app/Http/Controllers/Auth/ — move AuthController here
 Create folder app/Http/Controllers/Properties/ — move PropertyController here
 Create folder app/Http/Controllers/Services/ — move WorkerServiceController + ServiceRequestController here
 Create folder app/Http/Controllers/Admin/ — move AdminController here
 Create app/Http/Controllers/ReviewController.php in Services folder
 Update all route namespaces accordingly

Service Layer

 Create app/Services/PropertyService.php

 create(array $data, array $imageFiles, int $ownerId): Property — wraps creation in DB::transaction(), handles image storage, creates PropertyImage records
 delete(Property $property): void — deletes images from disk, deletes PropertyImage records, deletes Property — all in transaction
 updateStatus(Property $property, string $newStatus, User $actor): Property — validates status (available→pending, pending→sold or available, available→sold only), updates, logs activity


 Create app/Services/ServiceRequestService.php

 create(array $data, User $requester): ServiceRequest
 updateStatus(ServiceRequest $request, string $newStatus, User $actor): ServiceRequest — verify actor is the worker who owns the service, validate transition (pending→accepted, accepted→completed or cancelled, pending→cancelled), update, log activity


 Inject services into controllers via __construct (not new ServiceName())

Repository Pattern

 Create app/Repositories/Contracts/PropertyRepositoryInterface.php: methods all(array $filters): LengthAwarePaginator, findById(int $id): Property, findByOwner(int $ownerId): LengthAwarePaginator
 Create app/Repositories/EloquentPropertyRepository.php implements PropertyRepositoryInterface
 Create app/Repositories/Contracts/UserRepositoryInterface.php: all(array $filters): LengthAwarePaginator, findById(int $id): User, delete(int $id): void
 Create app/Repositories/EloquentUserRepository.php
 In AppServiceProvider@register: $this->app->bind(PropertyRepositoryInterface::class, EloquentPropertyRepository::class) and same for User
 Inject repositories into relevant controllers/services via constructor

Review Feature

 Create Review model: $fillable = [user_id, worker_service_id, rating, comment], user() belongsTo, workerService() belongsTo
 Add reviews() hasMany to WorkerService model
 ReviewController@store($serviceId): validate rating(integer 1-5) + comment(min:10), check ServiceRequest::where('user_id', auth()->id())->where('worker_service_id', $serviceId)->where('status','completed')->exists() → abort 403 if false, check not already reviewed, create review
 ReviewController@index($serviceId): return reviews with user:id,name, include avg_rating in response meta
 Add avg_rating to WorkerServiceResource: 'avg_rating' => round($this->reviews()->avg('rating'), 1)

Activity Log

 Create ActivityLog model: $fillable, no updated_at (public $timestamps = false + add created_at manually)
 Create app/Traits/LogsActivity.php trait: logActivity(string $action, Model $model, Request $request): void — creates ActivityLog record with auth()->id(), action, model class name, model id, $request->ip()
 Use trait in PropertyService and ServiceRequestService on every state change
 AdminController@logs(Request $r): filter by ?from=2024-01-01&to=2024-12-31, return paginated ActivityLog with user:id,name

Admin Endpoints

 AdminController@requests(): all ServiceRequests paginated with user + workerService relations, filter by ?status=
 AdminController@deleteReview($id): find and delete Review
 AdminController@updateProperty($id, Request $r): admin force-updates status on any property (no ownership check)
 AdminController@deleteUser($id): soft-delete or hard-delete user (add SoftDeletes trait to User if soft)
 Add all routes under /api/admin/* with ['auth:sanctum', 'admin'] middleware

Database Indexes

 Add index: properties.city — $table->index('city')
 Add index: properties.status
 Add index: properties.owner_id
 Add index: worker_services.worker_id
 Add index: worker_services.is_available
 Add index: service_requests.user_id
 Add index: service_requests.worker_service_id
 Add index: service_requests.status
 Run php artisan migrate after adding indexes

Rate Limiting

 In bootstrap/app.php or RouteServiceProvider: RateLimiter::for('api', fn($r) => $r->user() ? Limit::perMinute(200) : Limit::perMinute(60))

PHPUnit Feature Tests

 tests/Feature/AuthTest.php:

 test_user_can_register_as_user
 test_user_can_register_as_worker
 test_user_cannot_register_as_admin
 test_user_can_login_with_correct_credentials
 test_login_fails_with_wrong_password (assert 401)
 test_user_can_logout


 tests/Feature/PropertyTest.php:

 test_anyone_can_list_properties
 test_authenticated_user_can_create_property_with_images
 test_property_requires_at_least_1_image
 test_property_cannot_have_more_than_3_images
 test_owner_can_update_property_status
 test_non_owner_cannot_update_property_status (assert 403)
 test_owner_can_delete_property
 test_non_owner_cannot_delete_property (assert 403)
 test_property_list_filters_by_city
 test_property_list_filters_by_status


 tests/Feature/WorkerServiceTest.php:

 test_worker_can_create_service
 test_user_cannot_create_service (assert 403)
 test_anyone_can_list_services
 test_worker_can_update_own_service
 test_worker_cannot_update_others_service (assert 403)


 tests/Feature/ServiceRequestTest.php:

 test_user_can_create_service_request
 test_worker_can_see_incoming_requests
 test_worker_can_accept_request
 test_worker_can_complete_accepted_request
 test_non_worker_cannot_update_status (assert 403)
 test_wrong_worker_cannot_update_others_request (assert 403)


 tests/Feature/ReviewTest.php:

 test_user_can_review_after_completed_request
 test_user_cannot_review_without_completed_request (assert 403)
 test_user_cannot_review_same_service_twice (assert 422)


 tests/Feature/AdminTest.php:

 test_admin_can_list_users
 test_non_admin_cannot_access_admin_routes (assert 403)
 test_admin_can_see_stats
 test_admin_can_delete_review
 test_admin_can_view_activity_logs


 Run all tests: php artisan test --parallel


Summary
MetricPlan 1 — MVPPlan 2 — StructuredPlan 3 — ScalableEndpoints132128Controllers5 (flat)5 + AdminFeature-based foldersValidationInline in controllerForm Request classesForm Request classesAuthorizationManual abort_ifPolicy classesPolicy classesData formattingRaw modelAPI ResourcesAPI ResourcesBusiness logicIn controllerIn controllerService layerData accessDirect EloquentDirect EloquentRepository patternFilteringNoYes (query params)Yes (query params)PaginationNoYes (10/page)Yes (10/page)ReviewsNoNoYesAudit logNoNoYesTestsManual (Postman)Manual (Postman)PHPUnit full suite

Rule: Each checkbox = one LLM prompt. Always paste the relevant schema section with the task.