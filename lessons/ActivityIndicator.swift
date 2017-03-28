import UIKit

class ActivityIndicator{
    var container = UIView()
    var loadingView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var onHide: (() -> Void)?
    
    static let shared = ActivityIndicator()
    
    private init(){}
    
    func showActivityIndicator(uiView: UIView, onHide: (() -> Void)? = nil) {
        self.onHide = onHide
        
        container.bounds = uiView.bounds
        container.center = uiView.center
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.backgroundColor = UIColor.black.withAlphaComponent(0)

        
        loadingView.bounds = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        loadingView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        loadingView.center = CGPoint(x: container.bounds.midX, y: container.bounds.midY)
        loadingView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 0)

        
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.bounds = CGRect(x:0.0, y:0.0, width:40.0, height:40.0);
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.bounds.midX, y: loadingView.bounds.midY)
        activityIndicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        activityIndicator.color = UIColor.black
        
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTap (_:)))
        container.addGestureRecognizer(tapRecognizer)
        activityIndicator.startAnimating()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.container.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.loadingView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.loadingView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        })

    }
    
    func hide(){
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.3, animations: {
            self.container.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.loadingView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 0)
        }, completion: {(finished : Bool) in
            if (finished){
                self.container.removeFromSuperview()
                if (self.onHide != nil){
                    self.onHide!()
                }
            }
        })

    }
    @objc func onTap(_ sender:UITapGestureRecognizer){
        hide()
    }

    
}
