#include "ApiClient.h"
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

const QString ApiClient::BASE_URL = "http://127.0.0.1:8000/api";

ApiClient* ApiClient::instance()
{
    static ApiClient inst;
    return &inst;
}

ApiClient::ApiClient(QObject *parent)
    : QObject(parent)
{
    _manager = new QNetworkAccessManager(this);
    _pendingRequestsCount = 0;
    _settings = new QSettings("BBAdmin", "Auth", this);
}

void ApiClient::setToken(const QString& token)
{
    _settings->setValue("token", token);
}

QString ApiClient::token()
{
    return _settings->value("token").toString();
}

void ApiClient::clearToken()
{
    _settings->remove("token");
}

QNetworkRequest ApiClient::buildRequest(const QString& endpoint)
{
    QNetworkRequest request(QUrl(BASE_URL + endpoint));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Accept", "application/json");
    QString tokenVal = token();
    if (!tokenVal.isEmpty()) {
        request.setRawHeader("Authorization", "Bearer " + tokenVal.toUtf8());
    }
    return request;
}

// Shared reply handler — guards against double-fire of the finished signal.
void ApiClient::handleReply(QNetworkReply* reply,
                            std::function<void(QJsonObject)> onSuccess,
                            std::function<void(QString)> onError)
{
    QObject::connect(reply, &QNetworkReply::finished, [reply, onSuccess, onError, this]() {
        if (!_pendingRequests.contains(reply)) return;  // guard against double-fire
        QString reqId = _pendingRequests.take(reply);
        _pendingRequestsCount--;
        emit loadingChanged(_pendingRequestsCount > 0);

        if (reply->error() == QNetworkReply::NoError) {
            QByteArray responseData = reply->readAll();
            QJsonDocument doc = QJsonDocument::fromJson(responseData);
            QJsonObject root = doc.object();
            bool success = root["success"].toBool();
            if (success) {
                // Normalise both response shapes into a QJsonObject so callers
                // always do data["data"].toArray():
                //   Paginated:  root["data"] = { "data": [...], "meta": {...} }
                //   Collection: root["data"] = [...]  → wrap as { "data": [...] }
                QJsonObject data;
                if (root["data"].isArray()) {
                    data["data"] = root["data"].toArray();
                } else {
                    data = root["data"].toObject();
                }
                onSuccess(data);
                emit requestSuccess(reqId, data);
            } else {
                QString message = root["message"].toString();
                onError(message);
                emit requestError(reqId, message);
            }
        } else {
            onError(reply->errorString());
            emit requestError(reqId, reply->errorString());
        }
        reply->deleteLater();
    });
}

void ApiClient::get(const QString& endpoint, const QString& requestId,
                    std::function<void(QJsonObject)> onSuccess,
                    std::function<void(QString)> onError)
{
    QNetworkReply* reply = _manager->get(buildRequest(endpoint));
    _pendingRequests[reply] = requestId;
    _pendingRequestsCount++;
    emit loadingChanged(true);
    handleReply(reply, onSuccess, onError);
}

void ApiClient::post(const QString& endpoint, const QString& requestId,
                     const QJsonObject& body,
                     std::function<void(QJsonObject)> onSuccess,
                     std::function<void(QString)> onError)
{
    QNetworkReply* reply = _manager->post(buildRequest(endpoint), QJsonDocument(body).toJson());
    _pendingRequests[reply] = requestId;
    _pendingRequestsCount++;
    emit loadingChanged(true);
    handleReply(reply, onSuccess, onError);
}

void ApiClient::put(const QString& endpoint, const QString& requestId,
                    const QJsonObject& body,
                    std::function<void(QJsonObject)> onSuccess,
                    std::function<void(QString)> onError)
{
    QNetworkReply* reply = _manager->put(buildRequest(endpoint), QJsonDocument(body).toJson());
    _pendingRequests[reply] = requestId;
    _pendingRequestsCount++;
    emit loadingChanged(true);
    handleReply(reply, onSuccess, onError);
}

void ApiClient::deleteResource(const QString& endpoint, const QString& requestId,
                               std::function<void(QJsonObject)> onSuccess,
                               std::function<void(QString)> onError)
{
    QNetworkReply* reply = _manager->deleteResource(buildRequest(endpoint));
    _pendingRequests[reply] = requestId;
    _pendingRequestsCount++;
    emit loadingChanged(true);
    handleReply(reply, onSuccess, onError);
}
