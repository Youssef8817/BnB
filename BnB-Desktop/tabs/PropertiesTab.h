#ifndef PROPERTYTAB_H
#define PROPERTYTAB_H

#include <QWidget>
#include <QTableWidget>
#include <QPushButton>
#include <QComboBox>
#include <QVBoxLayout>
#include <QLabel>
#include <QVector>
#include "core/BaseTab.h"
#include "core/DataModels.h"

class PropertiesTab : public BaseTab
{
    Q_OBJECT
public:
    explicit PropertiesTab(QWidget *parent = nullptr);
    void loadData() override;

private slots:
    void filterRows();
    void showPropertyDetails(const QTableWidgetItem* item);

private:
    QComboBox* _cityFilter;
    QComboBox* _statusFilter;
    QVector<DataModels::PropertyModel> _properties;
};

#endif // PROPERTYTAB_H