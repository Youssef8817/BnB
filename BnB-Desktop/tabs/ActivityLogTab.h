#ifndef ACTIVITYLOGTAB_H
#define ACTIVITYLOGTAB_H

#include <QWidget>
#include <QTableWidget>
#include <QPushButton>
#include <QDateEdit>
#include <QLabel>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include "core/BaseTab.h"

class ActivityLogTab : public BaseTab
{
    Q_OBJECT
public:
    explicit ActivityLogTab(QWidget *parent = nullptr);
    void loadData() override;

private slots:
    void applyFilter();

private:
    QDateEdit* _fromDate;
    QDateEdit* _toDate;
    QPushButton* _filterBtn;
};

#endif // ACTIVITYLOGTAB_H