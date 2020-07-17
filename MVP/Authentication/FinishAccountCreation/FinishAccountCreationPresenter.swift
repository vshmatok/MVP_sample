import Foundation

// MARK: - Type

enum FinishAccountControllerState {

    // MARK: - Cases

    case loading
    case success
    case generalError
    case alreadyConfirmed

}

// MARK: - Protocols

protocol FinishAccountCreationView: Alertable {
    func prepareUI(for state: FinishAccountControllerState)
    func popViewController()
}

protocol FinishAccountCreationPresenter: class {
    func viewDidLoad()
    func didTapActionButton()
}

final class FinishAccountCreationPresenterImpl {

    // MARK: - Properties

    private weak var view: FinishAccountCreationView?
    private let authenticationGateway: AuthenticationGateway
    private var code: String

    private var type: FinishAccountControllerState = .loading {
        didSet {
            view?.prepareUI(for: type)
        }
    }

    // MARK: - Initialization

    init(view: FinishAccountCreationView,
         authenitcationGateway: AuthenticationGateway = AuthenticationGatewayImpl(apiClient: APIClient()),
         code: String) {
        self.view = view
        self.code = code
        self.authenticationGateway = authenitcationGateway
    }

    // MARK: - Private

    private func confirmAccountCreation() {
        type = .loading

        let requestModel = ConfirmAccountCreationRequestModel(code: code)

        authenticationGateway.confirmAccountCreation(parameters: requestModel) { [weak self] (result) in
            switch result {
            case .success(let status):
                self?.type = status.alreadyConfirmed ? .alreadyConfirmed : .success
            case .failure:
                self?.type = .generalError
            }
        }
    }
}

// MARK: - FinishAccountCreationPresenter

extension FinishAccountCreationPresenterImpl: FinishAccountCreationPresenter {
    func didTapActionButton() {
        switch type {
        case .success, .alreadyConfirmed:
            view?.popViewController()
        case .generalError:
            confirmAccountCreation()
        default:
            break
        }
    }

    func viewDidLoad() {
        confirmAccountCreation()
    }
}
