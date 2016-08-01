/*
 * ProjectViewerController.hpp
 *
 *  Created on: 8 août 2015
 *      Author: pierre
 */

#ifndef PROJECTVIEWERCONTROLLER_HPP_
#define PROJECTVIEWERCONTROLLER_HPP_

#include <bb/cascades/ListView>


class ProjectViewerController : public QObject {
    Q_OBJECT;

    private:

        bb::cascades::ListView              *m_ContentListView;
        bb::cascades::ListView              *m_IssuesListView;
        bb::cascades::ListView              *m_CommitsListView;
        QString                              m_CurrentPath;
        QString                              m_Root;
        QString                              m_RootIssues;
        QString                              m_RootCommits;
        int                                  m_CurrentIssue;


    public:
        ProjectViewerController              (QObject *parent = 0);
        virtual ~ProjectViewerController     ()                               {};



    public Q_SLOTS:
        void setRoot                  (const QString& url);
        void setRootIssues            (const QString& url);
        void setRootCommits           (const QString& url);
        void getContent               (const QString& url);
        void getCommits               (const QString& url);
        void refreshContents          ();
        void refreshIssues            ();
        void refreshCommits           ();
        void getIssues                (const QString& url);
        void loadContentCache         ();
        void loadIssueCache           ();
        void loadCommitCache          ();
        void pop                      ();
        inline void setContentListView(QObject *list)                  { m_ContentListView  = dynamic_cast<bb::cascades::ListView*>(list); };
        inline void setIssuesListView (QObject *list)                  { m_IssuesListView   = dynamic_cast<bb::cascades::ListView*>(list); };
        inline void setCommitsListView(QObject *list)                  { m_CommitsListView  = dynamic_cast<bb::cascades::ListView*>(list); };

        QString formatDate             (const QString& date);

        void updateContentViewReceived (const QString&, const QByteArray&);
        void updateContentView         (const QByteArray&);
        void updateIssueViewReceived   (const QByteArray& buffer);
        void updateIssuesView          (const QByteArray&);
        void updateCommitsViewReceived (const QByteArray& buffer);
        void updateCommitsView         (const QByteArray&);


    Q_SIGNALS:

        void loaded();
        void issueLoaded();
        void commitsLoaded();
        void failed();


};


#endif /* PROJECTVIEWERCONTROLLER_HPP_ */
