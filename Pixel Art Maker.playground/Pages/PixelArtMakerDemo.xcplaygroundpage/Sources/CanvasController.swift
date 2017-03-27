import UIKit

public class CanvasController: UIView {
	let canvas: Canvas
	let pallet: Pallet
	let controlCenter: CanvasControlCenter
	let width: Int
	let height: Int
	let pixelSize: CGFloat
	let colors: Array<UIColor>
	let theme: Theme
	let saveURL: URL

	static var numberOfSaves: Int = 0

	var currentPaintBrush: UIColor = .black {
		didSet {
			canvas.paintBrushColor = currentPaintBrush
		}
	}

	public init(width: Int, height: Int, pixelSize: CGFloat, canvasColor: UIColor, colorPallet: [UIColor], theme: Theme, saveURL: URL) {
		self.width = width
		self.height = height
		self.pixelSize = pixelSize
		self.colors = colorPallet.filter{ $0 != canvasColor } + [canvasColor]
		self.saveURL = saveURL

		canvas = Canvas(width: width, height: height, pixelSize: pixelSize, canvasColor: canvasColor)
		pallet = Pallet(colors: colors, theme: theme)
		controlCenter = CanvasControlCenter(theme: theme)
		self.theme = theme
		super.init(frame: CGRect(
			x: 0,
			y: 0,
			width:  max(controlCenter.bounds.width + pallet.bounds.width + Metrics.regular * 4, CGFloat(width) * pixelSize + Metrics.regular * 4),
			height: max(canvas.bounds.height + controlCenter.bounds.height + Metrics.regular * 3, pallet.bounds.height + Metrics.regular * 2 )))

		setupViews()
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupViews() {
		if let startingPaintBrush = self.colors.first {
			currentPaintBrush = startingPaintBrush
		}
		backgroundColor = theme.mainColor

		pallet.delegate = self
		controlCenter.delegate = self

		addSubview(canvas)
		addSubview(pallet)
		addSubview(controlCenter)

		canvas.frame.origin = CGPoint(x: Metrics.regular, y: Metrics.regular)
		controlCenter.frame.origin = CGPoint(
			x: Metrics.regular,
			y: canvas.bounds.height + Metrics.regular * 2
		)
		pallet.frame.origin = CGPoint(
			x: max(CGFloat(width) * pixelSize + 30, controlCenter.bounds.width + Metrics.regular * 2),
			y: Metrics.regular
		)

	}
}

extension CanvasController: PalletDelegate {
	func paintBrushDidChange(color: UIColor) {
		currentPaintBrush = color
	}
}

extension CanvasController: CanvasControlCenterDelegate {
	func redoPressed() {
		canvas.viewModel.redo()
	}

	func undoPressed() {
		canvas.viewModel.undo()
	}

	func savePressed() {
		print("trynna save")
		let image = canvas.makeImageFromSelf()
		try? UIImagePNGRepresentation(image)?.write(to: saveURL, options: .atomic)
	}
}