import UIKit

class FinishAccountCreationViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var resultImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var actionButton: LoadableButton!
    @IBOutlet private weak var backButton: UIButton!

    // MARK: - Properties

    var presenter: FinishAccountCreationPresenter!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.viewDidLoad()
    }

    // MARK: - IBActions

    @IBAction private func didTapActionButton(_ sender: LoadableButton) {
        presenter.didTapActionButton()
    }

    @IBAction private func didTapBackButton(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }

}

// MARK: - FinishAccountCreationView

extension FinishAccountCreationViewController: FinishAccountCreationView {

    func prepareUI(for state: FinishAccountControllerState) {
        switch state {
        case .loading:

            containerView.isHidden = true
            activityIndicatorView.startAnimating()

        case .success:

            resultImageView.image = UIImage(named: "confirmation_success")
            titleLabel.text = "FinishAccountCreation_success_title".localized
            descriptionLabel.text = "FinishAccountCreation_success_description".localized
            messageLabel.text = "FinishAccountCreation_success_message".localized
            actionButton.setTitle("SignUp_back_text".localized, for: .normal)
            backButton.isHidden = true

            containerView.isHidden = false
            activityIndicatorView.stopAnimating()

        case .generalError:

            resultImageView.image = UIImage(named: "confirmation_error")
            titleLabel.text = "FinishAccountCreation_error_title".localized
            descriptionLabel.text = "FinishAccountCreation_error_message".localized
            messageLabel.text = nil
            actionButton.setTitle("FinishAccountCreation_try_again".localized, for: .normal)
            backButton.isHidden = false

            containerView.isHidden = false
            activityIndicatorView.stopAnimating()

        case .alreadyConfirmed:

            resultImageView.image = UIImage(named: "confirmation_error")
            titleLabel.text = "FinishAccountCreation_error_title".localized
            descriptionLabel.text = "FinishAccountCreation_already_created_error_message".localized
            messageLabel.text = nil
            actionButton.setTitle("SignUp_back_text".localized, for: .normal)
            backButton.isHidden = true

            containerView.isHidden = false
            activityIndicatorView.stopAnimating()

        }
    }

    func popViewController() {
        navigationController?.popToRootViewController(animated: true)
    }
}
