#include <QApplication>
#include <QFont>
#include "windows/LoginWindow.h"
#include "core/Theme.h"
#include "core/ApiClient.h"
#include "core/SettingsManager.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    // Apply global dark design system
    a.setStyleSheet(Theme::QSS);

    QFont appFont("Segoe UI", 10);
    appFont.setHintingPreference(QFont::PreferFullHinting);
    a.setFont(appFont);

    // Restore saved token so user doesn't re-login after restart
    QString savedToken = SettingsManager::token();
    if (!savedToken.isEmpty()) {
        ApiClient::instance()->setToken(savedToken);
    }

    LoginWindow w;
    w.show();
    return a.exec();
}
