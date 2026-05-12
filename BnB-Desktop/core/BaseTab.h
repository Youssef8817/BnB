#ifndef BASETAB_H
#define BASETAB_H

#include <QWidget>
#include <QTableWidget>
#include <QPushButton>
#include <QLabel>
#include <QJsonArray>
#include <QJsonObject>
#include <functional>

class BaseTab : public QWidget
{
    Q_OBJECT
public:
    explicit BaseTab(QWidget *parent = nullptr);
    virtual ~BaseTab() = default;

protected:
    QTableWidget* _table;
    QPushButton* _refreshBtn;
    QLabel* _statusLabel;

    void setupTable(QStringList headers);
    void setLoading(bool loading);
    void showError(const QString& msg);
    void clearStatus();
    void populateTableFromArray(const QJsonArray& items,
        std::function<QStringList(QJsonObject)> rowMapper);

public slots:
    virtual void loadData() = 0;
};

#endif // BASETAB_H