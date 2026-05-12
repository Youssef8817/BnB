#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QListWidget>
#include <QStackedWidget>
#include <QLabel>
#include <QPushButton>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QToolBar>
#include <QStatusBar>
#include <QCloseEvent>
#include <QShowEvent>

#include "windows/LoginWindow.h"
#include "tabs/UsersTab.h"
#include "tabs/PropertiesTab.h"
#include "tabs/ServicesTab.h"
#include "tabs/RequestsTab.h"
#include "tabs/ReviewsTab.h"
#include "tabs/ActivityLogTab.h"
#include "tabs/StatsTab.h"

class MainWindow : public QMainWindow
{
    Q_OBJECT
public:
    explicit MainWindow(QWidget *parent = nullptr);

protected:
    void showEvent(QShowEvent* event) override;
    void closeEvent(QCloseEvent* event) override;

private:
    QListWidget* sidebar;
    QStackedWidget* stack;
    UsersTab* usersTab;
    PropertiesTab* propertiesTab;
    ServicesTab* servicesTab;
    RequestsTab* requestsTab;
    ReviewsTab* reviewsTab;
    ActivityLogTab* activityLogTab;
    StatsTab* statsTab;
    QLabel* titleLabel;
    QPushButton* logoutBtn;
};

#endif // MAINWINDOW_H