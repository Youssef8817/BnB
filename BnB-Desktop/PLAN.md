B&B — C++ Qt6 QWidgets Desktop Admin Dashboard
Senior Implementation Plans — All 3 Phases

Stack: C++ · Qt6 · QWidgets · QNetworkAccessManager
Role: Admin control panel — manages users, properties, services, requests
App: B&B Real Estate & Home Services Platform


Locked Specifications
#DecisionChoiceQt versionQt6UI frameworkQWidgets (not QML)HTTPQNetworkAccessManagerNo third-party librariesJSONQJsonDocument / QJsonObjectBuilt-in QtAuthBearer token via QSettingsPersists between sessionsAdmin roleMust have role = 'admin' in APIChecked on loginLanguageEnglish onlyLocationText only — displayed as-isNo map widgetPush notificationsNone — removed

Shared Data Contract
API Response Envelope

Every API response uses this exact JSON structure.

json{
  "success": true,
  "data": {},
  "message": "OK",
  "errors": null
}
How to parse in Qt
cppQNetworkReply* reply = ...;
QByteArray responseData = reply->readAll();
QJsonDocument doc = QJsonDocument::fromJson(responseData);
QJsonObject root = doc.object();

bool success = root["success"].toBool();
QJsonObject data = root["data"].toObject();     // single object
QJsonArray items = root["data"].toArray();      // list of items
QString message = root["message"].toString();
Admin-only Endpoints (used by Desktop only)
MethodEndpointDescriptionPOST/api/auth/loginLogin (check role == admin)GET/api/admin/usersAll usersGET/api/admin/statsCount statsGET/api/admin/requestsAll service requestsGET/api/admin/logsActivity audit log (Plan 3)DELETE/api/admin/reviews/{id}Delete review (Plan 3)PUT/api/admin/properties/{id}Force-update property (Plan 3)DELETE/api/admin/users/{id}Delete user (Plan 3)GET/api/propertiesAll properties (public)GET/api/worker-servicesAll worker services (public)


PLAN 1 — MVP

Goal: Working admin panel — login + 3 data tabs. Minimum code.
Rule: No abstraction layers. Direct QNetworkAccessManager calls in each window.
LLM Hint: One task = one LLM prompt. Each class under 200 lines.


Window List — Plan 1 (5 windows/tabs)
#WindowFeatures1LoginWindowEmail + password + login button2MainWindowSidebar + QStackedWidget with 3 tabs3UsersTabQTableWidget: id, name, email, role, phone4PropertiesTabQTableWidget: id, title, city, price, rooms, status5ServicesTabQTableWidget: id, type, worker name, price/unit, available

Folder Structure — Plan 1
bb-admin/
  bb-admin.pro
  main.cpp
  NetworkManager.h / .cpp
  LoginWindow.h / .cpp
  MainWindow.h / .cpp
  UsersTab.h / .cpp
  PropertiesTab.h / .cpp
  ServicesTab.h / .cpp

Task List — C++ Desktop MVP
Project Setup

 Create Qt6 Widgets project named bb-admin in Qt Creator
 In bb-admin.pro add: QT += core gui widgets network
 Set CONFIG += c++17
 Define BASE_URL as QString constant: const QString BASE_URL = "http://YOUR_SERVER_IP/api";

NetworkManager class

 NetworkManager.h: singleton class with static NetworkManager* instance()
 Private: QNetworkAccessManager* _manager
 void setToken(const QString& token) — stores in QSettings("BBAdmin", "Auth") with key "token"
 QString token() — reads from QSettings, returns empty string if not set
 void clearToken() — removes from QSettings
 QNetworkRequest buildRequest(const QString& endpoint) — creates QNetworkRequest(QUrl(BASE_URL + endpoint)), adds Authorization: Bearer {token} header, adds Accept: application/json header, adds Content-Type: application/json header
 void get(const QString& endpoint, QObject* receiver, std::function<void(QJsonObject)> onSuccess, std::function<void(QString)> onError) — calls _manager->get(buildRequest(endpoint)), connects finished signal to lambda that reads reply, parses JSON, checks success, calls onSuccess(data) or onError(message)
 void post(const QString& endpoint, const QJsonObject& body, QObject* receiver, std::function<void(QJsonObject)> onSuccess, std::function<void(QString)> onError) — same but _manager->post(request, QJsonDocument(body).toJson())
 void put(const QString& endpoint, const QJsonObject& body, QObject* receiver, std::function<void(QJsonObject)> onSuccess, std::function<void(QString)> onError) — same with PUT verb

