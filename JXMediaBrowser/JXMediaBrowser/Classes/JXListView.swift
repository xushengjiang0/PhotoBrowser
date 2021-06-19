//
//  JXListView.swift
//  JXMediaBrowser
//
//  Created by Jason on 2021/5/14.
//

import UIKit

open class JXListView : UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - 公开属性
    
    /// 代理。可选。本类支持闭包回调和代理回调，用户可二选一。
    /// 如果用户同时实现了闭包和代理，则忽略代理，只回调闭包
    weak public var delegate: JXListViewDelegate?
    
    /// 滑动方向
    public var scrollDirection: UICollectionView.ScrollDirection {
        set {
            self.flowLayout.scrollDirection = newValue
        }
        get {
            self.flowLayout.scrollDirection
        }
    }
    
    /// 沿着滑动方向的每项的长度。
    /// 说明：垂直于滑动方向的长度不可设置，其长度填满视图
    /// - 如果实现了lengthForItemAtIndex代理方法，则以代理方法为准
    /// - 默认值0，在展示的时候会自动填满视图
    public var itemLength: CGFloat {
        set {
            self._itemLength = newValue
        }
        get {
            if self._itemLength > 0 {
                return self._itemLength
            }
            var length: CGFloat = 0
            switch self.scrollDirection {
            case .horizontal:
                length = self.collectionView.bounds.width - self.padding.left - self.padding.right
            case .vertical:
                length = self.collectionView.bounds.height - self.padding.top - self.padding.bottom
            }
            return length
        }
    }
    
    /// 私有成员变量，用于itemLength属性的存储
    private var _itemLength: CGFloat = 0
    
    /// 项间距
    public var itemSpacing: CGFloat {
        set {
            self.flowLayout.minimumLineSpacing = newValue
            self.setNeedsLayout()
        }
        get {
            self.flowLayout.minimumLineSpacing
        }
    }
    
    /// 容器内边距
    public var padding: UIEdgeInsets {
        set {
            self.flowLayout.sectionInset = newValue
        }
        get {
            self.flowLayout.sectionInset
        }
    }
    
    /// 边缘回弹
    public var bounces: Bool {
        set {
            self.collectionView.bounces = newValue
        }
        get {
            self.collectionView.bounces
        }
    }
    
    /// 是否开启翻页模式。默认开启：true
    public var isPagingEnabled: Bool = true
    
    // MARK: - 公开方法
    
    /// 刷新视图
    open func reloadData() {
        self.collectionView.reloadData()
    }
    
    /// 注册复用Cell
    open func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    /// 取复用Cell。调本方法需要先注册Cell
    open func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        return cell
    }
    
    /// 取复用Cell。自动注册传入的Cell
    open func dequeueReusableCell<T: UICollectionViewCell>(withClass clazz: T.Type, for index: Int) -> T {
        let identifier = "\(clazz)"
        // 若没注册，自动注册Cell
        if !didRegisterCells.contains(identifier) {
            didRegisterCells.append(identifier)
            self.collectionView.register(clazz.self, forCellWithReuseIdentifier: identifier)
            JXMediaUtil.log(message: "注册\(identifier)成功")
        }
        let indexPath = IndexPath(item: index, section: 0)
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T else {
            fatalError("取复用Cell失败！\(clazz.self) ")
        }
        return cell
    }
    
    private lazy var didRegisterCells = [String]()
    
    // MARK: - 刷新界面触发的回调
    
    /// 共有多少项。必选实现。
    public var numberOfItems: (() -> Int)?
    
    /// 取指定项的视图。必选实现。
    public var cellForItemAtIndex: ((_ listView: JXListView, _ index: Int) -> UICollectionViewCell)?
    
    /// 一项的长度，沿着滑动方向
    public var lengthForItemAtIndex: ((_ listView: JXListView, _ index: Int) -> CGFloat)?
    
    /// Cell即将显示
    public var willDisplayCellAtIndex: ((_ cell: UICollectionViewCell, _ index: Int) -> Void)?
    
    /// Cell已消失
    public var didEndDisplayingCellAtIndex: ((_ cell: UICollectionViewCell, _ index: Int) -> Void)?
    
    
    // MARK: - 交互触发的回调
    
    /// 点击选中某项
    public var didSelectItemAtIndex: ((_ index: Int) -> Void)?
    
    /// 视图滑动
    public var didScroll: ((_ scrollView: UIScrollView) -> Void)?
    
    /// 即将开始拖动
    public var willBeginDragging: ((_ scrollView: UIScrollView) -> Void)?
    
    /// 即将停止拖动
    public var willEndDragging: ((_ scrollView: UIScrollView, _ velocity: CGPoint, _ targetContentOffset: UnsafeMutablePointer<CGPoint>) -> Void)?
    
    /// 已经停止拖动
    public var didEndDragging: ((_ scrollView: UIScrollView, _ decelerate: Bool) -> Void)?
    
    /// 即将开始滑动减速
    public var willBeginDecelerating: ((_ scrollView: UIScrollView) -> Void)?
    
    /// 已经停止滑动减速
    public var didEndDecelerating: ((_ scrollView: UIScrollView) -> Void)?
    
    /// 已经停止滑动动画
    public var didEndScrollingAnimation: ((_ scrollView: UIScrollView) -> Void)?
    
    
    // MARK: - UICollectionView DataSource

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var number = 0
        if let closure = self.numberOfItems {
            number = closure()
        } else if let dlg = self.delegate {
            number = dlg.numberOfItems(in: self)
        }
        return number
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var reuseCell: UICollectionViewCell?
        if let closure = self.cellForItemAtIndex {
            reuseCell = closure(self, indexPath.item)
        } else if let dlg = self.delegate {
            reuseCell = dlg.listView(self, cellForItemAt: indexPath.item)
        }
        assert(reuseCell != nil, "请提供可复用的Cell!")
        let cell = reuseCell ?? UICollectionViewCell()
        return cell
    }
    
    
    // MARK: - UICollectionView Delegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if let closure = self.didSelectItemAtIndex {
            closure(indexPath.item)
        } else if let dlg = self.delegate {
            dlg.listView(self, didSelectItemAt: indexPath.item)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let closure = self.willDisplayCellAtIndex {
            closure(cell, indexPath.item)
        } else if let dlg = self.delegate {
            dlg.listView(self, willDisplay: cell, forItemAt: indexPath.item)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let closure = self.didEndDisplayingCellAtIndex {
            closure(cell, indexPath.item)
        } else if let dlg = self.delegate {
            dlg.listView(self, didEndDisplaying: cell, forItemAt: indexPath.item)
        }
    }
    
    // MARK: - FlowLayout Delegate
    
    /// 项Size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let length: CGFloat = self.getItemLength(at: indexPath.item)
        var size = CGSize.zero
        switch self.scrollDirection {
        case .horizontal:
            let contentHeight = self.bounds.height - self.padding.top - self.padding.bottom
            size = CGSize(width: length, height: contentHeight)
        case .vertical:
            let contentWidth = self.bounds.width - self.padding.left - self.padding.right
            size = CGSize(width: contentWidth, height: length)
        }
        return size
    }
    
    /// 从闭包或代理取项长度
    private func getItemLength(at index: Int) -> CGFloat {
        var length: CGFloat = 0
        if let closure = self.lengthForItemAtIndex {
            length = closure(self, index)
        } else if let dlg = self.delegate {
            length = dlg.listView(self, lengthForItemAt: index)
        } else {
            length = self.itemLength
        }
        return length
    }
    
    // MARK: - UIScrollView Delegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let closure = self.didScroll {
            closure(scrollView)
        }
        else if let dlg = self.delegate {
            dlg.listView(self, didScroll: scrollView)
        }
    }
    
    /// drag前的cell的位置
    private var indexOfCellBeforeDragging: Int = 0
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let closure = self.willBeginDragging {
            closure(scrollView)
        } else if let dlg = self.delegate {
            dlg.listView(self, willBeginDragging: scrollView)
        }
        if self.isPagingEnabled {
            self.indexOfCellBeforeDragging = self.currentItemIndex()
            JXMediaUtil.log(message: "WillBeginDragging currentIndex:\(self.indexOfCellBeforeDragging)")
        }
    }
    
    /// 求当前居中显示的项的index
    private func currentItemIndex() -> Int {
        let offset = self.collectionView.contentOffset
        let centerX = self.collectionView.frame.midX
        let centerY = self.collectionView.frame.midY
        let midPoint = CGPoint(x: offset.x + centerX, y: offset.y + centerY)
        let indexPath = self.collectionView.indexPathForItem(at: midPoint)
        return indexPath?.item ?? 0
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let closure = self.willEndDragging {
            closure(scrollView, velocity, targetContentOffset)
        } else if let dlg = self.delegate {
            dlg.listView(self, willEndDragging: scrollView, velocity: velocity, targetContentOffset: targetContentOffset)
        }
        if self.isPagingEnabled {
            self.scrollPaging(withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
    }
    
    // 实现翻页效果
    private func scrollPaging(withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // 先停止当前滑动
        targetContentOffset.pointee = collectionView.contentOffset
        // 计算滑动条件
        let pageWidth = self.itemLength + self.itemSpacing
        let collectionViewItemCount = collectionView.numberOfItems(inSection: 0)
        let proportionalOffset = collectionView.contentOffset.x / pageWidth
        // 当前四舍五入后应位于哪个位置
        let indexOfMajorCell = Int(round(proportionalOffset))
        // 拖动加速度是否满足滑到下个位置
        let swipeVelocityThreshold: CGFloat = 0.5
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < collectionViewItemCount && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
        // 目标位置
        var snapToIndex = indexOfMajorCell
        if didUseSwipeToSkipCell {
            snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
        }
        let safeIndex = max(0, min(snapToIndex, collectionViewItemCount - 1))
        let indexPath = IndexPath(item: safeIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let closure = self.didEndDragging {
            closure(scrollView, decelerate)
        } else if let dlg = self.delegate {
            dlg.listView(self, didEndDragging: scrollView, willDecelerate: decelerate)
        }
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if let closure = self.willBeginDecelerating {
            closure(scrollView)
        } else if let dlg = self.delegate {
            dlg.listView(self, willBeginDecelerating: scrollView)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let closure = self.didEndDecelerating {
            closure(scrollView)
        } else if let dlg = self.delegate {
            dlg.listView(self, didEndDecelerating: scrollView)
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let closure = self.didEndScrollingAnimation {
            closure(scrollView)
        } else if let dlg = self.delegate {
            dlg.listView(self, didEndScrollingAnimation: scrollView)
        }
    }
    
    // MARK: - 初始化
    
    public convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    open func setup() {
        self.backgroundColor = .clear
        self.addSubview(self.collectionView)
        self.clipsToBounds = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.frame = self.bounds
    }

    private lazy var flowLayout: UICollectionViewFlowLayout = { [unowned self] in
        let flow = UICollectionViewFlowLayout()
        flow.minimumLineSpacing = 0
        flow.minimumInteritemSpacing = 0
        flow.sectionInset = .zero
        flow.scrollDirection = .horizontal
        return flow
    }()
    
    private lazy var collectionView: UICollectionView = { [unowned self] in
        let view = UICollectionView(frame: self.bounds, collectionViewLayout: self.flowLayout)
        view.backgroundColor = .clear
        view.backgroundView?.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.bounces = true
        view.isPagingEnabled = false
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        view.dataSource = self
        view.delegate = self
        return view
    }()
}
