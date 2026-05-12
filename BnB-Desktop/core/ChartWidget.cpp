#include "ChartWidget.h"
#include <QPainter>
#include <QPaintEvent>

ChartWidget::ChartWidget(QWidget *parent)
    : QWidget(parent)
{
    // Default bar color
    _barColor = QColor(70, 130, 180); // Steel blue
}

void ChartWidget::setData(const QMap<QString, int>& data)
{
    _data = data;
    update(); // Trigger a repaint
}

void ChartWidget::setTitle(const QString& title)
{
    _title = title;
    update(); // Trigger a repaint
}

void ChartWidget::setBarColor(const QColor& color)
{
    _barColor = color;
    update(); // Trigger a repaint
}

QSize ChartWidget::sizeHint() const
{
    return QSize(400, 250);
}

void ChartWidget::paintEvent(QPaintEvent* event)
{
    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing);

    if (_data.isEmpty()) {
        // If no data, just draw the title if available
        if (!_title.isEmpty()) {
            painter.setPen(Qt::black);
            painter.drawText(rect(), Qt::AlignCenter, _title);
        }
        return;
    }

    // Calculate dimensions
    int width = this->width();
    int height = this->height();
    int padding = 20;
    int bottomPadding = 40; // For labels below bars
    int topPadding = 20;    // For title above
    int leftPadding = 20;   // For y-axis labels (we don't have y-axis labels, but we can leave space)
    int rightPadding = 20;  // For space on the right

    int chartWidth = width - leftPadding - rightPadding;
    int chartHeight = height - topPadding - bottomPadding;

    // Find the maximum value for scaling
    int maxValue = 0;
    for (auto value : _data) {
        if (value > maxValue) {
            maxValue = value;
        }
    }
    if (maxValue == 0) {
        maxValue = 1; // Avoid division by zero
    }

    // Calculate bar width and gap
    int barCount = _data.size();
    int gap = 5; // Gap between bars
    int barWidth = (chartWidth - (barCount + 1) * gap) / barCount;
    if (barWidth < 1) {
        barWidth = 1;
    }

    // Draw bars
    int x = leftPadding + gap;
    for (auto it = _data.begin(); it != _data.end(); ++it) {
        QString label = it.key();
        int value = it.value();

        // Calculate bar height
        int barHeight = (value * chartHeight) / maxValue;

        // Draw bar
        painter.fillRect(x, height - bottomPadding - barHeight, barWidth, barHeight, _barColor);

        // Draw value above the bar
        painter.setPen(Qt::black);
        painter.drawText(x, height - bottomPadding - barHeight - 10, barWidth, 20, Qt::AlignCenter, QString::number(value));

        // Draw label below the bar
        painter.drawText(x, height - bottomPadding + 5, barWidth, 20, Qt::AlignCenter, label);

        x += barWidth + gap;
    }

    // Draw title at the top
    if (!_title.isEmpty()) {
        painter.setPen(Qt::black);
        QFont titleFont = painter.font();
        titleFont.setPointSize(12);
        titleFont.setBold(true);
        painter.setFont(titleFont);
        painter.drawText(leftPadding, topPadding, chartWidth, 20, Qt::AlignCenter, _title);
    }
}