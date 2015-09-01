//
//  MainCell.swift
//  ARNInteractiveTransition
//
//  Created by xxxAIRINxxx on 2015/08/31.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

class MainCell: UICollectionViewCell {
    
    @IBOutlet weak var tableView : UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let imageView = UIImageView(image: UIImage(named: "image.jpg"))
        imageView.contentMode = .ScaleAspectFill
        imageView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 300)
        self.tableView.tableHeaderView = imageView
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        return cell
    }
}