LoginWindow

 UI: QVBoxLayout → centered QFrame (max width 320px) containing: QLabel("B&B Admin") (large bold), QLineEdit* emailEdit, QLineEdit* passwordEdit (EchoMode = Password), QPushButton* loginBtn("Login"), QLabel* errorLabel (red, hidden by default)
 Connect loginBtn::clicked → call NetworkManager::instance()->post("/auth/login", {{"email", email}, {"password", password}}, this, onSuccess, onError)
 onSuccess: check data["user"]["role"].toString() == "admin" — if yes: NetworkManager::instance()->setToken(data["token"].toString()) → MainWindow* w = new MainWindow(); w->show(); this->close() — if no: show errorLabel "Access denied. Admin only."
 onError: show errorLabel with error message
 Disable loginBtn while request is in flight, re-enable on response

MainWindow

 QHBoxLayout as central layout
 Left: QListWidget* sidebar (fixed width 160px) with items: "Users", "Properties", "Services"
 Right: QStackedWidget* stack containing: UsersTab, PropertiesTab, ServicesTab (in this order, indices 0/1/2)
 Connect sidebar->currentRowChanged(int) → stack->setCurrentIndex(int)
 Top: QMenuBar or QToolBar with title label "B&B Admin Dashboard" + QPushButton("Logout") aligned right
 Logout: NetworkManager::instance()->clearToken() → show LoginWindow → close MainWindow
 showEvent: select first sidebar item, call usersTab->loadData()
 Connect sidebar->currentRowChanged to also call loadData() on the tab being shown:

cpp  connect(sidebar, &QListWidget::currentRowChanged, this, [=](int row) {
      stack->setCurrentIndex(row);
      if (row == 0) usersTab->loadData();
      else if (row == 1) propertiesTab->loadData();
      else if (row == 2) servicesTab->loadData();
  });
UsersTab

 UI: QVBoxLayout → QPushButton* refreshBtn("Refresh") + QTableWidget* table
 QStringList headers = {"ID", "Name", "Email", "Role", "Phone", "Created"}
 table->setColumnCount(6) + table->setHorizontalHeaderLabels(headers)
 table->setEditTriggers(QAbstractItemView::NoEditTriggers)
 table->setSelectionBehavior(QAbstractItemView::SelectRows)
 table->horizontalHeader()->setStretchLastSection(true)
 void loadData(): call NetworkManager::instance()->get("/admin/users", this, [=](QJsonObject data){ populateTable(data["data"].toArray()); }, onError)
 void populateTable(QJsonArray users): table->setRowCount(0) → loop array → table->insertRow(row) → table->setItem(row, col, new QTableWidgetItem(value))
 Connect refreshBtn::clicked → loadData()

PropertiesTab

 Same pattern as UsersTab
 Headers: {"ID", "Title", "City", "Price", "Rooms", "Status", "Owner"}
 loadData(): call GET /properties
 Parse: id, title, city, price, rooms, status, owner.name
 Connect double-click table->itemDoubleClicked → show QDialog with all property details in QFormLayout

ServicesTab

 Same pattern
 Headers: {"ID", "Type", "Worker", "Price/Unit", "Unit", "Available"}
 loadData(): call GET /worker-services
 Parse: id, type, worker.name, price_per_unit, unit, is_available → show "Yes"/"No"



PLAN 2 — Structured

Goal: Maintainable admin panel with 7 tabs, proper class hierarchy, reusable components.
Rule: BaseTab abstract class. ApiClient replaces NetworkManager. DataModels namespace.
LLM Hint: Refactor from Plan 1. Each class = one LLM prompt.


