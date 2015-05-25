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
    
    let skeletonPath = execPath.stringByAppendingPathComponent("Skeleton.swift")
    var swakefilePath = cwd.stringByAppendingPathComponent("Swakefile")


    // parse arguments
    
    var numberOfArgumentsToSkip = 2 // 0 is the path, 1 is the task
    var shouldListTasks = false
    for i in [1,3] {
        if i > arguments.count - 1 {
            break;
        }
        let possibleFlag = arguments[i]
            
        if (possibleFlag == "-h" || possibleFlag == "--help") {
            println("swake - it's kinda like rake, but in Swift!")
            println()
            println("Usage:")
            println("swake task [arguments]                  # run the specified task with the given arguments")
            println("swake --file /path/to/Swakefile task    # run the specified task and specify the path to the Swakefile")
            println("swake --tasks                           # print all available tasks")
            println("swake --help                            # print this help message")
            exit(0)
        }
        
        if (possibleFlag == "-f" || possibleFlag == "--file") {
            swakefilePath = arguments[i + 1]
            numberOfArgumentsToSkip += 2
        }
        
        if (possibleFlag == "-t" || possibleFlag == "--tasks") {
            shouldListTasks = true
        }
   
    }

    let skeleton = NSString(contentsOfFile: skeletonPath, encoding: NSUTF8StringEncoding, error: nil)
    var swakefile = NSString(contentsOfFile: swakefilePath, encoding: NSUTF8StringEncoding, error: nil)

    // hand the rest of the arguments over to the task
    let task = arguments[1]
    let taskArguments = arguments[2..<arguments.count].map({ "\"\($0)\"" })

    if let swakefile = swakefile {

        var script = "#!/usr/bin/xcrun swift" + "\n"
        script += (skeleton! as String) + "\n"
        script += (swakefile as String) + "\n"
        
        if (shouldListTasks) {
            script += "    println(\"Available tasks:\")" + "\n" + "\n"
            script += "for key in sorted(tasks.keys) {" + "\n"
            script += "    print(\"- \")" + "\n"
            script += "    println(key)" + "\n"
            script += "}" + "\n"
        } else {
            script += "let taskToExecute = tasks[\""
            script += task
            script += "\"]" + "\n"
            script += "let taskArguments = \(taskArguments) as [String]" + "\n"
            script += "taskToExecute!(taskArguments)" + "\n"
        }
        
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
