import UIKit
import Kontena

class ViewController: UIViewController
{
    @IBOutlet weak var nameLabel: UILabel!

    var some: SomeBaseClass?

    override func viewDidLoad()
    {
        super.viewDidLoad()

        some = Container.sharedInstance.resolveType(SomeBaseClass.self)

        var text = ""
        if let name = some?.name {
            text += name
        }

        if let serviceName = some?.service?.name {
            text += " + " + serviceName
        }

        self.nameLabel.text = text
        println(self.nameLabel.text)
    }
}
