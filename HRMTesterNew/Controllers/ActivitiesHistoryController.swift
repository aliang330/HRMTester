//
//  ActivitiesHistoryController.swift
//  HRMTesterNew
//
//  Created by Allen Liang on 9/14/20.
//  Copyright © 2020 Allen Liang. All rights reserved.
//

import UIKit

class ActivitiesHistoryController: UITableViewController {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ActivityCell.self, forCellReuseIdentifier: cellId)
        tableView.backgroundColor = .white
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ActivityCell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

class ActivityCell: UITableViewCell {
    let cellId = "activityCellId"
    
    let activityLabel: UILabel = {
        let lb = UILabel(text: "2020-09-14 8:00AM", font: .systemFont(ofSize: 18))
        
        return lb
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: cellId)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(activityLabel)
        
        activityLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 26, left: 12, bottom: 16, right: 0))
        activityLabel.centerYInSuperview()
    }
    
    
}
