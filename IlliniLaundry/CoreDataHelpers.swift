//
//  CoreDataHelpers.swift
//  IlliniLaundry
//
//  Created by Minhyuk Park on 07/02/2017.
//  Copyright © 2017 Minhyuk Park. All rights reserved.
//

import CoreData
import SwiftyJSON

class CoreDataHelpers {

    
    class func fetchLaundryStatus() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.container!;
        if let data = try? Data(contentsOf: URL(string: "http://23.23.147.128/homes/mydata/urba7723")!) {
            let jsonUIUC = JSON(data: data)
            let dormJSONArray = jsonUIUC["location"]["rooms"].arrayValue;
            
            DispatchQueue.main.async {
                for dormJSON in dormJSONArray{
                    let dormStatus = DormStatus(context: container.viewContext);
                    
                    self.configure(dormStatus: dormStatus, usingJSON: dormJSON);
                    print("pulled dormJSON");
                }
                print("debug statement in fetch laundry status");
                self.saveContext();
            }
        }
    }
    class func configure(dormStatus: DormStatus,
                   usingJSON dormJson: JSON){
        if let id = dormJson["id"].int16 {
            dormStatus.id = id;
        };
        
        if let name = dormJson["name"].string {
            dormStatus.name = name;
        };
        
        if let networked = dormJson["networked"].string {
            dormStatus.networked = networked;
        };
        
        if let dormMachines = configure(usingJSON: dormJson["machines"]) {
            dormStatus.dormMachines = dormMachines;
        };
        print(dormStatus);
        print("configured dorm status");
    }
    class func configure(usingJSON dormMachinesJson: JSON) -> NSMutableOrderedSet?{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.container!;
        let dormMachinesMutableSet = NSMutableOrderedSet();
        
        
        
        let managedContext = container.viewContext;
        
        for _ in dormMachinesMutableSet{
            let dormMachines = NSEntityDescription.insertNewObject(forEntityName: "DormMachines", into: managedContext) as? DormMachines;
            
            if let port = dormMachinesJson["port"].int16 {
                dormMachines?.port = port;
            };
            if let label = dormMachinesJson["label"].int16 {
                dormMachines?.label = label;
            };
            
            if let description = dormMachinesJson["description"].string {
                dormMachines?.description_ = description;
            };
            
            if let status = dormMachinesJson["status"].int16 {
                dormMachines?.status = status;
            }
            
            let formatter = ISO8601DateFormatter();
            dormMachines?.startTime = formatter.date(from: dormMachinesJson["startTime"].stringValue) ?? Date();
            
            dormMachines?.timeRemaining = dormMachinesJson["timeRemaining"].stringValue;
            dormMachinesMutableSet.add(dormMachines!);
            print("add dormMachine");
        }
        print("configured dorm status");
        return dormMachinesMutableSet;
        
    }
    class func clear() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.container!;
        let context = container.viewContext
        
        for i in 0...container.managedObjectModel.entities.count-1 {
            let entity = container.managedObjectModel.entities[i]
            
            do {
                let query = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
                let deleterequest = NSBatchDeleteRequest(fetchRequest: query)
                try context.execute(deleterequest)
                try context.save()
                
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                abort()
            }
        }
    }
    class func saveContext() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.container!;
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)");
            }
        }
    }
    
}
