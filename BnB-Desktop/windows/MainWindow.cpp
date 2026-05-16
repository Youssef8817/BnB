#include "MainWindow.h"
#include "core/ApiClient.h"
#include "core/SettingsManager.h"
#include "core/Theme.h"
#include <QApplication>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QLabel>
#include <QPushButton>
#include <QListWidget>
#include <QStackedWidget>
#include <QToolBar>
#include <QStatusBar>
#include <QFrame>
#include "windows/LoginWindow.h"
#include "tabs/UsersTab.h"
#include "tabs/PropertiesTab.h"
#include "tabs/ServicesTab.h"
#include "tabs/RequestsTab.h"
#include "tabs/ReviewsTab.h"
#include "tabs/ActivityLogTab.h"
#include "tabs/StatsTab.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    setWindowTitle("B&B Admin Dashboard");
    resize(1340, 840);
    setMinimumSize(900, 600);

    // ── Toolbar ──────────────────────────────────────────────────────────────
    QToolBar* toolbar = new QToolBar();
    toolbar->setMovable(false);
    toolbar->setIconSize(QSize(0, 0));
    addToolBar(toolbar);

    // Brand section
    QWidget* brandWidget = new QWidget();
    brandWidget->setStyleSheet("background: transparent;");
    QHBoxLayout* brandLayout = new QHBoxLayout(brandWidget);
    brandLayout->setContentsMargins(4, 0, 0, 0);
    brandLayout->setSpacing(10);

    QLabel* logoLabel = new QLabel("B&B");
    logoLabel->setFixedSize(36, 36);
    logoLabel->setAlignment(Qt::AlignCenter);
    logoLabel->setStyleSheet(QString(R"(
        QLabel {
            background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                stop:0 %1, stop:1 %2);
            border-radius: 10px;
            border: none;
            color: #FFFFFF;
            font-size: 12px;
            font-weight: 800;
        }
    )").arg(Theme::ACCENT_DEEP, Theme::CYAN));
    brandLayout->addWidget(logoLabel);

    titleLabel = new QLabel("B&B Admin Dashboard");
    titleLabel->setStyleSheet(QString(R"(
        QLabel {
            color: %1;
            font-size: 15px;
            font-weight: 700;
            letter-spacing: -0.3px;
            background: transparent;
        }
    )").arg(Theme::TEXT_PRIMARY));
    brandLayout->addWidget(titleLabel);
    toolbar->addWidget(brandWidget);

    // Spacer
    QWidget* spacer = new QWidget();
    spacer->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Preferred);
    spacer->setStyleSheet("background: transparent;");
    toolbar->addWidget(spacer);

    // Logout button
    logoutBtn = new QPushButton("  Logout");
    logoutBtn->setObjectName("outlineBtn");
    logoutBtn->setFixedHeight(34);
    logoutBtn->setCursor(Qt::PointingHandCursor);
    toolbar->addWidget(logoutBtn);
    toolbar->addSeparator();

    // ── Status bar ───────────────────────────────────────────────────────────
    statusBar()->showMessage("Ready");

    // ── Central layout ───────────────────────────────────────────────────────
    QWidget* central = new QWidget(this);
    central->setStyleSheet(QString("background-color: %1;").arg(Theme::BG));
    setCentralWidget(central);

    QHBoxLayout* hLayout = new QHBoxLayout(central);
    hLayout->setContentsMargins(0, 0, 0, 0);
    hLayout->setSpacing(0);

    // ── Sidebar ──────────────────────────────────────────────────────────────
    QWidget* sidebarContainer = new QWidget();
    sidebarContainer->setFixedWidth(200);
    sidebarContainer->setStyleSheet(QString("background-color: %1;").arg(Theme::SURFACE));
    QVBoxLayout* sidebarLayout = new QVBoxLayout(sidebarContainer);
    sidebarLayout->setContentsMargins(0, 12, 0, 12);
    sidebarLayout->setSpacing(0);

    // Section label
    QLabel* navLabel = new QLabel("NAVIGATION");
    navLabel->setStyleSheet(QString(R"(
        QLabel {
            color: %1;
            font-size: 10px;
            font-weight: 700;
            letter-spacing: 1.2px;
            padding: 8px 20px 4px 20px;
            background: transparent;
            border: none;
        }
    )").arg(Theme::TEXT_MUTED));
    sidebarLayout->addWidget(navLabel);

    sidebar = new QListWidget();
    sidebar->setStyleSheet("QListWidget { border: none; background: transparent; }");

    struct NavItem { QString icon; QString label; };
    QList<NavItem> navItems = {
        {"👥", "Users"},
        {"🏠", "Properties"},
        {"🔧", "Services"},
        {"📋", "Requests"},
        {"⭐", "Reviews"},
        {"📊", "Stats"},
        {"📜", "Activity Log"},
    };
    for (const auto& item : navItems) {
        sidebar->addItem(QString("  %1  %2").arg(item.icon, item.label));
    }
    sidebarLayout->addWidget(sidebar, 1);

    // Version footer
    QLabel* versionLabel = new QLabel("v1.0  ·  Admin");
    versionLabel->setStyleSheet(QString(R"(
        QLabel {
            color: %1; font-size: 11px;
            padding: 8px 20px;
            background: transparent; border: none;
        }
    )").arg(Theme::TEXT_MUTED));
    sidebarLayout->addWidget(versionLabel);

    hLayout->addWidget(sidebarContainer);

    // Separator
    QFrame* sep = new QFrame();
    sep->setFrameShape(QFrame::VLine);
    sep->setStyleSheet("QFrame { border: none; background-color: rgba(255,255,255,0.07); width: 1px; }");
    sep->setFixedWidth(1);
    hLayout->addWidget(sep);

    // ── Stacked content area ──────────────────────────────────────────────────
    QWidget* contentArea = new QWidget();
    contentArea->setStyleSheet(QString("background-color: %1;").arg(Theme::BG));
    QVBoxLayout* contentLayout = new QVBoxLayout(contentArea);
    contentLayout->setContentsMargins(0, 0, 0, 0);
    contentLayout->setSpacing(0);

    stack = new QStackedWidget();
    contentLayout->addWidget(stack);
    hLayout->addWidget(contentArea, 1);

    // ── Create tabs ───────────────────────────────────────────────────────────
    usersTab       = new UsersTab();
    propertiesTab  = new PropertiesTab();
    servicesTab    = new ServicesTab();
    requestsTab    = new RequestsTab();
    reviewsTab     = new ReviewsTab();
    statsTab       = new StatsTab();
    activityLogTab = new ActivityLogTab();

    stack->addWidget(usersTab);       // 0
    stack->addWidget(propertiesTab);  // 1
    stack->addWidget(servicesTab);    // 2
    stack->addWidget(requestsTab);    // 3
    stack->addWidget(reviewsTab);     // 4
    stack->addWidget(statsTab);       // 5
    stack->addWidget(activityLogTab); // 6

    // ── Connections ───────────────────────────────────────────────────────────
    connect(sidebar, &QListWidget::currentRowChanged, this, [=](int row) {
        stack->setCurrentIndex(row);

        if (row == 3)
            requestsTab->startAutoRefresh();
        else
            requestsTab->stopAutoRefresh();

        switch (row) {
        case 0: usersTab->loadData();       break;
        case 1: propertiesTab->loadData();  break;
        case 2: servicesTab->loadData();    break;
        case 3: requestsTab->loadData();    break;
        case 4: reviewsTab->loadData();     break;
        case 5: statsTab->loadData();       break;
        case 6: activityLogTab->loadData(); break;
        }
    });

    connect(logoutBtn, &QPushButton::clicked, this, [=]() {
        ApiClient::instance()->clearToken();
        SettingsManager::clearToken();
        LoginWindow* loginWindow = new LoginWindow();
        loginWindow->show();
        this->close();
    });

    sidebar->setCurrentRow(0);
}

void MainWindow::showEvent(QShowEvent* event)
{
    QMainWindow::showEvent(event);
    SettingsManager::restoreWindowGeometry(this);
}

void MainWindow::closeEvent(QCloseEvent* event)
{
    SettingsManager::saveWindowGeometry(this);
    event->accept();
}
