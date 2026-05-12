#include "SettingsManager.h"

QSettings& SettingsManager::settings()
{
    static QSettings s("BBAdmin", "App");
    return s;
}

QString SettingsManager::token()
{
    return settings().value("token").toString();
}

void SettingsManager::setToken(const QString& token)
{
    settings().setValue("token", token);
}

void SettingsManager::clearToken()
{
    settings().remove("token");
}

QString SettingsManager::savedEmail()
{
    return settings().value("savedEmail").toString();
}

void SettingsManager::setSavedEmail(const QString& email)
{
    settings().setValue("savedEmail", email);
}

void SettingsManager::saveWindowGeometry(QWidget* widget)
{
    settings().setValue("geometry", widget->saveGeometry());
}

void SettingsManager::restoreWindowGeometry(QWidget* widget)
{
    widget->restoreGeometry(settings().value("geometry").toByteArray());
}