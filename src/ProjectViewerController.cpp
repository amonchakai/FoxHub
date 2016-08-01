/*
 * ProjectViewerController.cpp
 *
 *  Created on: 8 août 2015
 *      Author: pierre
 */
#include "ProjectViewerController.hpp"
#include "GitHub.hpp"

#include <bb/data/JsonDataAccess>
#include <bb/cascades/GroupDataModel>
#include <QFile>
#include <QDir>

#include <bb/cascades/Application>
#include <bb/cascades/ThemeSupport>
#include <bb/cascades/ColorTheme>
#include <bb/cascades/Theme>

#include <bb/system/SystemToast>

ProjectViewerController::ProjectViewerController(QObject *parent) : QObject(parent), m_ContentListView(NULL), m_IssuesListView(NULL) {
    bool ok = QObject::connect(GitHub::get(), SIGNAL(reposContents(const QString&, const QByteArray&)), this, SLOT(updateContentViewReceived(const QString&, const QByteArray&)));
    Q_ASSERT(ok);

    ok = QObject::connect(GitHub::get(), SIGNAL(issuesLoaded(const QByteArray&)), this, SLOT(updateIssueViewReceived(const QByteArray&)));
    Q_ASSERT(ok);

    ok = QObject::connect(GitHub::get(), SIGNAL(commitsLoaded(const QByteArray&)), this, SLOT(updateCommitsViewReceived(const QByteArray&)));
    Q_ASSERT(ok);

}

QString ProjectViewerController::formatDate(const QString& date) {
    QDateTime date_dt = QDateTime::fromString(date, "yyyy-MM-ddThh:mm:ssZ");

    return  tr("on ") + date_dt.date().toString(Qt::SystemLocaleShortDate) + tr(" at ") + date_dt.time().toString("hh:mm");
}

void ProjectViewerController::updateContentViewReceived (const QString& url_str, const QByteArray& buffer) {

    updateContentView(buffer);

    if(url_str == m_Root) {
        QString directory = QDir::homePath() + QLatin1String("/ApplicationData/");
        if (!QFile::exists(directory)) {
            QDir dir;
            dir.mkpath(directory);
        }

        QFile file(directory + QString::number(qHash(url_str)) +  ".json");

        if (file.open(QIODevice::WriteOnly)) {
            file.write(buffer);
            file.close();
        }
    }

    emit loaded();
}

void ProjectViewerController::updateIssueViewReceived (const QByteArray& buffer) {
    updateIssuesView(buffer);


    QString directory = QDir::homePath() + QLatin1String("/ApplicationData/");
    if (!QFile::exists(directory)) {
        QDir dir;
        dir.mkpath(directory);
    }

    QFile file(directory + QString::number(qHash(m_RootIssues)) +  ".json");

    if (file.open(QIODevice::WriteOnly)) {
        file.write(buffer);
        file.close();
    }

    emit issueLoaded();
}

void ProjectViewerController::updateCommitsViewReceived (const QByteArray& buffer) {
    updateCommitsView(buffer);


    QString directory = QDir::homePath() + QLatin1String("/ApplicationData/");
    if (!QFile::exists(directory)) {
        QDir dir;
        dir.mkpath(directory);
    }

    QFile file(directory + QString::number(qHash(m_RootCommits)) +  ".json");

    if (file.open(QIODevice::WriteOnly)) {
        file.write(buffer);
        file.close();
    }

    emit commitsLoaded();
}


void ProjectViewerController::updateIssuesView(const QByteArray& buffer) {
    using namespace bb::data;
    JsonDataAccess jda;

    QVariant qtData = jda.loadFromBuffer(buffer);

    if(jda.hasError()) {
        qDebug() << jda.error().errorMessage();
    }


    if(m_IssuesListView == NULL) {
        qWarning() << "did not received the list. quit.";
        return;
    }

    using namespace bb::cascades;
    GroupDataModel* dataModel = dynamic_cast<GroupDataModel*>(m_IssuesListView->dataModel());
    dataModel->clear();
    dataModel->insertList(qtData.toList());
}

void ProjectViewerController::updateContentView(const QByteArray& buffer) {

    using namespace bb::data;
    JsonDataAccess jda;

    QVariant qtData = jda.loadFromBuffer(buffer);

    if(jda.hasError()) {
        qDebug() << jda.error().errorMessage();
    }


    if(m_ContentListView == NULL) {
        qWarning() << "did not received the list. quit.";
        return;
    }

    using namespace bb::cascades;
    GroupDataModel* dataModel = dynamic_cast<GroupDataModel*>(m_ContentListView->dataModel());
    dataModel->clear();
    dataModel->insertList(qtData.toList());

}

