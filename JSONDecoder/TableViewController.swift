//
//  PokemonTableViewController.swift
//  JSONDecoder
//
//  Created by Michael Miles on 11/5/19.
//  Copyright © 2019 Michael Miles. All rights reserved.
//

import UIKit



class PokemonTableViewController: UITableViewController {

    // Determine whether the application is loading
    var loading = true
    
   
    
    // array of item filtered from itemArray
    var newArray: [Item] = []

    // viewload
    override func viewDidLoad() {
        super.viewDidLoad()
       
        fetchData()
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading {
            return 1
        } else {
        
            return  newArray.count
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokemonCell", for: indexPath)

        //CONFIGURE CELL WITH DECODED DATA
        // if still loading
        if  loading {
            cell.textLabel?.text = " Loading..."
            
        }else{
            
        // Render Data
            let item = newArray[indexPath.row]
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = "listId:" + String(item.listId!)+" id:"+String(item.id!)
        }
        
        return cell
    }
    
    // MARK: Networking
    
    
    
    
    func fetchData(){
        
        let urlString =
        "https://fetch-hiring.s3.amazonaws.com/hiring.json"
        
        let url=URL(string: urlString)
        
        guard url != nil else{
            return
        }
        
        let session = URLSession.shared
        
        // get json data
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            
            if error == nil && data != nil {
                
                //decode json data
                do{
                    // get decode json data
                    let items = try JSONDecoder().decode([Item].self, from: data!)
                    
                    
                                      
                    // Filter out any items where "name" is blank or null
                    for item in items {
                        if item.name != nil && item.name != "" {
                            self.newArray.append(item)
                        }
                    }
                    
                    // Sort the results first by "listId" then by "name" when displaying.

                    self.newArray.sort { (lhs, rhs) in
                        if lhs.listId == rhs.listId {
                            let sequence_l :[String] =
                            lhs.name!.components(separatedBy: " ")
                            
                            let sequence_r :[String] = rhs.name!.components(separatedBy: " ")
                            
                            let l = Int(sequence_l[1])
                            
                            let r = Int(sequence_r[1])
                            
                            return l! < r!
                        }
                      return lhs.listId! < rhs.listId! // <2>
                    }
                    
                    
                    self.loading = false
                    
                    
                    // reloadData
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                

                }  catch {
                    print("Error in Json parsing")
                }
                
            }
        }
        
        dataTask.resume()
        
        
    }

}


// create codable item
struct Item: Codable{
    let id: Int?
    let listId: Int?
    let name: String?
    
}
