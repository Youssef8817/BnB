#ifndef TABLEMANAGER_H
#define TABLEMANAGER_H

#include <QTableWidget>
#include <QPushButton>
#include <QList>
#include <QJsonArray>
#include <QJsonObject>
#include <functional>

class TableManager
{
public:
    static void setup(QTableWidget* t, QStringList headers, bool alternating = true);
    static void populate(QTableWidget* t, QJsonArray data, std::function<QStringList(QJsonObject)> rowMapper);
    static void filterByText(QTableWidget* t, const QString& query, QList<int> columns = {});
    static void filterByValue(QTableWidget* t, const QString& value, int column);
    static void addActionButton(QTableWidget* t, int row, int column, const QString& label, std::function<void()> onClick);
};

#endif // TABLEMANAGER_H