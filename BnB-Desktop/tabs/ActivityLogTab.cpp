#include "ActivityLogTab.h"
#include "core/ApiClient.h"
#include "core/DataModels.h"
#include "core/TableManager.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QDateEdit>
#include <QPushButton>
#include <QTableWidget>
#include <QHeaderView>
#include <QJsonArray>
#include <QDate>

ActivityLogTab::ActivityLogTab(QWidget *parent)
    : BaseTab(parent)
{
    // Create the layout for this tab
    QVBoxLayout* mainLayout = new QVBoxLayout(this);

    // Create a layout for the filter controls
    QHBoxLayout* filterLayout = new QHBoxLayout();

    // From date
    filterLayout->addWidget(new QLabel("From:"));
    _fromDate = new QDateEdit();
    _fromDate->setDate(QDate::currentDate().addDays(-7)); // Default: 7 days ago
    _fromDate->setCalendarPopup(true);
    filterLayout->addWidget(_fromDate);

    // To date
    filterLayout->addWidget(new QLabel("To:"));
    _toDate = new QDateEdit();
    _toDate->setDate(QDate::currentDate()); // Default: today
    _toDate->setCalendarPopup(true);
    filterLayout->addWidget(_toDate);

    // Filter button
    _filterBtn = new QPushButton("Filter");
    filterLayout->addWidget(_filterBtn);

    mainLayout->addLayout(filterLayout);

    // Create the table
    _table = new QTableWidget();
    QStringList headers = {"ID", "User", "Action", "Model", "IP Address", "Date"};
    TableManager::setup(_table, headers);
    mainLayout->addWidget(_table);

    // Create refresh button
    _refreshBtn = new QPushButton("Refresh");
    mainLayout->addWidget(_refreshBtn);

    // Status label
    _statusLabel = new QLabel("Ready");
    mainLayout->addWidget(_statusLabel);

    // Connect signals
    connect(_refreshBtn, &QPushButton::clicked, this, &ActivityLogTab::loadData);
    connect(_filterBtn, &QPushButton::clicked, this, &ActivityLogTab::applyFilter);
}

void ActivityLogTab::loadData()
{
    // We'll use the current dates from the date edits
    QDate fromDate = _fromDate->date();
    QDate toDate = _toDate->date();

    // Build the query string
    QString query = QString("?from=%1&to=%2")
        .arg(fromDate.toString("yyyy-MM-dd"))
        .arg(toDate.toString("yyyy-MM-dd"));

    setLoading(true);
    clearStatus();
    // Use a fixed requestId for simplicity
    ApiClient::instance()->get(QString("/admin/logs%1").arg(query), "activity_logs_load",
        [this](QJsonObject data) {
            // Assuming the data is in the "data" field as an array
            QJsonArray logs = data["data"].toArray();
            TableManager::populate(_table, logs, [](QJsonObject logObj) {
                DataModels::ActivityLogModel log = DataModels::ActivityLogModel::fromJson(logObj);
                return QStringList{
                    QString::number(log.id),
                    log.userName,
                    log.action,
                    log.modelName,
                    log.ipAddress,
                    log.createdAt.toString(Qt::ISODate)
                };
            });
            setLoading(false);
        },
        [this](QString message) {
            showError(message);
            setLoading(false);
        });
}

void ActivityLogTab::applyFilter()
{
    // Simply call loadData to refresh with the new dates
    loadData();
}