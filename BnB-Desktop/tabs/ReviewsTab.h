#ifndef REVIEWSTAB_H
#define REVIEWSTAB_H

#include <QWidget>
#include <QTableWidget>
#include <QPushButton>
#include <QVBoxLayout>
#include "core/BaseTab.h"
#include "core/TableManager.h"

class ReviewsTab : public BaseTab
{
    Q_OBJECT
public:
    explicit ReviewsTab(QWidget *parent = nullptr);
    void loadData() override;

private:
    // We'll use TableManager for action buttons in the table
};

#endif // REVIEWSTAB_H