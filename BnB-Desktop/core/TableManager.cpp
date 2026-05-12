#include "TableManager.h"
#include <QHeaderView>
#include <QPushButton>
#include <QWidget>
#include <QJsonArray>
#include <QJsonObject>

void TableManager::setup(QTableWidget* t, QStringList headers, bool alternating)
{
    t->setColumnCount(headers.size());
    t->setHorizontalHeaderLabels(headers);
    t->setEditTriggers(QAbstractItemView::NoEditTriggers);
    t->setSelectionBehavior(QAbstractItemView::SelectRows);
    t->horizontalHeader()->setStretchLastSection(true);
    t->setAlternatingRowColors(alternating);
}

void TableManager::populate(QTableWidget* t, QJsonArray data, std::function<QStringList(QJsonObject)> rowMapper)
{
    t->setRowCount(0);
    for (int i = 0; i < data.size(); ++i) {
        QJsonObject item = data[i].toObject();
        QStringList rowData = rowMapper(item);
        int row = t->rowCount();
        t->insertRow(row);
        for (int col = 0; col < rowData.size(); ++col) {
            t->setItem(row, col, new QTableWidgetItem(rowData[col]));
        }
    }
}

void TableManager::filterByText(QTableWidget* t, const QString& query, QList<int> columns)
{
    if (query.isEmpty()) {
        // Show all rows
        for (int row = 0; row < t->rowCount(); ++row) {
            t->setRowHidden(row, false);
        }
        return;
    }

    QString lowerQuery = query.toLower();
    for (int row = 0; row < t->rowCount(); ++row) {
        bool match = false;
        if (columns.isEmpty()) {
            // Check all columns
            for (int col = 0; col < t->columnCount(); ++col) {
                QTableWidgetItem* item = t->item(row, col);
                if (item && item->text().toLower().contains(lowerQuery)) {
                    match = true;
                    break;
                }
            }
        } else {
            // Check only the specified columns
            for (int col : columns) {
                QTableWidgetItem* item = t->item(row, col);
                if (item && item->text().toLower().contains(lowerQuery)) {
                    match = true;
                    break;
                }
            }
        }
        t->setRowHidden(row, !match);
    }
}

void TableManager::filterByValue(QTableWidget* t, const QString& value, int column)
{
    if (value.isEmpty()) {
        // Show all rows
        for (int row = 0; row < t->rowCount(); ++row) {
            t->setRowHidden(row, false);
        }
        return;
    }

    for (int row = 0; row < t->rowCount(); ++row) {
        QTableWidgetItem* item = t->item(row, column);
        bool match = (item && item->text() == value);
        t->setRowHidden(row, !match);
    }
}

void TableManager::addActionButton(QTableWidget* t, int row, int column, const QString& label, std::function<void()> onClick)
{
    QPushButton* button = new QPushButton(label);
    QObject::connect(button, &QPushButton::clicked, [onClick]() {
        if (onClick) {
            onClick();
        }
    });
    t->setCellWidget(row, column, button);
}