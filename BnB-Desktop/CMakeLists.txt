cmake_minimum_required(VERSION 3.16)
project(bb-admin)

find_package(Qt6 COMPONENTS Core Gui Widgets Network REQUIRED)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

set(SOURCES
    main.cpp

    # Core
    core/ApiClient.cpp
    core/BaseTab.cpp
    core/ChartWidget.cpp
    core/SettingsManager.cpp
    core/TableManager.cpp

    # Windows
    windows/LoginWindow.cpp
    windows/MainWindow.cpp

    # Tabs
    tabs/UsersTab.cpp
    tabs/PropertiesTab.cpp
    tabs/ServicesTab.cpp
    tabs/RequestsTab.cpp
    tabs/ReviewsTab.cpp
    tabs/StatsTab.cpp
    tabs/ActivityLogTab.cpp

    # Dialogs
    dialogs/PropertyDetailDialog.cpp
)

set(HEADERS
    # Core (header-only included here for MOC)
    core/ApiClient.h
    core/BaseTab.h
    core/ChartWidget.h
    core/CsvExporter.h
    core/DataModels.h
    core/SettingsManager.h
    core/TableManager.h
    core/Theme.h

    # Windows
    windows/LoginWindow.h
    windows/MainWindow.h

    # Tabs
    tabs/UsersTab.h
    tabs/PropertiesTab.h
    tabs/ServicesTab.h
    tabs/RequestsTab.h
    tabs/ReviewsTab.h
    tabs/StatsTab.h
    tabs/ActivityLogTab.h

    # Dialogs
    dialogs/ConfirmDialog.h
    dialogs/PropertyDetailDialog.h
)

add_executable(bb-admin ${SOURCES} ${HEADERS})

target_include_directories(bb-admin PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(bb-admin PRIVATE Qt6::Core Qt6::Gui Qt6::Widgets Qt6::Network)

if(WIN32)
    set_target_properties(bb-admin PROPERTIES WIN32_EXECUTABLE TRUE)
endif()
