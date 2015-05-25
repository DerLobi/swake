# swake
*It's kinda like rake, but in Swift!*

Swake can be used as a simple task runner to automate and combine tasks.

It is written in Swift, the `Swakefile`s are written in Swift, and you can use every Swift language feature, as well as the whole Cocoa framework!

:warning: This is alpha quality software (I hacked this together in a day). It is not as complete as other tools, missing tests, documentation, edge-case handling and the API is subject to change. So use at your own risk!

## Installation
Right now, you have to clone the repo, build it in Xcode, then copy the `swake` executable and `Skeleton.swift` to some folder in your `$PATH`. I'll look into homebrew to make the installation easier.
For myself I added a Swakefile to build and install swake (woah - SWAKECEPTION).

## Swakefile
You can define the tasks that are available in a `Swakefile`.
Take a look at this example `Swakefile` to see which features already work.
```swift
// a simple task, call it with swake test in the directory of your Swakefile
task("test") { args in
    let names = ", ".join(args!)
    println("Hello, \(names)")
}

// right now you still have to include arguments in the closure, even if you don't supply any
task("something") { _ in
    println("something executed")
}

// you can execute other tasks from a task like this:
task("taskExecutingTask") { _ in
    tasks["something"]!(nil)
}

// you can also supply arguments to other tasks
task("taskExecutingTaskWithArguments") { args in
    tasks["something"]!(args)
}

// sh() runs a terminal command and returns the exit code
task("fail") { _ in
    let status = sh("nonexistant")
    exit(status)
}

// you can define swift functions to call from tasks
func myHelper() -> String {
    return "42"
}

// ... as long as the function is defined before its execution
task("callAFunction") { _ in
    println(myHelper())
}

// you can use namespaces
namespace("myNamespace") { args in

    task("build") { args in
        println("build executed")
    }

    // ...and prerequisites. myNamespace:build will be executed before myNamespace:test
    task("test", ["build"]) { args in
        println("test executed")
    }
}

namespace("otherNamespace") { args in

    // execute this task by running `swake otherNamespace:test`
    task("test") { args in
        println("Hello from other namespaced task, \(args!.first!)")
    }

}

```

## Running tasks
Running tasks is as simple as entering
```bash
swake myTaskName
```
 in the directory where your swakefile lies.
 From another directory that would be
 ```bash
 swake -f /path/to/Swakefile myTaskName
 ```
 You can run namespaced tasks by specifying the namespace, a colon and the task name, like this:
 ```bash
 swake myNamespace:myTask
 ```

## Why is it named swake?
Swake, as in **Sw**ift m**ake**. It is inspired by [rake](https://github.com/ruby/rake), and comparable to the other make tools like [jake](https://github.com/jakejs/jake), [FAKE](https://github.com/fsharp/FAKE), etc. I would have loved to name it [Sake](https://github.com/sakeproject/sake), but that name was also taken.

## But... why?
The Swift language is really nice. If you have any legacy codebase you are already switching between Swift and Objective-C, why should you have to write your tasks in yet another language like Ruby? With swake you can use everthing Cocoa has to offer in your Swakefile.



## License
Copyright 2015 Christian Lobach

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
