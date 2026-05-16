#include "UsersTab.h"
#include "core/ApiClient.h"
#include "core/DataModels.h"
#include "core/TableManager.h"
#include "core/CsvExporter.h"
#include "core/Theme.h"
#include "dialogs/ConfirmDialog.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QComboBox>
#include <QPushButton>
#include <QTableWidget>
#include <QHeaderView>
#include <QJsonArray>
#include <QMenu>
#include <QMessageBox>

UsersTab::UsersTab(QWidget *parent)
    : BaseTab(parent)
{
    QVBoxLayout* mainLayout = new QVBoxLayout(this);
    mainLayout->setContentsMargins(24, 20, 24, 20);
    mainLayout->setSpacing(16);

    // ── Header ────────────────────────────────────────────────────────────────
    QLabel* heading = new QLabel("Users");
    heading->setStyleSheet(QString(R"(
        QLabel {
            color: %1; font-size: 20px; font-weight: 800;
            letter-spacing: -0.3px; background: transparent; border: none;
        }
    )").arg(Theme::TEXT_PRIMARY));
    mainLayout->addWidget(heading);

    // ── Filter row ────────────────────────────────────────────────────────────
    QHBoxLayout* filterLayout = new QHBoxLayout();
    filterLayout->setSpacing(10);

    _searchEdit = new QLineEdit();
    _searchEdit->setPlaceholderText("Search by name or email…");
    _searchEdit->setFixedHeight(38);
    filterLayout->addWidget(_searchEdit, 1);

    _roleFilter = new QComboBox();
    _roleFilter->setFixedHeight(38);
    _roleFilter->addItem("All Roles");
    _roleFilter->addItem("admin");
    _roleFilter->addItem("user");
    _roleFilter->addItem("worker");
    filterLayout->addWidget(_roleFilter);

    _refreshBtn = new QPushButton("Refresh");
    _refreshBtn->setFixedHeight(38);
    _refreshBtn->setCursor(Qt::PointingHandCursor);
    filterLayout->addWidget(_refreshBtn);

    QPushButton* exportBtn = new QPushButton("Export CSV");
    exportBtn->setObjectName("outlineBtn");
    exportBtn->setFixedHeight(38);
    exportBtn->setCursor(Qt::PointingHandCursor);
    filterLayout->addWidget(exportBtn);

    mainLayout->addLayout(filterLayout);

    // ── Table ─────────────────────────────────────────────────────────────────
    _table = new QTableWidget();
    QStringList headers = {"ID", "Name", "Email", "Role", "Phone", "Created"};
    TableManager::setup(_table, headers);
    setupTable(headers);
    mainLayout->addWidget(_table, 1);

    // ── Status bar ────────────────────────────────────────────────────────────
    _statusLabel = new QLabel("Ready");
    clearStatus();
    mainLayout->addWidget(_statusLabel);

    // ── Context menu ──────────────────────────────────────────────────────────
    _table->setContextMenuPolicy(Qt::CustomContextMenu);
    _contextMenu = new QMenu(this);
    QAction* deleteAction = _contextMenu->addAction("Delete User");
    QAction* exportAction = _contextMenu->addAction("Export CSV");
    connect(deleteAction, &QAction::triggered, this, &UsersTab::deleteUser);
    connect(exportAction, &QAction::triggered, this, &UsersTab::exportCsv);

    // ── Signals ───────────────────────────────────────────────────────────────
    connect(_refreshBtn, &QPushButton::clicked, this, &UsersTab::loadData);
    connect(exportBtn,   &QPushButton::clicked, this, &UsersTab::exportCsv);
    connect(_searchEdit, &QLineEdit::textChanged, this, &UsersTab::filterRows);
    connect(_roleFilter, &QComboBox::currentTextChanged, this, &UsersTab::filterRows);
    connect(_table, &QTableWidget::customContextMenuRequested, this, &UsersTab::showContextMenu);
}

void UsersTab::loadData()
{
    setLoading(true);
    ApiClient::instance()->get("/admin/users?per_page=500", "users_load",
        [this](QJsonObject data) {
            QJsonArray users = data["data"].toArray();
            TableManager::populate(_table, users, [](QJsonObject userObj) {
                DataModels::UserModel user = DataModels::UserModel::fromJson(userObj);
                return QStringList{
                    QString::number(user.id),
                    user.name,
                    user.email,
                    user.role,
                    user.phone,
                    user.createdAt.toString("yyyy-MM-dd")
                };
            });
            setLoading(false);
        },
        [this](QString message) {
            showError(message);
            setLoading(false);
        });
}

void UsersTab::filterRows()
{
    QString searchText = _searchEdit->text().toLower();
    QString roleFilter = _roleFilter->currentText();

    for (int row = 0; row < _table->rowCount(); ++row) {
        bool matches = true;
        if (!searchText.isEmpty()) {
            QString name  = _table->item(row, 1)->text().toLower();
            QString email = _table->item(row, 2)->text().toLower();
            if (!name.contains(searchText) && !email.contains(searchText))
                matches = false;
        }
        if (matches && roleFilter != "All Roles") {
            if (_table->item(row, 3)->text() != roleFilter)
                matches = false;
        }
        _table->setRowHidden(row, !matches);
    }
}

void UsersTab::showContextMenu(const QPoint& pos)
{
    _contextMenu->exec(_table->viewport()->mapToGlobal(pos));
}

void UsersTab::deleteUser()
{
    auto selected = _table->selectedItems();
    if (selected.isEmpty()) {
        QMessageBox::warning(this, "No Selection", "Please select a user to delete.");
        return;
    }
    int row = selected.first()->row();
    int id  = _table->item(row, 0)->text().toInt();

    if (ConfirmDialog::ask(this, QString("Delete user #%1? This cannot be undone.").arg(id))) {
        setLoading(true);
        ApiClient::instance()->deleteResource(QString("/admin/users/%1").arg(id), "delete_user",
            [this, id](QJsonObject) {
                for (int r = 0; r < _table->rowCount(); ++r) {
                    if (_table->item(r, 0)->text().toInt() == id) {
                        _table->removeRow(r);
                        break;
                    }
                }
                setLoading(false);
            },
            [this](QString message) {
                showError(message);
                setLoading(false);
            });
    }
}

void UsersTab::exportCsv()
{
    CsvExporter::exportTable(_table, this, "users");
}
