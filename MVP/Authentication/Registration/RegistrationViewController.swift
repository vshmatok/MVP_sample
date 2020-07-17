import UIKit

class RegistrationViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var emailView: TitledTextFieldView!
    @IBOutlet private weak var emailErrorLabel: UILabel!
    @IBOutlet private weak var nameView: TitledTextFieldView!
    @IBOutlet private weak var nameErrorLabel: UILabel!
    @IBOutlet private weak var passwordView: TitledTextFieldView!
    @IBOutlet private weak var passwordErrorLabel: UILabel!
    @IBOutlet private weak var repeatPasswordView: TitledTextFieldView!
    @IBOutlet private weak var repeatPasswordErrorLabel: UILabel!
    @IBOutlet private weak var signUpButton: LoadableButton!
    @IBOutlet private weak var backButton: UIButton!

    // MARK: - Properties

    private var presenter: RegistrationPresenter!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = RegistrationPresenterImpl(view: self)
        presenter.viewDidLoad()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AuthenticationConfirmationViewController {
            presenter.prepareConfirmationController(controller)
        }
    }

    // MARK: - IBActions

    @IBAction private func didTapSignUpButton(_ sender: LoadableButton) {
        guard let password = passwordView.text, passwordView.text == repeatPasswordView.text else {
            showErrorAlert(message: "RestorePassword_validation_error".localized)
            return
        }

        guard let email = emailView.text, let name = nameView.text else { return }

        let signUpRequestModel = SignUpRequestModel(email: email, name: name, password: password)
        presenter.didTapSignUpButton(requestModel: signUpRequestModel)
    }

    @IBAction private func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

}

// MARK: - RegistrationView

extension RegistrationViewController: RegistrationView {
    func prepareUI() {
        emailView.configure(as: .emailTextField, delegate: self)
        nameView.configure(as: .nameTextField, delegate: self)

        var passwordConfiguration = TitledTextFieldModel.passwordTextField
        passwordConfiguration.returnKeyType = .next
        passwordView.configure(as: passwordConfiguration, delegate: self)

        repeatPasswordView.configure(as: .confirmPasswordasswordTextField, delegate: self)

        signUpButton(isEnabled: false)
    }

    func showErrorInViewAt(tag: Int, message: String?) {
        switch tag {
        case 0:
            emailErrorLabel.animateTextChange(toText: message, duration: 0.4)
        case 1:
            nameErrorLabel.animateTextChange(toText: message, duration: 0.4)
        case 2:
            passwordErrorLabel.animateTextChange(toText: message, duration: 0.4)
        default:
            repeatPasswordErrorLabel.animateTextChange(toText: message, duration: 0.4)
        }
    }

    func signUpButton(isEnabled: Bool) {
        signUpButton.isEnabled = isEnabled
        signUpButton.animateAlpha(toValue: isEnabled ? 1 : 0.5, duration: 0.1)
    }

    func loading(_ loading: Bool) {
        if loading {
            signUpButton.startLoading()
        } else {
            signUpButton.stopLoading()
        }

        backButton.isUserInteractionEnabled = !loading
        nameView.isUserInteractionEnabled = !loading
        emailView.isUserInteractionEnabled = !loading
        passwordView.isUserInteractionEnabled = !loading
        repeatPasswordView.isUserInteractionEnabled = !loading
    }

    func openConfirmationSceen() {
        performSegue(withIdentifier: "confirmationSegue", sender: nil)
    }
}

// MARK: - TitledTextFieldDelegate

extension RegistrationViewController: TitledTextFieldDelegate {
    func titledTextFieldDidEndEditing(_ view: TitledTextFieldView, with validationResult: ValidationResult) {
        presenter.titledTextFieldDidEndEditingAt(tag: view.tag, validationResult: validationResult)
    }

    func titledTextFieldShouldReturn(_ view: TitledTextFieldView) {
        switch view.tag {
        case 0:
            nameView.beginEditing()
        case 1:
            passwordView.beginEditing()
        case 2:
            repeatPasswordView.beginEditing()
        default:
            view.endEditing(true)
        }
    }

    func titledTextFieldDidBeginEditing(_ view: TitledTextFieldView) {

        signUpButton(isEnabled: false)

        switch view.tag {
        case 0:
            emailErrorLabel.text = nil
        case 1:
            nameErrorLabel.text = nil
        case 2:
            passwordErrorLabel.text = nil
        default:
            repeatPasswordErrorLabel.text = nil
        }
    }

}
