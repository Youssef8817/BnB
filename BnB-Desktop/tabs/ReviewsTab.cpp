#include "ReviewsTab.h"
#include "core/ApiClient.h"
#include "core/DataModels.h"
#include "core/TableManager.h"
#include "dialogs/ConfirmDialog.h"
#include <QVBoxLayout>
#include <QPushButton>
#include <QTableWidget>
#include <QHeaderView>
#include <QJsonArray>
#include <QLabel>

ReviewsTab::ReviewsTab(QWidget *parent)
    : BaseTab(parent)
{
    // Create the layout for this tab
    QVBoxLayout* mainLayout = new QVBoxLayout(this);

    // Create the table
    _table = new QTableWidget();
    QStringList headers = {"ID", "Service Type", "User", "Rating", "Comment", "Date", "Action"};
    TableManager::setup(_table, headers);
    mainLayout->addWidget(_table);

    // Create refresh button
    _refreshBtn = new QPushButton("Refresh");
    mainLayout->addWidget(_refreshBtn);

    // Status label
    _statusLabel = new QLabel("Ready");
    mainLayout->addWidget(_statusLabel);

    // Connect signals
    connect(_refreshBtn, &QPushButton::clicked, this, &ReviewsTab::loadData);
}

void ReviewsTab::loadData()
{
    setLoading(true);
    clearStatus();
    // Use a fixed requestId for simplicity
    ApiClient::instance()->get("/admin/reviews", "reviews_load",
        [this](QJsonObject data) {
            // Assuming the data is in the "data" field as an array
            QJsonArray reviews = data["data"].toArray();
            TableManager::populate(_table, reviews, [](QJsonObject reviewObj) {
                DataModels::ReviewModel review = DataModels::ReviewModel::fromJson(reviewObj);
                return QStringList{
                    QString::number(review.id),
                    review.serviceType,
                    review.userName,
                    review.starString(),
                    review.comment,
                    review.createdAt.toString(Qt::ISODate)
                };
            });
            
            // Add delete buttons to the Action column (column 6)
            for (int row = 0; row < _table->rowCount(); ++row) {
                int id = _table->item(row, 0)->text().toInt();
                TableManager::addActionButton(_table, row, 6, "Delete",
                    [this, id, row]() {
                        if (ConfirmDialog::ask(this, QString("Delete review #%1?").arg(id))) {
                            setLoading(true);
                            clearStatus();
                            ApiClient::instance()->deleteResource(QString("/admin/reviews/%1").arg(id), "delete_review",
                                [this, row](QJsonObject data) {
                                    _table->removeRow(row);
                                    setLoading(false);
                                },
                                [this](QString message) {
                                    showError(message);
                                    setLoading(false);
                                });
                        }
                    });
            }
            
            setLoading(false);
        },
        [this](QString message) {
            showError(message);
            setLoading(false);
        });
}