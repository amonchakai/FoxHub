/*
 * AppSettings.cpp
 *
 *  Created on: 16 oct. 2014
 *      Author: pierre
 */


#include "SettingsController.hpp"



SettingsController::SettingsController(QObject *parent) : QObject(parent), m_Settings(NULL) {

     m_Settings = new QSettings("Amonchakai", "FoxHub");

    m_Theme = m_Settings->value("theme").value<int>();
    m_User = m_Settings->value("user_id").toString();
    m_SortProjectK = m_Settings->value("sort_key_project", 2).toInt();

}


void SettingsController::save() {
    m_Settings->setValue("theme", m_Theme);
    m_Settings->setValue("user_id", m_User);
    m_Settings->setValue("sort_key_project", m_SortProjectK);

}





