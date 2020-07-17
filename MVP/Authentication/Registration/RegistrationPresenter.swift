import Foundation

// MARK: - Protocol

protocol RegistrationView: Alertable {
    func prepareUI()
    func signUpButton(isEnabled: Bool)
    func loading(_ loading: Bool)
    func showErrorInViewAt(tag: Int, message: String?)
    func openConfirmationSceen()
}

protocol RegistrationPresenter: class {
    func viewDidLoad()
    func didTapSignUpButton(requestModel: SignUpRequestModel)
    func titledTextFieldDidEndEditingAt(tag: Int, validationResult: ValidationResult)
    func prepareConfirmationController(_ controller: AuthenticationConfirmationViewController)
}

class RegistrationPresenterImpl {

    // MARK: - Properties

    private weak var view: RegistrationView?
    private let authenticationGateway: AuthenticationGateway

    private var isLoginCorrect: Bool = false
    private var isNameCorrect: Bool = false
    private var isPasswordCorrect: Bool = false
    private var isConfirmPasswordCorrect: Bool = false

    private var userEmail: String?

    // MARK: - Initialization

    init(view: RegistrationView?,
         authenitcationGateway: AuthenticationGateway = AuthenticationGatewayImpl(apiClient: APIClient())) {
        self.view = view
        self.authenticationGateway = authenitcationGateway
    }
}

// MARK: - RegistrationPresenter

extension RegistrationPresenterImpl: RegistrationPresenter {

    func prepareConfirmationController(_ controller: AuthenticationConfirmationViewController) {
        guard let email = userEmail else { return }
        controller.presenter = AuthenticationConfirmationPresenterImpl(view: controller,
                                                                       type: .signUp(email: email))
    }

    func titledTextFieldDidEndEditingAt(tag: Int, validationResult: ValidationResult) {
        switch validationResult {
        case .success:
            switch tag {
            case 0:
                isLoginCorrect = true
            case 1:
                isNameCorrect = true
            case 2:
                isPasswordCorrect = true
            default:
                isConfirmPasswordCorrect = true
            }
        case .error(let error):
            switch tag {
            case 0:
                isLoginCorrect = false
            case 1:
                isNameCorrect = false
            case 2:
                isPasswordCorrect = false
            default:
                isConfirmPasswordCorrect = false
            }

            view?.showErrorInViewAt(tag: tag, message: error)
        }

        view?.signUpButton(isEnabled: isLoginCorrect && isPasswordCorrect && isNameCorrect && isConfirmPasswordCorrect)
    }

    func didTapSignUpButton(requestModel: SignUpRequestModel) {
        view?.loading(true)

        authenticationGateway.signUp(parameters: requestModel) { [weak self] (result) in
            self?.view?.loading(false)
            switch result {
            case .success:
                self?.userEmail = requestModel.email
                self?.view?.openConfirmationSceen()
            case .failure(let error):
                self?.view?.showErrorAlert(message: error.localizedDescription)
            }
        }
    }

    func viewDidLoad() {
        view?.prepareUI()
    }

}
