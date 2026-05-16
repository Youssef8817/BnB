#include "PropertyDetailDialog.h"
#include "core/Theme.h"
#include <QFormLayout>
#include <QLabel>
#include <QPushButton>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QFrame>

PropertyDetailDialog::PropertyDetailDialog(const DataModels::PropertyModel& model, QWidget* parent)
    : QDialog(parent)
{
    setWindowTitle(QString("Property #%1").arg(model.id));
    setMinimumWidth(440);
    setStyleSheet(QString("background-color: %1;").arg(Theme::SURFACE));

    QVBoxLayout* outer = new QVBoxLayout(this);
    outer->setContentsMargins(28, 28, 28, 24);
    outer->setSpacing(20);

    // ── Title row ─────────────────────────────────────────────────────────────
    QLabel* titleLabel = new QLabel(model.title);
    titleLabel->setStyleSheet(QString(R"(
        QLabel {
            color: %1; font-size: 18px; font-weight: 800;
            letter-spacing: -0.3px; background: transparent; border: none;
        }
    )").arg(Theme::TEXT_PRIMARY));
    titleLabel->setWordWrap(true);
    outer->addWidget(titleLabel);

    // ── Info card ─────────────────────────────────────────────────────────────
    QFrame* card = new QFrame();
    card->setStyleSheet(QString(R"(
        QFrame {
            background-color: rgba(255,255,255,0.03);
            border: 1px solid rgba(255,255,255,0.08);
            border-radius: 14px;
        }
    )"));
    QFormLayout* form = new QFormLayout(card);
    form->setContentsMargins(20, 16, 20, 16);
    form->setVerticalSpacing(10);
    form->setHorizontalSpacing(24);

    auto addRow = [&](const QString& label, const QString& value) {
        QLabel* lbl = new QLabel(label);
        lbl->setStyleSheet(QString(R"(
            QLabel {
                color: %1; font-size: 12px; font-weight: 600;
                letter-spacing: 0.3px; background: transparent; border: none;
            }
        )").arg(Theme::TEXT_MUTED));

        QLabel* val = new QLabel(value);
        val->setStyleSheet(QString("color: %1; font-size: 13px; background: transparent; border: none;")
                               .arg(Theme::TEXT_PRIMARY));
        val->setWordWrap(true);
        form->addRow(lbl, val);
    };

    addRow("ID",       QString::number(model.id));
    addRow("City",     model.city);
    addRow("Location", model.location);
    addRow("Price",    QString("$%1").arg(model.price, 0, 'f', 2));
    addRow("Rooms",    QString::number(model.rooms));
    addRow("Area",     QString("%1 m²").arg(model.areaMq, 0, 'f', 0));
    addRow("Status",   model.status);
    addRow("Owner",    model.ownerName);

    outer->addWidget(card);

    // ── Close button ──────────────────────────────────────────────────────────
    QHBoxLayout* btnRow = new QHBoxLayout();
    btnRow->addStretch();
    QPushButton* closeBtn = new QPushButton("Close");
    closeBtn->setFixedWidth(100);
    closeBtn->setFixedHeight(40);
    closeBtn->setObjectName("outlineBtn");
    closeBtn->setCursor(Qt::PointingHandCursor);
    btnRow->addWidget(closeBtn);
    outer->addLayout(btnRow);

    connect(closeBtn, &QPushButton::clicked, this, &QDialog::accept);
}
