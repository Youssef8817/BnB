#ifndef LOGINWINDOW_H
#define LOGINWINDOW_H

#include <QMainWindow>
#include <QLabel>
#include <QLineEdit>
#include <QPushButton>
#include <QVBoxLayout>
#include <QFrame>
#include <QCheckBox>
#include <QShowEvent>

class LoginWindow : public QMainWindow
{
    Q_OBJECT
public:
    explicit LoginWindow(QWidget *parent = nullptr);

protected:
    void showEvent(QShowEvent* event) override;

private slots:
    void onLoginClicked();

private:
    QLabel* titleLabel;
    QLineEdit* emailEdit;
    QLineEdit* passwordEdit;
    QPushButton* loginBtn;
    QLabel* errorLabel;
    QCheckBox* rememberCheckbox;
};

#endif // LOGINWINDOW_H