#include "LoginWindow.h"
#include "core/ApiClient.h"
#include "core/SettingsManager.h"
#include "core/Theme.h"
#include <QApplication>
#include <QJsonObject>
#include "MainWindow.h"
#include <QHBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QPushButton>
#include <QVBoxLayout>
#include <QFrame>
#include <QMessageBox>
#include <QCheckBox>
#include <QSpacerItem>

LoginWindow::LoginWindow(QWidget *parent)
    : QMainWindow(parent)
{
    setWindowTitle("B&B Admin");
    setFixedSize(420, 540);

    // ── Root widget ─────────────────────────────────────────────────────────
    QWidget* root = new QWidget(this);
    root->setStyleSheet(QString("background-color: %1;").arg(Theme::BG));
    setCentralWidget(root);

    QVBoxLayout* rootLayout = new QVBoxLayout(root);
    rootLayout->setContentsMargins(0, 0, 0, 0);
    rootLayout->addStretch();

    // ── Glass card ───────────────────────────────────────────────────────────
    QFrame* card = new QFrame();
    card->setFixedWidth(360);
    card->setStyleSheet(QString(R"(
        QFrame {
            background-color: %1;
            border: 1px solid rgba(255,255,255,0.09);
            border-radius: 20px;
        }
    )").arg(Theme::SURFACE));

    QVBoxLayout* cardLayout = new QVBoxLayout(card);
    cardLayout->setContentsMargins(32, 36, 32, 36);
    cardLayout->setSpacing(0);

    // Brand logo circle
    QLabel* logoBg = new QLabel();
    logoBg->setFixedSize(72, 72);
    logoBg->setAlignment(Qt::AlignCenter);
    logoBg->setStyleSheet(QString(R"(
        QLabel {
            background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                stop:0 %1, stop:1 %2);
            border-radius: 36px;
            border: none;
            color: #FFFFFF;
            font-size: 26px;
            font-weight: 800;
        }
    )").arg(Theme::ACCENT_DEEP, Theme::CYAN));
    logoBg->setText("B&B");

    QHBoxLayout* logoRow = new QHBoxLayout();
    logoRow->addStretch();
    logoRow->addWidget(logoBg);
    logoRow->addStretch();
    cardLayout->addLayout(logoRow);
    cardLayout->addSpacing(20);

    // Title
    titleLabel = new QLabel("Admin Login");
    titleLabel->setAlignment(Qt::AlignCenter);
    titleLabel->setStyleSheet(QString(R"(
        QLabel {
            color: %1;
            font-size: 22px;
            font-weight: 800;
            letter-spacing: -0.4px;
            background: transparent;
            border: none;
        }
    )").arg(Theme::TEXT_PRIMARY));
    cardLayout->addWidget(titleLabel);

    cardLayout->addSpacing(4);

    QLabel* subtitle = new QLabel("Sign in to your admin dashboard");
    subtitle->setAlignment(Qt::AlignCenter);
    subtitle->setStyleSheet(QString("color: %1; font-size: 13px; background: transparent; border: none;")
                                .arg(Theme::TEXT_MUTED));
    cardLayout->addWidget(subtitle);
    cardLayout->addSpacing(28);

    // Email field label
    QLabel* emailLabel = new QLabel("Email address");
    emailLabel->setStyleSheet(QString(R"(
        QLabel {
            color: %1; font-size: 12px; font-weight: 600;
            letter-spacing: 0.3px; background: transparent; border: none;
        }
    )").arg(Theme::TEXT_MUTED));
    cardLayout->addWidget(emailLabel);
    cardLayout->addSpacing(6);

    emailEdit = new QLineEdit();
    emailEdit->setPlaceholderText("you@example.com");
    emailEdit->setFixedHeight(44);
    cardLayout->addWidget(emailEdit);
    cardLayout->addSpacing(14);

    // Password field label
    QLabel* pwLabel = new QLabel("Password");
    pwLabel->setStyleSheet(QString(R"(
        QLabel {
            color: %1; font-size: 12px; font-weight: 600;
            letter-spacing: 0.3px; background: transparent; border: none;
        }
    )").arg(Theme::TEXT_MUTED));
    cardLayout->addWidget(pwLabel);
    cardLayout->addSpacing(6);

    passwordEdit = new QLineEdit();
    passwordEdit->setPlaceholderText("••••••••");
    passwordEdit->setEchoMode(QLineEdit::Password);
    passwordEdit->setFixedHeight(44);
    cardLayout->addWidget(passwordEdit);
    cardLayout->addSpacing(10);

    // Remember me
    rememberCheckbox = new QCheckBox("Remember email");
    cardLayout->addWidget(rememberCheckbox);
    cardLayout->addSpacing(20);

    // Login button
    loginBtn = new QPushButton("Sign In");
    loginBtn->setFixedHeight(46);
    loginBtn->setCursor(Qt::PointingHandCursor);
    cardLayout->addWidget(loginBtn);
    cardLayout->addSpacing(10);

    // Error label (hidden by default)
    errorLabel = new QLabel();
    errorLabel->setObjectName("errorLabel");
    errorLabel->setAlignment(Qt::AlignCenter);
    errorLabel->setWordWrap(true);
    errorLabel->setStyleSheet(QString(R"(
        QLabel {
            color: %1;
            background: rgba(255,83,112,0.10);
            border: 1px solid rgba(255,83,112,0.25);
            border-radius: 8px;
            padding: 8px 12px;
            font-size: 12px;
        }
    )").arg(Theme::ERROR));
    errorLabel->hide();
    cardLayout->addWidget(errorLabel);

    rootLayout->addWidget(card, 0, Qt::AlignHCenter);
    rootLayout->addStretch();

    // Footer
    QLabel* footer = new QLabel("B&B Admin Dashboard  ·  Internal use only");
    footer->setAlignment(Qt::AlignCenter);
    footer->setStyleSheet(QString("color: %1; font-size: 11px; background: transparent;")
                              .arg(Theme::TEXT_MUTED));
    rootLayout->addWidget(footer);
    rootLayout->addSpacing(16);

    connect(loginBtn, &QPushButton::clicked, this, &LoginWindow::onLoginClicked);
    connect(passwordEdit, &QLineEdit::returnPressed, this, &LoginWindow::onLoginClicked);
}

void LoginWindow::onLoginClicked()
{
    QString email    = emailEdit->text().trimmed();
    QString password = passwordEdit->text();

    if (email.isEmpty() || password.isEmpty()) {
        errorLabel->setText("Please enter your email and password.");
        errorLabel->show();
        return;
    }

    loginBtn->setEnabled(false);
    loginBtn->setText("Signing in…");
    errorLabel->hide();

    QJsonObject body;
    body["email"]    = email;
    body["password"] = password;

    ApiClient::instance()->post("/auth/login", "login",
        body,
        [this](QJsonObject data) {
            loginBtn->setEnabled(true);
            loginBtn->setText("Sign In");
            QJsonObject user = data["user"].toObject();
            if (user["role"].toString() == "admin") {
                ApiClient::instance()->setToken(data["token"].toString());
                SettingsManager::setToken(data["token"].toString());
                if (rememberCheckbox->isChecked())
                    SettingsManager::setSavedEmail(emailEdit->text());
                else
                    SettingsManager::setSavedEmail("");
                MainWindow* w = new MainWindow();
                w->show();
                this->close();
            } else {
                errorLabel->setText("Access denied. Admin accounts only.");
                errorLabel->show();
            }
        },
        [this](QString message) {
            loginBtn->setEnabled(true);
            loginBtn->setText("Sign In");
            errorLabel->setText(message);
            errorLabel->show();
        });
}

void LoginWindow::showEvent(QShowEvent* event)
{
    QMainWindow::showEvent(event);
    QString savedEmail = SettingsManager::savedEmail();
    if (!savedEmail.isEmpty()) {
        emailEdit->setText(savedEmail);
        rememberCheckbox->setChecked(true);
    }
}
