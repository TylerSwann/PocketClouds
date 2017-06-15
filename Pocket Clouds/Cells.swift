//
//  Cells.swift
//  Pocket Clouds
//
//  Created by Tyler on 17/04/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

class FolderCell: UICollectionViewCell
{
    @IBOutlet weak var cellThumbnail: UIImageView!
    
    @IBOutlet weak var cellCheckMark: UIImageView!
    
    @IBOutlet weak var folderNameLabel: UILabel!
}
class MediaPickerCell: UICollectionViewCell
{
    @IBOutlet weak var mediaThumbnail: UIImageView!
    
    @IBOutlet weak var blurredView: UIView!
    
    @IBOutlet weak var mediaInfoLabel: UILabel!
    
    @IBOutlet weak var checkMark: UIImageView!
}

class ImportCell: UICollectionViewCell
{
    var thumbnail = UIImageView()
    var checkmark = UIImageView()
    var nameview = UIView()
    var namelabel = UILabel()
    
    private var size = CGSize()
    private var cellcenter = CGPoint()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.setup()
    }
    
    func refresh()
    {
        self.size = CGSize(width: self.contentView.frame.size.width, height: self.contentView.frame.size.height)
        self.cellcenter = CGPoint(x: (size.width / 2), y: (size.height / 2))
        self.namelabel.center = cellcenter
        self.nameview.center = cellcenter
        self.namelabel.text = ""
        self.thumbnail.frame.size = self.size
        self.thumbnail.center = self.cellcenter
        
        self.namelabel.isHidden = true
        self.nameview.isHidden = true
        self.checkmark.isHidden = true
    }
    
    private func setup()
    {
        self.size = CGSize(width: self.contentView.frame.size.width, height: self.contentView.frame.size.height)
        self.cellcenter = CGPoint(x: (self.size.width / 2), y: (self.size.height / 2))
        let cellframe = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.thumbnail = UIImageView(frame: CGRect.init(x: 0, y: 0, width: self.contentView.frame.size.width, height: self.contentView.frame.size.height))
        self.thumbnail.center = self.cellcenter
        self.thumbnail.contentMode = .scaleAspectFill
        self.thumbnail.clipsToBounds = true
        
        self.checkmark = UIImageView(frame: CGRect(x: 0, y: 0, width: (size.width / CGFloat(4)), height: (size.height / CGFloat(4))))
        self.checkmark.center = cellcenter
        self.checkmark.center.x += (size.width / CGFloat(2)) - (self.checkmark.frame.size.width / CGFloat(2))
        self.checkmark.center.y += (size.height / CGFloat(2)) - (self.checkmark.frame.size.height / CGFloat(2))
        self.checkmark.image = #imageLiteral(resourceName: "checkmark")
        
        self.nameview = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: (self.size.height / CGFloat(3.5))))
        self.nameview.center = cellcenter
        self.nameview.backgroundColor = UIColor.white
        
        self.namelabel = UILabel(frame: cellframe)
        self.namelabel.textAlignment = .center
        self.namelabel.center = cellcenter
        self.namelabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        
        self.addSubview(self.thumbnail)
        self.addSubview(self.nameview)
        self.addSubview(self.namelabel)
        self.addSubview(self.checkmark)
        
        self.namelabel.isHidden = true
        self.nameview.isHidden = true
        self.checkmark.isHidden = true
    }
    
    func setCellToSelected()
    {
        self.checkmark.isHidden = false
        self.subviews.forEach({subview in
            if (subview != self.checkmark){subview.alpha = CGFloat(0.5)}
        })
    }
    
    func setCellDeselected()
    {
        self.checkmark.isHidden = true
        self.subviews.forEach({subview in
            if (subview != self.checkmark){subview.alpha = CGFloat(1.0)}
        })
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

class FileViewerCell: UICollectionViewCell
{
    var namelabel = UILabel()
    var label = UILabel()
    var nameview = UIView()
    var checkmark = UIImageView()
    var thumbnail = UIImageView()
    var detailLabel = UILabel()
    var cellcenter = CGPoint.zero
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.setup()
    }
    
    func setup()
    {
        let size = self.frame.size
        let cellframe = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.cellcenter = CGPoint(x: (size.width / CGFloat(2)), y: (size.height / CGFloat(2)))
        self.namelabel = UILabel(frame: cellframe)
        self.namelabel.frame.size.width -= 5
        self.namelabel.textAlignment = .center
        self.namelabel.center = cellcenter
        self.namelabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        self.detailLabel = UILabel(frame: cellframe)
        self.detailLabel.center = cellcenter
        self.detailLabel.textAlignment = .center
        self.detailLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        self.detailLabel.textColor = UIColor.darkGray
        self.thumbnail = UIImageView(frame: cellframe)
        self.thumbnail.contentMode = .scaleAspectFit
        self.label = UILabel(frame: cellframe)
        self.label.textAlignment = .center
        self.label.frame.size.width = (self.thumbnail.frame.size.width / 1.5)
        self.label.frame.size.height /= 2
        self.label.center = cellcenter
        self.label.center.y += (size.width / CGFloat(4))
        self.label.font = UIFont.systemFont(ofSize: 29, weight: UIFontWeightBlack)
        self.label.textColor = UIColor.init(red: 53/255, green: 53/255, blue: 53/255, alpha: 255/255)
        
        self.label.adjustsFontSizeToFitWidth = true
        self.nameview = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: (size.height / CGFloat(3.5))))
        self.nameview.center = cellcenter
        self.nameview.backgroundColor = UIColor.white
        self.checkmark = UIImageView(frame: CGRect(x: 0, y: 0, width: (size.width / CGFloat(4)), height: (size.height / CGFloat(4))))
        self.checkmark.center = cellcenter
        self.checkmark.center.x += (size.width / CGFloat(2)) - (self.checkmark.frame.size.width / CGFloat(2))
        self.checkmark.center.y += (size.height / CGFloat(2)) - (self.checkmark.frame.size.height / CGFloat(2))
        self.checkmark.image = #imageLiteral(resourceName: "checkmark")
        
        addSubview(thumbnail)
        addSubview(nameview)
        addSubview(label)
        addSubview(namelabel)
        addSubview(detailLabel)
        addSubview(checkmark)
        
        self.detailLabel.isHidden = true
        self.namelabel.isHidden = true
        self.label.isHidden = true
        self.nameview.isHidden = true
        self.checkmark.isHidden = true
    }
    
    func refresh()
    {
        let size = self.frame.size
        self.cellcenter = CGPoint(x: (size.width / CGFloat(2)), y: (size.height / CGFloat(2)))
        self.thumbnail.frame = self.frame
        self.thumbnail.center = cellcenter
        self.label.frame.size.width = (self.thumbnail.frame.size.width / 1.5)
        self.label.adjustsFontSizeToFitWidth = true
        self.label.center = cellcenter
        self.label.center.y += (size.width / CGFloat(6.5))
        
        self.namelabel.center = cellcenter
        self.nameview.center = cellcenter
        self.detailLabel.center = cellcenter
        
        self.namelabel.isHidden = true
        self.label.isHidden = true
        self.nameview.isHidden = true
        self.checkmark.isHidden = true
    }
    
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

