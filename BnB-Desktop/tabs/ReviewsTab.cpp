#include "ReviewsTab.h"
#include "core/ApiClient.h"
#include "core/DataModels.h"
#include "core/TableManager.h"
#include "core/Theme.h"
#include "dialogs/ConfirmDialog.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QPushButton>
#include <QTableWidget>
#include <QHeaderView>
#include <QJsonArray>
#include <QLabel>

ReviewsTab::ReviewsTab(QWidget *parent)
    : BaseTab(parent)
{
    QVBoxLayout* mainLayout = new QVBoxLayout(this);
    mainLayout->setContentsMargins(24, 20, 24, 20);
    mainLayout->setSpacing(16);

    // ── Header ────────────────────────────────────────────────────────────────
    QHBoxLayout* headerRow = new QHBoxLayout();
    QLabel* heading = new QLabel("Reviews");
    heading->setStyleSheet(QString(R"(
        QLabel {
            color: %1; font-size: 20px; font-weight: 800;
            letter-spacing: -0.3px; background: transparent; border: none;
        }
    )").arg(Theme::TEXT_PRIMARY));
    headerRow->addWidget(heading);
    headerRow->addStretch();

    _refreshBtn = new QPushButton("Refresh");
    _refreshBtn->setFixedHeight(38);
    _refreshBtn->setCursor(Qt::PointingHandCursor);
    headerRow->addWidget(_refreshBtn);
    mainLayout->addLayout(headerRow);

    // ── Table ─────────────────────────────────────────────────────────────────
    _table = new QTableWidget();
    QStringList headers = {"ID", "Service Type", "User", "Rating", "Comment", "Date", "Action"};
    TableManager::setup(_table, headers);
    setupTable(headers);
    mainLayout->addWidget(_table, 1);

    // ── Status ────────────────────────────────────────────────────────────────
    _statusLabel = new QLabel("Ready");
    clearStatus();
    mainLayout->addWidget(_statusLabel);

    connect(_refreshBtn, &QPushButton::clicked, this, &ReviewsTab::loadData);
}

void ReviewsTab::loadData()
{
    setLoading(true);
    ApiClient::instance()->get("/admin/reviews", "reviews_load",
        [this](QJsonObject data) {
            QJsonArray reviews = data["data"].toArray();
            TableManager::populate(_table, reviews, [](QJsonObject obj) {
                DataModels::ReviewModel r = DataModels::ReviewModel::fromJson(obj);
                return QStringList{
                    QString::number(r.id),
                    r.serviceType,
                    r.userName,
                    r.starString(),
                    r.comment,
                    r.createdAt.toString("yyyy-MM-dd")
                };
            });

            for (int row = 0; row < _table->rowCount(); ++row) {
                int id = _table->item(row, 0)->text().toInt();
                TableManager::addActionButton(_table, row, 6, "Delete",
                    [this, id, row]() {
                        if (ConfirmDialog::ask(this, QString("Delete review #%1?").arg(id))) {
                            setLoading(true);
                            ApiClient::instance()->deleteResource(
                                QString("/admin/reviews/%1").arg(id), "delete_review",
                                [this, row](QJsonObject) {
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
