cmake_minimum_required(VERSION 3.29)

# Set the project name
project(SwiftProject LANGUAGES Swift)

# Enable the generation of compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Specify the Swift source files
set(SWIFT_FILES
    Game/Sprite.swift
    Game/Engine.swift
    Game/Screen.swift
    Game/Core.swift
    Game/Utils.swift
    # other_file.swift
    # Add more Swift files as needed
)

# Create an executable target
add_executable(SwiftExecutable ${SWIFT_FILES})

# If you need to specify any additional Swift flags, you can do so
# For example, if you want to add Swift flags like -O or -enable-testing
# target_compile_options(SwiftExecutable PRIVATE -O)
