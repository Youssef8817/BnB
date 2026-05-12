#ifndef SERVICESTAB_H
#define SERVICESTAB_H

#include <QWidget>
#include <QTableWidget>
#include <QPushButton>
#include <QComboBox>
#include <QVBoxLayout>
#include <QLabel>
#include "core/BaseTab.h"

class ServicesTab : public BaseTab
{
    Q_OBJECT
public:
    explicit ServicesTab(QWidget *parent = nullptr);
    void loadData() override;

private slots:
    void filterRows();

private:
    QComboBox* _typeFilter;
};

#endif // SERVICESTAB_H