import Foundation

// MARK: - Protocol

protocol ForgotPasswordView: Alertable {
    func prepareUI(email: String?)
    func showError(message: String?)
    func sendButton(isEnabled: Bool)
    func loading(_ loading: Bool)
    func openConfirmationController()
}

protocol ForgotPasswordPresenter: class {
    func viewDidLoad()
    func titledTextFieldDidEndEditing(validationResult: ValidationResult)
    func didTapSendButton(requestModel: ForgotPasswordRequestModel)
    func prepareConfirmationController(_ controller: AuthenticationConfirmationViewController)
}

class ForgotPasswordPresenterImpl {

    // MARK: - Protocol

    private weak var view: ForgotPasswordView?
    private let authenticationGateway: AuthenticationGateway

    private var isLoginCorrect: Bool = false

    private var email: String?

    // MARK: - Initialization

    init(view: ForgotPasswordView?,
         authenitcationGateway: AuthenticationGateway = AuthenticationGatewayImpl(apiClient: APIClient()),
         email: String?) {
        self.view = view
        self.authenticationGateway = authenitcationGateway
        self.email = email
    }
}

// MARK: - ForgotPasswordPresenter

extension ForgotPasswordPresenterImpl: ForgotPasswordPresenter {
    func didTapSendButton(requestModel: ForgotPasswordRequestModel) {
        view?.loading(true)

        authenticationGateway.forgotPassword(parameters: requestModel) { [weak self] (result) in
            self?.view?.loading(false)
            switch result {
            case .success:
                self?.email = requestModel.email
                self?.view?.openConfirmationController()
            case .failure(let error):
                self?.view?.showErrorAlert(message: error.localizedDescription)
            }
        }
    }

    func viewDidLoad() {
        view?.prepareUI(email: email)
    }

    func titledTextFieldDidEndEditing(validationResult: ValidationResult) {
        switch validationResult {
        case .success:
            isLoginCorrect = true
        case .error(let error):
            isLoginCorrect = false
            view?.showError(message: error)
        }
        view?.sendButton(isEnabled: isLoginCorrect)
    }

    func prepareConfirmationController(_ controller: AuthenticationConfirmationViewController) {
        guard let email = email else { return }

        controller.presenter = AuthenticationConfirmationPresenterImpl(view: controller,
                                                                       type: .forgotPassword(email: email))
    }

}
