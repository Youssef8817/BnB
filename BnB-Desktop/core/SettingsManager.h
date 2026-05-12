#ifndef SETTINGSMANAGER_H
#define SETTINGSMANAGER_H

#include <QSettings>
#include <QString>
#include <QWidget>
#include <QByteArray>

class SettingsManager
{
public:
    static QString token();
    static void setToken(const QString& token);
    static void clearToken();
    static QString savedEmail();
    static void setSavedEmail(const QString& email);
    static void saveWindowGeometry(QWidget* widget);
    static void restoreWindowGeometry(QWidget* widget);

private:
    static QSettings& settings();
};

#endif // SETTINGSMANAGER_H