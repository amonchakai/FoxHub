import bb.cascades 1.3


NavigationPane {
    id: navSettings
    property variant loginPage
        
    Page {
        id: welcomePage
        signal done ()        
        property bool wasAnError
            
        Container {
            id: rootContainer
            background: back.imagePaint
            layout: DockLayout {
            }
            
            ActivityIndicator {
                id: connectingActivity
                preferredHeight: 80
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Fill
                accessibility.name: "connectingActivity"
            }

            
            Container {
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Fill    
                
                Label {
                    id: label
                    text: "FoxHub"
                    textStyle {
                        color: Color.Black
                        base: SystemDefaults.TextStyles.PrimaryText
                    }
                }
                    
                
                Container {
                    preferredHeight: 60
                }
                
                Button {
                    id: submitButton
                    text: qsTr("Connect")
                    horizontalAlignment: HorizontalAlignment.Center
                    onClicked: {
                        if(!loginPage)
                             loginPage = gitHubConnect.createObject();
                         
                         navSettings.push(loginPage);                                                
                    }
                }
            }
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: back
                    repeatPattern: RepeatPattern.XY
                    
                    
                    imageSource: "asset:///images/wallpaper/wallpaper.jpg"
                }
            ]
        }
        
        attachedObjects: [
            ComponentDefinition {
               id: gitHubConnect
               source: "GitHubConnect.qml"
            }
            
        ]
    }
    
    onPopTransitionEnded: {
        
    }
}
