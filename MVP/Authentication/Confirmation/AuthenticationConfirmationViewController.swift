import UIKit

class AuthenticationConfirmationViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var confirmTitleLabel: UILabel!
    @IBOutlet private weak var confirmDescriptionLabel: UILabel!
    @IBOutlet private weak var confirmMessageLabel: UILabel!

    // MARK: - Properties

    var presenter: AuthenticationConfirmationPresenter!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.viewDidLoad()
    }

    // MARK: - IBActions

    @IBAction private func didTapBackButton(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - AuthenticationConfirmationView

extension AuthenticationConfirmationViewController: AuthenticationConfirmationView {
    func set(title: String) {
        confirmTitleLabel.text = title
    }

    func set(description: String) {
        confirmDescriptionLabel.text = description
    }

    func set(confirmationMessage: NSMutableAttributedString) {
        confirmMessageLabel.attributedText = confirmationMessage
    }
}
