#include "LoginWindow.h"
#include "core/ApiClient.h"
#include "core/SettingsManager.h"
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

LoginWindow::LoginWindow(QWidget *parent)
    : QMainWindow(parent)
{
    setWindowTitle("B&B Admin Login");
    setFixedSize(320, 240);

    // Central widget and layout
    QWidget* centralWidget = new QWidget(this);
    setCentralWidget(centralWidget);
    QVBoxLayout* mainLayout = new QVBoxLayout(centralWidget);

    // Frame for the login form
    QFrame* frame = new QFrame();
    frame->setFrameShape(QFrame::StyledPanel);
    frame->setMaximumWidth(320);
    QVBoxLayout* frameLayout = new QVBoxLayout(frame);

    // Title label
    titleLabel = new QLabel("B&B Admin");
    titleLabel->setAlignment(Qt::AlignCenter);
    QFont font = titleLabel->font();
    font.setPointSize(16);
    font.setBold(true);
    titleLabel->setFont(font);
    frameLayout->addWidget(titleLabel);

    // Email input
    emailEdit = new QLineEdit();
    emailEdit->setPlaceholderText("Email");
    frameLayout->addWidget(emailEdit);

    // Password input
    passwordEdit = new QLineEdit();
    passwordEdit->setPlaceholderText("Password");
    passwordEdit->setEchoMode(QLineEdit::Password);
    frameLayout->addWidget(passwordEdit);

    // Remember me checkbox
    rememberCheckbox = new QCheckBox("Remember email");
    frameLayout->addWidget(rememberCheckbox);

    // Login button
    loginBtn = new QPushButton("Login");
    frameLayout->addWidget(loginBtn);

    // Error label
    errorLabel = new QLabel();
    errorLabel->setStyleSheet("color: red;");
    errorLabel->setAlignment(Qt::AlignCenter);
    errorLabel->hide();
    frameLayout->addWidget(errorLabel);

    mainLayout->addWidget(frame, 0, Qt::AlignCenter);

    // Connect signals
    connect(loginBtn, &QPushButton::clicked, this, &LoginWindow::onLoginClicked);
}

void LoginWindow::onLoginClicked()
{
    QString email = emailEdit->text();
    QString password = passwordEdit->text();

    if (email.isEmpty() || password.isEmpty()) {
        errorLabel->setText("Please enter email and password");
        errorLabel->show();
        return;
    }

    loginBtn->setEnabled(false);
    errorLabel->hide();

    // Call the login API
    QJsonObject body;
    body["email"] = email;
    body["password"] = password;
    ApiClient::instance()->post("/auth/login", "login",
        body,
        [this](QJsonObject data) {
            loginBtn->setEnabled(true);
            // Check if the user is an admin
            QJsonObject user = data["user"].toObject();
            if (user["role"].toString() == "admin") {
                // Set the token
                ApiClient::instance()->setToken(data["token"].toString());
                SettingsManager::setToken(data["token"].toString());
                // Remember email if checked
                if (rememberCheckbox->isChecked()) {
                    SettingsManager::setSavedEmail(emailEdit->text());
                } else {
                    SettingsManager::setSavedEmail("");
                }
                // Open the main window
                MainWindow* w = new MainWindow();
                w->show();
                this->close();
            } else {
                errorLabel->setText("Access denied. Admin only.");
                errorLabel->show();
            }
        },
        [this](QString message) {
            loginBtn->setEnabled(true);
            errorLabel->setText(message);
            errorLabel->show();
        });
}

// Override showEvent to load saved email
void LoginWindow::showEvent(QShowEvent* event)
{
    QMainWindow::showEvent(event);
    // If there is a saved email, fill it in and check the remember box
    QString savedEmail = SettingsManager::savedEmail();
    if (!savedEmail.isEmpty()) {
        emailEdit->setText(savedEmail);
        rememberCheckbox->setChecked(true);
    }
}