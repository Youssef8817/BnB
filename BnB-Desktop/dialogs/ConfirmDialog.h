#ifndef CONFIRMDIALOG_H
#define CONFIRMDIALOG_H

#include <QWidget>
#include <QString>
#include <QMessageBox>

class ConfirmDialog
{
public:
    static bool ask(QWidget* parent, const QString& message, const QString& title = "Confirm")
    {
        return QMessageBox::question(parent, title, message, QMessageBox::Yes | QMessageBox::No) == QMessageBox::Yes;
    }
};

#endif // CONFIRMDIALOG_H