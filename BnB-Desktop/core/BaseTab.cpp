#include "BaseTab.h"
#include <QVBoxLayout>
#include <QHeaderView>
#include <QJsonArray>
#include <QJsonObject>

BaseTab::BaseTab(QWidget *parent)
    : QWidget(parent)
{
    // Note: The actual UI setup (like creating _table, _refreshBtn, _statusLabel) 
    // is expected to be done in the derived classes, but we can provide a basic setup here if needed.
    // However, the plan says that the derived classes will set up their own UI and call setupTable.
    // So we leave the constructor empty for now, or we can initialize the pointers to nullptr.
    _table = nullptr;
    _refreshBtn = nullptr;
    _statusLabel = nullptr;
}

void BaseTab::setupTable(QStringList headers)
{
    if (!_table) {
        return; // or we could create the table here, but the plan expects the derived class to create it.
    }
    _table->setColumnCount(headers.size());
    _table->setHorizontalHeaderLabels(headers);
    _table->setEditTriggers(QAbstractItemView::NoEditTriggers);
    _table->setSelectionBehavior(QAbstractItemView::SelectRows);
    _table->horizontalHeader()->setStretchLastSection(true);
    _table->setAlternatingRowColors(true);
}

void BaseTab::setLoading(bool loading)
{
    if (_refreshBtn) {
        _refreshBtn->setEnabled(!loading);
    }
    if (_statusLabel) {
        _statusLabel->setText(loading ? "Loading..." : "Ready");
    }
}

void BaseTab::showError(const QString& msg)
{
    if (_statusLabel) {
        _statusLabel->setText("Error: " + msg);
        _statusLabel->setStyleSheet("color: red");
    }
}

void BaseTab::clearStatus()
{
    if (_statusLabel) {
        _statusLabel->setText("Ready");
        _statusLabel->setStyleSheet("");
    }
}

void BaseTab::populateTableFromArray(const QJsonArray& items, std::function<QStringList(QJsonObject)> rowMapper)
{
    if (!_table) {
        return;
    }
    _table->setRowCount(0);
    for (int i = 0; i < items.size(); ++i) {
        QJsonObject item = items[i].toObject();
        QStringList rowData = rowMapper(item);
        int row = _table->rowCount();
        _table->insertRow(row);
        for (int col = 0; col < rowData.size(); ++col) {
            _table->setItem(row, col, new QTableWidgetItem(rowData[col]));
        }
    }
}