#include "StatsTab.h"
#include <QFrame>
#include <QLabel>
#include <QPushButton>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QDateTime>
#include <QJsonArray>
#include <QJsonObject>
#include "core/ApiClient.h"
#include "core/DataModels.h"

StatsTab::StatsTab(QWidget *parent)
    : QWidget(parent)
{
    // Main layout: vertical box
    QVBoxLayout* mainLayout = new QVBoxLayout(this);
    mainLayout->setSpacing(10);

    // Top section: 5 cards in a horizontal layout
    QHBoxLayout* cardsLayout = new QHBoxLayout();
    cardsLayout->setSpacing(10);

    totalUsersLabel = createCard("Total Users", 0, cardsLayout);
    totalWorkersLabel = createCard("Total Workers", 0, cardsLayout);
    propertiesLabel = createCard("Properties", 0, cardsLayout);
    requestsLabel = createCard("Requests", 0, cardsLayout);
    pendingLabel = createCard("Pending", 0, cardsLayout);

    mainLayout->addLayout(cardsLayout);

    // Middle section: Refresh button and last updated label
    QHBoxLayout* bottomLayout = new QHBoxLayout();
    refreshBtn = new QPushButton("Refresh");
    lastUpdatedLabel = new QLabel("Last updated: --:--:--");
    lastUpdatedLabel->setAlignment(Qt::AlignRight | Qt::AlignVCenter);
    bottomLayout->addWidget(refreshBtn);
    bottomLayout->addStretch();
    bottomLayout->addWidget(lastUpdatedLabel);
    mainLayout->addLayout(bottomLayout);

    // Bottom section: Chart widget
    chartWidget = new ChartWidget();
    chartWidget->setTitle("Properties by City");
    mainLayout->addWidget(chartWidget, 1); // Give it a stretch factor of 1 so it takes available space

    // Connect refresh button
    connect(refreshBtn, &QPushButton::clicked, this, &StatsTab::loadData);
}

QLabel* StatsTab::createCard(const QString& title, int initialCount, QHBoxLayout* layout)
{
    // Create a frame for the card
    QFrame* frame = new QFrame();
    frame->setFrameShape(QFrame::StyledPanel);
    frame->setLineWidth(1);
    frame->setMinimumWidth(100);
    frame->setMaximumWidth(120);

    // Layout for the card: vertical box for title and count
    QVBoxLayout* cardLayout = new QVBoxLayout(frame);
    cardLayout->setAlignment(Qt::AlignCenter);

    // Title label
    QLabel* titleLabel = new QLabel(title);
    titleLabel->setAlignment(Qt::AlignCenter);
    titleLabel->setStyleSheet("color: grey; font-size: 12px;");
    cardLayout->addWidget(titleLabel);

    // Count label
    QLabel* countLabel = new QLabel(QString::number(initialCount));
    countLabel->setAlignment(Qt::AlignCenter);
    countLabel->setStyleSheet("color: black; font-size: 24px; font-weight: bold;");
    cardLayout->addWidget(countLabel);

    // Add the frame to the main layout
    layout->addWidget(frame);

    // Return the count label so we can update it later
    return countLabel;
}

void StatsTab::loadData()
{
    // Disable refresh button while loading
    refreshBtn->setEnabled(false);

    // Fetch stats for the count cards
    ApiClient::instance()->get("/admin/stats", "stats_load",
        [this](QJsonObject statsData) {
            // Update the count labels
            totalUsersLabel->setText(QString::number(statsData["total_users"].toInt()));
            totalWorkersLabel->setText(QString::number(statsData["total_workers"].toInt()));
            propertiesLabel->setText(QString::number(statsData["properties"].toInt()));
            requestsLabel->setText(QString::number(statsData["requests"].toInt()));
            pendingLabel->setText(QString::number(statsData["pending"].toInt()));

            // Now fetch properties for the chart
            ApiClient::instance()->get("/properties", "properties_for_chart",
                [this](QJsonObject propertiesData) {
                    // Assuming the data is in the "data" field as an array
                    QJsonArray properties = propertiesData["data"].toArray();
                    QMap<QString, int> cityCounts;
                    for (int i = 0; i < properties.size(); ++i) {
                        QJsonObject prop = properties[i].toObject();
                        QString city = prop["city"].toString();
                        if (!city.isEmpty()) {
                            cityCounts[city] = cityCounts.value(city, 0) + 1;
                        }
                    }
                    // Set the data in the chart widget
                    chartWidget->setData(cityCounts);
                    // Update the last updated label
                    QString time = QDateTime::currentDateTime().toString("hh:mm:ss");
                    lastUpdatedLabel->setText(QString("Last updated: %1").arg(time));
                    // Re-enable the refresh button
                    refreshBtn->setEnabled(true);
                },
                [this](QString message) {
                    // If we fail to get properties, we still update the time and re-enable the button
                    QString time = QDateTime::currentDateTime().toString("hh:mm:ss");
                    lastUpdatedLabel->setText(QString("Last updated: %1 (error loading chart)").arg(time));
                    refreshBtn->setEnabled(true);
                });
        },
        [this](QString message) {
            // If we fail to get stats, we still re-enable the button
            refreshBtn->setEnabled(true);
        });
}