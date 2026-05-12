#include "UsersTab.h"
#include "core/ApiClient.h"
#include "core/DataModels.h"
#include "core/TableManager.h"
#include "core/CsvExporter.h"
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
    // Create the layout for this tab
    QVBoxLayout* mainLayout = new QVBoxLayout(this);

    // Create a layout for the filter controls
    QHBoxLayout* filterLayout = new QHBoxLayout();

    // Search box
    _searchEdit = new QLineEdit();
    _searchEdit->setPlaceholderText("Search by name or email");
    filterLayout->addWidget(new QLabel("Search:"));
    filterLayout->addWidget(_searchEdit);

    // Role filter
    _roleFilter = new QComboBox();
    _roleFilter->addItem("All Roles");
    _roleFilter->addItem("admin");
    _roleFilter->addItem("user");
    filterLayout->addWidget(new QLabel("Role:"));
    filterLayout->addWidget(_roleFilter);

    mainLayout->addLayout(filterLayout);

    // Create the table
    _table = new QTableWidget();
    QStringList headers = {"ID", "Name", "Email", "Role", "Phone", "Created"};
    TableManager::setup(_table, headers);
    mainLayout->addWidget(_table);

    // Button row: Refresh + Export CSV
    QHBoxLayout* btnLayout = new QHBoxLayout();
    _refreshBtn = new QPushButton("Refresh");
    QPushButton* exportBtn = new QPushButton("Export CSV");
    btnLayout->addWidget(_refreshBtn);
    btnLayout->addWidget(exportBtn);
    btnLayout->addStretch();
    mainLayout->addLayout(btnLayout);

    // Status label
    _statusLabel = new QLabel("Ready");
    mainLayout->addWidget(_statusLabel);

    connect(exportBtn, &QPushButton::clicked, this, &UsersTab::exportCsv);

    // Set up context menu
    _table->setContextMenuPolicy(Qt::CustomContextMenu);
    _contextMenu = new QMenu(this);
    QAction* deleteAction = _contextMenu->addAction("Delete User");
    QAction* exportAction = _contextMenu->addAction("Export CSV");
    connect(deleteAction, &QAction::triggered, this, &UsersTab::deleteUser);
    connect(exportAction, &QAction::triggered, this, &UsersTab::exportCsv);

    // Connect signals
    connect(_refreshBtn, &QPushButton::clicked, this, &UsersTab::loadData);
    connect(_searchEdit, &QLineEdit::textChanged, this, &UsersTab::filterRows);
    connect(_roleFilter, &QComboBox::currentTextChanged, this, &UsersTab::filterRows);
    connect(_table, &QTableWidget::customContextMenuRequested, this, &UsersTab::showContextMenu);
}

void UsersTab::loadData()
{
    setLoading(true);
    clearStatus();
    // Use a fixed requestId for simplicity
    ApiClient::instance()->get("/admin/users", "users_load",
        [this](QJsonObject data) {
            // Assuming the data is in the "data" field as an array
            QJsonArray users = data["data"].toArray();
            TableManager::populate(_table, users, [](QJsonObject userObj) {
                DataModels::UserModel user = DataModels::UserModel::fromJson(userObj);
                return QStringList{
                    QString::number(user.id),
                    user.name,
                    user.email,
                    user.role,
                    user.phone,
                    user.createdAt.toString(Qt::ISODate)
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

        // Check search text in name and email columns (columns 1 and 2)
        if (!searchText.isEmpty()) {
            QString name = _table->item(row, 1)->text().toLower();
            QString email = _table->item(row, 2)->text().toLower();
            if (!name.contains(searchText) && !email.contains(searchText)) {
                matches = false;
            }
        }

        // Check role filter (column 3)
        if (matches && roleFilter != "All Roles") {
            QString role = _table->item(row, 3)->text();
            if (role != roleFilter) {
                matches = false;
            }
        }

        _table->setRowHidden(row, !matches);
    }
}

void UsersTab::showContextMenu(const QPoint& pos)
{
    // Global position for the menu
    QPoint globalPos = _table->viewport()->mapToGlobal(pos);
    _contextMenu->exec(globalPos);
}

void UsersTab::deleteUser()
{
    // Get the currently selected row
    QList<QTableWidgetItem*> selectedItems = _table->selectedItems();
    if (selectedItems.isEmpty()) {
        QMessageBox::warning(this, "No Selection", "Please select a user to delete.");
        return;
    }

    int row = selectedItems.first()->row();
    QString idStr = _table->item(row, 0)->text();
    bool ok;
    int id = idStr.toInt(&ok);
    if (!ok) {
        QMessageBox::warning(this, "Error", "Invalid user ID.");
        return;
    }

    // Confirm deletion
    if (ConfirmDialog::ask(this, QString("Are you sure you want to delete user ID %1?").arg(id))) {
        setLoading(true);
        clearStatus();
        ApiClient::instance()->deleteResource(QString("/admin/users/%1").arg(id), "delete_user",
            [this, id](QJsonObject data) {
                QMessageBox::information(this, "Success", "User deleted successfully.");
                // Remove the row from the table
                for (int row = 0; row < _table->rowCount(); ++row) {
                    if (_table->item(row, 0)->text() == QString::number(id)) {
                        _table->removeRow(row);
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
    if (CsvExporter::exportTable(_table, this, "users")) {
        // Success message is shown by CsvExporter
    } else {
        // User cancelled or error occurred
    }
}