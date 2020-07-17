import Foundation

// MARK: - Protocols

protocol LoginView: Alertable {
    func prepareUI()
    func showErrorInViewAt(tag: Int, message: String?)
    func loginButton(isEnabled: Bool)
    func loading(_ loading: Bool)
}

protocol LoginPresenter: class {
    func viewDidLoad()
    func didTapLoginButton(requestModel: SignInRequestModel)
    func titledTextFieldDidEndEditing(tag: Int, validationResult: ValidationResult)
}

class LoginPresenterImpl {

    // MARK: - Properties

    private weak var view: LoginView?
    private let authenticationGateway: AuthenticationGateway
    private let applicationRouter: ApplicationRouter
    private let keychainService: KeychainService
    private let userDefaultsService: UserDetultsService

    private var isLoginCorrect: Bool = false
    private var isPasswordCorrect: Bool = false

    // MARK: - Initialization

    init(view: LoginView?,
         authenitcationGateway: AuthenticationGateway = AuthenticationGatewayImpl(apiClient: APIClient()),
         keychainService: KeychainService = KeychainServiceImpl(),
         userDefaultsService: UserDetultsService = UserDetultsServiceImpl(),
         applicationRouter: ApplicationRouter = ApplicationRouterImpl()) {
        self.view = view
        self.authenticationGateway = authenitcationGateway
        self.userDefaultsService = userDefaultsService
        self.keychainService = keychainService
        self.applicationRouter = applicationRouter
    }

    // MARK: - Private

    private func changeFlow(token: String) {
        keychainService.saveValue(token, forKey: .authorizationToken)
        userDefaultsService.setValueForKey(.isAuthorized, true)

        applicationRouter.changeRootViewControllerTo(.main, animated: true)
    }
}

// MARK: - LoginPresenter

extension LoginPresenterImpl: LoginPresenter {

    func viewDidLoad() {
        view?.prepareUI()
    }

    func didTapLoginButton(requestModel: SignInRequestModel) {
        view?.loading(true)

        authenticationGateway.signIn(parameters: requestModel) { [weak self] (result) in
            self?.view?.loading(false)
            switch result {
            case .success(let loginResponse) :
                self?.changeFlow(token: loginResponse.token)
            case .failure(let error):
                self?.view?.showErrorAlert(message: error.localizedDescription)
            }
        }
    }

    func titledTextFieldDidEndEditing(tag: Int, validationResult: ValidationResult) {
        switch validationResult {
        case .success:
            if tag == 0 {
                isLoginCorrect = true
            } else {
                isPasswordCorrect = true
            }
        case .error(let error):
            if tag == 0 {
                isLoginCorrect = false
            } else {
                isPasswordCorrect = false
            }

            view?.showErrorInViewAt(tag: tag, message: error)
        }

        view?.loginButton(isEnabled: isLoginCorrect && isPasswordCorrect)
    }
}
