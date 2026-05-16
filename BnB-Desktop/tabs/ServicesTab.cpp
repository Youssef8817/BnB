#include "ServicesTab.h"
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

ServicesTab::ServicesTab(QWidget *parent)
    : BaseTab(parent)
{
    QVBoxLayout* mainLayout = new QVBoxLayout(this);
    mainLayout->setContentsMargins(24, 20, 24, 20);
    mainLayout->setSpacing(16);

    // ── Header ────────────────────────────────────────────────────────────────
    QLabel* heading = new QLabel("Services");
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

    _typeFilter = new QComboBox();
    _typeFilter->setFixedHeight(38);
    _typeFilter->addItem("All Types");
    _typeFilter->addItem("plumbing");
    _typeFilter->addItem("painting");
    _typeFilter->addItem("tiling");
    _typeFilter->addItem("electrical");
    _typeFilter->addItem("carpentry");
    _typeFilter->addItem("finishing");
    filterLayout->addWidget(_typeFilter);
    filterLayout->addStretch();

    _refreshBtn = new QPushButton("Refresh");
    _refreshBtn->setFixedHeight(38);
    _refreshBtn->setCursor(Qt::PointingHandCursor);
    filterLayout->addWidget(_refreshBtn);

    mainLayout->addLayout(filterLayout);

    // ── Table ─────────────────────────────────────────────────────────────────
    _table = new QTableWidget();
    QStringList headers = {"ID", "Type", "Worker", "Price/Unit", "Unit", "Available"};
    setupTable(headers);
    mainLayout->addWidget(_table, 1);

    // ── Status ────────────────────────────────────────────────────────────────
    _statusLabel = new QLabel("Ready");
    clearStatus();
    mainLayout->addWidget(_statusLabel);

    connect(_refreshBtn, &QPushButton::clicked, this, &ServicesTab::loadData);
    connect(_typeFilter, &QComboBox::currentTextChanged, this, &ServicesTab::filterRows);
}

void ServicesTab::loadData()
{
    setLoading(true);
    ApiClient::instance()->get("/worker-services", "services_load",
        [this](QJsonObject data) {
            QJsonArray services = data["data"].toArray();
            populateTableFromArray(services, [](QJsonObject obj) {
                DataModels::WorkerServiceModel s = DataModels::WorkerServiceModel::fromJson(obj);
                return QStringList{
                    QString::number(s.id),
                    s.type,
                    s.workerName,
                    QString("$%1").arg(s.pricePerUnit, 0, 'f', 2),
                    s.unit,
                    s.isAvailable ? "✓ Yes" : "✗ No"
                };
            });
            setLoading(false);
        },
        [this](QString message) {
            showError(message);
            setLoading(false);
        });
}

void ServicesTab::filterRows()
{
    QString typeFilter = _typeFilter->currentText();
    for (int row = 0; row < _table->rowCount(); ++row) {
        bool ok = (typeFilter == "All Types") || (_table->item(row, 1)->text() == typeFilter);
        _table->setRowHidden(row, !ok);
    }
}
