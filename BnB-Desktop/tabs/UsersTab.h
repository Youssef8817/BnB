#ifndef USERSTAB_H
#define USERSTAB_H

#include <QWidget>
#include <QTableWidget>
#include <QPushButton>
#include <QLineEdit>
#include <QComboBox>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QMenu>
#include "core/BaseTab.h"

class UsersTab : public BaseTab
{
    Q_OBJECT
public:
    explicit UsersTab(QWidget *parent = nullptr);
    void loadData() override;

private slots:
    void filterRows();
    void showContextMenu(const QPoint& pos);
    void deleteUser();
    void exportCsv();

private:
    QLineEdit* _searchEdit;
    QComboBox* _roleFilter;
    QMenu* _contextMenu;
};

#endif // USERSTAB_H