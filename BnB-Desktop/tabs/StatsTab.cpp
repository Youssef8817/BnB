#include "StatsTab.h"
#include "core/Theme.h"
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
    setStyleSheet(QString("background-color: %1;").arg(Theme::BG));

    QVBoxLayout* mainLayout = new QVBoxLayout(this);
    mainLayout->setContentsMargins(24, 20, 24, 20);
    mainLayout->setSpacing(20);

    // ── Page heading ──────────────────────────────────────────────────────────
    QHBoxLayout* headerRow = new QHBoxLayout();
    QLabel* heading = new QLabel("Dashboard Stats");
    heading->setStyleSheet(QString(R"(
        QLabel {
            color: %1; font-size: 20px; font-weight: 800;
            letter-spacing: -0.3px; background: transparent; border: none;
        }
    )").arg(Theme::TEXT_PRIMARY));
    headerRow->addWidget(heading);
    headerRow->addStretch();

    lastUpdatedLabel = new QLabel("Last updated: —");
    lastUpdatedLabel->setStyleSheet(QString("color: %1; font-size: 12px; background: transparent; border: none;")
                                        .arg(Theme::TEXT_MUTED));
    headerRow->addWidget(lastUpdatedLabel);

    refreshBtn = new QPushButton("Refresh");
    refreshBtn->setFixedHeight(36);
    refreshBtn->setCursor(Qt::PointingHandCursor);
    headerRow->addWidget(refreshBtn);
    mainLayout->addLayout(headerRow);

    // ── Stat cards ────────────────────────────────────────────────────────────
    QHBoxLayout* cardsLayout = new QHBoxLayout();
    cardsLayout->setSpacing(14);

    struct CardDef { QString title; QString icon; QString accentColor; };
    QList<CardDef> cards = {
        {"Total Users",    "👥", Theme::ACCENT},
        {"Total Workers",  "🔧", Theme::CYAN},
        {"Properties",     "🏠", Theme::SUCCESS},
        {"Requests",       "📋", Theme::WARNING},
        {"Pending",        "⏳", Theme::ERROR},
    };

    totalUsersLabel   = createCard(cards[0].title, cards[0].icon, cards[0].accentColor, cardsLayout);
    totalWorkersLabel = createCard(cards[1].title, cards[1].icon, cards[1].accentColor, cardsLayout);
    propertiesLabel   = createCard(cards[2].title, cards[2].icon, cards[2].accentColor, cardsLayout);
    requestsLabel     = createCard(cards[3].title, cards[3].icon, cards[3].accentColor, cardsLayout);
    pendingLabel      = createCard(cards[4].title, cards[4].icon, cards[4].accentColor, cardsLayout);

    mainLayout->addLayout(cardsLayout);

    // ── Chart ─────────────────────────────────────────────────────────────────
    QLabel* chartHeading = new QLabel("Properties by City");
    chartHeading->setStyleSheet(QString(R"(
        QLabel {
            color: %1; font-size: 15px; font-weight: 700;
            background: transparent; border: none;
        }
    )").arg(Theme::TEXT_PRIMARY));
    mainLayout->addWidget(chartHeading);

    chartWidget = new ChartWidget();
    chartWidget->setTitle("");
    chartWidget->setStyleSheet(QString(R"(
        QWidget {
            background-color: %1;
            border: 1px solid rgba(255,255,255,0.07);
            border-radius: 16px;
        }
    )").arg(Theme::SURFACE));
    mainLayout->addWidget(chartWidget, 1);

    connect(refreshBtn, &QPushButton::clicked, this, &StatsTab::loadData);
}

QLabel* StatsTab::createCard(const QString& title, const QString& icon,
                              const QString& accentColor, QHBoxLayout* layout)
{
    QFrame* card = new QFrame();
    card->setStyleSheet(QString(R"(
        QFrame {
            background-color: %1;
            border: 1px solid rgba(255,255,255,0.09);
            border-radius: 16px;
        }
    )").arg(Theme::SURFACE));
    card->setMinimumWidth(130);

    QVBoxLayout* cardLayout = new QVBoxLayout(card);
    cardLayout->setContentsMargins(20, 18, 20, 18);
    cardLayout->setSpacing(6);
    cardLayout->setAlignment(Qt::AlignCenter);

    QLabel* iconLabel = new QLabel(icon);
    iconLabel->setAlignment(Qt::AlignCenter);
    iconLabel->setStyleSheet("font-size: 24px; background: transparent; border: none;");
    cardLayout->addWidget(iconLabel);

    QLabel* titleLabel = new QLabel(title);
    titleLabel->setAlignment(Qt::AlignCenter);
    titleLabel->setStyleSheet(QString(R"(
        QLabel {
            color: %1; font-size: 11px; font-weight: 600;
            letter-spacing: 0.4px; background: transparent; border: none;
        }
    )").arg(Theme::TEXT_MUTED));
    cardLayout->addWidget(titleLabel);

    QLabel* countLabel = new QLabel("—");
    countLabel->setAlignment(Qt::AlignCenter);
    countLabel->setStyleSheet(QString(R"(
        QLabel {
            color: %1; font-size: 30px; font-weight: 800;
            background: transparent; border: none;
        }
    )").arg(accentColor));
    cardLayout->addWidget(countLabel);

    layout->addWidget(card);
    return countLabel;
}

void StatsTab::loadData()
{
    refreshBtn->setEnabled(false);

    ApiClient::instance()->get("/admin/stats", "stats_load",
        [this](QJsonObject statsData) {
            totalUsersLabel->setText(QString::number(statsData["total_users"].toInt()));
            totalWorkersLabel->setText(QString::number(statsData["total_workers"].toInt()));
            propertiesLabel->setText(QString::number(statsData["properties"].toInt()));
            requestsLabel->setText(QString::number(statsData["requests"].toInt()));
            pendingLabel->setText(QString::number(statsData["pending"].toInt()));

            ApiClient::instance()->get("/properties", "properties_for_chart",
                [this](QJsonObject propertiesData) {
                    QJsonArray properties = propertiesData["data"].toArray();
                    QMap<QString, int> cityCounts;
                    for (const auto& val : properties) {
                        QString city = val.toObject()["city"].toString();
                        if (!city.isEmpty())
                            cityCounts[city]++;
                    }
                    chartWidget->setData(cityCounts);
                    lastUpdatedLabel->setText(
                        QString("Last updated: %1")
                            .arg(QDateTime::currentDateTime().toString("hh:mm:ss")));
                    refreshBtn->setEnabled(true);
                },
                [this](QString) {
                    lastUpdatedLabel->setText(
                        QString("Last updated: %1  (chart error)")
                            .arg(QDateTime::currentDateTime().toString("hh:mm:ss")));
                    refreshBtn->setEnabled(true);
                });
        },
        [this](QString) {
            refreshBtn->setEnabled(true);
        });
}
