#include "RequestsTab.h"
#include "core/ApiClient.h"
#include "core/DataModels.h"
#include "core/Theme.h"
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
    QVBoxLayout* mainLayout = new QVBoxLayout(this);
    mainLayout->setContentsMargins(24, 20, 24, 20);
    mainLayout->setSpacing(16);

    // ── Header ────────────────────────────────────────────────────────────────
    QHBoxLayout* headerRow = new QHBoxLayout();
    QLabel* heading = new QLabel("Service Requests");
    heading->setStyleSheet(QString(R"(
        QLabel {
            color: %1; font-size: 20px; font-weight: 800;
            letter-spacing: -0.3px; background: transparent; border: none;
        }
    )").arg(Theme::TEXT_PRIMARY));
    headerRow->addWidget(heading);
    headerRow->addStretch();

    QLabel* autoLabel = new QLabel("Auto-refreshes every 60s");
    autoLabel->setStyleSheet(QString(R"(
        QLabel {
            color: %1; font-size: 11px;
            background: rgba(79,195,247,0.08);
            border: 1px solid rgba(79,195,247,0.20);
            border-radius: 6px;
            padding: 4px 10px;
        }
    )").arg(Theme::CYAN));
    headerRow->addWidget(autoLabel);
    mainLayout->addLayout(headerRow);

    // ── Filter row ────────────────────────────────────────────────────────────
    QHBoxLayout* filterLayout = new QHBoxLayout();
    filterLayout->setSpacing(10);

    _statusFilter = new QComboBox();
    _statusFilter->setFixedHeight(38);
    _statusFilter->addItem("All Statuses");
    _statusFilter->addItem("pending");
    _statusFilter->addItem("accepted");
    _statusFilter->addItem("completed");
    _statusFilter->addItem("cancelled");
    filterLayout->addWidget(_statusFilter);
    filterLayout->addStretch();

    _refreshBtn = new QPushButton("Refresh");
    _refreshBtn->setFixedHeight(38);
    _refreshBtn->setCursor(Qt::PointingHandCursor);
    filterLayout->addWidget(_refreshBtn);

    mainLayout->addLayout(filterLayout);

    // ── Table ─────────────────────────────────────────────────────────────────
    _table = new QTableWidget();
    QStringList headers = {"ID", "User", "Service Type", "Worker", "Address", "Status", "Date"};
    setupTable(headers);
    mainLayout->addWidget(_table, 1);

    // ── Status ────────────────────────────────────────────────────────────────
    _statusLabel = new QLabel("Ready");
    clearStatus();
    mainLayout->addWidget(_statusLabel);

    // Auto-refresh timer
    _autoRefreshTimer = new QTimer(this);
    _autoRefreshTimer->setInterval(60000);

    connect(_refreshBtn,   &QPushButton::clicked, this, &RequestsTab::loadData);
    connect(_statusFilter, &QComboBox::currentTextChanged, this, &RequestsTab::filterRows);
    connect(_autoRefreshTimer, &QTimer::timeout, this, &RequestsTab::autoRefresh);
}

void RequestsTab::loadData()
{
    setLoading(true);
    ApiClient::instance()->get("/admin/requests?per_page=500", "requests_load",
        [this](QJsonObject data) {
            QJsonArray requests = data["data"].toArray();
            populateTableFromArray(requests, [](QJsonObject obj) {
                DataModels::ServiceRequestModel r = DataModels::ServiceRequestModel::fromJson(obj);
                return QStringList{
                    QString::number(r.id),
                    r.userName,
                    r.serviceType,
                    r.workerName,
                    r.address,
                    r.status,
                    r.createdAt.toString("yyyy-MM-dd")
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
    QString filter = _statusFilter->currentText();
    for (int row = 0; row < _table->rowCount(); ++row) {
        bool ok = (filter == "All Statuses") || (_table->item(row, 5)->text() == filter);
        _table->setRowHidden(row, !ok);
    }
}

void RequestsTab::autoRefresh()
{
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
