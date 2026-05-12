#include "PropertyDetailDialog.h"
#include <QFormLayout>
#include <QLabel>
#include <QPushButton>
#include <QVBoxLayout>

PropertyDetailDialog::PropertyDetailDialog(const DataModels::PropertyModel& model, QWidget* parent)
    : QDialog(parent)
{
    setWindowTitle(QString("Property #%1").arg(model.id));
    setMinimumWidth(400);

    QVBoxLayout* outer = new QVBoxLayout(this);
    QFormLayout* form = new QFormLayout();

    form->addRow("ID:",       new QLabel(QString::number(model.id)));
    form->addRow("Title:",    new QLabel(model.title));
    form->addRow("City:",     new QLabel(model.city));
    form->addRow("Location:", new QLabel(model.location));
    form->addRow("Price:",    new QLabel(QString::number(model.price, 'f', 2)));
    form->addRow("Rooms:",    new QLabel(QString::number(model.rooms)));
    form->addRow("Area m²:",  new QLabel(QString::number(model.areaMq, 'f', 2)));
    form->addRow("Status:",   new QLabel(model.status));
    form->addRow("Owner:",    new QLabel(model.ownerName));

    outer->addLayout(form);

    QPushButton* closeBtn = new QPushButton("Close");
    outer->addWidget(closeBtn);
    connect(closeBtn, &QPushButton::clicked, this, &QDialog::accept);
}
