# How booting works

Booting a computer — that is, executing code on a computer starting from a completely uninitialized, powered off state — usually traverses several stages before reaching its stable state of running operating system software. 
The job of each boot stage is to retrieve the program to execute in the next stage from wherever it is being stored, load it into memory, and execute it.
Different boot stages are distinguished by their resource footprint, user interface, the types of storage locations from which they can retrieve data, and the executable image formats they are able to load.
Generally, boot stages are designed to be *ephemeral* in the sense that they leave as little as possible behind in memory when the next stage is running.
