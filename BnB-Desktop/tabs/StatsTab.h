#ifndef STATSTAB_H
#define STATSTAB_H

#include <QWidget>
#include <QFrame>
#include <QLabel>
#include <QPushButton>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include "core/ChartWidget.h"

class StatsTab : public QWidget
{
    Q_OBJECT
public:
    explicit StatsTab(QWidget *parent = nullptr);
    void loadData();

private:
    QLabel* totalUsersLabel;
    QLabel* totalWorkersLabel;
    QLabel* propertiesLabel;
    QLabel* requestsLabel;
    QLabel* pendingLabel;
    QPushButton* refreshBtn;
    QLabel* lastUpdatedLabel;
    ChartWidget* chartWidget;

    QLabel* createCard(const QString& title, int initialCount, QHBoxLayout* layout);
};

#endif // STATSTAB_H