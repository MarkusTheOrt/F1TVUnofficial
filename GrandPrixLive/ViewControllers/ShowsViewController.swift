//
//  ShowsViewController.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 11.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import UIKit

var shows: [Show] = []

class ShowsViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    
    var index: Int = 0
    
    
    var controllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTapped)))
        
        DispatchQueue.global().async{
            while(shows.count < ShowSlugs.count){}
            DispatchQueue.main.sync{
                self.presentPages()
            }
        }
        
    }
    
    
    
    private func presentPages(){
        shows.forEach({(show) -> Void in
            let controller = SingleShowViewController(nibName: "SingleShowViewController", bundle: nil);
            controller.show = show
            self.controllers.append(controller)
        })
        self.setViewControllers([self.controllers[self.index]], direction: .forward, animated: true)
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return shows.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return index
    }
    
    @objc func onTapped(){
        print(shows[index].title)
        let contentController = ContentViewController(nibName: "ContentViewController", bundle: nil);
        contentController.show = shows[index]
        //contentController.alreadyFetched()
        self.present(contentController, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        VideoPlayer.shared.context = self
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if(index == 0){
        }else{
            index -= 1
        }
        return controllers[index]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if(index == shows.count - 1){
        }else{
            index += 1
        }
        return controllers[index]
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
