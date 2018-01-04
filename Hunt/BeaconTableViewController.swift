

import UIKit
import ProximityKit

class BeaconTableViewController: UITableViewController, RPKManagerDelegate {
    
    var proximityKitManager: RPKManager?
    
    var beaconPhoto = UIImage(named: "beacon")
    var beacons = [RPKBeacon]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let configDict: [String:Any] = [
            "api_token": "7c9d93e957e3b2228c94cf87abcc41bc73759cd6cf074cfd57a26261498bdde1", // <Kit Token from Settings>
            "kit_url": "https://proximitykit.radiusnetworks.com/api/kits/10117" // Kit URL from Settings, e. g. https://proximitykit.radiusnetworks.com/api/kits/[number]
        ]
        
        self.proximityKitManager = RPKManager(delegate:self, andConfig:configDict)
        
        if let proximityKitManager = self.proximityKitManager {
            proximityKitManager.start()
        }
        
    }

    func proximityKitDidSync(_ manager : RPKManager) {
        print("Proximity Kit did sync")
    }
    
    func proximityKit(_ manager: RPKManager!, didDetermineState state: RPKRegionState, for region: RPKRegion!) {
        
        var stateDescription: String
        
        switch (state) {
        case .inside:
            stateDescription = "Inside"
        case .outside:
            stateDescription = "Outside"
        case .unknown:
            stateDescription = "Unknown"
        }
        
        print("State Changed: \(stateDescription) Region \(region.name) (\(region.identifier))")
    }
    
    func proximityKit(_ manager : RPKManager, didEnter region:RPKRegion) {
        
        //var alert = UIAlertController(title: "Entered Region", message: region.name, preferredStyle: /UIAlertControllerStyle.alert)
        //alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        //self.present(alert, animated: true, completion: nil)
    }
    
    func proximityKit(_ manager : RPKManager, didExit region:RPKRegion) {
        //var alert = UIAlertController(title: "Exited Region", message: region.name, preferredStyle: UIAlertControllerStyle.alert)
        //alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        //self.present(alert, animated: true, completion: nil)

        if let index = beacons.index(where: { $0.name == region.name }) {
            beacons.remove(at: index)
        }
    }
    
    func proximityKit(_ manager: RPKManager!, didRangeBeacons tbeacons: [Any]!, in region: RPKBeaconRegion!) {
        for beacon in tbeacons as! [RPKBeacon] {
            print("Beacon found:" + region.name +  " accuracy: \(beacon.accuracy)")
            let index = beacons.index(where: { $0.name == beacon.name })
            if(beacon.accuracy>0 && beacon.accuracy <= 6){
                //close by, add or update beacon
                if(index==nil) {
                    beacons.append(beacon)
                }
                else{
                    beacons[index!]=beacon
                }
                
                
            }else if(beacon.accuracy>6  ){
                //too far, remove beacon
                if(index != nil){
                    beacons.remove(at: index!)
                }
            }
            tableView.reloadData()
        }
        
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beacons.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "BeaconTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BeaconTableViewCell  else {
            fatalError("The dequeued cell is not an instance of BeaconTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let beacon = beacons[indexPath.row]
        
        cell.nameLabel.text = beacon.name
        cell.photoImageView.image = beaconPhoto
        cell.ratingControl.rating = 5 - min(5,max(0,Int(beacon.accuracy)))
        return cell
    }
    

}
