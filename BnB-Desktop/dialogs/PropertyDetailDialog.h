#ifndef PROPERTYDETAILDIALOG_H
#define PROPERTYDETAILDIALOG_H

#include <QDialog>
#include "core/DataModels.h"

class PropertyDetailDialog : public QDialog
{
    Q_OBJECT
public:
    explicit PropertyDetailDialog(const DataModels::PropertyModel& model, QWidget* parent = nullptr);
};

#endif // PROPERTYDETAILDIALOG_H
