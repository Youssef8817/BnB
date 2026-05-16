#include <QApplication>
#include <QFont>
#include "windows/LoginWindow.h"
#include "core/Theme.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    // Apply global dark design system
    a.setStyleSheet(Theme::QSS);

    QFont appFont("Segoe UI", 10);
    appFont.setHintingPreference(QFont::PreferFullHinting);
    a.setFont(appFont);

    LoginWindow w;
    w.show();
    return a.exec();
}
