import UIKit

class RestorePasswordViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var passwordView: TitledTextFieldView!
    @IBOutlet private weak var passwordErrorLabel: UILabel!
    @IBOutlet private weak var confirmPasswordView: TitledTextFieldView!
    @IBOutlet private weak var confirmPasswordErrorLabel: UILabel!
    @IBOutlet private weak var restoreButton: LoadableButton!
    @IBOutlet private weak var backButton: UIButton!

    // MARK: - Properties

    var presenter: RestorePasswordPresenter!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }

    // MARK: - IBActions

    @IBAction private func didTapRestoreButton(_ sender: LoadableButton) {
        guard let password = passwordView.text, passwordView.text == confirmPasswordView.text else {
            showErrorAlert(message: "RestorePassword_validation_error".localized)
            return
        }

        presenter.didTapRestoreButton(password: password)
    }

    @IBAction private func didTapBackButton(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MAKR: - RestorePasswordView

extension RestorePasswordViewController: RestorePasswordView {
    func prepareUI() {
        passwordView.configure(as: .passwordTextField, delegate: self)
        confirmPasswordView.configure(as: .confirmPasswordasswordTextField, delegate: self)

        restoreButton(isEnabled: false)
    }

    func showErrorInViewAt(tag: Int, message: String?) {
        if tag == 0 {
            passwordErrorLabel.animateTextChange(toText: message, duration: 0.4)
        } else {
            confirmPasswordErrorLabel.animateTextChange(toText: message, duration: 0.4)
        }
    }

    func restoreButton(isEnabled: Bool) {
        restoreButton.isEnabled = isEnabled
        restoreButton.animateAlpha(toValue: isEnabled ? 1 : 0.5, duration: 0.1)
    }

    func loading(_ loading: Bool) {
        if loading {
            restoreButton.startLoading()
        } else {
            restoreButton.stopLoading()
        }

        backButton.isUserInteractionEnabled = !loading
        confirmPasswordView.isUserInteractionEnabled = !loading
        passwordView.isUserInteractionEnabled = !loading
    }

    func popViewController() {
        navigationController?.popViewController(animated: true)
    }

}

// MARK: - TitledTextFieldDelegate

extension RestorePasswordViewController: TitledTextFieldDelegate {
    func titledTextFieldDidBeginEditing(_ view: TitledTextFieldView) {
        restoreButton(isEnabled: false)

        if view == passwordView {
            passwordErrorLabel.text = nil
        } else {
            confirmPasswordErrorLabel.text = nil
        }
    }

    func titledTextFieldDidEndEditing(_ view: TitledTextFieldView, with validationResult: ValidationResult) {
        presenter.titledTextFieldDidEndEditing(tag: view.tag, validationResult: validationResult)
    }

    func titledTextFieldShouldReturn(_ view: TitledTextFieldView) {
        if view == passwordView {
            confirmPasswordView.beginEditing()
        } else {
            view.endEditing(true)
        }
    }
}
