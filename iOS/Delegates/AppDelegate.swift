//
//  AppDelegate.swift
//  feather
//
//  Created by samara on 5/17/24.
//

import UIKit
import Nuke
import CoreData

var downloadTaskManager = DownloadTaskManager.shared
class AppDelegate: UIResponder, UIApplicationDelegate {

	static let isSideloaded = Bundle.main.bundleIdentifier != "kh.crysalis.feather"
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		UserDefaults.standard.set(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, forKey: "currentVersion")
		
		imagePipline()
		
		let tabBarController = TabbarController()
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = tabBarController
		
		DispatchQueue.main.async {
			self.window!.tintColor = Preferences.appTintColor.uiColor
			self.window!.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: Preferences.preferredInterfaceStyle) ?? .unspecified
		}
		
		window?.makeKeyAndVisible()
		createSourcesDirectory()
        // Delete all files in tmp directory
        let fileManager = FileManager.default
        let tmpDirectory = NSHomeDirectory() + "/tmp"
        
        if let files = try? fileManager.contentsOfDirectory(atPath: tmpDirectory) {
            for file in files {
                try? fileManager.removeItem(atPath: tmpDirectory + "/" + file)
            }
        }
		return true
	}
	
	func createSourcesDirectory() {
		let fileManager = FileManager.default
		if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
			let sourcesURL = documentsURL.appendingPathComponent("Apps")
			let certsURL = documentsURL.appendingPathComponent("Certificates")
			
			if !fileManager.fileExists(atPath: sourcesURL.path) {
				do { try! fileManager.createDirectory(at: sourcesURL, withIntermediateDirectories: true, attributes: nil) }
			}
			if !fileManager.fileExists(atPath: certsURL.path) {
				do { try! fileManager.createDirectory(at: certsURL, withIntermediateDirectories: true, attributes: nil) }
			}
		}
	}
	
	func imagePipline() {
		DataLoader.sharedUrlCache.diskCapacity = 0
		let pipeline = ImagePipeline {
			let dataLoader: DataLoader = {
				let config = URLSessionConfiguration.default
				config.urlCache = nil
				return DataLoader(configuration: config)
			}()
			let dataCache = try? DataCache(name: "com.ssalggnikool.pointercrate.datacache") // disk cache
			let imageCache = Nuke.ImageCache() // memory cache
			dataCache?.sizeLimit = 500 * 1024 * 1024
			imageCache.costLimit = 100 * 1024 * 1024
			$0.dataCache = dataCache
			$0.imageCache = imageCache
			$0.dataLoader = dataLoader
			$0.dataCachePolicy = .automatic
			$0.isStoringPreviewsInMemoryCache = false
		}
		ImagePipeline.shared = pipeline
	}
}

