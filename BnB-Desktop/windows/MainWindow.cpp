#include "MainWindow.h"
#include "core/ApiClient.h"
#include "core/SettingsManager.h"
#include <QApplication>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QLabel>
#include <QPushButton>
#include <QListWidget>
#include <QStackedWidget>
#include <QToolBar>
#include <QStatusBar>
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
    resize(1280, 800);

    // Central widget
    QWidget* centralWidget = new QWidget(this);
    setCentralWidget(centralWidget);
    QVBoxLayout* mainLayout = new QVBoxLayout(centralWidget);

    // We don't have a separate stats panel at the top in Plan 3 because we have a full StatsTab.
    // Instead, we will have the StatsTab as one of the tabs in the stacked widget.

    // Horizontal layout for sidebar and stacked widget
    QHBoxLayout* contentLayout = new QHBoxLayout();
    mainLayout->addLayout(contentLayout);

    // Sidebar
    sidebar = new QListWidget();
    sidebar->setFixedWidth(160);
    sidebar->addItem("Users");
    sidebar->addItem("Properties");
    sidebar->addItem("Services");
    sidebar->addItem("Requests");
    sidebar->addItem("Reviews");
    sidebar->addItem("Stats");
    sidebar->addItem("Activity Log");
    contentLayout->addWidget(sidebar);

    // Stacked widget for tabs
    stack = new QStackedWidget();
    contentLayout->addWidget(stack);

    // Create tabs
    usersTab = new UsersTab();
    propertiesTab = new PropertiesTab();
    servicesTab = new ServicesTab();
    requestsTab = new RequestsTab();
    reviewsTab = new ReviewsTab();
    statsTab = new StatsTab();
    activityLogTab = new ActivityLogTab();

    stack->addWidget(usersTab);        // index 0
    stack->addWidget(propertiesTab);   // index 1
    stack->addWidget(servicesTab);     // index 2
    stack->addWidget(requestsTab);     // index 3
    stack->addWidget(reviewsTab);      // index 4
    stack->addWidget(statsTab);        // index 5
    stack->addWidget(activityLogTab);  // index 6

    // Toolbar for title and logout
    QToolBar* toolbar = new QToolBar();
    toolbar->setMovable(false);
    addToolBar(toolbar);

    titleLabel = new QLabel("B&B Admin Dashboard");
    QFont font = titleLabel->font();
    font.setPointSize(14);
    font.setBold(true);
    titleLabel->setFont(font);
    toolbar->addWidget(titleLabel);

    toolbar->addSeparator();

    logoutBtn = new QPushButton("Logout");
    toolbar->addWidget(logoutBtn);

    // Status bar
    statusBar()->showMessage("Ready");

    // Connect sidebar to stacked widget and handle tab loading and auto-refresh for RequestsTab
    connect(sidebar, &QListWidget::currentRowChanged, this, [=](int row) {
        stack->setCurrentIndex(row);

        // Handle auto-refresh for RequestsTab (index 3)
        if (row == 3) {
            // Start the timer for RequestsTab when it becomes visible
            requestsTab->startAutoRefresh();
        } else {
            // Stop the timer for RequestsTab when switching away
            requestsTab->stopAutoRefresh();
        }

        // Load data for the tab being shown
        switch (row) {
        case 0:
            usersTab->loadData();
            break;
        case 1:
            propertiesTab->loadData();
            break;
        case 2:
            servicesTab->loadData();
            break;
        case 3:
            requestsTab->loadData();
            break;
        case 4:
            reviewsTab->loadData();
            break;
        case 5:
            statsTab->loadData(); // Assuming StatsTab has a loadData method
            break;
        case 6:
            activityLogTab->loadData();
            break;
        default:
            break;
        }
    });

    // Connect logout button
    connect(logoutBtn, &QPushButton::clicked, this, [=]() {
        ApiClient::instance()->clearToken();
        SettingsManager::clearToken(); // Also clear token in SettingsManager if used
        LoginWindow* loginWindow = new LoginWindow();
        loginWindow->show();
        this->close();
    });

    // Select first tab by default
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