Window List — Plan 2 (7 tabs)
#TabAdditions vs Plan 11LoginWindowSame2MainWindowStatsBar at top (4 count cards)3UsersTabSearch QLineEdit + role QComboBox filter4PropertiesTabCity + status filters + property detail QDialog5ServicesTabType filter QComboBox6RequestsTabNEW: all service requests + status filter7StatsPanelNEW: count cards from /api/admin/stats

Folder Structure — Plan 2
bb-admin/
  bb-admin.pro
  main.cpp
  core/
    ApiClient.h / .cpp
    DataModels.h              (all model structs)
    BaseTab.h / .cpp
  windows/
    LoginWindow.h / .cpp
    MainWindow.h / .cpp
  tabs/
    UsersTab.h / .cpp
    PropertiesTab.h / .cpp
    ServicesTab.h / .cpp
    RequestsTab.h / .cpp
    StatsPanel.h / .cpp

Task List — C++ Desktop Structured
ApiClient class (replaces NetworkManager)

 ApiClient.h: singleton class in core/ folder
 Private: QNetworkAccessManager* _manager, QString _baseUrl, QSettings _settings
 static ApiClient* instance() — thread-safe singleton via Q_GLOBAL_STATIC or local static
 void setToken(const QString& t) + QString token() + void clearToken() — via _settings
 QNetworkRequest buildRequest(const QString& endpoint) — adds Authorization, Accept, Content-Type headers
 void get(endpoint, onSuccess, onError) — lambda-based, same as Plan 1 NetworkManager but using _manager->get
 void post(endpoint, QJsonObject, onSuccess, onError) — uses _manager->post
 void put(endpoint, QJsonObject, onSuccess, onError) — uses _manager->sendCustomRequest with PUT verb
 void deleteResource(endpoint, onSuccess, onError) — _manager->deleteResource
 void parseAndDispatch(QNetworkReply*, onSuccess, onError) — shared reply parsing logic, checks success field, dispatches accordingly
 Emit signal void loadingChanged(bool isLoading) — MainWindow connects to update status bar

DataModels namespace (DataModels.h — header only)

 namespace DataModels {
 struct UserModel { int id; QString name, email, phone, role; QDateTime createdAt; static UserModel fromJson(const QJsonObject&); };
 struct PropertyModel { int id; QString title, city, location, status; double price; int rooms; double areaMq; QString ownerName; static PropertyModel fromJson(const QJsonObject&); };
 struct WorkerServiceModel { int id; QString type, description, unit, workerName, workerPhone; double pricePerUnit; bool isAvailable; static WorkerServiceModel fromJson(const QJsonObject&); };
 struct ServiceRequestModel { int id; QString note, address, status, userName; int userId, workerServiceId; QDateTime createdAt; static ServiceRequestModel fromJson(const QJsonObject&); };
 Each fromJson is a static function that reads fields with .toString(), .toInt(), .toDouble(), .toBool()
 } — close namespace

BaseTab class

 BaseTab.h: abstract QWidget subclass
 Protected: QTableWidget* _table, QPushButton* _refreshBtn, QLabel* _statusLabel
 void setupTable(QStringList headers) — sets column count, headers, EditTriggers=None, SelectionBehavior=Rows, StretchLastSection=true, AlternatingRowColors=true
 void setLoading(bool loading) — _refreshBtn->setEnabled(!loading), _statusLabel->setText(loading ? "Loading..." : "Ready")
 void showError(const QString& msg) — _statusLabel->setText("Error: " + msg), _statusLabel->setStyleSheet("color: red")
 void clearStatus() — _statusLabel->setText("Ready"), _statusLabel->setStyleSheet("")
 Pure virtual: virtual void loadData() = 0
 void populateTableFromArray(QJsonArray items, std::function<QStringList(QJsonObject)> rowMapper) — clears table, loops array, calls mapper for each row, inserts items

