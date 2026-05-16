#include "ChartWidget.h"
#include <QPainter>
#include <QPaintEvent>
#include <QLinearGradient>
#include <QPainterPath>

ChartWidget::ChartWidget(QWidget *parent)
    : QWidget(parent)
{
    _barColor = QColor(0x7C, 0x5C, 0xFC); // accent deep
    setMinimumHeight(220);
}

void ChartWidget::setData(const QMap<QString, int>& data)
{
    _data = data;
    update();
}

void ChartWidget::setTitle(const QString& title)
{
    _title = title;
    update();
}

void ChartWidget::setBarColor(const QColor& color)
{
    _barColor = color;
    update();
}

QSize ChartWidget::sizeHint() const
{
    return QSize(600, 280);
}

void ChartWidget::paintEvent(QPaintEvent*)
{
    QPainter p(this);
    p.setRenderHint(QPainter::Antialiasing);

    const int W  = width();
    const int H  = height();
    const int pl = 48;   // left padding (y-axis area)
    const int pr = 20;
    const int pt = 44;   // top (title)
    const int pb = 48;   // bottom (labels)

    // Background
    p.fillRect(rect(), QColor(0x0D, 0x14, 0x24));

    // Subtle grid lines
    QPen gridPen(QColor(255, 255, 255, 13));
    gridPen.setWidth(1);
    p.setPen(gridPen);
    int chartH = H - pt - pb;
    int chartW = W - pl - pr;
    for (int i = 1; i <= 4; ++i) {
        int y = pt + chartH * i / 4;
        p.drawLine(pl, y, pl + chartW, y);
    }

    if (_data.isEmpty()) {
        if (!_title.isEmpty()) {
            p.setPen(QColor(0x6B, 0x7A, 0x9F));
            p.drawText(rect(), Qt::AlignCenter, _title);
        }
        return;
    }

    // Find max
    int maxVal = 0;
    for (auto v : _data) if (v > maxVal) maxVal = v;
    if (maxVal == 0) maxVal = 1;

    // Bars
    int barCount = _data.size();
    int gap      = 12;
    int barW     = qMax(1, (chartW - (barCount + 1) * gap) / barCount);
    int x        = pl + gap;

    QColor accentDeep(0x7C, 0x5C, 0xFC);
    QColor cyan(0x4F, 0xC3, 0xF7);

    int idx = 0;
    for (auto it = _data.cbegin(); it != _data.cend(); ++it, ++idx) {
        int barH = qMax(4, (it.value() * chartH) / maxVal);
        int barY = pt + chartH - barH;

        // Gradient bar
        QLinearGradient grad(x, barY, x, barY + barH);
        float t = barCount > 1 ? float(idx) / (barCount - 1) : 0.5f;
        QColor topColor(
            int(accentDeep.red()   + t * (cyan.red()   - accentDeep.red())),
            int(accentDeep.green() + t * (cyan.green() - accentDeep.green())),
            int(accentDeep.blue()  + t * (cyan.blue()  - accentDeep.blue()))
        );
        grad.setColorAt(0, topColor);
        grad.setColorAt(1, topColor.darker(150));

        p.setPen(Qt::NoPen);
        p.setBrush(grad);
        // Rounded top corners
        QPainterPath path;
        int r = qMin(6, barW / 2);
        path.moveTo(x, barY + barH);
        path.lineTo(x, barY + r);
        path.quadTo(x, barY, x + r, barY);
        path.lineTo(x + barW - r, barY);
        path.quadTo(x + barW, barY, x + barW, barY + r);
        path.lineTo(x + barW, barY + barH);
        path.closeSubpath();
        p.drawPath(path);

        // Glow under bar
        QLinearGradient glow(x, barY + barH - 8, x, barY + barH + 16);
        QColor glowC = topColor;
        glowC.setAlpha(60);
        glow.setColorAt(0, glowC);
        glowC.setAlpha(0);
        glow.setColorAt(1, glowC);
        p.setBrush(glow);
        p.drawRect(x, barY + barH - 8, barW, 24);

        // Value label above bar
        p.setPen(QColor(0xF0, 0xF4, 0xFF));
        p.setFont(QFont("Segoe UI", 9, QFont::Bold));
        p.drawText(x, barY - 18, barW, 18, Qt::AlignCenter, QString::number(it.value()));

        // City label below bar
        p.setPen(QColor(0x6B, 0x7A, 0x9F));
        p.setFont(QFont("Segoe UI", 9));
        p.drawText(x, H - pb + 8, barW, pb - 8, Qt::AlignCenter | Qt::TextWordWrap, it.key());

        x += barW + gap;
    }

    // Title
    if (!_title.isEmpty()) {
        p.setPen(QColor(0xB0, 0xBD, 0xDA));
        p.setFont(QFont("Segoe UI", 11, QFont::Bold));
        p.drawText(pl, 0, chartW, pt - 4, Qt::AlignVCenter | Qt::AlignLeft, _title);
    }
}
