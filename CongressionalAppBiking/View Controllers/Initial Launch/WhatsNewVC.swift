//
//  WhatsNewVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 6/1/24.
//

import UIKit

class WhatsNewVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var slides: [Slide] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        scrollView.delegate = self
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
    }
    
    func createSlides() -> [Slide] {
        let slide1 = Bundle.main.loadNibNamed("WhatsNewView", owner: self, options: nil)?.first as! Slide
        slide1.imageView.image = UIImage(named: "RWGPS")
        slide1.textLabel.text = "First Slide"
        
        let slide2 = Bundle.main.loadNibNamed("WhatsNewView", owner: self, options: nil)?.first as! Slide
        slide2.imageView.image = UIImage(named: "RWGPS")
        slide2.textLabel.text = "Second Slide"
        
        let slide3 = Bundle.main.loadNibNamed("WhatsNewView", owner: self, options: nil)?.first as! Slide
        slide3.imageView.image = UIImage(named: "AppIcon")
        slide3.textLabel.text = "Third Slide"
        
        return [slide1, slide2, slide3]
    }
    
    func setupSlideScrollView(slides : [Slide]) {
        //scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: 1)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {

            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: scrollView.frame.height)
            scrollView.addSubview(slides[i])

            

            

        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}

extension WhatsNewVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(scrollView.contentOffset.x/view.frame.width)
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
            
    }
    
}
