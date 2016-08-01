/*
 * GitHubController.cpp
 *
 *  Created on: 2 août 2015
 *      Author: pierre
 */


#include "GitHubController.hpp"
#include "PrivateAPIKeys.hpp"
#include <bb/cascades/WebNavigationRequest>
#include "GitHub.hpp"

GitHubController::GitHubController(QObject *parent) : QObject(parent), m_WebView(NULL) {
    bool check = QObject::connect(GitHub::get(), SIGNAL(loggedIn()), this, SLOT(fowardLoggedIn()));
    Q_ASSERT(check);

}


bool GitHubController::isLogged() {
    return GitHub::get()->isLogged();
}

void GitHubController::logOut() {
    GitHub::get()->logOut();
}

void GitHubController::fowardLoggedIn() {
    emit loggedIn();
}



void GitHubController::setWebView(QObject *webView) {
    m_WebView = dynamic_cast<bb::cascades::WebView*>(webView);

    if(m_WebView != NULL) {
        bool check = connect(m_WebView, SIGNAL(navigationRequested(bb::cascades::WebNavigationRequest *)), this, SLOT(navigationRequested(bb::cascades::WebNavigationRequest *)));
        Q_ASSERT(check);
        Q_UNUSED(check);
    }
}

void GitHubController::navigationRequested(bb::cascades::WebNavigationRequest *request) {
    qDebug() << request->url().toString();

    QRegExp code("code=([0-9a-zA-Z]+)");
    if(code.indexIn(request->url().toString()) != -1) {
        emit closeConnect();

        GitHub::get()->getToken(code.cap(1));

    }
}

void GitHubController::logInRequest () {
    if(m_WebView == NULL)
        return;

    m_WebView->setUrl(QString("https://github.com/login/oauth/authorize?client_id=")+ GITHUB_CLIENT_ID + "&scope=user,repo");
}