Refactor existing tabs to inherit BaseTab

 UsersTab : public BaseTab:

 Add QLineEdit* _searchEdit and QComboBox* _roleFilter above table
 loadData() calls ApiClient::instance()->get("/admin/users", ...) → populateTableFromArray(data["data"].toArray(), [](QJsonObject u){ return QStringList{QString::number(u["id"].toInt()), u["name"].toString(), u["email"].toString(), u["role"].toString(), u["phone"].toString()}; })
 Connect _searchEdit->textChanged → filterRows()
 Connect _roleFilter->currentTextChanged → filterRows()
 void filterRows(): loop _table rows, check if name/email contains search text AND role matches filter → _table->setRowHidden(row, !matches)


 PropertiesTab : public BaseTab:

 Add QComboBox* _cityFilter + QComboBox* _statusFilter
 loadData() calls GET /properties
 Connect filters → filterRows() (client-side filtering)
 Connect _table->itemDoubleClicked → open PropertyDetailDialog(rowData)


 ServicesTab : public BaseTab:

 Add QComboBox* _typeFilter with options: All, plumbing, painting, tiling, electrical, carpentry, finishing
 loadData() calls GET /worker-services
 Connect filter → filterRows()



RequestsTab (new)

 RequestsTab : public BaseTab
 Headers: {"ID", "User", "Service Type", "Worker", "Address", "Status", "Date"}
 loadData(): call ApiClient::instance()->get("/admin/requests", ...) → populate
 Add QComboBox* _statusFilter (All, pending, accepted, completed, cancelled)
 Connect filter → client-side filterRows()
 Add QTimer* _autoRefresh = new QTimer(this) → connect(_autoRefresh, &QTimer::timeout, this, &RequestsTab::loadData) → start with 60000ms when tab shown

StatsPanel (new, not BaseTab)

 StatsPanel : public QWidget
 QHBoxLayout with 5 QFrame cards, each card has:

 QLabel* titleLabel (small, grey)
 QLabel* countLabel (large, bold, colored)


 Cards: "Total Users", "Total Workers", "Properties", "Requests", "Pending"
 void loadStats(): call ApiClient::instance()->get("/admin/stats", ...) → data["total_users"] etc → set each countLabel text
 QPushButton* refreshBtn on the right → re-call loadStats()

PropertyDetailDialog

 PropertyDetailDialog(DataModels::PropertyModel model, QWidget* parent) : QDialog
 QFormLayout with all property fields as read-only QLabel values
 Close button at bottom
 Title: "Property #" + QString::number(model.id)

MainWindow update

 Add StatsPanel* _statsPanel above the main QHBoxLayout
 Add RequestsTab* _requestsTab to QStackedWidget at index 3
 Add "Requests" to sidebar at index 3
 QStatusBar at bottom: show loading state from ApiClient::loadingChanged signal
 On login success: call _statsPanel->loadStats()
 Auto-refresh timer for RequestsTab: start when it's the visible tab, stop when switching away



PLAN 3 — Full Admin System

Goal: 9 tabs, complete admin control, charts, CSV export, audit log. Production quality.
Rule: Full async ApiClient with signals. DataModels fully bidirectional. Chart widget custom-painted.
LLM Hint: One class per prompt. Start with ApiClient refactor, then build new tabs one by one.


Window List — Plan 3 (9 tabs)
#TabFeatures1LoginWindowSame + remember-me (save email in QSettings)2MainWindowStats header + sidebar + QStackedWidget + full toolbar3UsersTabSearch, role filter, delete action, CSV export4PropertiesTabAll filters + force-update status + detail dialog5ServicesTabType filter + activate/deactivate toggle6RequestsTabStatus filter + auto-refresh 60s7ReviewsTabNEW: all reviews + delete inappropriate8StatsTabCount cards + QPainter bar chart9ActivityLogTabNEW: audit log with date range filter

