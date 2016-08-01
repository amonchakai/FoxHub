/*
 * ProjectController.hpp
 *
 *  Created on: 2 août 2015
 *      Author: pierre
 */

#ifndef PROJECTCONTROLLER_HPP_
#define PROJECTCONTROLLER_HPP_

#include <bb/cascades/ListView>


class ProjectsController : public QObject {
    Q_OBJECT;

    private:

        bb::cascades::ListView          *m_ListView;




    public:
        ProjectsController              (QObject *parent = 0);
        virtual ~ProjectsController     ()                               {};



    public Q_SLOTS:
        void getList                  ();
        void loadCache                ();
        void searchProject            (const QString& keywords);
        inline void setListView       (QObject *list)                  { m_ListView  = dynamic_cast<bb::cascades::ListView*>(list); };
        void loadRepoList             (const QByteArray&);
        QString formatDate            (const QString& date);

        void denied                   ();
        void updateView                 (const QByteArray&);


    Q_SIGNALS:

        void loaded();
        void failed();


};



#endif /* PROJECTCONTROLLER_HPP_ */