class ComputerImportCell: UITableViewCell
{
    weak var thumbnail: UIImageView?
    weak var label: UILabel?
    weak var checkmark: UIImageView?
    private var size = CGSize()
    private var cellcenter = CGPoint()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    private func setup()
    {
        self.size = self.frame.size
        self.cellcenter = CGPoint(x: (self.size.width / 2), y: (self.size.height / 2))
        self.thumbnail = UIImageView(frame: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.height))
        self.thumbnail?.center = self.cellcenter
        self.thumbnail?.center.x -= ((self.size.width / 2) + (self.size.height / 2))
        self.label = UILabel(frame: CGRect(x: 0, y: 0, width: (self.size.width - self.size.height), height: self.size.height))
        self.label?.center = self.cellcenter
        self.label?.textAlignment = .center
        self.label?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        self.checkmark = UIImageView(frame: CGRect(x: 0, y: 0, width: (self.size.height / 3), height: (self.size.height / 3)))
        self.checkmark?.center = self.cellcenter
        self.checkmark?.center.x += ((self.size.width / 2) + (self.size.height / 3))
        
        self.addSubview(self.thumbnail ?? UIImageView())
        self.addSubview(self.label ?? UILabel())
        self.addSubview(self.checkmark ?? UIImageView())
        
        self.checkmark?.isHidden = true
        self.label?.isHidden = false
        self.thumbnail?.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}





