Folder Structure — Plan 3
bb-admin/
  bb-admin.pro
  main.cpp
  core/
    ApiClient.h / .cpp
    DataModels.h
    BaseTab.h / .cpp
    TableManager.h / .cpp
    ChartWidget.h / .cpp
    CsvExporter.h / .cpp
    SettingsManager.h / .cpp
  windows/
    LoginWindow.h / .cpp
    MainWindow.h / .cpp
  tabs/
    UsersTab.h / .cpp
    PropertiesTab.h / .cpp
    ServicesTab.h / .cpp
    RequestsTab.h / .cpp
    ReviewsTab.h / .cpp
    StatsTab.h / .cpp
    ActivityLogTab.h / .cpp
  dialogs/
    PropertyDetailDialog.h / .cpp
    ConfirmDialog.h / .cpp

Task List — C++ Desktop Production
ApiClient full refactor

 Upgrade ApiClient to use proper Qt signals/slots pattern:

Emit void requestSuccess(const QString& requestId, QJsonObject data) signal
Emit void requestError(const QString& requestId, const QString& message) signal
Each get/post/put/deleteResource takes a requestId string for disambiguation


 Handle multiple concurrent requests — QMap<QNetworkReply*, QString> _pendingRequests to track requestId per reply
 Add void deleteResource(const QString& endpoint, ...) method
 Emit void loadingChanged(bool) — tracks count of pending requests: increment on send, decrement on finish

DataModels — add Plan 3 models

 struct ReviewModel { int id; QString userName, comment; int rating; QDateTime createdAt; static ReviewModel fromJson(const QJsonObject&); QString starString() const { return QString("★").repeated(rating) + QString("☆").repeated(5-rating); } };
 struct ActivityLogModel { int id; int userId; QString userName, action, modelName, ipAddress; QDateTime createdAt; static ActivityLogModel fromJson(const QJsonObject&); };
 Add toJson() to PropertyModel and UserModel for PUT/DELETE calls

TableManager class (core/TableManager.h)

 class TableManager { public:
 static void setup(QTableWidget* t, QStringList headers, bool alternating = true) — sets all standard properties
 static void populate(QTableWidget* t, QJsonArray data, std::function<QStringList(QJsonObject)> rowMapper) — clears + fills
 static void filterByText(QTableWidget* t, const QString& query, QList<int> columns = {}) — hide rows not matching; empty columns = all columns
 static void filterByValue(QTableWidget* t, const QString& value, int column) — hide rows where column != value (empty value = show all)
 static void addActionButton(QTableWidget* t, int row, int column, const QString& label, std::function<void()> onClick) — creates QPushButton, uses setCellWidget
 };

ChartWidget (core/ChartWidget.h)

 class ChartWidget : public QWidget { Q_OBJECT
 void setData(const QMap<QString, int>& data) — stores data, calls update()
 void setTitle(const QString& title)
 void setBarColor(const QColor& color)
 Override paintEvent(QPaintEvent*):

Compute maxValue from data
Compute barWidth = (width() - padding) / data.size()
Loop data: compute barHeight = (value / maxValue) * (height() - bottomPadding - topPadding)
painter.fillRect(x, y, barWidth-gap, barHeight, _barColor)
painter.drawText(...) for label below bar and value above bar
Draw title at top center


 Override sizeHint() → QSize(400, 250)
 };

CsvExporter (core/CsvExporter.h — header only)

 class CsvExporter { public:
 static bool exportTable(QTableWidget* table, QWidget* parent, const QString& defaultName = "export"):

QString filePath = QFileDialog::getSaveFileName(parent, "Export CSV", defaultName + ".csv", "CSV (*.csv)")
If empty → return false
Open QFile, write header row from horizontalHeaderItem
Loop visible rows only: collect cell texts, join with ,, handle commas inside values with " wrapping
Return true on success, show QMessageBox::information "Exported successfully"


 };

SettingsManager (core/SettingsManager.h — header only)

 class SettingsManager { public:
 static QString token() + static void setToken(QString) + static void clearToken()
 static QString savedEmail() + static void setSavedEmail(QString)
 static void saveWindowGeometry(QWidget* w) → settings.setValue("geometry", w->saveGeometry())
 static void restoreWindowGeometry(QWidget* w) → w->restoreGeometry(settings.value("geometry").toByteArray())
 Private static: static QSettings& settings() { static QSettings s("BBAdmin", "App"); return s; }
 };

