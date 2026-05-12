#ifndef APICLIENT_H
#define APICLIENT_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSettings>
#include <QMap>
#include <functional>

class ApiClient : public QObject
{
    Q_OBJECT
public:
    static ApiClient* instance();
    void setToken(const QString& token);
    QString token();
    void clearToken();
    QNetworkRequest buildRequest(const QString& endpoint);
    void get(const QString& endpoint, const QString& requestId, std::function<void(QJsonObject)> onSuccess, std::function<void(QString)> onError);
    void post(const QString& endpoint, const QString& requestId, const QJsonObject& body, std::function<void(QJsonObject)> onSuccess, std::function<void(QString)> onError);
    void put(const QString& endpoint, const QString& requestId, const QJsonObject& body, std::function<void(QJsonObject)> onSuccess, std::function<void(QString)> onError);
    void deleteResource(const QString& endpoint, const QString& requestId, std::function<void(QJsonObject)> onSuccess, std::function<void(QString)> onError);

signals:
    void requestSuccess(const QString& requestId, QJsonObject data);
    void requestError(const QString& requestId, const QString& message);
    void loadingChanged(bool isLoading);

private:
    explicit ApiClient(QObject *parent = nullptr);
    static const QString BASE_URL;
    QNetworkAccessManager* _manager;
    QSettings* _settings;
    QMap<QNetworkReply*, QString> _pendingRequests; // Maps reply to requestId
    int _pendingRequestsCount;
};

#endif // APICLIENT_H