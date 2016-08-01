/*
 * IssueController.cpp
 *
 *  Created on: 9 août 2015
 *      Author: pierre
 */

#include "IssueController.hpp"
#include "GitHub.hpp"

#include <bb/data/JsonDataAccess>
#include <bb/cascades/GroupDataModel>
#include <bb/system/SystemToast>

IssueController::IssueController(QObject *parent) : QObject(parent), m_ListView(NULL) {

    bool ok = QObject::connect(GitHub::get(), SIGNAL(issueDescriptionLoaded(const QByteArray&)), this, SLOT(issueDescription(const QByteArray&)));
    Q_ASSERT(ok);

    ok = QObject::connect(GitHub::get(), SIGNAL(commentOnIssueLoaded(const QByteArray&)), this, SLOT(commentsOnIssue(const QByteArray&)));
    Q_ASSERT(ok);

    ok = QObject::connect(GitHub::get(), SIGNAL(insertCommentSuccess()), this, SLOT(insertCommentSuccess()));
    Q_ASSERT(ok);
}


void IssueController::loadIssue(const QString& url) {
    m_RootIssues = url;
    GitHub::get()->getIssueDescription(url);
}

void IssueController::deleteComment(int id) {
    GitHub::get()->deleteComment(m_RootIssues.mid(0, m_RootIssues.lastIndexOf("/")) + "/comments/" + QString::number(id));
}

void IssueController::updateComment(int id, const QString &body) {
    GitHub::get()->updateComment(m_RootIssues.mid(0, m_RootIssues.lastIndexOf("/")) + "/comments/" + QString::number(id), body);
}


QString IssueController::formatDate(const QString& date) {
    QDateTime date_dt = QDateTime::fromString(date, "yyyy-MM-ddThh:mm:ssZ");

    return  tr("On ") + date_dt.date().toString(Qt::SystemLocaleShortDate) + tr(" at ") + date_dt.time().toString("hh:mm");
}


void IssueController::issueDescription(const QByteArray& buffer) {
    using namespace bb::data;
    JsonDataAccess jda;

    QVariant qtData = jda.loadFromBuffer(buffer);

    if(jda.hasError()) {
        qDebug() << jda.error().errorMessage();
    }


    QString message = qtData.toMap()["body"].toString();
    message.replace("\\r\\n", "<br/>");
    message.replace("\\\"", "\"");
    message.replace("\\n", "<br/>");

    emit descriptionLoaded(qtData.toMap()["user"].toMap()["login"].toString(), qtData.toMap()["user"].toMap()["avatar_url"].toString(), formatDate(qtData.toMap()["created_at"].toString()), message);

    GitHub::get()->getCommentsOnIssue(m_RootIssues + "/comments");
}




void IssueController::commentsOnIssue(const QByteArray& buffer) {
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
    dataModel->insertList(qtData.toList());

    emit loaded();

}


void IssueController::insertComment(const QString &body) {

    if(body.isEmpty()) {
        bb::system::SystemToast *toast = new bb::system::SystemToast(this);

        toast->setBody(tr("A comment should not be empty."));
        toast->setPosition(bb::system::SystemUiPosition::MiddleCenter);
        toast->show();
        return;

    }

    GitHub::get()->insertComment(body, m_RootIssues + "/comments");
}

void IssueController::insertCommentSuccess() {
    loadIssue(m_RootIssues);
}



