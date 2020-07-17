import UIKit

// MARK: - Type

enum AuthConfirmationControllerType {

    // MARK: - Cases

    case forgotPassword(email: String)
    case signUp(email: String)

    // MARK: - Properties

    var email: String {
        switch self {
        case .forgotPassword(let email), .signUp(let email):
            return email
        }
    }
}

// MARK: - Protocol

protocol AuthenticationConfirmationView: class {
    func set(title: String)
    func set(description: String)
    func set(confirmationMessage: NSMutableAttributedString)
}

protocol AuthenticationConfirmationPresenter: class {
    func viewDidLoad()
}

class AuthenticationConfirmationPresenterImpl {

    // MARK: - Properties

    private weak var view: AuthenticationConfirmationView?
    private var type: AuthConfirmationControllerType

    // MARK: - Initialization

    init(view: AuthenticationConfirmationView?, type: AuthConfirmationControllerType) {
        self.view = view
        self.type = type
    }

    // MARK: - Private

    func prepareConfirmMessage() {
        let defautTextAttribute: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.usfMediumGray,
                                                               .font: UIFont.openSansRegular(size: 15)]
        let emailTextAttribute: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.usfOrange,
                                                                  .font: UIFont.openSansRegular(size: 15)]

        let emailAttributedString = NSAttributedString(string: type.email,
                                                       attributes: emailTextAttribute)

        let mutableAttributedString: NSMutableAttributedString
        let footerAttributedString: NSAttributedString

        if case .signUp = type {
            mutableAttributedString = NSMutableAttributedString(string: "Auth_confirm_signin_header".localized,
                                                                attributes: defautTextAttribute)
            footerAttributedString = NSAttributedString(string: "Auth_confirm_signin_main_footer".localized,
                                                        attributes: defautTextAttribute)
        } else {
            mutableAttributedString = NSMutableAttributedString(string: "Auth_confirm_fogot_header".localized,
                                                                attributes: defautTextAttribute)
            footerAttributedString = NSAttributedString(string: "Auth_confirm_forgot_main_footer".localized,
                                                        attributes: defautTextAttribute)
        }

        mutableAttributedString.append(emailAttributedString)
        mutableAttributedString.append(footerAttributedString)

        view?.set(confirmationMessage: mutableAttributedString)
    }

}

// MARK: - AuthenticationConfirmationPresenter

extension AuthenticationConfirmationPresenterImpl: AuthenticationConfirmationPresenter {
    func viewDidLoad() {
        if case .signUp = type {
            view?.set(title: "Auth_confirm_signin_title".localized)
            view?.set(description: "Auth_confirm_signin_description".localized)
        } else {
            view?.set(title: "Auth_confirm_forgot_title".localized)
            view?.set(description: "Auth_confirm_forgot_description".localized)
        }

        prepareConfirmMessage()
    }
}
