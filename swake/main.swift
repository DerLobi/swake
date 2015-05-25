//
//  main.swift
//  swake
//
//  Created by Christian Lobach on 25/05/15.
//  Copyright (c) 2015 Christian Lobach. All rights reserved.
//

import Cocoa

let arguments = NSProcessInfo.processInfo().arguments as! [String]

if arguments.count > 1 {
    let execPath = arguments[0].stringByDeletingLastPathComponent
    let cwd = NSFileManager.defaultManager().currentDirectoryPath
    
    let task = arguments[1]
    let taskArguments = arguments[2..<arguments.count].map({ "\"\($0)\"" })
    
    let skeletonPath = execPath.stringByAppendingPathComponent("Skeleton.swift")
    let skeleton = NSString(contentsOfFile: skeletonPath, encoding: NSUTF8StringEncoding, error: nil)
    let swakefilePath = cwd.stringByAppendingPathComponent("Swakefile")
    let swakefile = NSString(contentsOfFile: swakefilePath, encoding: NSUTF8StringEncoding, error: nil)
        
    if let swakefile = swakefile {
        var script = "#!/usr/bin/xcrun swift" + "\n"
        script += (skeleton! as String) + "\n"
        script += (swakefile as String) + "\n"
        script += "let taskToExecute = tasks[\""
        script += task
        script += "\"]" + "\n"
        script += "let taskArguments = \(taskArguments) as [String]" + "\n"
        
        script += "taskToExecute!(taskArguments)"
        
        let scriptPath = ".swakescript.sh"
        script.writeToFile(scriptPath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        NSFileManager.defaultManager().setAttributes([ NSFilePosixPermissions: 484 ], ofItemAtPath: scriptPath, error: nil)
        
        var scriptTask = NSTask()
        scriptTask.launchPath = scriptPath
        
        scriptTask.launch()
        scriptTask.waitUntilExit()
        
        NSFileManager.defaultManager().removeItemAtPath(scriptPath, error: nil)
    } else {
        println("No Swakefile in current directory found")
        exit(1)
    }
} else {
    println("Not enough arguments!")
    exit(1)
}
