QT       += core gui widgets network

CONFIG   += c++17 console
CONFIG   -= app_bundle

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += \
    main.cpp \
    NetworkManager.cpp \
    LoginWindow.cpp \
    MainWindow.cpp \
    UsersTab.cpp \
    PropertiesTab.cpp \
    ServicesTab.cpp

HEADERS += \
    NetworkManager.h \
    LoginWindow.h \
    MainWindow.h \
    UsersTab.h \
    PropertiesTab.h \
    ServicesTab.h

# Default rules for deployment.
qnx: target.path = /tmp/$${target}/bin
else: unix:!android: target.path = /opt/$${target}/bin
!isEmpty(target.path): INSTALLS += target