void ProjectViewerController::updateCommitsView(const QByteArray& buffer) {
    using namespace bb::data;
    JsonDataAccess jda;

    QVariant qtData = jda.loadFromBuffer(buffer);

    if(jda.hasError()) {
        qDebug() << jda.error().errorMessage();
    }


    if(m_CommitsListView == NULL) {
        qWarning() << "did not received the list. quit.";
        return;
    }

    using namespace bb::cascades;
    GroupDataModel* dataModel = dynamic_cast<GroupDataModel*>(m_CommitsListView->dataModel());
    dataModel->clear();
    dataModel->insertList(qtData.toList());
}

void ProjectViewerController::pop() {
    if(m_CurrentPath == m_Root) return;

    getContent(m_CurrentPath.mid(0, m_CurrentPath.lastIndexOf("/")));

}

void ProjectViewerController::setRoot(const QString& url) {
    m_Root = url;
    m_CurrentPath = url;

    if(m_ContentListView != NULL) {
        using namespace bb::cascades;
        GroupDataModel* dataModel = dynamic_cast<GroupDataModel*>(m_ContentListView->dataModel());
        dataModel->clear();
    }

    loadContentCache();
}

void ProjectViewerController::setRootIssues(const QString& url) {
    m_RootIssues = url;

    if(m_IssuesListView != NULL) {
        using namespace bb::cascades;
        GroupDataModel* dataModel = dynamic_cast<GroupDataModel*>(m_IssuesListView->dataModel());
        dataModel->clear();
    }

    loadIssueCache();
}

void ProjectViewerController::setRootCommits(const QString& url) {
    m_RootCommits = url;

    if(m_CommitsListView != NULL) {
        using namespace bb::cascades;
        GroupDataModel* dataModel = dynamic_cast<GroupDataModel*>(m_CommitsListView->dataModel());
        dataModel->clear();
    }

    loadCommitCache();
}

void ProjectViewerController::getContent(const QString& url) {
    m_CurrentPath = url;
    GitHub::get()->getContent(url);
}

void ProjectViewerController::refreshContents() {
    GitHub::get()->getContent(m_CurrentPath);
}

void ProjectViewerController::refreshIssues () {
    GitHub::get()->getIssues(m_RootIssues);
}

void ProjectViewerController::refreshCommits () {
    GitHub::get()->getCommits(m_RootCommits);
}

void ProjectViewerController::getIssues(const QString& url) {
    GitHub::get()->getIssues(url);
}


void ProjectViewerController::getCommits(const QString& url) {
    GitHub::get()->getCommits(url);
}

void ProjectViewerController::loadContentCache() {

    QString directory = QDir::homePath() + QLatin1String("/ApplicationData/");
    if (!QFile::exists(directory)) {
        QDir dir;
        dir.mkpath(directory);
    }

    QFile file(directory + QString::number(qHash(m_Root)) + ".json");

    if (file.open(QIODevice::ReadOnly)) {
        QByteArray datas = file.readAll();
        updateContentView(datas);

        file.close();
    } else {
        getContent(m_Root);
    }
}

void ProjectViewerController::loadIssueCache() {

    QString directory = QDir::homePath() + QLatin1String("/ApplicationData/");
    if (!QFile::exists(directory)) {
        QDir dir;
        dir.mkpath(directory);
    }

    QFile file(directory + QString::number(qHash(m_RootIssues)) + ".json");

    if (file.open(QIODevice::ReadOnly)) {
        QByteArray datas = file.readAll();
        updateIssuesView(datas);

        file.close();
    } else {
        getIssues(m_RootIssues);
    }
}

void ProjectViewerController::loadCommitCache() {
    QString directory = QDir::homePath() + QLatin1String("/ApplicationData/");
    if (!QFile::exists(directory)) {
        QDir dir;
        dir.mkpath(directory);
    }

    QFile file(directory + QString::number(qHash(m_RootCommits)) + ".json");

    if (file.open(QIODevice::ReadOnly)) {
        QByteArray datas = file.readAll();
        updateCommitsView(datas);

        file.close();
    } else {
        getCommits(m_RootCommits);
    }
}



