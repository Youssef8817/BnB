#include "RequestsTab.h"
#include "core/ApiClient.h"
#include "core/DataModels.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QComboBox>
#include <QPushButton>
#include <QTableWidget>
#include <QHeaderView>
#include <QJsonArray>
#include <QTimer>

RequestsTab::RequestsTab(QWidget *parent)
    : BaseTab(parent)
{
    // Create the layout for this tab
    QVBoxLayout* mainLayout = new QVBoxLayout(this);

    // Create a layout for the filter controls
    QHBoxLayout* filterLayout = new QHBoxLayout();

    // Status filter
    _statusFilter = new QComboBox();
    _statusFilter->addItem("All");
    _statusFilter->addItem("pending");
    _statusFilter->addItem("accepted");
    _statusFilter->addItem("completed");
    _statusFilter->addItem("cancelled");
    filterLayout->addWidget(new QLabel("Status:"));
    filterLayout->addWidget(_statusFilter);

    mainLayout->addLayout(filterLayout);

    // Create the table
    _table = new QTableWidget();
    QStringList headers = {"ID", "User", "Service Type", "Worker", "Address", "Status", "Date"};
    setupTable(headers);
    mainLayout->addWidget(_table);

    // Create refresh button
    _refreshBtn = new QPushButton("Refresh");
    mainLayout->addWidget(_refreshBtn);

    // Status label
    _statusLabel = new QLabel("Ready");
    mainLayout->addWidget(_statusLabel);

    // Set up auto-refresh timer
    _autoRefreshTimer = new QTimer(this);
    _autoRefreshTimer->setInterval(60000); // 60 seconds

    // Connect signals
    connect(_refreshBtn, &QPushButton::clicked, this, &RequestsTab::loadData);
    connect(_statusFilter, &QComboBox::currentTextChanged, this, &RequestsTab::filterRows);
    connect(_autoRefreshTimer, &QTimer::timeout, this, &RequestsTab::autoRefresh);
}

void RequestsTab::loadData()
{
    setLoading(true);
    clearStatus();
    ApiClient::instance()->get("/admin/requests", "requests_load",
        [this](QJsonObject data) {
            // Assuming the data is in the "data" field as an array
            QJsonArray requests = data["data"].toArray();
            populateTableFromArray(requests, [](QJsonObject requestObj) {
                DataModels::ServiceRequestModel request = DataModels::ServiceRequestModel::fromJson(requestObj);
                return QStringList{
                    QString::number(request.id),
                    request.userName,
                    request.serviceType,
                    request.workerName,
                    request.address,
                    request.status,
                    request.createdAt.toString(Qt::ISODate)
                };
            });
            setLoading(false);
        },
        [this](QString message) {
            showError(message);
            setLoading(false);
        });
}

void RequestsTab::filterRows()
{
    QString statusFilter = _statusFilter->currentText();

    for (int row = 0; row < _table->rowCount(); ++row) {
        bool matches = true;

        // Check status filter (column 5)
        if (matches && statusFilter != "All") {
            QString status = _table->item(row, 5)->text();
            if (status != statusFilter) {
                matches = false;
            }
        }

        _table->setRowHidden(row, !matches);
    }
}

void RequestsTab::autoRefresh()
{
    // Only refresh if the tab is currently visible
    // We assume that the parent (MainWindow) will handle starting and stopping the timer based on visibility.
    // For now, we just refresh.
    loadData();
}

void RequestsTab::startAutoRefresh()
{
    _autoRefreshTimer->start();
}

void RequestsTab::stopAutoRefresh()
{
    _autoRefreshTimer->stop();
}