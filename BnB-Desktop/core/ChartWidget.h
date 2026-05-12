#ifndef CHARTWIDGET_H
#define CHARTWIDGET_H

#include <QWidget>
#include <QMap>
#include <QColor>

class ChartWidget : public QWidget
{
    Q_OBJECT
public:
    explicit ChartWidget(QWidget *parent = nullptr);
    void setData(const QMap<QString, int>& data);
    void setTitle(const QString& title);
    void setBarColor(const QColor& color);
    QSize sizeHint() const override;

protected:
    void paintEvent(QPaintEvent* event) override;

private:
    QMap<QString, int> _data;
    QString _title;
    QColor _barColor;
};

#endif // CHARTWIDGET_H