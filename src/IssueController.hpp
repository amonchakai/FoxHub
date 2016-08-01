/*
 * IssueController.hpp
 *
 *  Created on: 9 août 2015
 *      Author: pierre
 */

#ifndef ISSUECONTROLLER_HPP_
#define ISSUECONTROLLER_HPP_


#include <bb/cascades/ListView>


class IssueController : public QObject {
    Q_OBJECT;

    private:

        bb::cascades::ListView          *m_ListView;
        QString                          m_RootIssues;


    public:
        IssueController              (QObject *parent = 0);
        virtual ~IssueController     ()                               {};



    public Q_SLOTS:
        void loadIssue                (const QString& url);
        inline void setListView       (QObject *list)                  { m_ListView  = dynamic_cast<bb::cascades::ListView*>(list); };
        QString formatDate            (const QString& date);

        void insertComment            (const QString &body);
        void insertCommentSuccess     () ;
        void deleteComment            (int id);
        void updateComment            (int id, const QString &body);

        void issueDescription         (const QByteArray&);
        void commentsOnIssue          (const QByteArray&);


    Q_SIGNALS:
        void descriptionLoaded(const QString& user, const QString& avatar_url, const QString& dateIssue, const QString& message);
        void loaded();
        void failed();


};



#endif /* ISSUECONTROLLER_HPP_ */
