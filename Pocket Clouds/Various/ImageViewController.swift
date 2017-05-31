//
//  ImageViewController.swift
//  Pocket Clouds
//
//  Created by Tyler on 19/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

class ImageViewController: UIViewController,
                            UIPageViewControllerDelegate,
                            UIPageViewControllerDataSource,
                            UIScrollViewDelegate,
                            FolderRetreiveable

{

    var incomingImagePath = ""
    
    private var toolBarsAreHidden = true
    private var pageViewController = UIPageViewController()
    private var currentPageView = ContentViewController()
    private var initialLoadingHasOccured = false
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        print("ImageViewController received memory warning...")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let options = [UIPageViewControllerOptionInterPageSpacingKey : 6]
        
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
        
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self

        //guard let initialIndex = self.filenames.index(of: incomingFilename) else {return}
        //guard let initialIndex = self.imagefiles.index(of: incomingFilename) else {return}
        guard let startingViewController = self.viewControllerAt(index: 0) else {return}
        
        self.pageViewController.setViewControllers([startingViewController], direction: .forward, animated: false, completion: nil)
        
        self.pageViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParentViewController: self)
        self.pageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.pageViewController.view.accessibilityIdentifier = "pagecontrollerview"
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        //guard let initialIndex = self.imagefiles.index(of: incomingFilename) else {return}
        guard let startingViewController = self.viewControllerAt(index: 0) else {return}
        self.pageViewController.setViewControllers([startingViewController], direction: .forward, animated: false, completion: nil)
        self.currentPageView = startingViewController
    }
    
    
    private func viewControllerAt(index: Int) -> ContentViewController?
    {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapDetector(_:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapDetector(_:)))
        tap.numberOfTapsRequired = 1
        doubleTap.numberOfTapsRequired = 2
        tap.require(toFail: doubleTap)
        
        let contentViewController = ContentViewController()
        let center = CGPoint(x: (self.view.frame.size.width / CGFloat(2)), y:  (self.view.frame.size.height / CGFloat(2)))
        let scrollview = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        guard let data = try? Data.init(contentsOf: incomingImagePath.toURL())else {print("Couldn't get data"); return nil}
        guard let image = UIImage(data: data) else {print("Couldn't get image"); return nil}
        scrollview.backgroundColor = UIColor.black
        scrollview.alwaysBounceVertical = false
        scrollview.alwaysBounceHorizontal = false
        scrollview.flashScrollIndicators()
        scrollview.minimumZoomScale = 1.0
        scrollview.maximumZoomScale = 10.0
        scrollview.center = center
        scrollview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollview.addGestureRecognizer(tap)
        scrollview.addGestureRecognizer(doubleTap)
        scrollview.delegate = self
        
        let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        imageview.center = center
        imageview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageview.contentMode = .scaleAspectFit
        imageview.image = image
        scrollview.addSubview(imageview)
        contentViewController.scrollview = scrollview
        contentViewController.imageview = imageview
        contentViewController.view.addSubview(scrollview)
        contentViewController.pageindex = index
        return contentViewController
    }

    /// Hides navigation bar when the user taps that screen
    @objc private func tapDetector(_ sender: UITapGestureRecognizer)
    {
        changeToolBarsVisibility()
    }
    
    
    /// Zooms into image when double tap is detected
    @objc private func doubleTapDetector(_ sender: UITapGestureRecognizer)
    {
        if let scrollView =  self.currentPageView.scrollview
        {
            if (scrollView.zoomScale > scrollView.minimumZoomScale)
            {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            }
            else
            {
                let rect = self.zoomRect(scale: scrollView.maximumZoomScale / 3.0, center: sender.location(in: scrollView))
                scrollView.zoom(to: rect, animated: true)
            }

        }
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return self.currentPageView.imageview
    }
    
    /// Used to get the zoom rect for the image when the user doubletaps
    private func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect
    {
        var zoomRect = CGRect.zero
        if let imageV = self.currentPageView.imageview
        {
            zoomRect.size.height = imageV.frame.size.height / scale
            zoomRect.size.width = imageV.frame.size.width / scale
            let newCenter = imageV.convert(center, from: self.currentPageView.scrollview)
            zoomRect.origin.x = newCenter.x - ((zoomRect.size.width / 2.0))
            zoomRect.origin.y = newCenter.y - ((zoomRect.size.height / 2.0))
        }
        return zoomRect
    }
    
    /// changes the various toolbars on the users screen to invisible
    private func changeToolBarsVisibility()
    {
        let shouldHide = toolBarsAreHidden ? false : true
        self.navigationController?.setNavigationBarHidden(shouldHide, animated: true)
        toolBarsAreHidden = shouldHide
    }

    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        
        if (completed)
        {
            if let currentViewController = self.pageViewController.viewControllers?.first as? ContentViewController
            {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.currentPageView = currentViewController
            }
        }
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        guard var index = (viewController as? ContentViewController)?.pageindex else {return nil}
        if (index == 0 || index == NSNotFound){return nil}
        index -= 1
        return self.viewControllerAt(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard var index = (viewController as? ContentViewController)?.pageindex else {return nil}
        if (index == NSNotFound){return nil}
        index += 1
        if (index > 0){return nil}
        return self.viewControllerAt(index: index)
    }
}

class ContentViewController: UIPageViewController
{
    var pageindex = 0
    weak var imageview: UIImageView?
    weak var scrollview: UIScrollView?
    
    
    override func viewDidLoad()
    {
        self.view.backgroundColor = UIColor.black
    }
    override func viewDidDisappear(_ animated: Bool)
    {
        self.imageview = nil
        self.scrollview = nil
        //scrollview?.setZoomScale(0, animated: false)
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        print("ContentViewController received memory warning...")
    }
}

