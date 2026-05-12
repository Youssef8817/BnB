#include "PropertiesTab.h"
#include "core/ApiClient.h"
#include "core/DataModels.h"
#include "dialogs/PropertyDetailDialog.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QComboBox>
#include <QPushButton>
#include <QTableWidget>
#include <QHeaderView>
#include <QJsonArray>
#include <QSet>

PropertiesTab::PropertiesTab(QWidget *parent)
    : BaseTab(parent)
{
    QVBoxLayout* mainLayout = new QVBoxLayout(this);

    QHBoxLayout* filterLayout = new QHBoxLayout();

    _cityFilter = new QComboBox();
    _cityFilter->addItem("All Cities");
    filterLayout->addWidget(new QLabel("City:"));
    filterLayout->addWidget(_cityFilter);

    _statusFilter = new QComboBox();
    _statusFilter->addItem("All Statuses");
    _statusFilter->addItem("available");
    _statusFilter->addItem("pending");
    _statusFilter->addItem("sold");
    filterLayout->addWidget(new QLabel("Status:"));
    filterLayout->addWidget(_statusFilter);
    filterLayout->addStretch();

    mainLayout->addLayout(filterLayout);

    _table = new QTableWidget();
    QStringList headers = {"ID", "Title", "City", "Price", "Rooms", "Status", "Owner"};
    setupTable(headers);
    mainLayout->addWidget(_table);

    _refreshBtn = new QPushButton("Refresh");
    _statusLabel = new QLabel("Ready");
    mainLayout->addWidget(_refreshBtn);
    mainLayout->addWidget(_statusLabel);

    connect(_refreshBtn, &QPushButton::clicked, this, &PropertiesTab::loadData);
    connect(_cityFilter, &QComboBox::currentTextChanged, this, &PropertiesTab::filterRows);
    connect(_statusFilter, &QComboBox::currentTextChanged, this, &PropertiesTab::filterRows);
    connect(_table, &QTableWidget::itemDoubleClicked, this, &PropertiesTab::showPropertyDetails);
}

void PropertiesTab::loadData()
{
    setLoading(true);
    clearStatus();

    ApiClient::instance()->get("/properties", "properties_load",
        [this](QJsonObject data) {
            QJsonArray properties = data["data"].toArray();

            // Rebuild stored models for detail dialog lookup
            _properties.clear();

            // Rebuild city filter without triggering filterRows
            _cityFilter->blockSignals(true);
            _cityFilter->clear();
            _cityFilter->addItem("All Cities");
            QSet<QString> cities;

            for (const auto& val : properties) {
                DataModels::PropertyModel model = DataModels::PropertyModel::fromJson(val.toObject());
                _properties.append(model);
                if (!model.city.isEmpty()) cities.insert(model.city);
            }
            for (const QString& city : std::as_const(cities)) {
                _cityFilter->addItem(city);
            }
            _cityFilter->blockSignals(false);

            populateTableFromArray(properties, [](QJsonObject propObj) {
                DataModels::PropertyModel prop = DataModels::PropertyModel::fromJson(propObj);
                return QStringList{
                    QString::number(prop.id),
                    prop.title,
                    prop.city,
                    QString::number(prop.price, 'f', 2),
                    QString::number(prop.rooms),
                    prop.status,
                    prop.ownerName
                };
            });

            setLoading(false);
        },
        [this](QString message) {
            showError(message);
            setLoading(false);
        });
}

void PropertiesTab::filterRows()
{
    const QString cityFilter   = _cityFilter->currentText();
    const QString statusFilter = _statusFilter->currentText();

    for (int row = 0; row < _table->rowCount(); ++row) {
        bool matches = true;

        if (cityFilter != "All Cities") {
            matches = matches && (_table->item(row, 2)->text() == cityFilter);
        }
        if (statusFilter != "All Statuses") {
            matches = matches && (_table->item(row, 5)->text() == statusFilter);
        }

        _table->setRowHidden(row, !matches);
    }
}

void PropertiesTab::showPropertyDetails(const QTableWidgetItem* item)
{
    if (!item) return;

    int row = item->row();
    if (row < 0 || row >= _properties.size()) return;

    PropertyDetailDialog dlg(_properties.at(row), this);
    dlg.exec();
}