ReviewsTab (new)

 ReviewsTab : public BaseTab
 Headers: {"ID", "Service Type", "User", "Rating", "Comment", "Date", "Action"}
 loadData(): call GET /admin/reviews (add this endpoint to Laravel: returns all reviews paginated)
 Parse each row: use model.starString() for rating column
 "Delete" button in Action column via TableManager::addActionButton:

onClick lambda: show ConfirmDialog("Delete this review?") → if confirmed → ApiClient::deleteResource("/admin/reviews/" + id, ...) → loadData()



ActivityLogTab (new)

 ActivityLogTab : public BaseTab
 Headers: {"ID", "User", "Action", "Model", "IP Address", "Date"}
 UI extras above table: QLabel("From:") + QDateEdit* fromDate + QLabel("To:") + QDateEdit* toDate + QPushButton("Filter")
 Default: from = 7 days ago, to = today
 loadData(): build URL with ?from=YYYY-MM-DD&to=YYYY-MM-DD → call GET /admin/logs → populate
 Connect Filter button → loadData()

StatsTab upgrade

 Replace StatsPanel with full StatsTab : public QWidget
 Top section: 5 QFrame count cards (same as Plan 2 StatsPanel)
 Bottom section: ChartWidget for "Properties by City" — fetch property list, group by city client-side using QMap<QString,int>, pass to ChartWidget
 QPushButton("Refresh") + QLabel* lastUpdatedLabel ("Last updated: HH:mm:ss")

UsersTab additions

 "Delete User" action via right-click QMenu context menu:

Connect _table->customContextMenuRequested → setContextMenuPolicy(Qt::CustomContextMenu)
Show QMenu with "Delete User" action → confirm → ApiClient::deleteResource("/admin/users/" + id) → remove row from table


 "Export CSV" button → CsvExporter::exportTable(_table, this, "users")

LoginWindow additions

 "Remember email" QCheckBox below email field
 showEvent: if (SettingsManager::savedEmail() != "") emailEdit->setText(savedEmail) and check checkbox
 On successful login: if (rememberCheckbox->isChecked()) SettingsManager::setSavedEmail(emailEdit->text())

MainWindow additions

 showEvent / closeEvent: call SettingsManager::saveWindowGeometry(this) and restoreWindowGeometry
 QStatusBar at bottom: connect to ApiClient::loadingChanged — show "Loading..." / "Ready"
 API errors: connect(ApiClient::instance(), &ApiClient::requestError, this, [=](QString id, QString msg){ statusBar()->showMessage("Error: " + msg, 5000); }) — uses status bar, not QMessageBox (less disruptive)

ConfirmDialog (dialogs/ConfirmDialog.h)

 class ConfirmDialog { public: static bool ask(QWidget* parent, const QString& message, const QString& title = "Confirm") { return QMessageBox::question(parent, title, message, QMessageBox::Yes | QMessageBox::No) == QMessageBox::Yes; } };


Summary
MetricPlan 1 — MVPPlan 2 — StructuredPlan 3 — ProductionTabs/Windows579HTTP classNetworkManager (simple)ApiClient (singleton)ApiClient (full signals)Table logicManual in each tabBaseTab::populateTableFromArrayTableManager static classData parsingInline in callbacksDataModels::fromJson structsDataModels + toJsonFiltersNoneClient-side QComboBoxClient-side + date rangeChartsNoneStatsPanel (count cards only)ChartWidget (QPainter bars)CSV ExportNoneNoneCsvExporter static classReviews tabNoneNoneYes + delete actionAudit log tabNoneNoneYes + date filterSettingsToken onlyToken onlySettingsManager (all)Delete actionsNoneNoneUsers + Reviews

Rule: Each checkbox = one LLM prompt.
Always paste the relevant DataModels struct definition with the task.
Never mix API logic into tab/window classes — keep it in ApiClient only.