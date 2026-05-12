#include "ServicesTab.h"
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

ServicesTab::ServicesTab(QWidget *parent)
    : BaseTab(parent)
{
    // Create the layout for this tab
    QVBoxLayout* mainLayout = new QVBoxLayout(this);

    // Create a layout for the filter controls
    QHBoxLayout* filterLayout = new QHBoxLayout();

    // Type filter
    _typeFilter = new QComboBox();
    _typeFilter->addItem("All Types");
    _typeFilter->addItem("plumbing");
    _typeFilter->addItem("painting");
    _typeFilter->addItem("tiling");
    _typeFilter->addItem("electrical");
    _typeFilter->addItem("carpentry");
    _typeFilter->addItem("finishing");
    filterLayout->addWidget(new QLabel("Type:"));
    filterLayout->addWidget(_typeFilter);

    mainLayout->addLayout(filterLayout);

    // Create the table
    _table = new QTableWidget();
    QStringList headers = {"ID", "Type", "Worker", "Price/Unit", "Unit", "Available"};
    setupTable(headers);
    mainLayout->addWidget(_table);

    // Create refresh button
    _refreshBtn = new QPushButton("Refresh");
    mainLayout->addWidget(_refreshBtn);

    // Status label
    _statusLabel = new QLabel("Ready");
    mainLayout->addWidget(_statusLabel);

    // Connect signals
    connect(_refreshBtn, &QPushButton::clicked, this, &ServicesTab::loadData);
    connect(_typeFilter, &QComboBox::currentTextChanged, this, &ServicesTab::filterRows);
}

void ServicesTab::loadData()
{
    setLoading(true);
    clearStatus();
    // Use a fixed requestId for simplicity
    ApiClient::instance()->get("/worker-services", "services_load",
        [this](QJsonObject data) {
            // Assuming the data is in the "data" field as an array
            QJsonArray services = data["data"].toArray();
            populateTableFromArray(services, [](QJsonObject serviceObj) {
                DataModels::WorkerServiceModel service = DataModels::WorkerServiceModel::fromJson(serviceObj);
                return QStringList{
                    QString::number(service.id),
                    service.type,
                    service.workerName,
                    QString::number(service.pricePerUnit, 'f', 2),
                    service.unit,
                    service.isAvailable ? "Yes" : "No"
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
        bool matches = true;

        // Check type filter (column 1)
        if (matches && typeFilter != "All Types") {
            QString type = _table->item(row, 1)->text();
            if (type != typeFilter) {
                matches = false;
            }
        }

        _table->setRowHidden(row, !matches);
    }
}