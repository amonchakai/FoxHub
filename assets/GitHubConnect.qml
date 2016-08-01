import bb.cascades 1.3
import Utility.GitHubController 1.0

Page {
    ScrollView {
        WebView {
            id: githubConnectView
            
            //url: "http://github.com/"
            settings.textAutosizingEnabled: false
            settings.zoomToFitEnabled: false
            settings.userAgent: "Mozilla/5.0 (BB10; Touch) AppleWebKit/537.1+ (KHTML, like Gecko) Version/10.3.1.1337 Mobile Safari/537.1+"
            onMessageReceived: {
                console.log(message)
            }
            
            
        
        }
    }
    
    attachedObjects: [
        GitHubController {
            id: gitHubConnect
            
            onCloseConnect: {
                submitButton.visible = false;
                navSettings.pop();
                connectingActivity.start();
            }
            
            onLoggedIn: {
                welcome.close();
            }
            
        }
    ]
    
    onCreationCompleted: {
        gitHubConnect.setWebView(githubConnectView);
        gitHubConnect.logInRequest();
    
    }
}
