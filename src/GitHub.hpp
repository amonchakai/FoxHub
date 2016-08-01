/*
 * GitHub.hpp
 *
 *  Created on: 2 août 2015
 *      Author: pierre
 */

#ifndef GITHUB_HPP_
#define GITHUB_HPP_

#include "Images/NetImageTracker.h"

class GitHub  : public QObject {

    Q_OBJECT;

public:


    // ----------------------------------------------------------------------------------------------
    // member functions
    static GitHub* get            ();
    virtual ~GitHub               () {};

    void getToken                 (const QString& code);
    bool isLogged                 ();
    void logOut                   ();


    void getReposList             ();
    void searchProjects           (const QString& keywords);
    void getUserInfo              ();
    void setUser                  (const QString& id);

    void getContent               (const QString& url);
    void getIssues                (const QString& url);
    void getCommits               (const QString& url);
    void getIssueDescription      (const QString& url);
    void getCommentsOnIssue       (const QString& url);
    void insertComment            (const QString &body, const QString& issueUrl);

    void deleteComment            (const QString& url);
    void updateComment            (const QString& url, const QString& body);

public Q_SLOTS:
    void checkReplyGetToken       ();
    void checkReplyReposList      ();
    void checkReplyReposSearch    ();
    void checkReplyGetUserInfo    ();
    void checkReplyContentList    ();
    void checkReplyIssuesList     ();
    void checkReplyCommitsList    ();
    void checkReplyIssueDescription();
    void checkReplyCommentOnIssue  ();
    void checkReplyInsertComment   ();





Q_SIGNALS:
    void loggedIn   ();
    void denied     ();

    void reposList      (const QByteArray&);
    void reposSearch    (const QByteArray&);
    void reposContents  (const QString&, const QByteArray&);
    void issuesLoaded   (const QByteArray&);
    void commitsLoaded  (const QByteArray&);

    void issueDescriptionLoaded (const QByteArray&);
    void commentOnIssueLoaded   (const QByteArray&);
    void insertCommentSuccess   ();



private:

    void accessDenied               ();


    // ----------------------------------------------------------------------------------------------
    // member variables
    static GitHub *m_This;

    QSettings                    *m_Settings;
    QNetworkAccessManager        *m_NetworkAccessManager;


    // singleton; hide constructor
    GitHub                        (QObject *parent = 0);


};




#endif /* GITHUB_HPP_ */
