//
//  JXListView.swift
//  JXMediaBrowser
//
//  Created by Jason on 2021/5/14.
//

import UIKit

open class JXListView : UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - 公开属性
    
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
    /// - 如果同时实现了lengthForItem代理方法，则以代理方法取值为准
    /// - 默认值0，在展示的时候会自动填满视图frame
    public var itemLength: CGFloat = 0
    
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
    
    /// 是否开启翻页吸附。
    /// 说明：当需求为每页展示一个项视图时，可以开启
    public var isPagingEnabled: Bool {
        set {
            self.collectionView.isPagingEnabled = newValue
        }
        get {
            self.collectionView.isPagingEnabled
        }
    }
    
    // MARK: - 公开方法
    
    /// 刷新视图
    open func reloadData() {
        self.collectionView.reloadData()
    }
    
    /// 注册复用Cell
    open func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    /// 取复用Cell
    open func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        return cell
    }
    
    
    // MARK: - 回调闭包
    
    /// 共有多少项
    public var numberOfItems: (() -> Int)?
    
    /// 取指定项的视图
    public var cellForItemAtIndex: ((_ listView: JXListView, _ index: Int) -> UICollectionViewCell)?
    
    /// 定制项长度
    public var lengthForItemAtIndex: ((_ listView: JXListView, _ index: Int) -> CGFloat)?
    
    /// 点击选中某项
    public var didSelectItemAtIndex: ((_ index: Int) -> Void)?
    
    /// cell即将显示
    public var willDisplayCellAtIndex: ((_ cell: UICollectionViewCell, _ index: Int) -> Void)?
    
    /// cell已消失
    public var didEndDisplayingCellAtIndex: ((_ cell: UICollectionViewCell, _ index: Int) -> Void)?
    
    /// 视图滑动
    public var didScroll: ((_ scrollView: UIScrollView) -> Void)?
    
    public var willBeginDragging: ((_ scrollView: UIScrollView) -> Void)?
    
    
    // MARK: - UICollectionView DataSource

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var number = 0
        if let block = self.numberOfItems {
            number = block()
        }
        self.setNeedsLayout()
        return number
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseCell = self.cellForItemAtIndex?(self, indexPath.item)
        assert(reuseCell != nil, "请提供可复用的Cell!")
        let cell = reuseCell ?? UICollectionViewCell()
        return cell
    }
    
    
    // MARK: - UICollectionView Delegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        self.didSelectItemAtIndex?(indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.willDisplayCellAtIndex?(cell, indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.didEndDisplayingCellAtIndex?(cell, indexPath.item)
    }
    
    // MARK: - FlowLayout Delegate
    
    /// 项Size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let contentWidth = self.bounds.width - self.padding.left - self.padding.right
        let contentHeight = self.bounds.height - self.padding.top - self.padding.bottom
        
        var length = self.itemLength
        if let block = self.lengthForItemAtIndex {
            length = block(self, indexPath.item)
        }
        
        var size = CGSize.zero
        switch self.scrollDirection {
        case .horizontal:
            length = length > 0 ? length : contentWidth
            size = CGSize(width: length, height: contentHeight)
        case .vertical:
            length = length > 0 ? length : contentHeight
            size = CGSize(width: contentWidth, height: length)
        default:
            assert(false)
        }
        return size
    }
    
    // MARK: - UIScrollView Delegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.didScroll?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.willBeginDragging?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        var currentCellOffset = self.collectionView.contentOffset
//        currentCellOffset.x += self.itemSpacing / 2.0
        if let indexPath = self.collectionView.indexPathForItem(at: currentCellOffset) {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
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
//        let width = self.bounds.width + self.itemSpacing
//        self.collectionView.frame = CGRect(x: 0, y: 0, width: width, height: self.bounds.height)
//        let number = self.collectionView.numberOfItems(inSection: 0)
//        JXMediaUtil.log(content: "width:\(self.collectionView.frame.width * CGFloat(number))")
        JXMediaUtil.log(content: "contentSize:\(self.collectionView.contentSize)")
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
//        view.addObserver(self, forKeyPath: "contentSize", options: [.new], context: nil)
        return view
    }()
    
//    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        JXMediaUtil.log(content: "keyPath:\(keyPath ?? "")")
//        print(change ?? [:])
//    }
}
