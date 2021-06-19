//
//  JXListViewDelegate.swift
//  JXMediaBrowser
//
//  Created by Jason on 2021/5/29.
//

import UIKit

public protocol JXListViewDelegate: NSObjectProtocol {
    
    // MARK: - 刷新界面触发的回调
    
    /// 共有多少项。必选实现。
    func numberOfItems(in listView: JXListView) -> Int
    
    /// 取指定项的视图。必选实现。
    func listView(_ listView: JXListView, cellForItemAt index: Int) -> UICollectionViewCell
    
    /// 一项的长度，沿着滑动方向
    func listView(_ listView: JXListView, lengthForItemAt index: Int) -> CGFloat
    
    /// Cell即将显示
    func listView(_ listView: JXListView, willDisplay cell: UICollectionViewCell, forItemAt index: Int)
    
    /// Cell已消失
    func listView(_ listView: JXListView, didEndDisplaying cell: UICollectionViewCell, forItemAt index: Int)
    
    // MARK: - 交互触发的回调
    
    /// 点击选中某项
    func listView(_ listView: JXListView, didSelectItemAt index: Int)
    
    /// 视图滑动
    func listView(_ listView: JXListView, didScroll scrollView: UIScrollView)
    
    /// 即将开始拖动
    func listView(_ listView: JXListView, willBeginDragging scrollView: UIScrollView)
    
    /// 即将停止拖动
    func listView(_ listView: JXListView, willEndDragging scrollView: UIScrollView, velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    
    /// 已经停止拖动
    func listView(_ listView: JXListView, didEndDragging scrollView: UIScrollView, willDecelerate decelerate: Bool)
    
    /// 即将开始滑动减速
    func listView(_ listView: JXListView, willBeginDecelerating scrollView: UIScrollView)
    
    /// 已经停止滑动减速
    func listView(_ listView: JXListView, didEndDecelerating scrollView: UIScrollView)
    
    /// 已经停止滑动动画
    func listView(_ listView: JXListView, didEndScrollingAnimation scrollView: UIScrollView)
}
