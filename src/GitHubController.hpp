/*
 * GitHubController.hpp
 *
 *  Created on: 2 août 2015
 *      Author: pierre
 */

#ifndef GITHUBCONTROLLER_HPP_
#define GITHUBCONTROLLER_HPP_

#include <bb/cascades/WebView>


class GitHubController : public QObject {
    Q_OBJECT;

    private:

        bb::cascades::WebView        *m_WebView;


    public:
        GitHubController              (QObject *parent = 0);
        virtual ~GitHubController     ()                               {};



    public Q_SLOTS:
        bool isLogged                 ();
        void logOut                   ();

        void logInRequest             ();
        void setWebView               (QObject *webView);
        void navigationRequested      (bb::cascades::WebNavigationRequest *request);
        void fowardLoggedIn           ();



    Q_SIGNALS:

    void closeConnect();
    void loggedIn();


};


#endif /* GITHUBCONTROLLER_HPP_ */
