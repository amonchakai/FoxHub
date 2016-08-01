import bb.cascades 1.3
import Utility.SettingsController 1.0

NavigationPane {
    id: navSettings
    
    Page {
        id: settingsPage
        
        
        titleBar: TitleBar {
            title: qsTr("Settings")
            dismissAction: ActionItem {
                title: qsTr("Close")
                onTriggered: {
                    // Emit the custom signal here to indicate that this page needs to be closed
                    // The signal would be handled by the page which invoked it
                    settings.close();
                }
            }
            acceptAction: ActionItem {
                title: qsTr("Save")
                onTriggered: {
                    settingsController.save(); 
                    settings.close();
                }
            }
        }
        
        ScrollView {
            id: settingPage
            property string userName;
            
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.TopToBottom
                }
                id: headerContainer
                horizontalAlignment: HorizontalAlignment.Fill
                
                function themeStyleToHeaderColor(style){
                    switch (style) {
                        case VisualStyle.Bright:
                            return Color.create(0.96,0.96,0.96);
                        case VisualStyle.Dark: 
                            return Color.create(0.15,0.15,0.15);
                        default :
                            return Color.create(0.96,0.96,0.96);    
                    }
                    return Color.create(0.96,0.96,0.96); 
                }
                
                // --------------------------------------------------------------------------
                // Login settings
                Container {
                    layout: StackLayout { orientation: LayoutOrientation.LeftToRight }
                    
                    Label {
                        text: qsTr("Profile")
                        textStyle.fontSize: FontSize.Large
                        horizontalAlignment: HorizontalAlignment.Left
                        verticalAlignment: VerticalAlignment.Bottom
                    }
                
                }
                Divider { }
                
                Container {
                    layout: DockLayout { }
                    background: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? Color.create("#131313") : Color.create("#fafafaff")
                    Container {
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Left
                        
                        Container {
                            preferredWidth: ui.du(.1)
                        }
                        
                        
                        ImageView {
                            imageSource: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "asset:///images/avatar_white.png" : "asset:///images/avatar_black.png"
                            preferredHeight: ui.du(3)
                            preferredWidth: ui.du(3)
                            verticalAlignment: VerticalAlignment.Center
                            scalingMethod: ScalingMethod.AspectFit
                        
                        }
                        
                        TextField {
                            enabled: false
                            id: userLabel
                            text: settingsController.userName
                            verticalAlignment: VerticalAlignment.Center
                        
                        }
                    
                    }
                    
                    
                    
                    // Commit button
                    Button {
                        text: qsTr("Connect")
                        horizontalAlignment: HorizontalAlignment.Right
                        verticalAlignment: VerticalAlignment.Center
                        preferredWidth: ui.du(30)
                        id: loginButton
                        onClicked: {
                            welcome.open();
                        }
                        visible: (settingsController.userName == "")
                    }
                    
                    
                    Button {
                        id: logOutButton
                        text: qsTr("log out");
                        preferredWidth: ui.du(30)
                        horizontalAlignment: HorizontalAlignment.Right
                        verticalAlignment: VerticalAlignment.Center
                        
                        onClicked: {
                            loginButton.setVisible(true);
                            logOutButton.setVisible(false);
                            userLabel.setText(qsTr("IP: "));
                        }
                        visible: (settingsController.userName != "")
                    }
                
                }
                
                // --------------------------------------------------------------------------
                // Theme setting
                
                
                Container {
                    preferredHeight: ui.du(4)
                }
                
                Container {
                    layout: StackLayout { orientation: LayoutOrientation.LeftToRight }
                    
                    Label {
                        text: qsTr("Visual appearance")
                        textStyle.fontSize: FontSize.Large
                        horizontalAlignment: HorizontalAlignment.Left
                        verticalAlignment: VerticalAlignment.Bottom
                    }
                
                }
                Divider { }
                
                
                
                DropDown {
                    id: theme
                    title: qsTr("Visual Theme")
                    options: [
                        Option {
                            text: qsTr("Bright")
                            value: 1
                        },
                        Option {
                            text: qsTr("Dark")
                            value: 2
                        } 
                    ]
                    selectedIndex: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? 1 : 0
                    onSelectedOptionChanged: {
                        settingsController.theme = theme.selectedOption.value;
                    }
                
                } 
                
                DropDown {
                    id: sortProject
                    title: qsTr("Sort projects")
                    options: [
                        Option {
                            text: qsTr("Newest on top")
                            value: 1
                        },
                        Option {
                            text: qsTr("Last updated on top")
                            value: 2
                        },
                        Option {
                            text: qsTr("By title")
                            value: 3
                        }
                    ]
                    selectedIndex: settingsController.sortProject-1
                    onSelectedOptionChanged: {
                        settingsController.sortProject = selectedOption.value;
                    }
                }
            }
        }
    } 
    
    attachedObjects: [
        SettingsController {
            id: settingsController
        }
    ]
    

}
