#ifndef REQUESTSTAB_H
#define REQUESTSTAB_H

#include <QWidget>
#include <QTableWidget>
#include <QPushButton>
#include <QComboBox>
#include <QVBoxLayout>
#include <QLabel>
#include <QTimer>
#include "core/BaseTab.h"

class RequestsTab : public BaseTab
{
    Q_OBJECT
public:
    explicit RequestsTab(QWidget *parent = nullptr);
    void loadData() override;
    void startAutoRefresh();
    void stopAutoRefresh();

private slots:
    void filterRows();
    void autoRefresh();

private:
    QComboBox* _statusFilter;
    QTimer* _autoRefreshTimer;
};

#endif // REQUESTSTAB_H