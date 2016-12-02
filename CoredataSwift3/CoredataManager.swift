//
//  CoredataManager.swift
//  CoredataSwift3
//
//  Created by Amrit on 12/2/16.
//  Copyright © 2016 Amrit. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class CoredataManager: NSObject {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    func saveDataOnCoredata(data: [AnyObject]){
        
        let dataBaseUrl = getDocumentsDirectory()
        print(dataBaseUrl)
        let privateAsyncMOC_En = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)// The context is associated with the main queue, and as such is tied into the application’s event loop, but it is otherwise similar to a private queue-based context. You use this queue type for contexts linked to controllers and UI objects that are required to be used only on the main thread.
        
        privateAsyncMOC_En.parent = managedObjectContext
        privateAsyncMOC_En.perform{ // The perform(_:) method returns immediately and the context executes the block methods on its own thread. Here it use background thread.
            
            let convetedJSonData = self.convertAnyobjectToJSON(anyObject: data as AnyObject)
            for (_ ,object) in convetedJSonData{
                
                self.checkIFNewsIdForEnglishAlreadyExists(newsId: object["news_id"].intValue, completion: { (count) in
                    if count != 0{
                        
                        self.updateDataBaseOfEnglishNews(json: object, newsId: object["news_id"].intValue)
                    }else{
                        
                        let newPrivateAsyncMO_En = NSEntityDescription.insertNewObject(forEntityName: "TestEnt", into: privateAsyncMOC_En) as! TestEnt
                        self.processJSONIntoCoreData_En(managedObject: newPrivateAsyncMO_En, json: object)
                    }
                })
            }
            do {
                if privateAsyncMOC_En.hasChanges{
                    
                    try privateAsyncMOC_En.save()
                }
                if managedObjectContext.hasChanges{
                    
                    try managedObjectContext.save()
                }
                
            }catch {
                print(error)
            }
        }
    }
    
    private func processJSONIntoCoreData_En(managedObject:TestEnt,json:JSON){
        
        managedObject.name = json["news_title"].stringValue
        managedObject.id = json["news_id"].int64!
    }
    
    func retriveSavedData(saveResult:([TestEnt])->(), unknownError:(Bool)->()){
        
        let request:NSFetchRequest<TestEnt> = TestEnt.fetchRequest()
        do {
            
            saveResult(try managedObjectContext.fetch(request))
            unknownError(false)
            
        }catch{
            let error  = error as NSError
            print("\(error)")
            unknownError(true)
            
        }
    }
    
    //MARK:-check English NewID Already Exists or not
    // here coredata have not primary key concept so we sequently check data already exist in coredata or not.
    // data is updated if and only if updating data is already exist in coredata
    func checkIFNewsIdForEnglishAlreadyExists(newsId:Int,completion:(_ count:Int)->()){
        
        let fetchReq:NSFetchRequest<TestEnt> = TestEnt.fetchRequest()
        fetchReq.predicate = NSPredicate(format: "id = %d",newsId)
        fetchReq.fetchLimit = 1 // this gives one data at a time for checking coming data to saved data
        
        do {
            
            let count = try managedObjectContext.count(for: fetchReq)
            completion(count)
            
        }catch{
            let error  = error as NSError
            print("\(error)")
            completion(0)
        }
    }
    
    //MARK:-Update coredata
    func updateDataBaseOfEnglishNews(json: JSON, newsId : Int){
        
        do {
            let fetchRequest:NSFetchRequest<TestEnt> = TestEnt.fetchRequest()
            
            fetchRequest.predicate = NSPredicate(format: "id = %d",newsId)
            let fetchResults = try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as? [TestEnt]
            if let fetchResults = fetchResults {
                
                if fetchResults.count != 0{
                    
                    let newManagedObject = fetchResults[0]
                    newManagedObject.setValue(json["news_title"].stringValue, forKey: "name")
                    newManagedObject.setValue(json["news_id"].intValue, forKey: "id")
                    
                    
                    do {
                        if ((newManagedObject.managedObjectContext?.hasChanges) != nil){
                            
                            try newManagedObject.managedObjectContext?.save()
                        }
                    } catch {
                        let saveError = error as NSError
                        print(saveError)
                    }
                }
            }
        } catch {
            
            let saveError = error as NSError
            print(saveError)
        }
    }
    
    //MARK:-Convertion anyobject to JSON for daving purpose
    func convertAnyobjectToJSON(anyObject: AnyObject) -> JSON{
        
        let jsonData = try! JSONSerialization.data(withJSONObject: anyObject, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        if let dataFromString = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            
            let json = JSON(data: dataFromString)
            print(anyObject)
            print(json)
            return json
        }
        return nil
    }
    
    
    //MARK:-delete database
     func deleteDataBaseOfNewsIfItDeletedFromBackEnd(newsID: Int){
        
            do{
                let request: NSFetchRequest<TestEnt> = TestEnt.fetchRequest()
                let results = try managedObjectContext.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
                
                if results.count > 0 {
                    
                    for item in results as! [NSManagedObject]{
                        
                        managedObjectContext.delete(item)
                        
                    }
                }

                
            } catch{
                print(error)
            }
           }
}



class test : NSObject{
    
    //    "2016-09-05 12:38:18"
    let title1 = "english 1"
    let newsID1 = 1000
    let date1 = "2016-10-18 14:33:25"
    let title2 = "english 221"
    let newsID2 = 1000032
    let date2 = "2016-09-05 12:38:26"
    
    func newsAdded(){
        
        let object1 = ["category_id":6,"category_name":"Business","date":date1,"description":"asdsdsads","image_url":"http://inheadline.com/stage/public/assets/uploads/news/1_913941472725977.jpeg","language_id":1,"location":"National","news_id":newsID1,"news_title":title1,"source_name":"bbc","source_url":"http://www.bbc.com/news","special_cat_id":"","special_category":"","type":"None","writer_name":"InHeadline Stage"] as [String : Any]
        let object2 = ["category_id":6,"category_name":"Business","date":date2,"description":"asdsdsads","image_url":"http://inheadline.com/stage/public/assets/uploads/news/1_913941472725977.jpeg","language_id":1,"location":"National","news_id":newsID2,"news_title":title2,"source_name":"bbc","source_url":"http://www.bbc.com/news","special_cat_id":"","special_category":"","type":"None","writer_name":"InHeadline Stage"] as [String : Any]
        
        let object = [object1,object2]
        
        
        CoredataManager().saveDataOnCoredata(data: object as [AnyObject])
        
    }
}
