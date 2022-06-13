import UIKit
import Freddy

enum SheetOption {
    case addRecipe
    case addMeal
    case addWorkoutBot
    case updateWeight
    case shoppingList
    case scanBarCode
    case newRecipe
    case newFood
    case createARecipe

    fileprivate static let shown = [SheetOption.addMeal, .addWorkoutBot, .shoppingList, .newRecipe, .updateWeight]
    fileprivate static let newShown = [SheetOption.createARecipe, .scanBarCode, .newFood]

    fileprivate var title: String {
        switch self {
        case .addRecipe: return L10n.addRecipe
        case .addMeal: return L10n.addMealAddButton
        case .addWorkoutBot: return L10n.addWorkout
        case .updateWeight: return L10n.addWeight
        case .shoppingList: return L10n.shoppingListAction
        case .scanBarCode:  return L10n.scanBarcodeAction
        case .newRecipe: return  L10n.newRecipe
        case .newFood: return  L10n.newFood
        case .createARecipe: return  L10n.addRecipe

        }
    }

    fileprivate var icon: UIImage {
        switch self {
        case .addRecipe: return Asset.iconAddRecipe.image
        case .addMeal: return Asset.iconAddMeal.image
        case .addWorkoutBot: return Asset.iconAddWorkout.image
        case .updateWeight: return Asset.iconAddWeight.image
        case .shoppingList: return Asset.iconShopping.image
        case .scanBarCode: return Asset.scan.image
        case .newRecipe: return Asset.newRecipe.image
        case .newFood: return Asset.newFood.image
        case .createARecipe: return Asset.newRecipe.image
        }
    }

    fileprivate var color: UIColor {
        switch self {
        case .addRecipe: return .genewixBlue
        case .addMeal: return .mealOrange
        case .addWorkoutBot: return .genewixGreen
        case .updateWeight: return .genewixBlue
        case .shoppingList: return .genewixBlue
        case .newRecipe: return .genewixYellow
        case .scanBarCode: return .genewixDarkBlue
        case .newFood: return .mealOrange
        case .createARecipe: return .genewixYellow
        }
    }
}

protocol ActionSheetDelegate: DismissDelegate {
    func selected(option: SheetOption)
    func dismissActionsheet()
}

final class ActionSheetViewController: UIViewController {

    fileprivate weak var delegate: ActionSheetDelegate?
    var isNewSheet = false

    init(delegate: ActionSheetDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeActionsheet))
        tap.numberOfTapsRequired = 1
        blurEffectView.addGestureRecognizer(tap)
        view.addSubview(blurEffectView)
        blurEffectView.autoPinEdgesToSuperviewEdges()
        var buttons = [ActionSheetButton]()
        if self.isNewSheet {
            buttons = SheetOption.newShown.map(ActionSheetButton.init(option: ))
        } else {
            buttons = SheetOption.shown.map(ActionSheetButton.init(option: ))
        }
        //let buttons = SheetOption.shown.map(ActionSheetButton.init(option: ))
        buttons.forEach { $0.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)}

        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .vertical
        stackView.spacing = 15
        view.addSubview(stackView)
        stackView.autoPinEdges(toSuperviewEdges: [.leading, .trailing], withInset: 25)
        stackView.autoPin(toBottomLayoutGuideOf: self, withInset: 80)
    }

    @objc private func closeActionsheet() {
        delegate?.dismissActionsheet()
    }

    @objc private func buttonAction(_ button: ActionSheetButton) {
        delegate?.selected(option: button.option)
    }
}

final class ActionSheetButton: UIControl {
    private let imageView = UIImageView()
    private let label = UILabel(font: UIFont.openSansBoldFont(ofSize: 16))

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .grayBackground : .white
        }
    }

    let option: SheetOption

    init(option: SheetOption) {
        self.option = option
        super.init(frame: .zero)
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.isUserInteractionEnabled = false
        addSubview(stack)
        imageView.image = option.icon.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = option.color
        imageView.contentMode = .center
        imageView.autoSquare()
        stack.autoPinEdgesToSuperviewEdges()
        backgroundColor = .white
        label.textAlignment = .left
        label.textColor = option.color
        label.text = option.title
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        layer.cornerRadius = 4

        NSLayoutConstraint.autoSetPriority(.defaultHigh) {
            autoSetDimension(.height, toSize: 64)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
