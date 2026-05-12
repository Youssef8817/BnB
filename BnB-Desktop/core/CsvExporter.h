#ifndef CSVEXPORTER_H
#define CSVEXPORTER_H

#include <QTableWidget>
#include <QWidget>
#include <QString>
#include <QFile>
#include <QTextStream>
#include <QFileDialog>
#include <QMessageBox>

class CsvExporter
{
public:
    static bool exportTable(QTableWidget* table, QWidget* parent, const QString& defaultName = "export")
    {
        QString filePath = QFileDialog::getSaveFileName(parent, "Export CSV", defaultName + ".csv", "CSV (*.csv)");
        if (filePath.isEmpty()) {
            return false;
        }

        QFile file(filePath);
        if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            QMessageBox::warning(parent, "Error", "Cannot open file for writing: " + file.errorString());
            return false;
        }

        QTextStream out(&file);
        // Write header
        for (int col = 0; col < table->columnCount(); ++col) {
            if (col > 0) {
                out << ",";
            }
            QString headerText = table->horizontalHeaderItem(col) ? table->horizontalHeaderItem(col)->text() : "";
            out << "\"" << headerText.replace("\"", "\"\"") << "\"";
        }
        out << "\n";

        // Write data (only visible rows)
        for (int row = 0; row < table->rowCount(); ++row) {
            if (table->isRowHidden(row)) {
                continue;
            }
            for (int col = 0; col < table->columnCount(); ++col) {
                if (col > 0) {
                    out << ",";
                }
                QTableWidgetItem* item = table->item(row, col);
                QString cellText = item ? item->text() : "";
                out << "\"" << cellText.replace("\"", "\"\"") << "\"";
            }
            out << "\n";
        }

        file.close();
        QMessageBox::information(parent, "Success", "Data exported successfully to:\n" + filePath);
        return true;
    }
};

#endif // CSVEXPORTER_H