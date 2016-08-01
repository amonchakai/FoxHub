/*
 * GitHub.cpp
 *
 *  Created on: 2 août 2015
 *      Author: pierre
 */

#include "GitHub.hpp"
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QRegExp>

#include <bb/data/JsonDataAccess>
#include <bb/system/SystemToast>

#include "PrivateAPIKeys.hpp"

GitHub *GitHub::m_This = NULL;


GitHub *GitHub::get() {
    if(m_This == NULL)
        m_This = new GitHub();

    return m_This;
}

void GitHub::setUser(const QString& id) {
    if(m_Settings->value("user_id", "") != id) {
        m_Settings->setValue("user_id", id);
    }
}

GitHub::GitHub(QObject *parent) : QObject(parent) {
    m_Settings = new QSettings("Amonchakai", "FoxHub");
    m_NetworkAccessManager = new QNetworkAccessManager(this);
}

void GitHub::getToken(const QString& code) {
    QNetworkRequest request(QUrl("https://github.com/login/oauth/access_token"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    QUrl params;
    params.addQueryItem("code",         code);
    params.addQueryItem("client_id",    GITHUB_CLIENT_ID);
    params.addQueryItem("client_secret", GITHUB_CLIENT_SECRET);

    QNetworkReply* reply = m_NetworkAccessManager->post(request, params.encodedQuery());
    bool ok = connect(reply, SIGNAL(finished()), this, SLOT(checkReplyGetToken()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);
}

void GitHub::checkReplyGetToken() {

    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());

    QString response;
    if (reply) {
        if (reply->error() == QNetworkReply::NoError) {
            const int available = reply->bytesAvailable();
            if (available > 0) {
                const QByteArray buffer(reply->readAll());
                response = QString::fromUtf8(buffer);

                QRegExp token("access_token=([0-9a-zA-Z]+)");
                QRegExp scope("scope=([^&]+)");

                if(token.indexIn(response) != -1) {
                    m_Settings->setValue("access_token", token.cap(1));

                    emit loggedIn();

                    getUserInfo();
                }

                if(scope.indexIn(response) != -1) {
                    QString scope_s = scope.cap(1);
                    scope_s.replace("%2C", ",");
                    m_Settings->setValue("scope", scope_s);
                }

            }
        } else {
            qDebug() << "reply... " << reply->errorString();
            accessDenied();
        }

        reply->deleteLater();
    }
}


void GitHub::accessDenied() {

    bb::system::SystemToast *toast = new bb::system::SystemToast(this);

    toast->setBody(tr("Connection failed"));
    toast->setPosition(bb::system::SystemUiPosition::MiddleCenter);
    toast->show();

    emit denied();
}

bool GitHub::isLogged() {
    return !m_Settings->value("access_token", "").toString().isEmpty();
}

void GitHub::logOut() {
    m_Settings->setValue("access_token", "");
}




void GitHub::getReposList() {
    QNetworkRequest request(QUrl(QString("https://api.github.com/user/repos")));
    request.setRawHeader("Authorization", ("token " + m_Settings->value("access_token").value<QString>()).toAscii());

    QNetworkReply* reply = m_NetworkAccessManager->get(request);
    bool ok = connect(reply, SIGNAL(finished()), this, SLOT(checkReplyReposList()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);
}



void GitHub::checkReplyReposList () {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());

    QString response;
    if (reply) {
        if (reply->error() == QNetworkReply::NoError) {
            const int available = reply->bytesAvailable();
            if (available > 0) {
                emit reposList(reply->readAll());
            }
        } else {
            qDebug() << "reply... " << reply->errorString();
            accessDenied();
        }
        reply->deleteLater();
    }
}

void GitHub::searchProjects(const QString& keywords) {
    QString noSpace=keywords;
    noSpace.replace(" ", " +");

    qDebug() << (QString("https://api.github.com/search/repositories?q=") + noSpace);

    QNetworkRequest request(QUrl(QString("https://api.github.com/search/repositories?q=") + noSpace));
    request.setRawHeader("Authorization", ("token " + m_Settings->value("access_token").value<QString>()).toAscii());

    QNetworkReply* reply = m_NetworkAccessManager->get(request);
    bool ok = connect(reply, SIGNAL(finished()), this, SLOT(checkReplyReposSearch()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);
}


void GitHub::checkReplyReposSearch () {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());

    QString response;
    if (reply) {
        if (reply->error() == QNetworkReply::NoError) {
            const int available = reply->bytesAvailable();
            if (available > 0) {
                emit reposSearch(reply->readAll());
            }
        } else {
            qDebug() << "reply... " << reply->errorString();
            accessDenied();
        }
        reply->deleteLater();
    }
}

void GitHub::getUserInfo() {
    QNetworkRequest request(QUrl(QString("https://api.github.com/user")));
    request.setRawHeader("Authorization", ("token " + m_Settings->value("access_token").value<QString>()).toAscii());

    QNetworkReply* reply = m_NetworkAccessManager->get(request);
    bool ok = connect(reply, SIGNAL(finished()), this, SLOT(checkReplyGetUserInfo()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);
}


void GitHub::checkReplyGetUserInfo () {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());

    QString response;
    if (reply) {
        if (reply->error() == QNetworkReply::NoError) {
            const int available = reply->bytesAvailable();
            if (available > 0) {
                using namespace bb::data;
                JsonDataAccess jda;

                QVariant qtData = jda.loadFromBuffer(reply->readAll());

                if(jda.hasError()) {
                    qDebug() << jda.error().errorMessage();
                }

                setUser(qtData.toMap()["login"].toString());

            }
        } else {
            qDebug() << "reply... " << reply->errorString();
            accessDenied();
        }
        reply->deleteLater();
    }
}



void GitHub::getContent(const QString& url) {
    QNetworkRequest request(QUrl(QString("") + url));
    request.setRawHeader("Authorization", ("token " + m_Settings->value("access_token").value<QString>()).toAscii());

    QNetworkReply* reply = m_NetworkAccessManager->get(request);
    bool ok = connect(reply, SIGNAL(finished()), this, SLOT(checkReplyContentList()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);
}

void GitHub::checkReplyContentList () {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());

    QString response;
    if (reply) {
        if (reply->error() == QNetworkReply::NoError) {
            const int available = reply->bytesAvailable();
            if (available > 0) {
                emit reposContents(reply->url().toString(), reply->readAll());
            }
        } else {
            qDebug() << "reply... " << reply->errorString();
            accessDenied();
        }
        reply->deleteLater();
    }
}

void GitHub::getIssues(const QString& url) {
    QNetworkRequest request(QUrl(QString("") + url));
    request.setRawHeader("Authorization", ("token " + m_Settings->value("access_token").value<QString>()).toAscii());

    QNetworkReply* reply = m_NetworkAccessManager->get(request);
    bool ok = connect(reply, SIGNAL(finished()), this, SLOT(checkReplyIssuesList()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);
}

void GitHub::checkReplyIssuesList() {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());

    QString response;
    if (reply) {
        if (reply->error() == QNetworkReply::NoError) {
            const int available = reply->bytesAvailable();
            if (available > 0) {
                emit issuesLoaded(reply->readAll());
            }
        } else {
            qDebug() << "reply... " << reply->errorString();
            accessDenied();
        }
        reply->deleteLater();
    }
}

void GitHub::getCommits(const QString& url) {
    QNetworkRequest request(QUrl(QString("") + url));
    request.setRawHeader("Authorization", ("token " + m_Settings->value("access_token").value<QString>()).toAscii());

    QNetworkReply* reply = m_NetworkAccessManager->get(request);
    bool ok = connect(reply, SIGNAL(finished()), this, SLOT(checkReplyCommitsList()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);
}

void GitHub::checkReplyCommitsList() {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());

    QString response;
    if (reply) {
        if (reply->error() == QNetworkReply::NoError) {
            const int available = reply->bytesAvailable();
            if (available > 0) {
                emit commitsLoaded(reply->readAll());
            }
        } else {
            qDebug() << "reply... " << reply->errorString();
            accessDenied();
        }
        reply->deleteLater();
    }
}

void GitHub::getIssueDescription(const QString& url) {
    QNetworkRequest request(QUrl(QString("") + url));
    request.setRawHeader("Authorization", ("token " + m_Settings->value("access_token").value<QString>()).toAscii());

    QNetworkReply* reply = m_NetworkAccessManager->get(request);
    bool ok = connect(reply, SIGNAL(finished()), this, SLOT(checkReplyIssueDescription()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);
}


void GitHub::checkReplyIssueDescription() {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());

    QString response;
    if (reply) {
        if (reply->error() == QNetworkReply::NoError) {
            const int available = reply->bytesAvailable();
            if (available > 0) {
                emit issueDescriptionLoaded(reply->readAll());
            }
        } else {
            qDebug() << "reply... " << reply->errorString();
            accessDenied();
        }
        reply->deleteLater();
    }
}

void GitHub::getCommentsOnIssue(const QString& url) {
    QNetworkRequest request(QUrl(QString("") + url));
    request.setRawHeader("Authorization", ("token " + m_Settings->value("access_token").value<QString>()).toAscii());

    QNetworkReply* reply = m_NetworkAccessManager->get(request);
    bool ok = connect(reply, SIGNAL(finished()), this, SLOT(checkReplyCommentOnIssue()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);
}

void GitHub::checkReplyCommentOnIssue() {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());

    QString response;
    if (reply) {
        if (reply->error() == QNetworkReply::NoError) {
            const int available = reply->bytesAvailable();
            if (available > 0) {
                emit commentOnIssueLoaded(reply->readAll());
            }
        } else {
            qDebug() << "reply... " << reply->errorString();
            accessDenied();
        }
        reply->deleteLater();
    }
}


void GitHub::insertComment(const QString &body, const QString& issueUrl) {

    const QUrl url(QString("") + issueUrl);

    QByteArray datas;
    datas += QString("{").toAscii();
    datas += QString(QString("\"body\": \"") + body + "\"").toAscii();
    datas += QString("}").toAscii();

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", ("token " + m_Settings->value("access_token").value<QString>()).toAscii());


    QNetworkReply* reply = m_NetworkAccessManager->post(request, datas);
    bool ok = connect(reply, SIGNAL(finished()), this, SLOT(checkReplyInsertComment()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);
}

void GitHub::checkReplyInsertComment() {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());

    QString response;
    if (reply) {
        if (reply->error() == QNetworkReply::NoError) {
            emit insertCommentSuccess();
        } else {
            qDebug() << reply->errorString();
        }

        reply->deleteLater();
    }
}

void GitHub::deleteComment(const QString& url) {
    QNetworkRequest request(QUrl(QString("") + url));
    request.setRawHeader("Authorization", ("token " + m_Settings->value("access_token").value<QString>()).toAscii());

    QNetworkReply* reply = m_NetworkAccessManager->sendCustomRequest(request, "DELETE");
    bool ok = connect(reply, SIGNAL(finished()), this, SLOT(checkReplyInsertComment()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);
}

void GitHub::updateComment(const QString& url_str, const QString& body) {
    const QUrl url(QString("") + url_str);

    QByteArray datas;
    datas += QString("{").toAscii();
    datas += QString(QString("\"body\": \"") + body + "\"").toAscii();
    datas += QString("}").toAscii();

    QNetworkRequest request(url);
    request.setRawHeader("Authorization", ("token " + m_Settings->value("access_token").value<QString>()).toAscii());
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");


    QNetworkReply* reply = m_NetworkAccessManager->sendCustomRequest(request, "PATCH");
    bool ok = connect(reply, SIGNAL(finished()), this, SLOT(checkReplyInsertComment()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);
}

