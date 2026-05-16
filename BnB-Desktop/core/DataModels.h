#ifndef DATAMODELS_H
#define DATAMODELS_H

#include <QJsonObject>
#include <QDateTime>
#include <QString>

namespace DataModels {

struct UserModel {
    int id;
    QString name;
    QString email;
    QString phone;
    QString role;
    QDateTime createdAt;

    static UserModel fromJson(const QJsonObject& json) {
        UserModel model;
        model.id        = json["id"].toInt();
        model.name      = json["name"].toString();
        model.email     = json["email"].toString();
        model.phone     = json["phone"].toString();
        model.role      = json["role"].toString();
        model.createdAt = QDateTime::fromString(json["created_at"].toString(), Qt::ISODate);
        return model;
    }

    QJsonObject toJson() const {
        QJsonObject obj;
        obj["id"]    = id;
        obj["name"]  = name;
        obj["email"] = email;
        obj["phone"] = phone;
        obj["role"]  = role;
        return obj;
    }
};

struct PropertyModel {
    int id;
    QString title;
    QString city;
    QString location;
    QString status;
    double price;
    int rooms;
    double areaMq;
    QString ownerName;
    QString ownerPhone;

    static PropertyModel fromJson(const QJsonObject& json) {
        PropertyModel model;
        model.id         = json["id"].toInt();
        model.title      = json["title"].toString();
        model.city       = json["city"].toString();
        model.location   = json["location"].toString();
        model.status     = json["status"].toString();
        model.price      = json["price"].toDouble();
        model.rooms      = json["rooms"].toInt();
        model.areaMq     = json["area_m2"].toDouble();
        model.ownerName  = json["owner"].toObject()["name"].toString();
        model.ownerPhone = json["owner"].toObject()["phone"].toString();
        return model;
    }

    QJsonObject toJson() const {
        QJsonObject obj;
        obj["id"]       = id;
        obj["title"]    = title;
        obj["city"]     = city;
        obj["location"] = location;
        obj["status"]   = status;
        obj["price"]    = price;
        obj["rooms"]    = rooms;
        obj["area_m2"]  = areaMq;
        return obj;
    }
};

struct WorkerServiceModel {
    int id;
    QString type;
    QString description;
    QString unit;
    QString workerName;
    QString workerPhone;
    double pricePerUnit;
    bool isAvailable;

    static WorkerServiceModel fromJson(const QJsonObject& json) {
        WorkerServiceModel model;
        model.id           = json["id"].toInt();
        model.type         = json["type"].toString();
        model.description  = json["description"].toString();
        model.unit         = json["unit"].toString();
        model.workerName   = json["worker"].toObject()["name"].toString();
        model.workerPhone  = json["worker"].toObject()["phone"].toString();
        model.pricePerUnit = json["price_per_unit"].toDouble();
        model.isAvailable  = json["is_available"].toBool();
        return model;
    }
};

struct ServiceRequestModel {
    int id;
    QString note;
    QString address;
    QString status;
    QString userName;
    QString userPhone;
    QString serviceType;
    QString workerName;
    QString workerPhone;
    QDateTime createdAt;

    static ServiceRequestModel fromJson(const QJsonObject& json) {
        ServiceRequestModel model;
        model.id          = json["id"].toInt();
        model.note        = json["note"].toString();
        model.address     = json["address"].toString();
        model.status      = json["status"].toString();
        model.userName    = json["user"].toObject()["name"].toString();
        model.userPhone   = json["user"].toObject()["phone"].toString();
        model.serviceType = json["worker_service"].toObject()["type"].toString();
        model.workerName  = json["worker_service"].toObject()["worker"].toObject()["name"].toString();
        model.workerPhone = json["worker_service"].toObject()["worker"].toObject()["phone"].toString();
        model.createdAt   = QDateTime::fromString(json["created_at"].toString(), Qt::ISODate);
        return model;
    }
};

struct ReviewModel {
    int id;
    QString userName;
    QString serviceType;
    QString comment;
    int rating;
    QDateTime createdAt;

    static ReviewModel fromJson(const QJsonObject& json) {
        ReviewModel model;
        model.id          = json["id"].toInt();
        model.userName    = json["user"].toObject()["name"].toString();
        model.serviceType = json["worker_service"].toObject()["type"].toString();
        model.comment     = json["comment"].toString();
        model.rating      = json["rating"].toInt();
        model.createdAt   = QDateTime::fromString(json["created_at"].toString(), Qt::ISODate);
        return model;
    }

    QString starString() const {
        return QString("★").repeated(rating) + QString("☆").repeated(5 - rating);
    }
};

struct ActivityLogModel {
    int id;
    int userId;
    QString userName;
    QString action;
    QString modelName;
    QString ipAddress;
    QDateTime createdAt;

    static ActivityLogModel fromJson(const QJsonObject& json) {
        ActivityLogModel model;
        model.id        = json["id"].toInt();
        model.userId    = json["user_id"].toInt();
        model.userName  = json["user"].toObject()["name"].toString();
        model.action    = json["action"].toString();
        model.modelName = json["model"].toString();
        model.ipAddress = json["ip_address"].toString();
        model.createdAt = QDateTime::fromString(json["created_at"].toString(), Qt::ISODate);
        return model;
    }
};

} // namespace DataModels

#endif // DATAMODELS_H
