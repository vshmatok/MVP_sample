import Foundation

// MARK: - Protocol

protocol RestorePasswordView: Alertable {
    func prepareUI()
    func showErrorInViewAt(tag: Int, message: String?)
    func loading(_ loading: Bool)
    func restoreButton(isEnabled: Bool)
    func popViewController()
}

protocol RestorePasswordPresenter: class {
    func viewDidLoad()
    func titledTextFieldDidEndEditing(tag: Int, validationResult: ValidationResult)
    func didTapRestoreButton(password: String)
}

final class RestorePasswordPresenterImpl {

    // MARK: - Properties

    private weak var view: RestorePasswordView?
    private let authenticationGateway: AuthenticationGateway

    private var isPasswordCorrect: Bool = false
    private var isConfirmPasswordCorrect: Bool = false

    private var code: String

    // MARK: - Initialization

    init(view: RestorePasswordView?,
         authenitcationGateway: AuthenticationGateway = AuthenticationGatewayImpl(apiClient: APIClient()),
         code: String) {
        self.view = view
        self.authenticationGateway = authenitcationGateway
        self.code = code
    }
}

// MARK: - RestorePasswordPresenter

extension RestorePasswordPresenterImpl: RestorePasswordPresenter {
    func didTapRestoreButton(password: String) {
        let requestModel = RestorePasswordRequestModel(code: code, password: password)

        view?.loading(true)

        authenticationGateway.restorePassword(parameters: requestModel) { [weak self] (result) in
            self?.view?.loading(false)
            switch result {
            case .success:
                self?.view?.showErrorAlert(message: "RestorePassword_success_message".localized,
                                           completion: {
                                            self?.view?.popViewController()
                })
            case .failure(let error):
                self?.view?.showErrorAlert(message: error.localizedDescription)
            }
        }
    }

    func titledTextFieldDidEndEditing(tag: Int, validationResult: ValidationResult) {
        switch validationResult {
        case .success:
            if tag == 0 {
                isPasswordCorrect = true
            } else {
                isConfirmPasswordCorrect = true
            }
        case .error(let error):
            if tag == 0 {
                isPasswordCorrect = false
            } else {
                isConfirmPasswordCorrect = false
            }

            view?.showErrorInViewAt(tag: tag, message: error)
        }

        view?.restoreButton(isEnabled: isPasswordCorrect && isConfirmPasswordCorrect)
    }

    func viewDidLoad() {
        view?.prepareUI()
    }
}
