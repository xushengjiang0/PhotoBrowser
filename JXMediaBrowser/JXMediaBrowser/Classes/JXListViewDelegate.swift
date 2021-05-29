//
//  JXListViewDelegate.swift
//  JXMediaBrowser
//
//  Created by Jason on 2021/5/29.
//

import UIKit

public protocol JXListViewDelegate {
    
    // MARK: - 刷新界面触发的回调
    
    /// 共有多少项。必选实现。
    func numberOfItems() -> Int
    
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
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    
    /// 即将开始拖动
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    
    /// 即将停止拖动
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    
    /// 已经停止拖动
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    
    /// 即将开始滑动减速
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    
    /// 已经停止滑动减速
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    
    /// 已经停止滑动动画
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
}
