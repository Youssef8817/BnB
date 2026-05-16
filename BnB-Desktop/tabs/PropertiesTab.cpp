#include "PropertiesTab.h"
#include "core/ApiClient.h"
#include "core/DataModels.h"
#include "core/Theme.h"
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
    mainLayout->setContentsMargins(24, 20, 24, 20);
    mainLayout->setSpacing(16);

    // ── Header ────────────────────────────────────────────────────────────────
    QLabel* heading = new QLabel("Properties");
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

    _cityFilter = new QComboBox();
    _cityFilter->setFixedHeight(38);
    _cityFilter->addItem("All Cities");
    filterLayout->addWidget(_cityFilter);

    _statusFilter = new QComboBox();
    _statusFilter->setFixedHeight(38);
    _statusFilter->addItem("All Statuses");
    _statusFilter->addItem("available");
    _statusFilter->addItem("pending");
    _statusFilter->addItem("sold");
    filterLayout->addWidget(_statusFilter);

    filterLayout->addStretch();

    _refreshBtn = new QPushButton("Refresh");
    _refreshBtn->setFixedHeight(38);
    _refreshBtn->setCursor(Qt::PointingHandCursor);
    filterLayout->addWidget(_refreshBtn);

    mainLayout->addLayout(filterLayout);

    // ── Table ─────────────────────────────────────────────────────────────────
    _table = new QTableWidget();
    QStringList headers = {"ID", "Title", "City", "Price", "Rooms", "Status", "Owner"};
    setupTable(headers);

    QLabel* hint = new QLabel("Double-click a row to view details");
    hint->setStyleSheet(QString("color: %1; font-size: 11px; background: transparent; border: none;")
                            .arg(Theme::TEXT_MUTED));
    mainLayout->addWidget(_table, 1);
    mainLayout->addWidget(hint);

    // ── Status ────────────────────────────────────────────────────────────────
    _statusLabel = new QLabel("Ready");
    clearStatus();
    mainLayout->addWidget(_statusLabel);

    // ── Signals ───────────────────────────────────────────────────────────────
    connect(_refreshBtn,  &QPushButton::clicked, this, &PropertiesTab::loadData);
    connect(_cityFilter,  &QComboBox::currentTextChanged, this, &PropertiesTab::filterRows);
    connect(_statusFilter,&QComboBox::currentTextChanged, this, &PropertiesTab::filterRows);
    connect(_table, &QTableWidget::itemDoubleClicked, this, &PropertiesTab::showPropertyDetails);
}

void PropertiesTab::loadData()
{
    setLoading(true);
    ApiClient::instance()->get("/properties?per_page=500", "properties_load",
        [this](QJsonObject data) {
            QJsonArray properties = data["data"].toArray();
            _properties.clear();

            _cityFilter->blockSignals(true);
            _cityFilter->clear();
            _cityFilter->addItem("All Cities");
            QSet<QString> cities;

            for (const auto& val : properties) {
                DataModels::PropertyModel model = DataModels::PropertyModel::fromJson(val.toObject());
                _properties.append(model);
                if (!model.city.isEmpty()) cities.insert(model.city);
            }
            for (const QString& city : std::as_const(cities))
                _cityFilter->addItem(city);
            _cityFilter->blockSignals(false);

            populateTableFromArray(properties, [](QJsonObject obj) {
                DataModels::PropertyModel p = DataModels::PropertyModel::fromJson(obj);
                return QStringList{
                    QString::number(p.id),
                    p.title,
                    p.city,
                    QString("$%1").arg(p.price, 0, 'f', 0),
                    QString::number(p.rooms),
                    p.status,
                    p.ownerName
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
        bool ok = true;
        if (cityFilter   != "All Cities")   ok = ok && (_table->item(row, 2)->text() == cityFilter);
        if (statusFilter != "All Statuses") ok = ok && (_table->item(row, 5)->text() == statusFilter);
        _table->setRowHidden(row, !ok);
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
