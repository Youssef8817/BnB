#include "ActivityLogTab.h"
#include "core/ApiClient.h"
#include "core/DataModels.h"
#include "core/TableManager.h"
#include "core/Theme.h"
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
    QVBoxLayout* mainLayout = new QVBoxLayout(this);
    mainLayout->setContentsMargins(24, 20, 24, 20);
    mainLayout->setSpacing(16);

    // ── Header ────────────────────────────────────────────────────────────────
    QLabel* heading = new QLabel("Activity Log");
    heading->setStyleSheet(QString(R"(
        QLabel {
            color: %1; font-size: 20px; font-weight: 800;
            letter-spacing: -0.3px; background: transparent; border: none;
        }
    )").arg(Theme::TEXT_PRIMARY));
    mainLayout->addWidget(heading);

    // ── Filter row ────────────────────────────────────────────────────────────
    QHBoxLayout* filterLayout = new QHBoxLayout();
    filterLayout->setSpacing(10);

    QLabel* fromLbl = new QLabel("From:");
    fromLbl->setStyleSheet("background: transparent; border: none;");
    filterLayout->addWidget(fromLbl);

    _fromDate = new QDateEdit();
    _fromDate->setDate(QDate::currentDate().addDays(-7));
    _fromDate->setCalendarPopup(true);
    _fromDate->setFixedHeight(38);
    filterLayout->addWidget(_fromDate);

    QLabel* toLbl = new QLabel("To:");
    toLbl->setStyleSheet("background: transparent; border: none;");
    filterLayout->addWidget(toLbl);

    _toDate = new QDateEdit();
    _toDate->setDate(QDate::currentDate());
    _toDate->setCalendarPopup(true);
    _toDate->setFixedHeight(38);
    filterLayout->addWidget(_toDate);

    _filterBtn = new QPushButton("Apply Filter");
    _filterBtn->setFixedHeight(38);
    _filterBtn->setCursor(Qt::PointingHandCursor);
    filterLayout->addWidget(_filterBtn);

    filterLayout->addStretch();

    _refreshBtn = new QPushButton("Refresh");
    _refreshBtn->setFixedHeight(38);
    _refreshBtn->setCursor(Qt::PointingHandCursor);
    filterLayout->addWidget(_refreshBtn);

    mainLayout->addLayout(filterLayout);

    // ── Table ─────────────────────────────────────────────────────────────────
    _table = new QTableWidget();
    QStringList headers = {"ID", "User", "Action", "Model", "IP Address", "Date"};
    TableManager::setup(_table, headers);
    setupTable(headers);
    mainLayout->addWidget(_table, 1);

    // ── Status ────────────────────────────────────────────────────────────────
    _statusLabel = new QLabel("Ready");
    clearStatus();
    mainLayout->addWidget(_statusLabel);

    connect(_refreshBtn, &QPushButton::clicked, this, &ActivityLogTab::loadData);
    connect(_filterBtn,  &QPushButton::clicked, this, &ActivityLogTab::applyFilter);
}

void ActivityLogTab::loadData()
{
    QDate fromDate = _fromDate->date();
    QDate toDate   = _toDate->date();
    QString query  = QString("?per_page=500&from=%1&to=%2")
        .arg(fromDate.toString("yyyy-MM-dd"))
        .arg(toDate.toString("yyyy-MM-dd"));

    setLoading(true);
    ApiClient::instance()->get(QString("/admin/logs%1").arg(query), "activity_logs_load",
        [this](QJsonObject data) {
            QJsonArray logs = data["data"].toArray();
            TableManager::populate(_table, logs, [](QJsonObject obj) {
                DataModels::ActivityLogModel log = DataModels::ActivityLogModel::fromJson(obj);
                return QStringList{
                    QString::number(log.id),
                    log.userName,
                    log.action,
                    log.modelName,
                    log.ipAddress,
                    log.createdAt.toString("yyyy-MM-dd hh:mm")
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
    loadData();
}
