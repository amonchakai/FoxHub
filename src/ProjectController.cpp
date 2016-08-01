/*
 * ProjectController.cpp
 *
 *  Created on: 2 août 2015
 *      Author: pierre
 */

#include "ProjectController.hpp"
#include "GitHub.hpp"

#include <bb/data/JsonDataAccess>
#include <bb/cascades/GroupDataModel>
#include <QFile>
#include <QDir>
#include <QDateTime>

ProjectsController::ProjectsController(QObject *parent) : QObject(parent), m_ListView(NULL) {
    bool ok = QObject::connect(GitHub::get(), SIGNAL(reposList(const QByteArray&)), this, SLOT(loadRepoList(const QByteArray&)));
    Q_ASSERT(ok);

    ok = QObject::connect(GitHub::get(), SIGNAL(reposSearch(const QByteArray&)), this, SLOT(updateView(const QByteArray&)));
    Q_ASSERT(ok);

    ok = QObject::connect(GitHub::get(), SIGNAL(denied()), this, SLOT(denied()));
    Q_ASSERT(ok);
}

void ProjectsController::loadCache() {
    QString directory = QDir::homePath() + QLatin1String("/ApplicationData");
    if (!QFile::exists(directory)) {
        QDir dir;
        dir.mkpath(directory);
    }

    QFile file(directory + "/CacheProjectList.json");

    if (file.open(QIODevice::ReadOnly)) {
        QByteArray datas = file.readAll();
        updateView(datas);

        file.close();
    } else {
        getList();
    }
}

void ProjectsController::getList() {
    GitHub::get()->getReposList();
}


void ProjectsController::loadRepoList(const QByteArray& buffer) {

    updateView(buffer);


    QString directory = QDir::homePath() + QLatin1String("/ApplicationData");
    if (!QFile::exists(directory)) {
        QDir dir;
        dir.mkpath(directory);
    }

    QFile file(directory + "/CacheProjectList.json");

    if (file.open(QIODevice::WriteOnly)) {
        file.write(buffer);
        file.close();
    }

    emit loaded();
}


void ProjectsController::searchProject(const QString& keywords) {
    GitHub::get()->searchProjects(keywords);
}

void ProjectsController::updateView(const QByteArray& buffer) {
    using namespace bb::data;
    JsonDataAccess jda;

    QVariant qtData = jda.loadFromBuffer(buffer);

    if(jda.hasError()) {
        qDebug() << jda.error().errorMessage();
    }


    if(m_ListView == NULL) {
        qWarning() << "did not received the list. quit.";
        return;
    }

    using namespace bb::cascades;
    GroupDataModel* dataModel = dynamic_cast<GroupDataModel*>(m_ListView->dataModel());
    dataModel->clear();

    QStringList keys;
    QSettings settings("Amonchakai", "FoxHub");

    bool ascending = false;

    switch(settings.value("sort_key_project", 2).toInt()) {
        case 1:
            keys.push_back("created_at");
            break;

        case 2:
            keys.push_back("pushed_at");
            break;

        case 3:
            keys.push_back("name");
            ascending = true;
            break;

    }

    dataModel->setSortingKeys(keys);
    dataModel->setSortedAscending(ascending);

    dataModel->insertList(qtData.toList());



}

void ProjectsController::denied() {
    emit failed();
}


QString ProjectsController::formatDate(const QString& date) {
    return  QDateTime::fromString(date, "yyyy-MM-ddThh:mm:ssZ").date().toString(Qt::SystemLocaleLongDate);
}


