#include "BaseTab.h"
#include "Theme.h"
#include <QVBoxLayout>
#include <QHeaderView>
#include <QJsonArray>
#include <QJsonObject>

BaseTab::BaseTab(QWidget *parent)
    : QWidget(parent)
{
    _table       = nullptr;
    _refreshBtn  = nullptr;
    _statusLabel = nullptr;
}

void BaseTab::setupTable(QStringList headers)
{
    if (!_table) return;
    _table->setColumnCount(headers.size());
    _table->setHorizontalHeaderLabels(headers);
    _table->setEditTriggers(QAbstractItemView::NoEditTriggers);
    _table->setSelectionBehavior(QAbstractItemView::SelectRows);
    _table->setSelectionMode(QAbstractItemView::SingleSelection);
    _table->horizontalHeader()->setStretchLastSection(true);
    _table->horizontalHeader()->setSectionResizeMode(QHeaderView::Interactive);
    _table->verticalHeader()->setVisible(false);
    _table->setShowGrid(false);
    _table->setAlternatingRowColors(true);
    _table->setVerticalScrollMode(QAbstractItemView::ScrollPerPixel);
    _table->setHorizontalScrollMode(QAbstractItemView::ScrollPerPixel);
}

void BaseTab::setLoading(bool loading)
{
    if (_refreshBtn) {
        _refreshBtn->setEnabled(!loading);
        _refreshBtn->setText(loading ? "Loading…" : "Refresh");
    }
    if (_statusLabel && !loading && !_statusLabel->text().startsWith("⚠")) {
        clearStatus();
    }
}

void BaseTab::showError(const QString& msg)
{
    if (_statusLabel) {
        _statusLabel->setText("⚠  " + msg);
        _statusLabel->setStyleSheet(QString(R"(
            QLabel {
                color: %1;
                background: rgba(255,83,112,0.10);
                border: 1px solid rgba(255,83,112,0.25);
                border-radius: 8px;
                padding: 6px 10px;
                font-size: 12px;
            }
        )").arg(Theme::ERROR));
    }
}

void BaseTab::clearStatus()
{
    if (_statusLabel) {
        _statusLabel->setText("Ready");
        _statusLabel->setStyleSheet(QString(R"(
            QLabel {
                color: %1;
                background: transparent;
                border: none;
                font-size: 12px;
                padding: 4px 0;
            }
        )").arg(Theme::TEXT_MUTED));
    }
}

void BaseTab::populateTableFromArray(const QJsonArray& items,
    std::function<QStringList(QJsonObject)> rowMapper)
{
    if (!_table) return;
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
