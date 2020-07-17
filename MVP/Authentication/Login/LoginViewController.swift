import UIKit

class LoginViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var loginView: TitledTextFieldView!
    @IBOutlet private weak var loginErrorLabel: UILabel!
    @IBOutlet private weak var passwordView: TitledTextFieldView!
    @IBOutlet private weak var passwordErrorLabel: UILabel!
    @IBOutlet private weak var loginButton: LoadableButton!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var forgotPasswordButton: UIButton!

    // MARK: - Properties

    private var presenter: LoginPresenter!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = LoginPresenterImpl(view: self)
        presenter.viewDidLoad()
    }

    // MARK: - IBActions

    @IBAction private func didTapLoginButton(_ sender: LoadableButton) {
        guard let email = loginView.text, let password = passwordView.text else { return }

        let signInRequestModel = SignInRequestModel(email: email, password: password)
        presenter.didTapLoginButton(requestModel: signInRequestModel)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ForgotPasswordViewController {
            controller.presenter = ForgotPasswordPresenterImpl(view: controller, email: loginView.text)
        }
    }
}

// MARK: - LoginView

extension LoginViewController: LoginView {

    func prepareUI() {
        loginView.configure(as: .emailTextField, delegate: self)
        passwordView.configure(as: .passwordTextField, delegate: self)

        loginButton(isEnabled: false)
    }

    func showErrorInViewAt(tag: Int, message: String?) {
        if tag == 0 {
            loginErrorLabel.animateTextChange(toText: message, duration: 0.4)
        } else {
            passwordErrorLabel.animateTextChange(toText: message, duration: 0.4)
        }
    }

    func loginButton(isEnabled: Bool) {
        loginButton.isEnabled = isEnabled
        loginButton.animateAlpha(toValue: isEnabled ? 1 : 0.5, duration: 0.1)
    }

    func loading(_ loading: Bool) {
        if loading {
            loginButton.startLoading()
        } else {
            loginButton.stopLoading()
        }

        signUpButton.isUserInteractionEnabled = !loading
        forgotPasswordButton.isUserInteractionEnabled = !loading
        loginView.isUserInteractionEnabled = !loading
        passwordView.isUserInteractionEnabled = !loading
    }
}

// MARK: - TitledTextFieldDelegate

extension LoginViewController: TitledTextFieldDelegate {
    func titledTextFieldDidBeginEditing(_ view: TitledTextFieldView) {

        loginButton(isEnabled: false)

        if view == loginView {
            loginErrorLabel.text = nil
        } else {
            passwordErrorLabel.text = nil
        }
    }

    func titledTextFieldDidEndEditing(_ view: TitledTextFieldView, with validationResult: ValidationResult) {
        presenter.titledTextFieldDidEndEditing(tag: view.tag, validationResult: validationResult)
    }

    func titledTextFieldShouldReturn(_ view: TitledTextFieldView) {
        if view == loginView {
            passwordView.beginEditing()
        } else {
            view.endEditing(true)
        }
    }
}
