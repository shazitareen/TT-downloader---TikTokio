import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user taps Post. Make sure to call super.didSelectPost() at the end!
        
        if let item = extensionContext?.inputItems.first as? NSExtensionItem,
           let itemProvider = item.attachments?.first {
            
            if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePlainText as String) {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePlainText as String, options: nil) { (text, error) in
                    if let sharedText = text as? String {
                        self.openMainApp(with: sharedText)
                    }
                }
            } else if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (url, error) in
                    if let sharedURL = url as? URL {
                        self.openMainApp(with: sharedURL.absoluteString)
                    }
                }
            }
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    private func openMainApp(with sharedText: String) {
        // Encode the shared text
        guard let encodedText = sharedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        // Define your custom URL scheme
        let urlString = "tiktokio://share?text=\(encodedText)"
        if let url = URL(string: urlString) {
            // Use responder chain to find UIApplication and open URL
            var responder: UIResponder? = self
            while responder != nil {
                if let application = responder as? UIApplication {
                    application.perform(Selector(("openURL:")), with: url)
                    break
                }
                responder = responder?.next
            }
        }
        
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
