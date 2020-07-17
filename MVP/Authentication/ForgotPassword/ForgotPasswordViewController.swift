import UIKit

class ForgotPasswordViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var emailView: TitledTextFieldView!
    @IBOutlet private weak var emailErrorLabel: UILabel!
    @IBOutlet private weak var sendButton: LoadableButton!
    @IBOutlet private weak var backButton: UIButton!

    // MARK: - Properties

    var presenter: ForgotPasswordPresenter!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.viewDidLoad()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AuthenticationConfirmationViewController {
            presenter.prepareConfirmationController(controller)
        }
    }

    // MARK: - IBActions

    @IBAction private func didTapSendButton(_ sender: LoadableButton) {
        guard let email = emailView.text else { return }

        let forgotPasswordRequestModel = ForgotPasswordRequestModel(email: email)
        presenter.didTapSendButton(requestModel: forgotPasswordRequestModel)
    }

    @IBAction private func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

}

// MARK: - ForgotPasswordView

extension ForgotPasswordViewController: ForgotPasswordView {
    func openConfirmationController() {
        performSegue(withIdentifier: "confirmationSegue", sender: nil)
    }

    func prepareUI(email: String?) {
        var emailTextFieldConfiguration = TitledTextFieldModel.emailTextField
        emailTextFieldConfiguration.text = email

        emailView.configure(as: emailTextFieldConfiguration, delegate: self)

        if let email = email, !email.isEmpty {
            emailView.validateTextField()
        } else {
            sendButton(isEnabled: false)
        }
    }

    func showError(message: String?) {
        emailErrorLabel.animateTextChange(toText: message, duration: 0.4)
    }

    func sendButton(isEnabled: Bool) {
        sendButton.isEnabled = isEnabled
        sendButton.animateAlpha(toValue: isEnabled ? 1 : 0.5, duration: 0.1)
    }

    func loading(_ loading: Bool) {
        if loading {
            sendButton.startLoading()
        } else {
            sendButton.stopLoading()
        }

        backButton.isUserInteractionEnabled = !loading
        emailView.isUserInteractionEnabled = !loading
    }
}

// MARK: - TitledTextFieldDelegate

extension ForgotPasswordViewController: TitledTextFieldDelegate {
    func titledTextFieldDidEndEditing(_ view: TitledTextFieldView, with validationResult: ValidationResult) {
        presenter.titledTextFieldDidEndEditing(validationResult: validationResult)
    }

    func titledTextFieldShouldReturn(_ view: TitledTextFieldView) {
        view.endEditing(true)
    }

    func titledTextFieldDidBeginEditing(_ view: TitledTextFieldView) {
        sendButton(isEnabled: false)
        emailErrorLabel.text = nil
    }
}
